CREATE TABLE organization (
    id                BIGSERIAL PRIMARY KEY,
    public_id         UUID NOT NULL DEFAULT gen_random_uuid() UNIQUE,
    name              TEXT NOT NULL,
    organization_type TEXT NOT NULL CHECK (organization_type IN (
        'SHIPPER', 'FORWARDER', 'CUSTOMS_BROKER', 'CARRIER',
        'TRANSPORTER', 'WAREHOUSE', 'OTHER'
    )),
    business_number   TEXT,
    email             TEXT,
    phone             TEXT,
    status            TEXT NOT NULL DEFAULT 'ACTIVE'
                      CHECK (status IN ('ACTIVE', 'INACTIVE')),
    created_at        TIMESTAMP NOT NULL DEFAULT NOW(),
    updated_at        TIMESTAMP NOT NULL DEFAULT NOW()
);

CREATE TABLE app_user (
    id            BIGSERIAL PRIMARY KEY,
    public_id     UUID NOT NULL DEFAULT gen_random_uuid() UNIQUE,
    email         TEXT NOT NULL UNIQUE,
    password_hash TEXT,
    name          TEXT NOT NULL,
    phone         TEXT,
    status        TEXT NOT NULL DEFAULT 'ACTIVE'
                  CHECK (status IN ('ACTIVE', 'INACTIVE', 'INVITED')),
    last_login_at TIMESTAMP,
    created_at    TIMESTAMP NOT NULL DEFAULT NOW(),
    updated_at    TIMESTAMP NOT NULL DEFAULT NOW()
);

CREATE TABLE organization_member (
    id              BIGSERIAL PRIMARY KEY,
    organization_id BIGINT NOT NULL REFERENCES organization(id) ON DELETE RESTRICT,
    user_id         BIGINT NOT NULL REFERENCES app_user(id) ON DELETE RESTRICT,
    member_role     TEXT NOT NULL CHECK (member_role IN ('OWNER', 'ADMIN', 'OPERATOR', 'VIEWER')),
    status          TEXT NOT NULL DEFAULT 'ACTIVE' CHECK (status IN ('ACTIVE', 'INACTIVE')),
    joined_at       TIMESTAMP NOT NULL DEFAULT NOW(),
    UNIQUE (organization_id, user_id)
);

CREATE INDEX idx_organization_type ON organization(organization_type);
CREATE INDEX idx_organization_member_user ON organization_member(user_id);
