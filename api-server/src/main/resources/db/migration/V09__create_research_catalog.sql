CREATE TABLE source_product (
    id                BIGSERIAL PRIMARY KEY,
    source            TEXT NOT NULL,
    source_product_id TEXT NOT NULL,
    search_keyword    TEXT,
    title             TEXT NOT NULL,
    price             NUMERIC CHECK (price IS NULL OR price >= 0),
    url               TEXT,
    seller            TEXT,
    raw_json          TEXT,
    created_at        TIMESTAMP NOT NULL DEFAULT NOW(),
    UNIQUE (source, source_product_id)
);

CREATE TABLE product (
    id                BIGSERIAL PRIMARY KEY,
    source_product_id BIGINT UNIQUE REFERENCES source_product(id) ON DELETE RESTRICT,
    title             TEXT NOT NULL,
    brand             TEXT,
    category          TEXT,
    source            TEXT,
    created_at        TIMESTAMP NOT NULL DEFAULT NOW()
);

CREATE INDEX idx_source_product_keyword ON source_product(search_keyword);
CREATE INDEX idx_product_title ON product(title);
CREATE INDEX idx_product_brand ON product(brand);
