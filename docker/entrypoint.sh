#!/bin/bash
set -e

if [ -f /app/.env ]; then
    export $(grep -v '^#' /app/.env | xargs)
fi

echo "Waiting for Postgres..."
until pg_isready -h postgres -p 5432 -U product_user; do
    echo "Postgres unavailable - retrying in 2s"
    sleep 2
done
echo "Postgres is ready!"

if [ "$RUN_MIGRATIONS" = "true" ]; then
    echo "Creating tables..."
    python -c "
from app.db.database import engine
from app.models.base import Base
from app.models import product, source_product, product_cluster, product_cluster_item, product_snapshot
from app.models.sku_master import SkuMaster
from app.models.wholesale_product import WholesaleProduct, WholesaleSource
Base.metadata.create_all(bind=engine)
print('Tables created.')
"
fi

exec "$@"
