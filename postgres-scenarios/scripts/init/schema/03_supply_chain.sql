SET search_path TO public;

CREATE TABLE IF NOT EXISTS suppliers (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    project_id UUID NOT NULL REFERENCES projects(id) ON DELETE CASCADE,
    supplier_code VARCHAR(100) NOT NULL,
    name VARCHAR(255) NOT NULL,
    contact_name VARCHAR(255),
    contact_email VARCHAR(255),
    contact_phone VARCHAR(50),
    address_line1 VARCHAR(255),
    address_line2 VARCHAR(255),
    city VARCHAR(100),
    state_id UUID REFERENCES states(id),
    country_code VARCHAR(2) REFERENCES countries(code),
    postal_code VARCHAR(20),
    incoterm VARCHAR(3) REFERENCES incoterms(abbreviation),
    created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW(),
    UNIQUE(project_id, supplier_code)
);

CREATE TABLE IF NOT EXISTS warehouses (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    project_id UUID NOT NULL REFERENCES projects(id) ON DELETE CASCADE,
    name VARCHAR(255) NOT NULL,
    warehouse_code VARCHAR(100) NOT NULL,
    description TEXT,
    address_line1 VARCHAR(255),
    address_line2 VARCHAR(255),
    city VARCHAR(100),
    state_id UUID REFERENCES states(id),
    country_code VARCHAR(2) REFERENCES countries(code),
    postal_code VARCHAR(20),
    latitude NUMERIC(10,7),
    longitude NUMERIC(10,7),
    is_active BOOLEAN NOT NULL DEFAULT TRUE,
    created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW(),
    UNIQUE(project_id, warehouse_code)
);

CREATE TABLE IF NOT EXISTS commodity_codes (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    project_id UUID NOT NULL REFERENCES projects(id) ON DELETE CASCADE,
    engineered_code VARCHAR(255) NOT NULL,
    short_description VARCHAR(500) NOT NULL,
    long_description TEXT,
    commodity_class VARCHAR(255),
    unit_of_measure_id UUID REFERENCES units_of_measure(id),
    datasheet_specification TEXT,
    created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW(),
    UNIQUE(project_id, engineered_code)
);

CREATE TABLE IF NOT EXISTS equipment_list (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    project_id UUID NOT NULL REFERENCES projects(id) ON DELETE CASCADE,
    engineered_tag VARCHAR(255) NOT NULL,
    equipment_type VARCHAR(255),
    description TEXT,
    manufacturer VARCHAR(255),
    model_number VARCHAR(255),
    serial_number VARCHAR(255),
    unit_of_measure_id UUID REFERENCES units_of_measure(id),
    created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW(),
    UNIQUE(project_id, engineered_tag)
);

CREATE TABLE IF NOT EXISTS mtos (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    project_id UUID NOT NULL REFERENCES projects(id) ON DELETE CASCADE,
    mto_number VARCHAR(100) NOT NULL,
    title VARCHAR(255),
    revision VARCHAR(20),
    status VARCHAR(20) NOT NULL DEFAULT 'draft',
    issued_date DATE,
    created_by UUID REFERENCES users(id),
    created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW(),
    UNIQUE(project_id, mto_number, revision)
);

CREATE TABLE IF NOT EXISTS mto_line_items (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    mto_id UUID NOT NULL REFERENCES mtos(id) ON DELETE CASCADE,
    line_number VARCHAR(50) NOT NULL,
    commodity_code_id UUID REFERENCES commodity_codes(id),
    equipment_id UUID REFERENCES equipment_list(id),
    description TEXT,
    quantity NUMERIC(18,4) NOT NULL,
    unit_of_measure_id UUID REFERENCES units_of_measure(id),
    wbs_id UUID REFERENCES wbs(id),
    notes TEXT,
    created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW(),
    UNIQUE(mto_id, line_number)
);

CREATE TABLE IF NOT EXISTS purchase_orders (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    project_id UUID NOT NULL REFERENCES projects(id) ON DELETE CASCADE,
    po_number VARCHAR(100) NOT NULL,
    supplier_id UUID REFERENCES suppliers(id),
    mto_id UUID REFERENCES mtos(id),
    status VARCHAR(30) NOT NULL DEFAULT 'draft',
    currency VARCHAR(3) NOT NULL DEFAULT 'USD',
    order_date DATE,
    expected_delivery_date DATE,
    total_value NUMERIC(18,2),
    created_by UUID REFERENCES users(id),
    created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW(),
    UNIQUE(project_id, po_number)
);

