CREATE TABLE IF NOT EXISTS product_cluster (
    id           BIGSERIAL PRIMARY KEY,
    cluster_name TEXT,
    created_at   TIMESTAMP DEFAULT NOW()
);
