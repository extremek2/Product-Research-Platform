CREATE TABLE IF NOT EXISTS source_product (
    id                BIGSERIAL PRIMARY KEY,
    source            TEXT,
    source_product_id TEXT,
    title             TEXT,
    price             NUMERIC,
    url               TEXT,
    seller            TEXT,
    raw_json          TEXT,
    created_at        TIMESTAMP DEFAULT NOW()
);