CREATE TABLE IF NOT EXISTS po_line_items (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    po_id UUID NOT NULL REFERENCES purchase_orders(id) ON DELETE CASCADE,
    line_number VARCHAR(50) NOT NULL,
    commodity_code_id UUID REFERENCES commodity_codes(id),
    equipment_id UUID REFERENCES equipment_list(id),
    description TEXT,
    quantity_ordered NUMERIC(18,4) NOT NULL,
    unit_price NUMERIC(18,4),
    line_value NUMERIC(18,2),
    contractual_delivery_date DATE,
    forecast_delivery_date DATE,
    wbs_id UUID REFERENCES wbs(id),
    parent_line_id UUID REFERENCES po_line_items(id) ON DELETE SET NULL,
    line_type VARCHAR(30) NOT NULL DEFAULT 'standard',
    scn_number VARCHAR(100),
    quantity_shipped NUMERIC(18,4) NOT NULL DEFAULT 0,
    quantity_received NUMERIC(18,4) NOT NULL DEFAULT 0,
    created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW(),
    UNIQUE(po_id, line_number)
);

CREATE TABLE IF NOT EXISTS po_line_item_companions (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    line_item_id UUID NOT NULL REFERENCES po_line_items(id) ON DELETE CASCADE,
    companion_line_item_id UUID NOT NULL REFERENCES po_line_items(id) ON DELETE CASCADE,
    UNIQUE(line_item_id, companion_line_item_id)
);

