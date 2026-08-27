CREATE TABLE product_cluster (
    id           BIGSERIAL PRIMARY KEY,
    cluster_name TEXT NOT NULL,
    created_at   TIMESTAMP NOT NULL DEFAULT NOW()
);

CREATE TABLE product_cluster_item (
    id               BIGSERIAL PRIMARY KEY,
    cluster_id       BIGINT NOT NULL REFERENCES product_cluster(id) ON DELETE CASCADE,
    product_id       BIGINT NOT NULL REFERENCES product(id) ON DELETE CASCADE,
    confidence_score FLOAT NOT NULL DEFAULT 1.0 CHECK (confidence_score BETWEEN 0 AND 1),
    UNIQUE (cluster_id, product_id)
);

CREATE INDEX idx_cluster_item_product ON product_cluster_item(product_id);
