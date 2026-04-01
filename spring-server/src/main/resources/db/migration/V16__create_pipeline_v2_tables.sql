-- 소매 소스 관리
CREATE TABLE retail_source (
    id           BIGSERIAL PRIMARY KEY,
    name         TEXT NOT NULL,
    source_key   TEXT NOT NULL UNIQUE,
    crawler_type TEXT NOT NULL DEFAULT 'API',
    is_active    BOOLEAN DEFAULT TRUE,
    priority     INTEGER DEFAULT 0,
    rate_limit   INTEGER DEFAULT 1,
    created_at   TIMESTAMP DEFAULT NOW()
);

INSERT INTO retail_source (name, source_key, crawler_type, priority) VALUES
    ('네이버쇼핑', 'naver_shopping', 'API',   100),
    ('쿠팡',       'coupang',        'CRAWL',  80),
    ('11번가',     '11st',           'API',    60),
    ('G마켓',      'gmarket',        'CRAWL',  40);

-- 인기 상품 수집
CREATE TABLE retail_popular_product (
    id             BIGSERIAL PRIMARY KEY,
    source_id      BIGINT REFERENCES retail_source(id),
    category       TEXT,
    search_keyword TEXT,
    title          TEXT NOT NULL,
    price          NUMERIC,
    review_count   INTEGER DEFAULT 0,
    purchase_count INTEGER DEFAULT 0,
    rank           INTEGER DEFAULT 0,
    brand          TEXT,
    model_number   TEXT,
    normalized_sku TEXT,
    sku_master_id  BIGINT REFERENCES sku_master(id),
    seller         TEXT,
    url            TEXT,
    image_url      TEXT,
    rating         FLOAT,
    raw_json       TEXT,
    collected_at   TIMESTAMP DEFAULT NOW()
);

CREATE INDEX idx_popular_category    ON retail_popular_product(category);
CREATE INDEX idx_popular_keyword     ON retail_popular_product(search_keyword);
CREATE INDEX idx_popular_rank        ON retail_popular_product(rank);
CREATE INDEX idx_popular_collected   ON retail_popular_product(collected_at DESC);

-- 트렌드 분석
CREATE TABLE trend_analysis (
    id                   BIGSERIAL PRIMARY KEY,
    keyword              TEXT NOT NULL,
    category             TEXT,
    naver_search_trend   FLOAT DEFAULT 0,
    naver_shopping_trend FLOAT DEFAULT 0,
    google_trend         FLOAT DEFAULT 0,
    trend_type           TEXT DEFAULT 'UNKNOWN',
    peak_month           INTEGER,
    momentum             FLOAT DEFAULT 0,
    volatility           FLOAT DEFAULT 0,
    confidence           FLOAT DEFAULT 0,
    raw_data             TEXT,
    analyzed_at          TIMESTAMP DEFAULT NOW()
);

CREATE INDEX idx_trend_keyword     ON trend_analysis(keyword);
CREATE INDEX idx_trend_type        ON trend_analysis(trend_type);
CREATE INDEX idx_trend_analyzed    ON trend_analysis(analyzed_at DESC);

-- 소싱 후보
CREATE TABLE sourcing_candidate (
    id                    BIGSERIAL PRIMARY KEY,
    trend_analysis_id     BIGINT REFERENCES trend_analysis(id),
    keyword               TEXT NOT NULL,
    category              TEXT,
    retail_min_price      NUMERIC,
    retail_avg_price      NUMERIC,
    retail_product_count  INTEGER DEFAULT 0,
    competition_level     TEXT DEFAULT 'UNKNOWN',
    estimated_margin_rate FLOAT,
    sourcing_status       TEXT DEFAULT 'PENDING',
    memo                  TEXT,
    created_at            TIMESTAMP DEFAULT NOW(),
    updated_at            TIMESTAMP DEFAULT NOW()
);

CREATE INDEX idx_candidate_keyword ON sourcing_candidate(keyword);
CREATE INDEX idx_candidate_status  ON sourcing_candidate(sourcing_status);
CREATE INDEX idx_candidate_margin  ON sourcing_candidate(estimated_margin_rate DESC);
