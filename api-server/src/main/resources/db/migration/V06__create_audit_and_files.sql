CREATE TABLE case_comment (
    id                    BIGSERIAL PRIMARY KEY,
    public_id             UUID NOT NULL DEFAULT gen_random_uuid() UNIQUE,
    shipment_case_id      BIGINT NOT NULL REFERENCES shipment_case(id) ON DELETE RESTRICT,
    issue_id              BIGINT REFERENCES operation_issue(id) ON DELETE RESTRICT,
    task_id               BIGINT REFERENCES operation_task(id) ON DELETE RESTRICT,
    author_participant_id BIGINT NOT NULL REFERENCES case_participant(id) ON DELETE RESTRICT,
    content               TEXT NOT NULL,
    created_at            TIMESTAMP NOT NULL DEFAULT NOW(),
    updated_at            TIMESTAMP,
    deleted_at            TIMESTAMP
);

CREATE TABLE attachment (
    id                         BIGSERIAL PRIMARY KEY,
    public_id                  UUID NOT NULL DEFAULT gen_random_uuid() UNIQUE,
    shipment_case_id           BIGINT NOT NULL REFERENCES shipment_case(id) ON DELETE RESTRICT,
    issue_id                   BIGINT REFERENCES operation_issue(id) ON DELETE RESTRICT,
    task_id                    BIGINT REFERENCES operation_task(id) ON DELETE RESTRICT,
    comment_id                 BIGINT REFERENCES case_comment(id) ON DELETE RESTRICT,
    document_category          TEXT NOT NULL CHECK (document_category IN (
        'PI', 'COMMERCIAL_INVOICE', 'PACKING_LIST', 'BILL_OF_LADING',
        'CERTIFICATE_OF_ORIGIN', 'CUSTOMS_DOCUMENT', 'DELIVERY_DOCUMENT', 'OTHER'
    )),
    original_filename          TEXT NOT NULL,
    storage_key                TEXT NOT NULL UNIQUE,
    content_type               TEXT,
    file_size                  BIGINT CHECK (file_size IS NULL OR file_size >= 0),
    checksum                   TEXT,
    uploaded_by_participant_id BIGINT NOT NULL REFERENCES case_participant(id) ON DELETE RESTRICT,
    created_at                 TIMESTAMP NOT NULL DEFAULT NOW(),
    deleted_at                 TIMESTAMP
);

CREATE TABLE change_history (
    id                   BIGSERIAL PRIMARY KEY,
    shipment_case_id     BIGINT NOT NULL REFERENCES shipment_case(id) ON DELETE RESTRICT,
    actor_participant_id BIGINT REFERENCES case_participant(id) ON DELETE RESTRICT,
    actor_type           TEXT NOT NULL CHECK (actor_type IN ('USER', 'EXTERNAL_PARTICIPANT', 'API', 'SYSTEM')),
    entity_type          TEXT NOT NULL,
    entity_id            BIGINT NOT NULL,
    field_name           TEXT,
    old_value            JSONB,
    new_value            JSONB,
    change_reason        TEXT,
    source_type          TEXT NOT NULL CHECK (source_type IN ('API', 'MANUAL', 'FILE', 'SYSTEM')),
    changed_at           TIMESTAMP NOT NULL DEFAULT NOW()
);

CREATE INDEX idx_case_comment_case ON case_comment(shipment_case_id, created_at);
CREATE INDEX idx_attachment_case ON attachment(shipment_case_id, document_category);
CREATE INDEX idx_change_history_case ON change_history(shipment_case_id, changed_at DESC);
