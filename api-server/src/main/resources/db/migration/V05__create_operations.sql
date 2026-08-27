CREATE TABLE operation_issue (
    id               BIGSERIAL PRIMARY KEY,
    public_id        UUID NOT NULL DEFAULT gen_random_uuid() UNIQUE,
    shipment_case_id BIGINT NOT NULL REFERENCES shipment_case(id) ON DELETE RESTRICT,
    issue_type       TEXT NOT NULL,
    severity         TEXT NOT NULL CHECK (severity IN ('INFO', 'ATTENTION', 'URGENT')),
    status           TEXT NOT NULL DEFAULT 'OPEN' CHECK (status IN ('OPEN', 'ACKNOWLEDGED', 'RESOLVED', 'DISMISSED')),
    title            TEXT NOT NULL,
    description      TEXT,
    detection_source TEXT NOT NULL CHECK (detection_source IN ('RULE', 'USER', 'EXTERNAL_API', 'AI')),
    rule_code        TEXT,
    evidence         JSONB,
    detected_at      TIMESTAMP NOT NULL DEFAULT NOW(),
    acknowledged_at  TIMESTAMP,
    resolved_at      TIMESTAMP,
    resolved_by      BIGINT REFERENCES app_user(id) ON DELETE RESTRICT,
    resolution_note  TEXT,
    created_at       TIMESTAMP NOT NULL DEFAULT NOW(),
    updated_at       TIMESTAMP NOT NULL DEFAULT NOW()
);

CREATE TABLE operation_task (
    id                      BIGSERIAL PRIMARY KEY,
    public_id               UUID NOT NULL DEFAULT gen_random_uuid() UNIQUE,
    shipment_case_id        BIGINT NOT NULL REFERENCES shipment_case(id) ON DELETE RESTRICT,
    issue_id                BIGINT REFERENCES operation_issue(id) ON DELETE RESTRICT,
    task_type               TEXT NOT NULL,
    title                   TEXT NOT NULL,
    description             TEXT,
    status                  TEXT NOT NULL DEFAULT 'OPEN'
                            CHECK (status IN ('OPEN', 'IN_PROGRESS', 'BLOCKED', 'COMPLETED', 'CANCELLED')),
    priority                TEXT NOT NULL DEFAULT 'NORMAL'
                            CHECK (priority IN ('NORMAL', 'ATTENTION', 'URGENT')),
    assignee_participant_id BIGINT REFERENCES case_participant(id) ON DELETE RESTRICT,
    requested_by            BIGINT REFERENCES app_user(id) ON DELETE RESTRICT,
    due_at                  TIMESTAMP,
    started_at              TIMESTAMP,
    completed_at            TIMESTAMP,
    completion_note         TEXT,
    created_at              TIMESTAMP NOT NULL DEFAULT NOW(),
    updated_at              TIMESTAMP NOT NULL DEFAULT NOW()
);

CREATE INDEX idx_operation_issue_queue ON operation_issue(shipment_case_id, status, severity);
CREATE INDEX idx_operation_task_assignee ON operation_task(assignee_participant_id, status, due_at);
CREATE INDEX idx_operation_task_case ON operation_task(shipment_case_id, status);
