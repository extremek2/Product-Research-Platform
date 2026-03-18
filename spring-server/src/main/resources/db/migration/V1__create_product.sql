CREATE TABLE IF NOT EXISTS product (
    id         BIGSERIAL PRIMARY KEY,
    title      TEXT      NOT NULL,
    brand      TEXT,
    category   TEXT,
    source     TEXT,
    created_at TIMESTAMP DEFAULT NOW()
);
