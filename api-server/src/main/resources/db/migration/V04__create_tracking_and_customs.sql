CREATE TABLE tracking_event (
    id                BIGSERIAL PRIMARY KEY,
    public_id         UUID NOT NULL DEFAULT gen_random_uuid() UNIQUE,
    shipment_case_id  BIGINT NOT NULL REFERENCES shipment_case(id) ON DELETE RESTRICT,
    provider          TEXT NOT NULL,
    provider_event_id TEXT,
    event_code        TEXT NOT NULL,
    event_name        TEXT NOT NULL,
    location_code     TEXT,
    location_name     TEXT,
    occurred_at       TIMESTAMP NOT NULL,
    received_at       TIMESTAMP NOT NULL DEFAULT NOW(),
    source_type       TEXT NOT NULL CHECK (source_type IN ('API', 'MANUAL', 'FILE', 'SYSTEM')),
    deduplication_key TEXT NOT NULL,
    raw_payload       JSONB,
    created_at        TIMESTAMP NOT NULL DEFAULT NOW(),
    UNIQUE (provider, deduplication_key)
);

CREATE TABLE customs_event (
    id                  BIGSERIAL PRIMARY KEY,
    public_id           UUID NOT NULL DEFAULT gen_random_uuid() UNIQUE,
    shipment_case_id    BIGINT NOT NULL REFERENCES shipment_case(id) ON DELETE RESTRICT,
    declaration_number  TEXT,
    customs_office      TEXT,
    provider            TEXT NOT NULL,
    event_code          TEXT NOT NULL,
    event_name          TEXT NOT NULL,
    occurred_at         TIMESTAMP NOT NULL,
    received_at         TIMESTAMP NOT NULL DEFAULT NOW(),
    inspection_required BOOLEAN,
    hold_reason         TEXT,
    deduplication_key   TEXT NOT NULL,
    raw_payload         JSONB,
    created_at          TIMESTAMP NOT NULL DEFAULT NOW(),
    UNIQUE (provider, deduplication_key)
);

CREATE TABLE shipment_milestone (
    id               BIGSERIAL PRIMARY KEY,
    shipment_case_id BIGINT NOT NULL REFERENCES shipment_case(id) ON DELETE RESTRICT,
    milestone_type   TEXT NOT NULL,
    status           TEXT NOT NULL CHECK (status IN ('PENDING', 'EXPECTED', 'COMPLETED', 'MISSED', 'CANCELLED')),
    planned_at       TIMESTAMP,
    estimated_at     TIMESTAMP,
    actual_at        TIMESTAMP,
    source_type      TEXT NOT NULL CHECK (source_type IN ('API', 'MANUAL', 'FILE', 'SYSTEM')),
    source_reference TEXT,
    updated_at       TIMESTAMP NOT NULL DEFAULT NOW(),
    UNIQUE (shipment_case_id, milestone_type)
);

CREATE INDEX idx_tracking_event_timeline ON tracking_event(shipment_case_id, occurred_at DESC);
CREATE INDEX idx_customs_event_timeline ON customs_event(shipment_case_id, occurred_at DESC);
CREATE INDEX idx_customs_declaration ON customs_event(declaration_number);
