CREATE TABLE integration_sync_run (
    id               BIGSERIAL PRIMARY KEY,
    public_id        UUID NOT NULL DEFAULT gen_random_uuid() UNIQUE,
    shipment_case_id BIGINT REFERENCES shipment_case(id) ON DELETE RESTRICT,
    provider         TEXT NOT NULL,
    integration_type TEXT NOT NULL,
    status           TEXT NOT NULL CHECK (status IN ('PENDING', 'RUNNING', 'SUCCESS', 'PARTIAL_SUCCESS', 'FAILED')),
    requested_by     TEXT NOT NULL,
    started_at       TIMESTAMP NOT NULL DEFAULT NOW(),
    completed_at     TIMESTAMP,
    records_received INTEGER NOT NULL DEFAULT 0 CHECK (records_received >= 0),
    records_created  INTEGER NOT NULL DEFAULT 0 CHECK (records_created >= 0),
    error_code       TEXT,
    error_message    TEXT,
    retry_count      INTEGER NOT NULL DEFAULT 0 CHECK (retry_count >= 0),
    created_at       TIMESTAMP NOT NULL DEFAULT NOW()
);

CREATE TABLE integration_raw_event (
    id                BIGSERIAL PRIMARY KEY,
    sync_run_id       BIGINT NOT NULL REFERENCES integration_sync_run(id) ON DELETE RESTRICT,
    provider          TEXT NOT NULL,
    external_reference TEXT,
    payload_type      TEXT NOT NULL,
    payload           JSONB NOT NULL,
    payload_hash      TEXT NOT NULL,
    received_at       TIMESTAMP NOT NULL DEFAULT NOW(),
    processed_at      TIMESTAMP,
    processing_status TEXT NOT NULL DEFAULT 'PENDING'
                      CHECK (processing_status IN ('PENDING', 'PROCESSED', 'FAILED', 'IGNORED')),
    error_message     TEXT,
    UNIQUE (provider, payload_hash)
);

CREATE TABLE ai_summary (
    id                  BIGSERIAL PRIMARY KEY,
    public_id           UUID NOT NULL DEFAULT gen_random_uuid() UNIQUE,
    shipment_case_id    BIGINT NOT NULL REFERENCES shipment_case(id) ON DELETE RESTRICT,
    summary_type        TEXT NOT NULL,
    status              TEXT NOT NULL CHECK (status IN ('PENDING', 'SUCCESS', 'FAILED')),
    summary_text        TEXT,
    recommended_actions JSONB,
    model_name          TEXT,
    prompt_version      TEXT,
    input_hash          TEXT NOT NULL,
    source_snapshot     JSONB NOT NULL,
    generated_at        TIMESTAMP,
    error_message       TEXT,
    created_at          TIMESTAMP NOT NULL DEFAULT NOW(),
    UNIQUE (shipment_case_id, summary_type, input_hash)
);

CREATE INDEX idx_sync_run_status ON integration_sync_run(provider, status, created_at DESC);
CREATE INDEX idx_raw_event_status ON integration_raw_event(processing_status, received_at);
CREATE INDEX idx_ai_summary_case ON ai_summary(shipment_case_id, created_at DESC);
