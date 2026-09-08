# 가입 승인·건별 협업 운영 실행서

이 문서는 실행할 절차를 준비한 것이며 실제 운영 적용을 수행했다는 기록이 아니다.
실제 DB·관리자 생성·외부 수신자 발송·서비스 공개는 대상과 결과를 검토한 뒤 명시적으로 승인받고 실행한다.
현재 검증 결과와 제약은 [6단계 문서](../docs/engineering/identity-stage-6.md)를 참고한다.

## 1. 배포 전 결정

- Linux Docker 서버, PostgreSQL 15 이상, 실제 HTTPS 도메인과 인증서를 정한다.
- 템플릿의 `172.30.88.0/24`가 기존 네트워크와 겹치지 않는지 확인한다. 변경하면 Compose의
  subnet·frontend IP와 application-production.yml의 Tomcat internal-proxies를 함께 변경한다.
- Nginx가 직접 TLS를 종료하고 실제 클라이언트 IP를 본다는 배치다. 다른 프록시를 앞에 두면
  이를 그대로 사용하지 말고 그 프록시만 신뢰하도록 IP 전달 구성을 조정·검증한다.
- 상품 리서치·AI·Celery는 이번 운영 스택에 포함하지 않는다. 해당 공개 API도 production에서 차단한다.
- 실제 SMTP 제공자, 인증·STARTTLS(기본 587) 또는 TLS(예: 465), 발신 주소와 테스트 수신자를 정한다.
  SMTP_SSL=true일 때 제공자에 따라 SMTP_STARTTLS=false로 설정한다. TLS 자체를 끄지는 않는다.

환경 예제를 `ops/.env.production`에 복사하고 권한을 600으로 제한한다. 기존 파일은 덮어쓰지 않는다.
실제 값을 채우되 이 파일을 Git에 넣거나 `docker compose config` 전체 출력을 공유하지 않는다.
JWT_SECRET과 MAIL_OUTBOX_KEY는 서로 다른 무작위 값으로 생성하고 DB 백업과 별도로 안전하게 보관한다.
MAIL_OUTBOX_KEY는 Base64 32바이트다. 분실하면 기존 발송 대기 본문을 복호화할 수 없다.
PUBLIC_ORIGIN에는 경로·끝 슬래시 없이 `https://실제도메인`을 지정한다.

```bash
# 프로젝트 루트에서, 문법 검사만 실행. 비밀값은 출력하지 않는다.
./ops/scripts/compose.sh config --quiet
# 실제 배포 전 확정한 코드로 이미지 생성. RELEASE_TAG는 재사용하지 않는 릴리스 식별값이다.
./ops/scripts/compose.sh build
```

프런트의 API 주소는 빌드 시 `/api/v1`로 고정해 같은 HTTPS Origin을 사용한다.
API·DB 포트는 호스트에 공개하지 않고 인증서 파일 두 개만 웹 컨테이너에 읽기 전용 마운트한다.
이미지 ID·다이제스트, 소스 커밋, 환경 파일의 비밀값 제외 설정, Flyway 버전, 승인자를 릴리스 기록에 남긴다.

## 2. 새 DB와 기존 DB 전환

### 새 DB

```bash
./ops/scripts/compose.sh up -d postgres
./ops/scripts/compose.sh run --rm --no-deps migrate
```

스키마 적용 후 DB 관리자 계정으로 런타임 역할을 생성·권한 부여한다.

```bash
./ops/scripts/compose.sh exec -T postgres sh -c 'psql -U "$POSTGRES_USER" -d "$POSTGRES_DB" -v ON_ERROR_STOP=1' < ops/sql/grant-runtime-role.sql
```

POSTGRES_USER/POSTGRES_PASSWORD는 마이그레이션·백업용이며 APP_DB_USER/APP_DB_PASSWORD는
일반 앱 실행용으로 서로 다르게 지정한다. 런타임 역할은 스키마 생성·Flyway 이력 변경과
감사 이력 수정·삭제 권한을 받지 않는다. 이 스크립트는 기존 비밀번호를 덮어쓰지 않는다.
마이그레이션으로 테이블이 추가될 때와 새 DB 복원 후에도 대상 DB에 다시 적용한다.

migrate-only는 웹 포트를 열거나 메일을 보내지 않고 Flyway 적용 후 종료한다.
일반 production 서버는 자동 마이그레이션을 하지 않는다. 스키마가 없거나 맞지 않으면 정상 기동하지 않는다.

### 기존 데이터

