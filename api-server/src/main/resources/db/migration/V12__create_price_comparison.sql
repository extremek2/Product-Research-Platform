CREATE TABLE sku_price_summary (
                                   id                     BIGSERIAL PRIMARY KEY,
                                   sku_master_id          BIGINT REFERENCES sku_master(id) UNIQUE,
                                   retail_min_price       NUMERIC,
                                   retail_max_price       NUMERIC,
                                   retail_avg_price       NUMERIC,
                                   retail_product_count   INTEGER DEFAULT 0,
                                   wholesale_min_price    NUMERIC,
                                   wholesale_avg_price    NUMERIC,
                                   wholesale_product_count INTEGER DEFAULT 0,
                                   best_margin_rate       FLOAT,
                                   best_trade_type        TEXT,
                                   calculated_at          TIMESTAMP DEFAULT NOW()
);

CREATE TABLE sourcing_report (
                                 id                   BIGSERIAL PRIMARY KEY,
                                 sku_master_id        BIGINT REFERENCES sku_master(id),
                                 retail_product_id    BIGINT REFERENCES retail_product(id),
                                 wholesale_product_id BIGINT REFERENCES wholesale_product(id),
                                 import_cost_id       BIGINT REFERENCES import_cost_estimate(id),
                                 retail_price         NUMERIC,
                                 total_landed_cost    NUMERIC,
                                 platform             TEXT,
                                 platform_fee         NUMERIC DEFAULT 0,
                                 domestic_shipping    NUMERIC DEFAULT 0,
                                 net_margin           NUMERIC,
                                 margin_rate          FLOAT,
                                 recommendation       TEXT,
                                 created_at           TIMESTAMP DEFAULT NOW()
);

CREATE INDEX idx_sourcing_sku        ON sourcing_report(sku_master_id);
CREATE INDEX idx_sourcing_margin     ON sourcing_report(margin_rate DESC);
CREATE INDEX idx_price_summary_sku   ON sku_price_summary(sku_master_id);