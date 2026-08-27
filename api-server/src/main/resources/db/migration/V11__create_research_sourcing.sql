CREATE TABLE sku_master (
    id                    BIGSERIAL PRIMARY KEY,
    normalized_sku        TEXT NOT NULL UNIQUE,
    brand                 TEXT,
    model_number          TEXT,
    category              TEXT,
    color                 TEXT,
    variant               TEXT,
    extraction_confidence FLOAT NOT NULL DEFAULT 0 CHECK (extraction_confidence BETWEEN 0 AND 1),
    extraction_method     TEXT NOT NULL DEFAULT 'RULE',
    verified              BOOLEAN NOT NULL DEFAULT FALSE,
    created_at            TIMESTAMP NOT NULL DEFAULT NOW(),
    updated_at            TIMESTAMP NOT NULL DEFAULT NOW()
);

CREATE TABLE retail_source (
    id           BIGSERIAL PRIMARY KEY,
    name         TEXT NOT NULL,
    source_key   TEXT NOT NULL UNIQUE,
    crawler_type TEXT NOT NULL DEFAULT 'API',
    is_active    BOOLEAN NOT NULL DEFAULT TRUE,
    priority     INTEGER NOT NULL DEFAULT 0,
    rate_limit   INTEGER NOT NULL DEFAULT 1 CHECK (rate_limit > 0),
    created_at   TIMESTAMP NOT NULL DEFAULT NOW()
);

CREATE TABLE retail_popular_product (
    id             BIGSERIAL PRIMARY KEY,
    source_id      BIGINT NOT NULL REFERENCES retail_source(id) ON DELETE RESTRICT,
    category       TEXT,
    search_keyword TEXT,
    title          TEXT NOT NULL,
    price          NUMERIC CHECK (price IS NULL OR price >= 0),
    review_count   INTEGER NOT NULL DEFAULT 0 CHECK (review_count >= 0),
    purchase_count INTEGER NOT NULL DEFAULT 0 CHECK (purchase_count >= 0),
    rank           INTEGER NOT NULL DEFAULT 0 CHECK (rank >= 0),
    brand          TEXT,
    model_number   TEXT,
    normalized_sku TEXT,
    sku_master_id  BIGINT REFERENCES sku_master(id) ON DELETE RESTRICT,
    seller         TEXT,
    url            TEXT,
    image_url      TEXT,
    rating         FLOAT,
    raw_json       TEXT,
    collected_at   TIMESTAMP NOT NULL DEFAULT NOW(),
    UNIQUE (source_id, title)
);

CREATE TABLE wholesale_source (
    id           BIGSERIAL PRIMARY KEY,
    name         TEXT NOT NULL,
    source_key   TEXT NOT NULL UNIQUE,
    country      TEXT NOT NULL DEFAULT 'KR',
    base_url     TEXT,
    crawler_type TEXT NOT NULL DEFAULT 'API',
    is_active    BOOLEAN NOT NULL DEFAULT TRUE,
    created_at   TIMESTAMP NOT NULL DEFAULT NOW()
);

CREATE TABLE wholesale_product (
    id                BIGSERIAL PRIMARY KEY,
    sku_master_id     BIGINT REFERENCES sku_master(id) ON DELETE RESTRICT,
    source_id         BIGINT NOT NULL REFERENCES wholesale_source(id) ON DELETE RESTRICT,
    source_product_id TEXT NOT NULL,
    trade_type        TEXT NOT NULL DEFAULT 'PURCHASE',
    title             TEXT NOT NULL,
    price             NUMERIC CHECK (price IS NULL OR price >= 0),
    currency          TEXT NOT NULL DEFAULT 'KRW',
    moq               INTEGER NOT NULL DEFAULT 1 CHECK (moq > 0),
    supplier          TEXT,
    country           TEXT NOT NULL DEFAULT 'KR',
    normalized_sku    TEXT,
    brand             TEXT,
    model_number      TEXT,
    search_keyword    TEXT,
    url               TEXT,
    raw_json          TEXT,
    collected_at      TIMESTAMP NOT NULL DEFAULT NOW(),
    UNIQUE (source_id, source_product_id)
);

CREATE INDEX idx_sku_master_brand ON sku_master(brand);
CREATE INDEX idx_sku_master_model ON sku_master(model_number);
CREATE INDEX idx_popular_category ON retail_popular_product(category);
CREATE INDEX idx_popular_keyword ON retail_popular_product(search_keyword);
CREATE INDEX idx_popular_collected ON retail_popular_product(collected_at DESC);
CREATE INDEX idx_wholesale_sku ON wholesale_product(sku_master_id);
CREATE INDEX idx_wholesale_keyword ON wholesale_product(search_keyword);
