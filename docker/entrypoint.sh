#!/bin/bash
set -e

# 1. 환경변수 로드
if [ -f /app/.env ]; then
    export $(grep -v '^#' /app/.env | xargs)
fi

# 2. Postgres 준비 대기
echo "Waiting for Postgres to be ready..."
until pg_isready -h postgres -p 5432 -U "$POSTGRES_USER"; do
  echo "Postgres is unavailable - sleeping"
  sleep 2
done

# 3. Alembic 마이그레이션
if [ "$RUN_MIGRATIONS" = "true" ]; then
    echo "Running Alembic migrations..."
    alembic upgrade head
fi

# 4. CMD 실행
exec "$@"