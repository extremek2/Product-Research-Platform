CREATE TABLE shipment_case (
    id                        BIGSERIAL PRIMARY KEY,
    public_id                 UUID NOT NULL DEFAULT gen_random_uuid() UNIQUE,
    owner_organization_id     BIGINT NOT NULL REFERENCES organization(id) ON DELETE RESTRICT,
    case_number               TEXT NOT NULL,
    direction                 TEXT NOT NULL CHECK (direction IN ('IMPORT', 'EXPORT')),
    transport_mode            TEXT NOT NULL CHECK (transport_mode IN ('SEA', 'AIR', 'ROAD', 'RAIL', 'MULTIMODAL')),
    current_stage             TEXT NOT NULL DEFAULT 'PREPARATION' CHECK (current_stage IN (
        'PREPARATION', 'BOOKING', 'DEPARTED', 'IN_TRANSIT',
        'ARRIVED', 'CUSTOMS', 'DELIVERY', 'COMPLETED'
    )),
    status                    TEXT NOT NULL DEFAULT 'OPEN'
                              CHECK (status IN ('OPEN', 'ON_HOLD', 'COMPLETED', 'CANCELLED', 'ARCHIVED')),
    priority                  TEXT NOT NULL DEFAULT 'NORMAL'
                              CHECK (priority IN ('NORMAL', 'ATTENTION', 'URGENT')),
    shipper_reference         TEXT,
    purchase_order_number     TEXT,
    carrier_name              TEXT,
    vessel_name               TEXT,
    voyage_number             TEXT,
    flight_number             TEXT,
    origin_location_code      TEXT,
    origin_location_name      TEXT,
    destination_location_code TEXT,
    destination_location_name TEXT,
    etd                       TIMESTAMP,
    atd                       TIMESTAMP,
    eta                       TIMESTAMP,
    ata                       TIMESTAMP,
    cargo_description         TEXT,
    package_count             INTEGER CHECK (package_count IS NULL OR package_count >= 0),
    gross_weight              NUMERIC CHECK (gross_weight IS NULL OR gross_weight >= 0),
    weight_unit               TEXT,
    container_count           INTEGER CHECK (container_count IS NULL OR container_count >= 0),
    created_by                BIGINT NOT NULL REFERENCES app_user(id) ON DELETE RESTRICT,
    archived_at               TIMESTAMP,
    created_at                TIMESTAMP NOT NULL DEFAULT NOW(),
    updated_at                TIMESTAMP NOT NULL DEFAULT NOW(),
    version                   BIGINT NOT NULL DEFAULT 0,
    UNIQUE (owner_organization_id, case_number)
);

CREATE TABLE transport_document (
    id               BIGSERIAL PRIMARY KEY,
    public_id        UUID NOT NULL DEFAULT gen_random_uuid() UNIQUE,
    shipment_case_id BIGINT NOT NULL REFERENCES shipment_case(id) ON DELETE RESTRICT,
    document_type    TEXT NOT NULL CHECK (document_type IN ('MBL', 'HBL', 'MAWB', 'HAWB', 'BOOKING', 'OTHER')),
    document_number  TEXT NOT NULL,
    issuer_name      TEXT,
    issued_at        TIMESTAMP,
    is_primary       BOOLEAN NOT NULL DEFAULT FALSE,
    created_at       TIMESTAMP NOT NULL DEFAULT NOW(),
    updated_at       TIMESTAMP NOT NULL DEFAULT NOW(),
    UNIQUE (shipment_case_id, document_type, document_number)
);

CREATE INDEX idx_shipment_case_dashboard ON shipment_case(owner_organization_id, status, archived_at);
CREATE INDEX idx_shipment_case_priority ON shipment_case(owner_organization_id, priority, current_stage);
CREATE INDEX idx_shipment_case_eta ON shipment_case(eta);
CREATE INDEX idx_transport_document_number ON transport_document(document_number);
