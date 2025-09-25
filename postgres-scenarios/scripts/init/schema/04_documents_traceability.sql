SET search_path TO public;

CREATE TABLE IF NOT EXISTS documents (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    project_id UUID NOT NULL REFERENCES projects(id) ON DELETE CASCADE,
    filename VARCHAR(500) NOT NULL,
    original_filename VARCHAR(500) NOT NULL,
    file_size BIGINT,
    mime_type VARCHAR(255),
    file_path VARCHAR(1000),
    document_type_id UUID REFERENCES document_types(id),
    description TEXT,
    is_visible BOOLEAN NOT NULL DEFAULT TRUE,
    uploaded_by UUID REFERENCES users(id),
    uploaded_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS document_associations (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    document_id UUID NOT NULL REFERENCES documents(id) ON DELETE CASCADE,
    entity_type VARCHAR(50) NOT NULL,
    entity_id UUID NOT NULL,
    line_item_id UUID,
    created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS traceability_certificates (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    project_id UUID NOT NULL REFERENCES projects(id) ON DELETE CASCADE,
    certificate_number VARCHAR(255) NOT NULL,
    batch_heat_number VARCHAR(255) NOT NULL,
    document_id UUID REFERENCES documents(id) ON DELETE SET NULL,
    document_type_id UUID REFERENCES document_types(id),
    is_approved BOOLEAN NOT NULL DEFAULT FALSE,
    approved_by UUID REFERENCES users(id),
    approved_at TIMESTAMP WITH TIME ZONE,
    po_id UUID REFERENCES purchase_orders(id),
    supplier_id UUID REFERENCES suppliers(id),
    scn_id UUID REFERENCES scns(id),
    receipt_id UUID REFERENCES receipts(id),
    warehouse_id UUID REFERENCES warehouses(id),
    created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW(),
    UNIQUE(project_id, certificate_number, batch_heat_number)
);

CREATE TABLE IF NOT EXISTS certificate_materials (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    certificate_id UUID NOT NULL REFERENCES traceability_certificates(id) ON DELETE CASCADE,
    commodity_code_id UUID REFERENCES commodity_codes(id),
    equipment_id UUID REFERENCES equipment_list(id),
    wbs_id UUID REFERENCES wbs(id),
    quantity NUMERIC(18,4),
    created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW(),
    CONSTRAINT chk_certificate_material_type CHECK (
        (commodity_code_id IS NOT NULL AND equipment_id IS NULL)
        OR (commodity_code_id IS NULL AND equipment_id IS NOT NULL)
    )
);

CREATE TABLE IF NOT EXISTS emergency_incidents (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    project_id UUID NOT NULL REFERENCES projects(id) ON DELETE CASCADE,
    scn_id UUID REFERENCES scns(id),
    incident_type VARCHAR(50) NOT NULL,
    incident_date TIMESTAMP WITH TIME ZONE NOT NULL,
    reported_by UUID REFERENCES users(id),
    description TEXT,
    status VARCHAR(20) NOT NULL DEFAULT 'reported',
    resolution_notes TEXT,
    created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS emergency_accommodations (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    incident_id UUID NOT NULL REFERENCES emergency_incidents(id) ON DELETE CASCADE,
    original_line_item_id UUID REFERENCES po_line_items(id),
    source_warehouse_id UUID REFERENCES warehouses(id),
    source_inventory_id UUID REFERENCES warehouse_inventory(id),
    quantity_allocated NUMERIC(18,4) NOT NULL,
    availability_score INTEGER,
    compatibility_score INTEGER,
    impact_level VARCHAR(20) NOT NULL DEFAULT 'no_impact',
    displaced_commitment_id UUID REFERENCES inventory_reservations(id),
    approved_by UUID REFERENCES users(id),
    approved_at TIMESTAMP WITH TIME ZONE,
    executed_at TIMESTAMP WITH TIME ZONE,
    created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS commitment_impacts (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    original_reservation_id UUID REFERENCES inventory_reservations(id),
    impacted_entity_type VARCHAR(20),
    impacted_entity_id UUID,
    impact_severity VARCHAR(20),
    impact_description TEXT,
    alternative_suggested BOOLEAN NOT NULL DEFAULT FALSE,
    mitigation_cost NUMERIC(18,2),
    created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS search_audit_log (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    project_id UUID NOT NULL REFERENCES projects(id) ON DELETE CASCADE,
    user_id UUID REFERENCES users(id),
    search_type VARCHAR(50) NOT NULL,
    parameters JSONB,
    results_count INTEGER,
    executed_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW()
);
