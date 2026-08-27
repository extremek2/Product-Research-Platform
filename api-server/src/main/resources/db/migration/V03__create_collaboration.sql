CREATE TABLE external_contact (
    id                    BIGSERIAL PRIMARY KEY,
    owner_organization_id BIGINT NOT NULL REFERENCES organization(id) ON DELETE RESTRICT,
    name                  TEXT NOT NULL,
    company_name          TEXT,
    email                 TEXT NOT NULL,
    phone                 TEXT,
    contact_type          TEXT NOT NULL CHECK (contact_type IN (
        'FORWARDER', 'CUSTOMS_BROKER', 'CARRIER', 'TRANSPORTER', 'WAREHOUSE', 'OTHER'
    )),
    created_at            TIMESTAMP NOT NULL DEFAULT NOW(),
    updated_at            TIMESTAMP NOT NULL DEFAULT NOW(),
    UNIQUE (owner_organization_id, email)
);

CREATE TABLE case_participant (
    id                  BIGSERIAL PRIMARY KEY,
    shipment_case_id    BIGINT NOT NULL REFERENCES shipment_case(id) ON DELETE RESTRICT,
    organization_id     BIGINT REFERENCES organization(id) ON DELETE RESTRICT,
    user_id             BIGINT REFERENCES app_user(id) ON DELETE RESTRICT,
    external_contact_id BIGINT REFERENCES external_contact(id) ON DELETE RESTRICT,
    participant_role    TEXT NOT NULL CHECK (participant_role IN (
        'SHIPPER', 'FORWARDER', 'CUSTOMS_BROKER', 'TRANSPORTER', 'WAREHOUSE', 'VIEWER'
    )),
    access_level        TEXT NOT NULL CHECK (access_level IN ('EDITOR', 'CONTRIBUTOR', 'VIEWER')),
    status              TEXT NOT NULL DEFAULT 'ACTIVE' CHECK (status IN ('INVITED', 'ACTIVE', 'REVOKED')),
    joined_at           TIMESTAMP,
    created_at          TIMESTAMP NOT NULL DEFAULT NOW(),
    CHECK ((user_id IS NOT NULL)::INTEGER + (external_contact_id IS NOT NULL)::INTEGER = 1),
    UNIQUE NULLS NOT DISTINCT (shipment_case_id, user_id, external_contact_id)
);

CREATE TABLE case_invitation (
    id             BIGSERIAL PRIMARY KEY,
    public_id      UUID NOT NULL DEFAULT gen_random_uuid() UNIQUE,
    participant_id BIGINT NOT NULL REFERENCES case_participant(id) ON DELETE CASCADE,
    token_hash     TEXT NOT NULL UNIQUE,
    target_email   TEXT NOT NULL,
    expires_at     TIMESTAMP NOT NULL,
    accepted_at    TIMESTAMP,
    revoked_at     TIMESTAMP,
    created_by     BIGINT NOT NULL REFERENCES app_user(id) ON DELETE RESTRICT,
    created_at     TIMESTAMP NOT NULL DEFAULT NOW()
);

CREATE TABLE case_data_authority (
    id               BIGSERIAL PRIMARY KEY,
    shipment_case_id BIGINT NOT NULL REFERENCES shipment_case(id) ON DELETE RESTRICT,
    data_domain      TEXT NOT NULL CHECK (data_domain IN (
        'TRADE', 'BOOKING', 'TRANSPORT_DOCUMENT', 'SCHEDULE',
        'TRACKING', 'CUSTOMS', 'DELIVERY', 'WAREHOUSE'
    )),
    authority_type   TEXT NOT NULL CHECK (authority_type IN ('PARTICIPANT', 'EXTERNAL_API', 'SYSTEM')),
    participant_id   BIGINT REFERENCES case_participant(id) ON DELETE RESTRICT,
    source_name      TEXT,
    created_at       TIMESTAMP NOT NULL DEFAULT NOW(),
    updated_at       TIMESTAMP NOT NULL DEFAULT NOW(),
    CHECK (
        (authority_type = 'PARTICIPANT' AND participant_id IS NOT NULL)
        OR (authority_type <> 'PARTICIPANT' AND participant_id IS NULL)
    ),
    UNIQUE (shipment_case_id, data_domain)
);

CREATE INDEX idx_case_participant_case_role ON case_participant(shipment_case_id, participant_role);
CREATE INDEX idx_case_invitation_email ON case_invitation(target_email, expires_at);
