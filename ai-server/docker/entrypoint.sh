#!/bin/bash
set -e

if [ -f /app/.env ]; then
    export $(grep -v '^#' /app/.env | xargs)
fi

echo "Waiting for Postgres..."
until pg_isready -h postgres -p 5432 -U product_user; do
    sleep 2
done
echo "Postgres is ready!"

exec "$@"