CREATE TABLE IF NOT EXISTS po_line_item_notes (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    line_item_id UUID NOT NULL REFERENCES po_line_items(id) ON DELETE CASCADE,
    note TEXT NOT NULL,
    created_by UUID REFERENCES users(id),
    created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS po_status_history (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    po_id UUID NOT NULL REFERENCES purchase_orders(id) ON DELETE CASCADE,
    old_status VARCHAR(30),
    new_status VARCHAR(30) NOT NULL,
    changed_by UUID REFERENCES users(id),
    changed_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS scns (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    project_id UUID NOT NULL REFERENCES projects(id) ON DELETE CASCADE,
    scn_number VARCHAR(100) NOT NULL,
    description TEXT,
    collection_supplier_id UUID REFERENCES suppliers(id),
    delivery_warehouse_id UUID REFERENCES warehouses(id),
    forecast_collection_date DATE,
    forecast_delivery_date DATE,
    actual_collection_date DATE,
    actual_delivery_date DATE,
    status VARCHAR(30) NOT NULL DEFAULT 'draft',
    created_by UUID REFERENCES users(id),
    created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW(),
    UNIQUE(project_id, scn_number)
);

CREATE TABLE IF NOT EXISTS scn_packages (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    scn_id UUID NOT NULL REFERENCES scns(id) ON DELETE CASCADE,
    package_number VARCHAR(100) NOT NULL,
    freight_package_id UUID REFERENCES freight_packages(id),
    gross_weight NUMERIC(18,4),
    net_weight NUMERIC(18,4),
    dimensions TEXT,
    created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW(),
    UNIQUE(scn_id, package_number)
);

CREATE TABLE IF NOT EXISTS scn_line_items (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    scn_id UUID NOT NULL REFERENCES scns(id) ON DELETE CASCADE,
    package_id UUID REFERENCES scn_packages(id) ON DELETE SET NULL,
    po_line_item_id UUID REFERENCES po_line_items(id) ON DELETE SET NULL,
    quantity NUMERIC(18,4) NOT NULL,
    created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS receipts (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    project_id UUID NOT NULL REFERENCES projects(id) ON DELETE CASCADE,
    receipt_number VARCHAR(100) NOT NULL,
    warehouse_id UUID NOT NULL REFERENCES warehouses(id),
    scn_id UUID REFERENCES scns(id),
    receipt_date DATE NOT NULL,
    status VARCHAR(30) NOT NULL DEFAULT 'draft',
    inspected_by UUID REFERENCES users(id),
    created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW(),
    UNIQUE(project_id, receipt_number)
);

CREATE TABLE IF NOT EXISTS receipt_line_items (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    receipt_id UUID NOT NULL REFERENCES receipts(id) ON DELETE CASCADE,
    scn_line_item_id UUID REFERENCES scn_line_items(id) ON DELETE SET NULL,
    po_line_item_id UUID REFERENCES po_line_items(id) ON DELETE SET NULL,
    quantity_received NUMERIC(18,4) NOT NULL,
    quantity_accepted NUMERIC(18,4),
    quantity_rejected NUMERIC(18,4),
    inspection_notes TEXT,
    created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS warehouse_inventory (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    project_id UUID NOT NULL REFERENCES projects(id) ON DELETE CASCADE,
    warehouse_id UUID NOT NULL REFERENCES warehouses(id) ON DELETE CASCADE,
    commodity_code_id UUID REFERENCES commodity_codes(id),
    equipment_id UUID REFERENCES equipment_list(id),
    wbs_id UUID REFERENCES wbs(id),
    quantity_available NUMERIC(18,4) NOT NULL DEFAULT 0,
    quantity_reserved NUMERIC(18,4) NOT NULL DEFAULT 0,
    quantity_hard_reserved NUMERIC(18,4) NOT NULL DEFAULT 0,
    safety_stock_level NUMERIC(18,4) NOT NULL DEFAULT 0,
    status VARCHAR(20) NOT NULL DEFAULT 'available',
    last_receipt_id UUID REFERENCES receipts(id),
    created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS inventory_movements (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    inventory_id UUID NOT NULL REFERENCES warehouse_inventory(id) ON DELETE CASCADE,
    movement_type VARCHAR(30) NOT NULL,
    quantity NUMERIC(18,4) NOT NULL,
    reference_type VARCHAR(30),
    reference_id UUID,
    notes TEXT,
    created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS fmrs (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    project_id UUID NOT NULL REFERENCES projects(id) ON DELETE CASCADE,
    fmr_number VARCHAR(100) NOT NULL,
    warehouse_id UUID NOT NULL REFERENCES warehouses(id),
    requested_by UUID REFERENCES users(id),
    status VARCHAR(30) NOT NULL DEFAULT 'draft',
    requested_date DATE NOT NULL,
    finalized_at TIMESTAMP WITH TIME ZONE,
    created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW(),
    UNIQUE(project_id, fmr_number)
);

CREATE TABLE IF NOT EXISTS fmr_line_items (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    fmr_id UUID NOT NULL REFERENCES fmrs(id) ON DELETE CASCADE,
    inventory_id UUID REFERENCES warehouse_inventory(id),
    commodity_code_id UUID REFERENCES commodity_codes(id),
    equipment_id UUID REFERENCES equipment_list(id),
    quantity_requested NUMERIC(18,4) NOT NULL,
    quantity_issued NUMERIC(18,4) NOT NULL DEFAULT 0,
    required_date DATE,
    wbs_id UUID REFERENCES wbs(id),
    notes TEXT,
    created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS inventory_reservations (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    inventory_id UUID NOT NULL REFERENCES warehouse_inventory(id) ON DELETE CASCADE,
    reservation_type VARCHAR(30) NOT NULL,
    reserved_quantity NUMERIC(18,4) NOT NULL,
    reserved_for_entity_type VARCHAR(30),
    reserved_for_entity_id UUID,
    reservation_date TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW(),
    required_by_date DATE,
    priority_level INTEGER NOT NULL DEFAULT 50,
    can_reassign BOOLEAN NOT NULL DEFAULT FALSE,
    created_by UUID REFERENCES users(id),
    created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS materials_issued (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    fmr_id UUID NOT NULL REFERENCES fmrs(id) ON DELETE CASCADE,
    line_item_id UUID REFERENCES fmr_line_items(id) ON DELETE SET NULL,
    inventory_id UUID REFERENCES warehouse_inventory(id),
    quantity_issued NUMERIC(18,4) NOT NULL,
    issued_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW(),
    issued_by UUID REFERENCES users(id)
);
