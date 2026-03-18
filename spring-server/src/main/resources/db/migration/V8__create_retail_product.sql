CREATE TABLE retail_product (
                                id               BIGSERIAL PRIMARY KEY,
                                sku_master_id    BIGINT REFERENCES sku_master(id),
                                trend_keyword_id BIGINT REFERENCES trend_keyword_ranked(id),
                                source           TEXT NOT NULL,
                                title            TEXT NOT NULL,
                                price            NUMERIC,
                                review_count     INTEGER DEFAULT 0,
                                rating           FLOAT,
                                seller           TEXT,
                                url              TEXT,
                                trend_score      FLOAT DEFAULT 0,
                                retail_rank      INTEGER,
                                normalized_sku   TEXT,
                                brand            TEXT,
                                model_number     TEXT,
                                raw_json         TEXT,
                                collected_at     TIMESTAMP DEFAULT NOW()
);

CREATE INDEX idx_retail_sku      ON retail_product(sku_master_id);
CREATE INDEX idx_retail_source   ON retail_product(source);
CREATE INDEX idx_retail_rank     ON retail_product(retail_rank);