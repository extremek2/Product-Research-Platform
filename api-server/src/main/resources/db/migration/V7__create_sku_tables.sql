CREATE TABLE sku_master (
                            id                    BIGSERIAL PRIMARY KEY,
                            normalized_sku        TEXT NOT NULL UNIQUE,
                            brand                 TEXT,
                            model_number          TEXT,
                            category              TEXT,
                            color                 TEXT,
                            variant               TEXT,
                            extraction_confidence FLOAT DEFAULT 0,
                            extraction_method     TEXT DEFAULT 'RULE',
                            verified              BOOLEAN DEFAULT FALSE,
                            created_at            TIMESTAMP DEFAULT NOW(),
                            updated_at            TIMESTAMP DEFAULT NOW()
);

CREATE TABLE sku_alias (
                           id               BIGSERIAL PRIMARY KEY,
                           sku_master_id    BIGINT REFERENCES sku_master(id),
                           raw_title        TEXT NOT NULL,
                           source           TEXT,
                           alias_sku        TEXT,
                           similarity_score FLOAT,
                           created_at       TIMESTAMP DEFAULT NOW()
);

CREATE INDEX idx_sku_master_brand   ON sku_master(brand);
CREATE INDEX idx_sku_master_model   ON sku_master(model_number);
CREATE INDEX idx_sku_alias_raw      ON sku_alias(raw_title);
CREATE INDEX idx_sku_alias_master   ON sku_alias(sku_master_id);