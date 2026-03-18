CREATE TABLE trend_keyword_raw (
                                   id           BIGSERIAL PRIMARY KEY,
                                   source       TEXT NOT NULL,
                                   keyword      TEXT NOT NULL,
                                   score        FLOAT,
                                   rank         INTEGER,
                                   collected_at TIMESTAMP DEFAULT NOW()
);

CREATE TABLE trend_keyword_ranked (
                                      id           BIGSERIAL PRIMARY KEY,
                                      keyword      TEXT NOT NULL,
                                      category     TEXT,
                                      naver_score  FLOAT DEFAULT 0,
                                      google_score FLOAT DEFAULT 0,
                                      youtube_score FLOAT DEFAULT 0,
                                      cross_score  FLOAT DEFAULT 0,
                                      final_rank   INTEGER,
                                      ranked_at    TIMESTAMP DEFAULT NOW()
);

CREATE INDEX idx_trend_ranked_rank ON trend_keyword_ranked(final_rank);
CREATE INDEX idx_trend_raw_source  ON trend_keyword_raw(source, collected_at);