CREATE TABLE IF NOT EXISTS product_snapshot (
    id           BIGSERIAL PRIMARY KEY,
    product_id   BIGINT REFERENCES product(id),
    price        INTEGER,
    rating       FLOAT,
    review_count INTEGER,
    seller_name  TEXT,
    crawled_at   TIMESTAMP DEFAULT NOW()
);