1. 연결 대상·현재 스키마 버전·DB 소유자·용량을 확인한다. preflight는 이미 V13 이상인 DB용이다.
   그보다 오래된 DB나 Flyway 이력이 없는 DB는 별도 전환 계획이 필요하며 자동 baseline/repair하지 않는다.
2. 기존 API, 메일 워커와 같은 DB를 사용하는 AI/Celery 등 모든 쓰기 주체를 파악한다.
3. 전환 전에 백업을 만들고 새 DB로 복원해 리허설한다. 접속 정보는 PG 환경변수·보안 파일로
   설정하고 비밀번호를 URL·명령 인수에 넣지 않는다. 외부 DB 백업은 해당 환경의 pg_dump로 준비한다.
4. 최종 전환에서는 쓰기를 중단한 뒤 새 일관 백업을 만든다. 개발 Compose의 볼륨을 운영 Compose에
   임의로 연결하거나 `down -v`로 삭제하지 않는다.

운영 Compose로 관리되는 기존 DB의 검사·백업 예시:

```bash
./ops/scripts/compose.sh exec -T postgres sh -c 'psql -U "$POSTGRES_USER" -d "$POSTGRES_DB" -v ON_ERROR_STOP=1' < ops/sql/preflight.sql
./ops/scripts/backup.sh ops/backups
```

정규화 이메일 중복은 전환을 차단한다. OWNER 부재, 여러 활성 소속, 기존 연락처 중복도 검토하고
결정 사항을 남긴다. 검사 스크립트가 행위자나 업체를 임의로 병합·승격하지 않는다.
백업 파일은 비밀번호 해시·개인정보·키 없이도 사용할 수 있는 DB 정보를 포함하므로 접근을 제한하고
암호화된 저장소에 보관한다. 목차 검사와 체크섬만으로 복원 가능성이 입증되지는 않는다.

```bash
# 지정한 이름의 DB가 이미 있으면 실패한다. 기존 DB 삭제·덮어쓰기를 하지 않는다.
./ops/scripts/restore-to-new-db.sh /안전한경로/backup.dump trade_ops_candidate
```

복원 후 POSTGRES_DB를 candidate로 지정한 **별도 검토용 환경 파일**로 연결 대상을 명확히 한다.
OPS_ENV_FILE로 환경 파일을 선택할 수 있다. 메일은 false 상태로 두고 다음을 실행한다.

```bash
OPS_ENV_FILE=/안전한경로/candidate.env ./ops/scripts/compose.sh run --rm --no-deps migrate
OPS_ENV_FILE=/안전한경로/candidate.env ./ops/scripts/compose.sh exec -T postgres sh -c 'psql -U "$POSTGRES_USER" -d "trade_ops_candidate" -v ON_ERROR_STOP=1' < ops/sql/postflight.sql
```

주의: exec는 이미 실행 중인 컨테이너의 환경을 사용한다. 예시처럼 psql 대상 DB를 명시하고
current_database()로 확인한다. 실제 컨테이너 환경을 변경하려면 별도 재생성·전환 검토가 필요하다.
마이그레이션 실패 시 서비스를 열지 않고 원인을 해결한다. 기존 migration 파일 수정·flyway repair로
검증을 우회하지 않는다. 적용된 V14~V17 체크섬은 유지한다.

## 3. 최초 관리자·메일·공개

새 DB에 아직 초기 관리자가 없을 때 승인받은 운영자가 대화형 터미널에서 실행한다.

```bash
./ops/scripts/compose.sh run --rm --no-deps api-server --bootstrap-admin
```

이 명령은 이미 마이그레이션된 운영 DB에서 사용한다. 메일 스케줄과 웹 서버는 열지 않으며
비밀번호는 숨김 입력으로 받는다. 기존 일반 계정 승격·추가 관리자 생성·비밀번호 덮어쓰기를
하지 않는다. 관리자 분실·복구가 필요한 경우 bootstrap을 재활성화 도구로 사용하지 않는다.

실제 SMTP 설정과 테스트 수신 승인을 마친 후 MAIL_DISPATCH_ENABLED=true로 설정한다.
단, 활성화하면 미발송 대기 전체가 대상이므로 먼저 outbox 건수·기한을 확인하고 원치 않는
대기 메일이 없는지 검토한다. 만료 건만 정리하려면 다음 명시적 작업을 사용한다.

```bash
./ops/scripts/compose.sh exec -T postgres sh -c 'psql -U "$POSTGRES_USER" -d "$POSTGRES_DB" -v ON_ERROR_STOP=1' < ops/sql/expire-pending-mail.sql
```

