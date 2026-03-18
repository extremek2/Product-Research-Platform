CREATE TABLE shipping_policy (
                                 id               BIGSERIAL PRIMARY KEY,
                                 name             TEXT NOT NULL,
                                 shipping_type    TEXT NOT NULL,
                                 carrier          TEXT,
                                 origin_type      TEXT NOT NULL DEFAULT 'DOMESTIC',
                                 origin_country   TEXT DEFAULT 'KR',
                                 destination      TEXT DEFAULT 'KR',
                                 method           TEXT,
                                 cost_type        TEXT NOT NULL DEFAULT 'FIXED',
                                 base_cost        NUMERIC DEFAULT 0,
                                 cost_per_kg      NUMERIC DEFAULT 0,
                                 free_threshold   NUMERIC,
                                 min_cost         NUMERIC DEFAULT 0,
                                 max_cost         NUMERIC,
                                 transit_days     INTEGER,
                                 is_active        BOOLEAN DEFAULT TRUE,
                                 updated_at       TIMESTAMP DEFAULT NOW()
);

INSERT INTO shipping_policy
(name, shipping_type, carrier, origin_type, cost_type, base_cost, free_threshold, transit_days)
VALUES
    ('국내 기본 택배',    'DOMESTIC_TO_CUSTOMER', 'CJ대한통운', 'DOMESTIC', 'FIXED',    3000,  50000,  1),
    ('국내 도매 화물',    'DOMESTIC_TO_WAREHOUSE', '화물',       'DOMESTIC', 'PER_KG',   0,     NULL,   2),
    ('쿠팡 로켓배송',     'FULFILLMENT',           '쿠팡',       'DOMESTIC', 'FIXED',    0,     NULL,   1),
    ('네이버 스마트스토어','FULFILLMENT',           '네이버',     'DOMESTIC', 'FIXED',    2500,  NULL,   2),
    ('EMS 국제배송',      'INTERNATIONAL',         'EMS',        'OVERSEAS', 'PER_KG',   13000, NULL,   5),
    ('DHL 국제배송',      'INTERNATIONAL',         'DHL',        'OVERSEAS', 'PER_KG',   25000, NULL,   3);

CREATE TABLE platform_fee (
                              id           BIGSERIAL PRIMARY KEY,
                              platform     TEXT NOT NULL,
                              fee_type     TEXT NOT NULL,
                              fee_rate     FLOAT DEFAULT 0,
                              fixed_fee    NUMERIC DEFAULT 0,
                              min_fee      NUMERIC DEFAULT 0,
                              description  TEXT,
                              updated_at   TIMESTAMP DEFAULT NOW()
);

INSERT INTO platform_fee (platform, fee_type, fee_rate, description) VALUES
                                                                         ('쿠팡',       'COMMISSION',    0.108, '로켓그로스 기본 수수료'),
                                                                         ('쿠팡',       'FULFILLMENT',   0.03,  '풀필먼트 보관/배송비'),
                                                                         ('네이버쇼핑',  'COMMISSION',   0.02,  '스마트스토어 기본 수수료'),
                                                                         ('네이버쇼핑',  'PAYMENT',      0.036, '네이버페이 결제 수수료'),
                                                                         ('11번가',      'COMMISSION',   0.09,  '기본 카테고리 수수료'),
                                                                         ('G마켓',       'COMMISSION',   0.10,  '기본 카테고리 수수료');