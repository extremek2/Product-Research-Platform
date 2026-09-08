DO $$ BEGIN
    IF EXISTS (SELECT 1 FROM app_user GROUP BY lower(btrim(email)) HAVING count(*) > 1) THEN
        RAISE EXCEPTION 'Duplicate normalized user emails: reconcile accounts before V15';
    END IF;
END $$;
UPDATE app_user SET email = lower(btrim(email));
CREATE UNIQUE INDEX uq_app_user_normalized_email ON app_user(lower(btrim(email)));
ALTER TABLE app_user ADD COLUMN email_verified_at TIMESTAMP;

CREATE TABLE organization_application (
    id BIGSERIAL PRIMARY KEY,
    public_id UUID NOT NULL UNIQUE DEFAULT gen_random_uuid(),
    applicant_user_id BIGINT NOT NULL REFERENCES app_user(id) ON DELETE RESTRICT,
    organization_name TEXT NOT NULL,
    business_number TEXT,
    applicant_name TEXT NOT NULL,
    applicant_email TEXT NOT NULL,
    phone TEXT,
    status TEXT NOT NULL CHECK (status IN ('PENDING_EMAIL','PENDING_REVIEW','APPROVED','REJECTED')),
    previous_application_id BIGINT UNIQUE REFERENCES organization_application(id) ON DELETE RESTRICT,
    approved_organization_id BIGINT UNIQUE REFERENCES organization(id) ON DELETE RESTRICT,
    reviewed_by BIGINT REFERENCES app_user(id) ON DELETE RESTRICT,
    public_reason TEXT,
    internal_note TEXT,
    submitted_at TIMESTAMP NOT NULL DEFAULT NOW(),
    reviewed_at TIMESTAMP,
    version BIGINT NOT NULL DEFAULT 0,
    CHECK ((status = 'APPROVED') = (approved_organization_id IS NOT NULL)),
    CHECK ((status IN ('APPROVED','REJECTED')) = (reviewed_by IS NOT NULL AND reviewed_at IS NOT NULL AND public_reason IS NOT NULL))
);
CREATE UNIQUE INDEX uq_application_pending_user ON organization_application(applicant_user_id)
    WHERE status IN ('PENDING_EMAIL','PENDING_REVIEW');
CREATE INDEX idx_application_review_queue ON organization_application(status,submitted_at,id);
CREATE INDEX idx_application_user ON organization_application(applicant_user_id,submitted_at DESC);

CREATE TABLE email_auth_token (
    id BIGSERIAL PRIMARY KEY,
    public_id UUID NOT NULL UNIQUE DEFAULT gen_random_uuid(),
    user_id BIGINT NOT NULL REFERENCES app_user(id) ON DELETE RESTRICT,
    purpose TEXT NOT NULL CHECK (purpose='VERIFY_EMAIL'),
    target_email TEXT NOT NULL,
    token_hash TEXT NOT NULL UNIQUE,
    created_at TIMESTAMP NOT NULL DEFAULT NOW(),
    expires_at TIMESTAMP NOT NULL,
    consumed_at TIMESTAMP,
    revoked_at TIMESTAMP
);
CREATE INDEX idx_email_token_user ON email_auth_token(user_id,created_at DESC);

CREATE TABLE mail_outbox (
    id BIGSERIAL PRIMARY KEY,
    public_id UUID NOT NULL UNIQUE DEFAULT gen_random_uuid(),
    email_token_id BIGINT REFERENCES email_auth_token(id) ON DELETE RESTRICT,
    encrypted_payload TEXT,
    status TEXT NOT NULL DEFAULT 'PENDING' CHECK (status IN ('PENDING','SENT','EXPIRED','FAILED','CANCELLED')),
    attempts INTEGER NOT NULL DEFAULT 0 CHECK (attempts >= 0),
    available_at TIMESTAMP NOT NULL DEFAULT NOW(),
    expires_at TIMESTAMP NOT NULL,
    created_at TIMESTAMP NOT NULL DEFAULT NOW(),
    sent_at TIMESTAMP,
    last_error TEXT,
    CHECK (status <> 'PENDING' OR encrypted_payload IS NOT NULL)
);
CREATE INDEX idx_mail_outbox_pending ON mail_outbox(available_at,id) WHERE status='PENDING';

CREATE TABLE auth_rate_limit (
    bucket_key TEXT NOT NULL,
    window_start TIMESTAMP NOT NULL,
    requests INTEGER NOT NULL,
    PRIMARY KEY(bucket_key,window_start)
);
