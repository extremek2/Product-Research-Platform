CREATE TABLE IF NOT EXISTS product_cluster_item (
    id               BIGSERIAL PRIMARY KEY,
    cluster_id       BIGINT REFERENCES product_cluster(id),
    product_id       BIGINT REFERENCES product(id),
    confidence_score FLOAT
);
