CREATE TABLE platform_role_assignment (
    id BIGSERIAL PRIMARY KEY,
    user_id BIGINT NOT NULL REFERENCES app_user(id) ON DELETE RESTRICT,
    role TEXT NOT NULL CHECK (role = 'SYSTEM_ADMIN'),
    active BOOLEAN NOT NULL DEFAULT TRUE,
    granted_by BIGINT REFERENCES app_user(id) ON DELETE RESTRICT,
    granted_at TIMESTAMP NOT NULL DEFAULT NOW(),
    revoked_at TIMESTAMP,
    UNIQUE (user_id, role),
    CHECK ((active AND revoked_at IS NULL) OR (NOT active AND revoked_at IS NOT NULL))
);

CREATE TABLE identity_audit_event (
    id BIGSERIAL PRIMARY KEY,
    actor_user_id BIGINT REFERENCES app_user(id) ON DELETE RESTRICT,
    actor_type TEXT NOT NULL CHECK (actor_type IN ('USER', 'BOOTSTRAP', 'SYSTEM')),
    action TEXT NOT NULL,
    target_type TEXT NOT NULL,
    target_id TEXT NOT NULL,
    organization_id BIGINT REFERENCES organization(id) ON DELETE RESTRICT,
    old_value TEXT,
    new_value TEXT,
    reason TEXT NOT NULL,
    request_id UUID NOT NULL,
    occurred_at TIMESTAMP NOT NULL DEFAULT NOW()
);
CREATE INDEX idx_identity_audit_target ON identity_audit_event(target_type, target_id, occurred_at);

ALTER TABLE refresh_session ADD COLUMN public_id UUID NOT NULL DEFAULT gen_random_uuid();
ALTER TABLE refresh_session ADD CONSTRAINT uq_refresh_session_public_id UNIQUE (public_id);
ALTER TABLE refresh_session ADD COLUMN session_kind TEXT NOT NULL DEFAULT 'ORGANIZATION';
ALTER TABLE refresh_session ALTER COLUMN organization_id DROP NOT NULL;
ALTER TABLE refresh_session ADD CONSTRAINT ck_refresh_session_context CHECK (
    (session_kind = 'ORGANIZATION' AND organization_id IS NOT NULL)
    OR (session_kind IN ('ACCOUNT', 'PLATFORM') AND organization_id IS NULL)
);
-- CASE sessions will be added with case participation in stage 5.
