CREATE TABLE partner_company (
    id BIGSERIAL PRIMARY KEY,
    public_id UUID NOT NULL UNIQUE DEFAULT gen_random_uuid(),
    owner_organization_id BIGINT NOT NULL REFERENCES organization(id) ON DELETE RESTRICT,
    name TEXT NOT NULL,
    company_type TEXT NOT NULL CHECK(company_type IN ('FORWARDER','CUSTOMS_BROKER')),
    created_at TIMESTAMP NOT NULL DEFAULT NOW()
);
CREATE UNIQUE INDEX uq_partner_company_name ON partner_company(owner_organization_id,company_type,lower(btrim(name)));
CREATE TABLE case_partner (
    id BIGSERIAL PRIMARY KEY,
    public_id UUID NOT NULL UNIQUE DEFAULT gen_random_uuid(),
    shipment_case_id BIGINT NOT NULL REFERENCES shipment_case(id) ON DELETE RESTRICT,
    partner_company_id BIGINT NOT NULL REFERENCES partner_company(id) ON DELETE RESTRICT,
    created_at TIMESTAMP NOT NULL DEFAULT NOW(),
    UNIQUE(shipment_case_id,partner_company_id)
);
ALTER TABLE external_contact ADD COLUMN partner_company_id BIGINT REFERENCES partner_company(id) ON DELETE RESTRICT;
ALTER TABLE case_participant ADD COLUMN public_id UUID NOT NULL UNIQUE DEFAULT gen_random_uuid();
ALTER TABLE case_participant ADD COLUMN case_partner_id BIGINT REFERENCES case_partner(id) ON DELETE RESTRICT;
-- Keep legacy participants unchanged. They do not qualify for CASE sessions without an explicit partner mapping.
ALTER TABLE case_participant DROP CONSTRAINT case_participant_check;
ALTER TABLE case_participant ADD CONSTRAINT ck_participant_identity CHECK (
    (case_partner_id IS NULL AND ((user_id IS NOT NULL)::INTEGER + (external_contact_id IS NOT NULL)::INTEGER = 1))
    OR (case_partner_id IS NOT NULL AND external_contact_id IS NOT NULL AND organization_id IS NULL
        AND access_level IN ('VIEWER','CONTRIBUTOR') AND (status <> 'ACTIVE' OR user_id IS NOT NULL))
);
CREATE UNIQUE INDEX uq_case_verified_user ON case_participant(shipment_case_id,user_id)
    WHERE case_partner_id IS NOT NULL AND user_id IS NOT NULL AND status='ACTIVE';
CREATE UNIQUE INDEX uq_case_external_contact ON case_participant(shipment_case_id,external_contact_id)
    WHERE case_partner_id IS NOT NULL AND status IN ('INVITED','ACTIVE');
ALTER TABLE case_invitation ADD COLUMN invitation_status TEXT NOT NULL DEFAULT 'PENDING'
    CHECK(invitation_status IN ('PENDING','ACCEPTED','REVOKED','EXPIRED'));
UPDATE case_invitation SET invitation_status=CASE WHEN revoked_at IS NOT NULL THEN 'REVOKED'
    WHEN accepted_at IS NOT NULL THEN 'ACCEPTED' WHEN expires_at<=NOW() THEN 'EXPIRED' ELSE 'PENDING' END;
ALTER TABLE email_auth_token ALTER COLUMN user_id DROP NOT NULL;
ALTER TABLE email_auth_token DROP CONSTRAINT email_auth_token_purpose_check;
ALTER TABLE email_auth_token ADD COLUMN invitation_id BIGINT REFERENCES case_invitation(id) ON DELETE RESTRICT;
ALTER TABLE email_auth_token ADD CONSTRAINT ck_email_token_purpose CHECK (
    (purpose='VERIFY_EMAIL' AND user_id IS NOT NULL AND invitation_id IS NULL)
    OR (purpose='CASE_LOGIN' AND invitation_id IS NOT NULL)
);
CREATE INDEX idx_email_token_invitation ON email_auth_token(invitation_id,created_at);
ALTER TABLE refresh_session ADD COLUMN participant_id BIGINT REFERENCES case_participant(id) ON DELETE RESTRICT;
ALTER TABLE refresh_session DROP CONSTRAINT ck_refresh_session_context;
ALTER TABLE refresh_session ADD CONSTRAINT ck_refresh_session_context CHECK (
    (session_kind='ORGANIZATION' AND organization_id IS NOT NULL AND participant_id IS NULL)
    OR (session_kind IN ('ACCOUNT','PLATFORM') AND organization_id IS NULL AND participant_id IS NULL)
    OR (session_kind='CASE' AND organization_id IS NULL AND participant_id IS NOT NULL)
);
CREATE INDEX idx_refresh_participant ON refresh_session(participant_id) WHERE participant_id IS NOT NULL;