TLS·인증서·메일 발송 대상 검토 후 공개할 서비스를 시작한다.

```bash
./ops/scripts/compose.sh up -d api-server frontend
```

확인할 항목:

- 승인된 수신 계정으로 가입 확인 메일과 외부 초대 메일을 실제 수신하고 링크를 연다.
- 직접 `/verify-email`, `/external-access`, 관리자 상세 주소에 진입해도 404가 나지 않는지 확인한다.
- 실제 HTTPS에서 로그인·새로고침·로그아웃과 Secure/HttpOnly/SameSite 쿠키 동작을 확인한다.
- 관리자 승인·화주 진입·외부 건별 조회·철회 후 차단을 실제 도메인에서 확인한다.
- Origin을 바꾼 요청이 차단되는지, 프록시가 임의 X-Forwarded-For를 전달하지 않는지 확인한다.
- POSTGRES_DB가 의도한 DB인지, 외부에 5432/8080이 열려 있지 않은지 확인한다.

실제 SMTP의 TLS·발신 도메인(SPF/DKIM/DMARC)·스팸 분류·도달률은 제공자에서 확인한다.
로컬 메일 테스트 통과가 외부 메일 전달을 보장하지 않는다.

## 4. 장애 시 복구

1. 웹·API·메일 및 관련 쓰기 주체를 중단하고 장애 시점의 DB와 로그도 별도 보존한다.
2. 직전 앱 이미지로만 되돌려 최신 DB를 연결하지 않는다. 역할·가입 계약이 달라 구버전 앱의
   자동 OWNER 생성 등 과거 동작이 재활성화될 수 있다.
3. 확인된 백업을 **새 DB**에 복원한다. 운영 DB를 지우거나 덮어쓰지 않는다.
4. V17 복구 DB에 최신 코드를 사용할 때, 트래픽과 메일을 끈 상태에서 다음 SQL을 적용한다.

```bash
./ops/scripts/restore-to-new-db.sh /안전한경로/backup.dump trade_ops_recovered
./ops/scripts/compose.sh exec -T postgres sh -c 'psql -U "$POSTGRES_USER" -d trade_ops_recovered -v ON_ERROR_STOP=1' < ops/sql/invalidate-restored-access.sql
```

이 작업은 복원된 세션·미사용 링크·발송 대기를 철회하고 새 모델의 외부 참여를 모두 철회한다.
외부 담당자는 검토 후 재초대한다. V13 등 이전 스키마에는 이 SQL을 바로 실행하지 않는다.
먼저 해당 스키마의 격리 복구 계획·최신 스키마 전환 여부를 정한다. 복원 후 실행 계정의
권한 부여도 대상 DB에 다시 적용한다.

5. 백업 이후의 승인·OWNER/ADMIN 변경·계정 비활성화·외부 철회·화물 변경을 감사 기록과 대조한다.
   이 대조를 마치기 전에는 복원 DB를 외부에 연결하지 않는다. 토큰 철회만으로 권한 데이터의
   시점 차이를 해결할 수 없다. 필요하면 모든 접근을 계속 중단한다.
6. 검증된 앱·DB·키 조합으로 연결을 전환하고 실제 도메인·메일을 다시 검증한 뒤 공개한다.

RPO는 마지막 검증된 백업 이후의 손실 가능 범위이고, RTO는 실제 데이터 복원과 권한 대조에
걸린 시간이다. 이 프로젝트의 작은 테스트 DB 결과로 운영 RPO/RTO를 보장하지 않는다.

## 5. 반복 운영

- postflight의 outbox PENDING 최장 대기, FAILED 증가, 오래된 미처리 신청을 주기적으로 확인한다.
- SMTP 오류가 생기면 네트워크·인증·제공자 상태를 확인한다. 실패 본문은 최종 실패 후 삭제되므로
  기존 메시지를 임의 복구해 재발송하지 말고 새 확인 링크·초대를 발급한다.
- 백업 주기·보관 위치·암호화·복원 리허설 주기와 담당자를 정한다. DB 키는 별도로 보관한다.
- 키 교체 전 미발송 암호문을 처리·취소하는 절차를 정한다. JWT 키 교체 시 기존 access 토큰의
  인증은 실패하며 refresh 세션·클라이언트 복구 동작을 함께 점검한다.
- 정기적인 의존성·권한·감사 검토는 계속 필요하다. 계정 복구·직원 전용 초대·리서치 권한은 후속 기능이다.
