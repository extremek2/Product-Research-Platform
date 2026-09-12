# ADR-0001: Core와 Automation의 소유권 분리

- 상태: 검토 중인 승인 제안. 승인 전에는 목표 구조이며 구현 완료로 간주하지 않는다.
- 작성일: 2026-09-01
- 최종 검토일: 2026-09-12
- 기준 문서: `docs/product/TECH_STACK.md`

## 문제

현재 Spring Flyway/JPA와 Python SQLAlchemy가 상품, 소싱, 클러스터 테이블을 함께 사용한다. 또한 브라우저가 Spring을 거치지 않고 FastAPI 작업 API를 직접 호출한다. 이 구조에서는 스키마 변경, 조직 권한, 작업 멱등성, 감사 이력의 최종 책임자를 정할 수 없다.

확인된 Python 직접 쓰기 경로는 다음과 같다.

| 경로 | 읽기 | 쓰기 |
|---|---|---|
| `cluster_pipeline.py` | `product` | `product_cluster`, `product_cluster_item` |
| `wholesale_pipeline.py` | `wholesale_source`, `wholesale_product`, `sku_master` | `wholesale_product`, `sku_master` |
| `popular_pipeline.py` | `retail_source`, `retail_popular_product`, `sku_master` | `retail_popular_product`, `sku_master` |

브라우저 직접 호출은 `frontend/src/pages/ResearchPage.js`의 트렌드·클러스터 작업 요청과 상태 폴링이다.

## 결정

1. Spring은 업무 원장과 사용자에게 보이는 작업 상태를 소유한다.
2. Python은 자동화 실행, 외부 원본, 중간 결과를 소유한다.
3. Python은 기존 코어 테이블에서 한 번에 철수하지 않는다. 신규 `staging`/`automation` 경로를 만든 뒤 쓰기 경로, 읽기 경로, DB 권한 순서로 전환한다.
4. 브라우저는 Spring `/api/v1`만 호출한다.
5. Spring은 `core.automation_job`과 Transactional Outbox를 같은 업무 트랜잭션에 기록한다.
6. Dispatcher만 FastAPI `/internal/v1/jobs`를 호출한다.
7. Python 결과는 Spring Callback 계약을 통해서만 코어 상태에 반영한다.
8. Spring 내부 도메인 이벤트와 외부 자동화 Outbox는 별도 저장소와 별도 전달 메커니즘을 사용한다.

## 계약 식별자

- `jobId`: Spring이 발급하는 UUID. 양쪽 DB에서 계약 ID로 사용한다.
- `idempotencyKey`: 조직과 작업 유형 범위에서 중복 작업 생성을 막는다.
- `traceId`: 사용자 요청부터 Worker와 Callback까지 전달한다.
- `sequence`: Python Callback의 단조 증가 순번이다.
- `contractVersion`: 요청과 결과 Payload를 독립적으로 버전 관리한다.

## 단계적 이전

1. 현재 위반을 허용 목록으로 고정하고 신규 위반을 막는 구조 테스트를 추가한다.
2. Spring에 `automation_job`과 `automation_outbox`를 추가한다.
3. FastAPI 작업 접수 계약과 Spring Callback 계약의 contract test를 추가한다.
4. 트렌드 작업을 첫 종단 간 Vertical Slice로 전환한다.
5. 클러스터 입력을 Spring Snapshot 또는 Object Storage 입력으로 바꾼다.
6. Python 결과를 `automation` 스키마에 저장하고 Callback으로 Spring에 반영한다.
7. 도매 수집 원본을 `staging`으로 옮기고 Spring Import Use Case를 추가한다.
8. Python의 코어 SQLAlchemy Model과 쓰기를 제거한다.
9. 런타임 DB 권한으로 교차 스키마 쓰기를 차단한다.

## 롤백

- 각 Vertical Slice는 기능 플래그로 새 경로와 기존 경로 중 하나만 활성화한다.
- 신규 테이블은 기존 테이블을 삭제하거나 이름 변경하지 않고 추가한다.
- Dual-write는 사용하지 않는다. 필요하면 입력을 재처리할 수 있도록 원본 Snapshot과 멱등성 키를 보존한다.
- Callback 반영 실패 시 Outbox와 Automation Result를 보존하여 재전달한다.
- DB 권한 차단은 애플리케이션 전환과 데이터 대조가 끝난 마지막 단계에서 적용한다.

## 결과

초기에는 테이블과 계약이 늘어나지만 데이터 작성자가 명확해지고, Worker 장애가 업무 트랜잭션을 롤백시키지 않으며, 조직 권한과 감사 이력을 Spring에서 일관되게 적용할 수 있다.
