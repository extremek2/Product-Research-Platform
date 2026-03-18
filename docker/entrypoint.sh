#!/bin/bash
set -e

# 1. .env 로드 (있을 때만)
if [ -f /app/.env ]; then
    export $(grep -v '^#' /app/.env | xargs)
fi

# 2. Postgres 준비 대기
echo "Waiting for Postgres..."
until pg_isready -h postgres -p 5432 -U product_user; do
    echo "Postgres unavailable - retrying in 2s"
    sleep 2
done
echo "Postgres is ready!"

# 3. DB 테이블 생성 (Spring 붙이기 전까지 SQLAlchemy로 처리)
if [ "$RUN_MIGRATIONS" = "true" ]; then
    echo "Creating tables..."
    python -c "
from app.db.database import engine
from app.models.base import Base
from app.models import product, source_product, product_cluster, product_cluster_item, product_snapshot
Base.metadata.create_all(bind=engine)
print('Tables created.')
"
fi

# 4. CMD 실행
exec "$@"