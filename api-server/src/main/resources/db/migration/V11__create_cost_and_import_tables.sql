CREATE TABLE exchange_rate (
                               id            BIGSERIAL PRIMARY KEY,
                               from_currency TEXT NOT NULL,
                               to_currency   TEXT NOT NULL DEFAULT 'KRW',
                               rate          FLOAT NOT NULL,
                               source        TEXT DEFAULT 'MANUAL',
                               fetched_at    TIMESTAMP DEFAULT NOW()
);

INSERT INTO exchange_rate (from_currency, to_currency, rate, source) VALUES
                                                                         ('CNY', 'KRW', 190.0, 'MANUAL'),
                                                                         ('USD', 'KRW', 1350.0, 'MANUAL'),
                                                                         ('JPY', 'KRW', 9.0, 'MANUAL');

CREATE TABLE tariff_rate (
                             id               BIGSERIAL PRIMARY KEY,
                             hs_code          TEXT,
                             product_category TEXT NOT NULL,
                             import_duty_rate FLOAT DEFAULT 0,
                             vat_rate         FLOAT DEFAULT 0.10,
                             origin_country   TEXT DEFAULT 'CN',
                             description      TEXT,
                             updated_at       TIMESTAMP DEFAULT NOW()
);

INSERT INTO tariff_rate (product_category, import_duty_rate, vat_rate, description) VALUES
                                                                                        ('전자제품',   0.08,  0.10, '가전/전자기기 기본 관세'),
                                                                                        ('생활용품',   0.06,  0.10, '생활용품 기본 관세'),
                                                                                        ('의류',       0.13,  0.10, '의류 기본 관세'),
                                                                                        ('식품',       0.18,  0.10, '가공식품 기본 관세'),
                                                                                        ('주방용품',   0.08,  0.10, '주방용품 기본 관세');

CREATE TABLE payment_method (
                                id               BIGSERIAL PRIMARY KEY,
                                method_type      TEXT NOT NULL,
                                description      TEXT,
                                fee_rate         FLOAT DEFAULT 0,
                                min_fee          NUMERIC DEFAULT 0,
                                max_fee          NUMERIC,
                                fixed_fee        NUMERIC DEFAULT 0,
                                payment_days     INTEGER DEFAULT 0,
                                currency_support TEXT DEFAULT 'ALL',
                                is_active        BOOLEAN DEFAULT TRUE,
                                updated_at       TIMESTAMP DEFAULT NOW()
);

INSERT INTO payment_method (method_type, description, fee_rate, fixed_fee, payment_days) VALUES
                                                                                             ('TT',       'T/T 전신환',      0.0025, 10000, 3),
                                                                                             ('CARD',     '신용카드',         0.030,  0,     0),
                                                                                             ('PAYPAL',   '페이팔',           0.044,  0,     0),
                                                                                             ('ALIPAY',   '알리페이',         0.010,  0,     0),
                                                                                             ('LC',       'L/C 신용장',       0.005,  50000, 30),
                                                                                             ('CASH',     '현금',             0,      0,     0);

CREATE TABLE payment_condition (
                                   id                   BIGSERIAL PRIMARY KEY,
                                   wholesale_product_id BIGINT REFERENCES wholesale_product(id),
                                   payment_method_id    BIGINT REFERENCES payment_method(id),
                                   tt_condition         TEXT,
                                   deposit_rate         INTEGER DEFAULT 30,
                                   balance_rate         INTEGER DEFAULT 70,
                                   deposit_timing       TEXT DEFAULT '주문시',
                                   balance_timing       TEXT DEFAULT '선적전',
                                   wire_transfer_fee    NUMERIC DEFAULT 0,
                                   bank_name            TEXT,
                                   swift_code           TEXT,
                                   notes                TEXT
);

CREATE TABLE wholesale_import_detail (
                                         id                   BIGSERIAL PRIMARY KEY,
                                         wholesale_product_id BIGINT REFERENCES wholesale_product(id) UNIQUE,
                                         hs_code              TEXT,
                                         import_duty_rate     FLOAT DEFAULT 0,
                                         vat_rate             FLOAT DEFAULT 0.10,
                                         shipping_method      TEXT,
                                         carrier              TEXT,
                                         transit_days         INTEGER,
                                         customs_clearance_fee NUMERIC DEFAULT 50000,
                                         origin_port          TEXT,
                                         destination_port     TEXT DEFAULT '인천항'
);

CREATE TABLE import_cost_estimate (
                                      id                   BIGSERIAL PRIMARY KEY,
                                      wholesale_product_id BIGINT REFERENCES wholesale_product(id),
                                      exchange_rate_id     BIGINT REFERENCES exchange_rate(id),
                                      payment_condition_id BIGINT REFERENCES payment_condition(id),
                                      quantity             FLOAT DEFAULT 1,
                                      product_price_krw    NUMERIC,
                                      import_duty          NUMERIC DEFAULT 0,
                                      vat                  NUMERIC DEFAULT 0,
                                      international_shipping NUMERIC DEFAULT 0,
                                      domestic_shipping    NUMERIC DEFAULT 0,
                                      customs_fee          NUMERIC DEFAULT 0,
                                      payment_fee          NUMERIC DEFAULT 0,
                                      total_landed_cost    NUMERIC,
                                      estimated_at         TIMESTAMP DEFAULT NOW()
);