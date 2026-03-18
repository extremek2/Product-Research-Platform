CREATE TABLE wholesale_source (
                                  id           BIGSERIAL PRIMARY KEY,
                                  name         TEXT NOT NULL,
                                  country      TEXT NOT NULL DEFAULT 'KR',
                                  base_url     TEXT,
                                  crawler_type TEXT,
                                  is_active    BOOLEAN DEFAULT TRUE,
                                  created_at   TIMESTAMP DEFAULT NOW()
);

INSERT INTO wholesale_source (name, country, crawler_type) VALUES
                                                               ('도매꾹',   'KR', 'API'),
                                                               ('오너클랜', 'KR', 'CRAWL'),
                                                               ('도도매',   'KR', 'CRAWL'),
                                                               ('알리익스프레스', 'CN', 'API');

CREATE TABLE wholesale_product (
                                   id             BIGSERIAL PRIMARY KEY,
                                   sku_master_id  BIGINT REFERENCES sku_master(id),
                                   source_id      BIGINT REFERENCES wholesale_source(id),
                                   trade_type     TEXT NOT NULL DEFAULT 'PURCHASE',
                                   title          TEXT NOT NULL,
                                   price          NUMERIC,
                                   currency       TEXT DEFAULT 'KRW',
                                   moq            INTEGER DEFAULT 1,
                                   supplier       TEXT,
                                   country        TEXT DEFAULT 'KR',
                                   normalized_sku TEXT,
                                   brand          TEXT,
                                   model_number   TEXT,
                                   url            TEXT,
                                   raw_json       TEXT,
                                   collected_at   TIMESTAMP DEFAULT NOW()
);

CREATE INDEX idx_wholesale_sku        ON wholesale_product(sku_master_id);
CREATE INDEX idx_wholesale_trade_type ON wholesale_product(trade_type);
CREATE INDEX idx_wholesale_country    ON wholesale_product(country);

CREATE TABLE wholesale_consignment (
                                       id                   BIGSERIAL PRIMARY KEY,
                                       wholesale_product_id BIGINT REFERENCES wholesale_product(id) UNIQUE,
                                       commission_rate      FLOAT,
                                       settlement_days      INTEGER,
                                       settlement_cycle     TEXT,
                                       return_allowed       BOOLEAN DEFAULT TRUE,
                                       return_condition     TEXT,
                                       min_stock_qty        INTEGER DEFAULT 0,
                                       platform_restriction TEXT
);

CREATE TABLE wholesale_purchase (
                                    id                   BIGSERIAL PRIMARY KEY,
                                    wholesale_product_id BIGINT REFERENCES wholesale_product(id) UNIQUE,
                                    purchase_qty         INTEGER,
                                    unit_price           NUMERIC,
                                    bulk_discount_rate   FLOAT DEFAULT 0,
                                    lead_time_days       INTEGER,
                                    stock_available      BOOLEAN DEFAULT TRUE,
                                    stock_qty            INTEGER DEFAULT 0,
                                    warranty_period      TEXT,
                                    return_policy        TEXT
);

CREATE TABLE wholesale_parallel_import (
                                           id                   BIGSERIAL PRIMARY KEY,
                                           wholesale_product_id BIGINT REFERENCES wholesale_product(id) UNIQUE,
                                           origin_country       TEXT,
                                           brand_country        TEXT,
                                           authorized_dealer    BOOLEAN DEFAULT FALSE,
                                           authentic_cert       TEXT,
                                           hs_code              TEXT,
                                           import_duty_rate     FLOAT DEFAULT 0,
                                           customs_category     TEXT,
                                           trademark_risk       BOOLEAN DEFAULT FALSE,
                                           trademark_notes      TEXT
);

CREATE TABLE wholesale_oem (
                               id                   BIGSERIAL PRIMARY KEY,
                               wholesale_product_id BIGINT REFERENCES wholesale_product(id) UNIQUE,
                               min_order_qty        INTEGER,
                               product_spec         TEXT,
                               material             TEXT,
                               customizable_parts   TEXT,
                               sample_lead_days     INTEGER,
                               sample_cost          NUMERIC DEFAULT 0,
                               production_lead_days INTEGER,
                               mold_required        BOOLEAN DEFAULT FALSE,
                               mold_cost            NUMERIC DEFAULT 0,
                               certification_needed TEXT,
                               packaging_option     TEXT
);