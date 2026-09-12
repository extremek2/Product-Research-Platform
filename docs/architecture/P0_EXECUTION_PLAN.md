# P0 실행 계획

- 상태: 실행 전 초안
- 선행 결정: [ADR-0001](ADR-0001-p0-service-and-data-ownership.md) 승인
- 최종 검토일: 2026-09-12

이 계획은 각 슬라이스가 독립적으로 테스트되고 롤백될 수 있도록 구성한다. ADR 승인 후 슬라이스 0부터 시작하며, 다음 단계는 이전 단계의 테스트 게이트를 통과한 뒤에만 시작한다. 체크되지 않은 항목이나 테스트 초안의 존재만으로 해당 슬라이스가 완료됐다고 간주하지 않는다.

## 현재 기준선

### 데이터 소유권 중복

Python에 남아 있는 코어 테이블 매핑:

```text
product
product_cluster
product_cluster_item
retail_popular_product
retail_source
sku_master
source_product
wholesale_product
wholesale_source
```

현재 실행 가능한 직접 쓰기는 클러스터와 도매 파이프라인이다. 네이버 상품 수집 제거 후 `popular_pipeline.py`는 호출 라우트가 없지만 코어 쓰기 코드가 남아 있다.

### 서비스 경계 위반

```text
Browser -> FastAPI /api/v1/trend
Browser -> FastAPI /api/v1/cluster
FastAPI/Celery -> Spring 소유 테이블
```

## 슬라이스 0: 경계 동결

목표: 기존 기능을 바꾸지 않고 신규 직접 의존이 추가되는 것을 막는다.

- Python 코어 테이블 매핑 허용 목록 테스트
- 브라우저 FastAPI 직접 호출 허용 파일 테스트
- 현재 테스트 명령과 결과 기록

완료 조건:

```text
PYTHONPATH=ai-server python3 -m unittest discover -s ai-server/tests -v
cd frontend && CI=true npm test -- --watchAll=false
cd api-server && ./gradlew test
docker compose config --quiet
```

## 슬라이스 1: 계약과 Spring 작업 원장

목표: Worker 실행 전에 Spring이 사용자 작업을 영속한다.

- `core.automation_job`
- `core.automation_outbox`
- 상태 전이와 Terminal 상태 보호
- 조직 범위 멱등성 제약
- Outbox Dispatcher Port와 비활성 기본 Adapter

테스트:

- 상태 전이 단위 테스트
- 동일 조직/멱등성 키 중복 방지 통합 테스트
- 다른 조직의 작업 조회 차단 테스트
- 업무 저장과 Outbox 저장의 원자성 테스트

롤백: Dispatcher를 비활성화하고 신규 테이블은 유지한다.

## 슬라이스 2: 내부 작업 계약

목표: Spring과 FastAPI 사이의 버전된 계약을 만든다.

- FastAPI `POST /internal/v1/jobs`
- FastAPI 취소 요청
- Spring progress/result Callback
- 서비스 인증
- `jobId`, `idempotencyKey`, `traceId`, `sequence`, 계약 버전

테스트:

- 양방향 contract fixture
- 중복 접수
- 순서가 뒤처진 Callback 무시
- Terminal 상태 회귀 차단
- timeout과 재전달

## 슬라이스 3: 트렌드 Vertical Slice

목표: 가장 작은 자동화 작업인 Shopping Insight를 새 경로로 전환한다.

```text
Browser -> Spring -> Outbox -> FastAPI -> Celery
        <- Spring Callback <- Result Publisher
```

- 프론트엔드 AI API URL 제거
- FastAPI 브라우저 CORS 제거
- Spring 작업 조회 API로 폴링 전환
- 기존 FastAPI 공개 `/api/v1/trend` 제거

롤백: Spring의 트렌드 Trigger UI를 기능 플래그로 숨긴다. 브라우저 직접 FastAPI 경로는 복구하지 않는다.

## 슬라이스 4: Python 영속 스키마

목표: Python 소유 실행 기록과 결과를 코어 업무 테이블에서 분리한다.

- Alembic 도입
- `automation.automation_run`
- `automation.automation_result`
- `staging.provider_snapshot`
- 만료와 결과 전달 상태

테스트:

- Alembic upgrade/downgrade smoke test
- 재시도별 실행 기록
- Redis 초기화 후 복구
- 결과 Callback 재전달

## 슬라이스 5: 클러스터와 수집 전환

목표: Python의 코어 테이블 직접 쓰기를 제거한다.

- 클러스터 입력 Snapshot 계약
- 클러스터 결과 Callback과 Spring 반영 Use Case
- 도매 원본 `staging` 적재
- Spring 검증/Import Use Case
- 사용되지 않는 `popular_pipeline.py` 제거
- 코어 SQLAlchemy Model 제거

테스트:

- 기존/신규 결과 대조
- 동일 입력 재처리 멱등성
- 부분 성공
- 조직 혼입 차단

## 슬라이스 6: DB 권한과 Modulith

목표: 코드 규칙을 DB와 모듈 테스트로 강제한다.

- 플랫폼 초기화용 Schema/Role 생성
- Spring Flyway와 Python Alembic Role 분리
- 런타임 Role의 교차 스키마 쓰기 차단
- Spring Modulith 도입과 `ApplicationModules.verify()`
- 내부 Event Publication Registry 적용

권한 차단은 모든 쓰기 경로 전환과 데이터 대조가 완료된 뒤 적용한다.

## 별도 설계 트랙

Candidate → PO → Shipment → Inventory Lot은 아직 Candidate, PO, Inventory Aggregate가 구현되지 않았다. P0에서는 공통 ID를 억지로 기존 Shipment 테이블에 추가하지 않고 다음 식별 규칙을 먼저 고정한다.

- 외부 계약 ID는 UUID를 사용한다.
- 각 Aggregate는 자체 ID와 `organization_id`를 소유한다.
- `tradecase`는 Aggregate ID만 참조한다.
- 문서번호와 외부 ID의 유일성은 조직 범위로 제한한다.
- 향후 Aggregate 도입 ADR에서 전이와 참조 무결성을 확정한다.
