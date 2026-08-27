CREATE TABLE reference_code (
    id           BIGSERIAL PRIMARY KEY,
    code_type    TEXT NOT NULL,
    code         TEXT NOT NULL,
    name         TEXT NOT NULL,
    country_code TEXT,
    metadata     JSONB,
    is_active    BOOLEAN NOT NULL DEFAULT TRUE,
    UNIQUE (code_type, code)
);

CREATE TABLE operation_rule (
    id            BIGSERIAL PRIMARY KEY,
    rule_code     TEXT NOT NULL UNIQUE,
    name          TEXT NOT NULL,
    description   TEXT,
    issue_type    TEXT NOT NULL,
    severity      TEXT NOT NULL CHECK (severity IN ('INFO', 'ATTENTION', 'URGENT')),
    rule_type     TEXT NOT NULL DEFAULT 'THRESHOLD',
    configuration JSONB NOT NULL,
    is_active     BOOLEAN NOT NULL DEFAULT TRUE,
    created_at    TIMESTAMP NOT NULL DEFAULT NOW(),
    updated_at    TIMESTAMP NOT NULL DEFAULT NOW()
);

CREATE INDEX idx_reference_code_type ON reference_code(code_type, is_active);
CREATE INDEX idx_operation_rule_active ON operation_rule(is_active, issue_type);
