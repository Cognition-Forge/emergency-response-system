\set ON_ERROR_STOP on

-- Deterministic identifiers for scenario entities
SELECT
    uuid_generate_v5('6ba7b810-9dad-11d1-80b4-00c04fd430c8'::uuid, 'scenario1-project')               AS scenario1_project_id,
    uuid_generate_v5('6ba7b810-9dad-11d1-80b4-00c04fd430c8'::uuid, 'scenario1-wbs-root')              AS scenario1_wbs_root_id,
    uuid_generate_v5('6ba7b810-9dad-11d1-80b4-00c04fd430c8'::uuid, 'scenario1-wbs-node')              AS scenario1_wbs_node_id,
    uuid_generate_v5('6ba7b810-9dad-11d1-80b4-00c04fd430c8'::uuid, 'scenario1-supplier-crestline')    AS scenario1_supplier_id,
    uuid_generate_v5('6ba7b810-9dad-11d1-80b4-00c04fd430c8'::uuid, 'scenario1-warehouse-coastal')     AS scenario1_warehouse_id,
    uuid_generate_v5('6ba7b810-9dad-11d1-80b4-00c04fd430c8'::uuid, 'scenario1-unit-ea')               AS scenario1_uom_id,
    uuid_generate_v5('6ba7b810-9dad-11d1-80b4-00c04fd430c8'::uuid, 'scenario1-commodity-shelter')     AS scenario1_commodity_id,
    uuid_generate_v5('6ba7b810-9dad-11d1-80b4-00c04fd430c8'::uuid, 'scenario1-mto')                   AS scenario1_mto_id,
    uuid_generate_v5('6ba7b810-9dad-11d1-80b4-00c04fd430c8'::uuid, 'scenario1-mto-line')              AS scenario1_mto_line_id,
    uuid_generate_v5('6ba7b810-9dad-11d1-80b4-00c04fd430c8'::uuid, 'scenario1-po')                    AS scenario1_po_id,
    uuid_generate_v5('6ba7b810-9dad-11d1-80b4-00c04fd430c8'::uuid, 'scenario1-po-line')               AS scenario1_po_line_id,
    uuid_generate_v5('6ba7b810-9dad-11d1-80b4-00c04fd430c8'::uuid, 'scenario1-scn')                   AS scenario1_scn_id,
    uuid_generate_v5('6ba7b810-9dad-11d1-80b4-00c04fd430c8'::uuid, 'scenario1-scn-package')           AS scenario1_scn_package_id,
    uuid_generate_v5('6ba7b810-9dad-11d1-80b4-00c04fd430c8'::uuid, 'scenario1-scn-line')              AS scenario1_scn_line_id,
    uuid_generate_v5('6ba7b810-9dad-11d1-80b4-00c04fd430c8'::uuid, 'scenario1-receipt')               AS scenario1_receipt_id,
    uuid_generate_v5('6ba7b810-9dad-11d1-80b4-00c04fd430c8'::uuid, 'scenario1-receipt-line')          AS scenario1_receipt_line_id,
    uuid_generate_v5('6ba7b810-9dad-11d1-80b4-00c04fd430c8'::uuid, 'scenario1-inventory')             AS scenario1_inventory_id,
    uuid_generate_v5('6ba7b810-9dad-11d1-80b4-00c04fd430c8'::uuid, 'scenario1-fmr')                   AS scenario1_fmr_id,
    uuid_generate_v5('6ba7b810-9dad-11d1-80b4-00c04fd430c8'::uuid, 'scenario1-fmr-line')              AS scenario1_fmr_line_id,
    uuid_generate_v5('6ba7b810-9dad-11d1-80b4-00c04fd430c8'::uuid, 'scenario1-incident')              AS scenario1_incident_id,
    uuid_generate_v5('6ba7b810-9dad-11d1-80b4-00c04fd430c8'::uuid, 'scenario1-accommodation')         AS scenario1_accommodation_id
\gset

-- Remove any previous run for this scenario (cascades to child records)
DELETE FROM projects WHERE id = :'scenario1_project_id';

-- Minimal global reference data required by the scenario
INSERT INTO countries (code, name, alpha3_code)
VALUES ('AU', 'Australia', 'AUS')
ON CONFLICT (code) DO UPDATE SET name = EXCLUDED.name, alpha3_code = EXCLUDED.alpha3_code;

INSERT INTO incoterms (abbreviation, description)
VALUES ('DAP', 'Delivered At Place')
ON CONFLICT (abbreviation) DO UPDATE SET description = EXCLUDED.description;

-- Ensure demo users exist and capture their identifiers
INSERT INTO users (username, email, password_hash, first_name, last_name, organization, is_active)
VALUES ('planner', 'planner@demo.local', 'demo-hash', 'Casey', 'Planner', 'Emergency Demo', TRUE)
ON CONFLICT (email) DO UPDATE SET
    username = EXCLUDED.username,
    first_name = EXCLUDED.first_name,
    last_name = EXCLUDED.last_name,
    organization = EXCLUDED.organization,
    is_active = TRUE
RETURNING id AS planner_user_id
\gset

INSERT INTO users (username, email, password_hash, first_name, last_name, organization, is_active)
VALUES ('warehouse', 'warehouse@demo.local', 'demo-hash', 'Robin', 'Storey', 'Emergency Demo', TRUE)
ON CONFLICT (email) DO UPDATE SET
    username = EXCLUDED.username,
    first_name = EXCLUDED.first_name,
    last_name = EXCLUDED.last_name,
    organization = EXCLUDED.organization,
    is_active = TRUE
RETURNING id AS warehouse_user_id
\gset

INSERT INTO users (username, email, password_hash, first_name, last_name, organization, is_active)
VALUES ('incident', 'incident@demo.local', 'demo-hash', 'Alex', 'Commander', 'Emergency Demo', TRUE)
ON CONFLICT (email) DO UPDATE SET
    username = EXCLUDED.username,
    first_name = EXCLUDED.first_name,
    last_name = EXCLUDED.last_name,
    organization = EXCLUDED.organization,
    is_active = TRUE
RETURNING id AS incident_user_id
\gset

-- Project configuration
INSERT INTO projects (id, name, description, default_currency, include_gst, created_by)
VALUES (
    :'scenario1_project_id',
    'Scenario 1 - Coastal Relief',
    'Simple surge response with direct inventory match and no conflicts.',
    'AUD',
    FALSE,
    :'planner_user_id'
);

INSERT INTO project_users (project_id, user_id, access_level)
VALUES
    (:'scenario1_project_id', :'planner_user_id', 'admin'),
    (:'scenario1_project_id', :'warehouse_user_id', 'write'),
    (:'scenario1_project_id', :'incident_user_id', 'read');

-- Reference data scoped to the project
INSERT INTO units_of_measure (id, project_id, long_description, abbreviation, is_default)
VALUES (:'scenario1_uom_id', :'scenario1_project_id', 'Each', 'EA', TRUE);

INSERT INTO freight_packages (id, project_id, package_type)
VALUES (uuid_generate_v5('6ba7b810-9dad-11d1-80b4-00c04fd430c8'::uuid, 'scenario1-freight-pallet'), :'scenario1_project_id', 'Pallet');

INSERT INTO document_types (id, project_id, type_name)
VALUES (uuid_generate_v5('6ba7b810-9dad-11d1-80b4-00c04fd430c8'::uuid, 'scenario1-doc-docket'), :'scenario1_project_id', 'Delivery Docket');

INSERT INTO wbs (id, project_id, code, name, parent_id, level, sort_order, path)
VALUES
    (:'scenario1_wbs_root_id', :'scenario1_project_id', 'SC1', 'Scenario 1 Root', NULL, 0, 1, 'SC1'),
    (:'scenario1_wbs_node_id', :'scenario1_project_id', 'SC1.1', 'Temporary Shelters', :'scenario1_wbs_root_id', 1, 10, 'SC1>SC1.1');

INSERT INTO wbs_ros_dates (wbs_id, ros_date)
VALUES (:'scenario1_wbs_node_id', DATE '2024-05-12');

-- Supply chain master data
INSERT INTO suppliers (id, project_id, supplier_code, name, contact_name, contact_email, country_code, incoterm)
VALUES (
    :'scenario1_supplier_id',
    :'scenario1_project_id',
    'SUP-CREST',
    'Crestline Manufacturing',
    'Taylor Reed',
    'taylor.reed@crestline.example',
    'AU',
    'DAP'
);

INSERT INTO warehouses (id, project_id, name, warehouse_code, description, city, country_code, is_active)
VALUES (
    :'scenario1_warehouse_id',
    :'scenario1_project_id',
    'Coastal Relief Depot',
    'WH-COAST',
    'Primary staging warehouse for coastal deployments.',
    'Newcastle',
    'AU',
    TRUE
);

INSERT INTO commodity_codes (id, project_id, engineered_code, short_description, long_description, commodity_class, unit_of_measure_id)
VALUES (
    :'scenario1_commodity_id',
    :'scenario1_project_id',
    'COM-EMERG-SHELTER',
    'Emergency Shelter Kit',
    'Rapid-deploy shelter kit including frame, canopy, and anchoring hardware.',
    'Shelters',
    :'scenario1_uom_id'
);

-- Planning artefacts
INSERT INTO mtos (id, project_id, mto_number, title, revision, status, issued_date, created_by)
VALUES (
    :'scenario1_mto_id',
    :'scenario1_project_id',
    'MTO-SC1-001',
    'Shelter deployment requirements',
    'A',
    'issued',
    DATE '2024-04-25',
    :'planner_user_id'
);

INSERT INTO mto_line_items (id, mto_id, line_number, commodity_code_id, description, quantity, unit_of_measure_id, wbs_id)
VALUES (
    :'scenario1_mto_line_id',
    :'scenario1_mto_id',
    '10',
    :'scenario1_commodity_id',
    'Emergency Shelter Kit',
    20,
    :'scenario1_uom_id',
    :'scenario1_wbs_node_id'
);

-- Procurement
INSERT INTO purchase_orders (id, project_id, po_number, supplier_id, mto_id, status, currency, order_date, expected_delivery_date, total_value, created_by)
VALUES (
    :'scenario1_po_id',
    :'scenario1_project_id',
    'SC1-PO-1001',
    :'scenario1_supplier_id',
    :'scenario1_mto_id',
    'open',
    'AUD',
    DATE '2024-04-26',
    DATE '2024-05-05',
    125000,
    :'planner_user_id'
);

INSERT INTO po_line_items (id, po_id, line_number, commodity_code_id, description, quantity_ordered, unit_price, line_value, contractual_delivery_date, forecast_delivery_date, wbs_id, line_type)
VALUES (
    :'scenario1_po_line_id',
    :'scenario1_po_id',
    '10',
    :'scenario1_commodity_id',
    'Emergency Shelter Kit',
    20,
    6250,
    125000,
    DATE '2024-05-05',
    DATE '2024-05-05',
    :'scenario1_wbs_node_id',
    'standard'
);

-- Logistics and receipts
INSERT INTO scns (id, project_id, scn_number, description, collection_supplier_id, delivery_warehouse_id, forecast_collection_date, forecast_delivery_date, actual_collection_date, actual_delivery_date, status, created_by)
VALUES (
    :'scenario1_scn_id',
    :'scenario1_project_id',
    'SCN-SC1-01',
    'Shelter Kits - Coastal Relief',
    :'scenario1_supplier_id',
    :'scenario1_warehouse_id',
    DATE '2024-05-02',
    DATE '2024-05-04',
    DATE '2024-05-02',
    DATE '2024-05-04',
    'delivered',
    :'planner_user_id'
);

INSERT INTO scn_packages (id, scn_id, package_number, freight_package_id, gross_weight, net_weight, dimensions)
VALUES (
    :'scenario1_scn_package_id',
    :'scenario1_scn_id',
    'PKG-001',
    uuid_generate_v5('6ba7b810-9dad-11d1-80b4-00c04fd430c8'::uuid, 'scenario1-freight-pallet'),
    1800,
    1600,
    '2.4m x 1.2m x 1.2m'
);

INSERT INTO scn_line_items (id, scn_id, package_id, po_line_item_id, quantity)
VALUES (
    :'scenario1_scn_line_id',
    :'scenario1_scn_id',
    :'scenario1_scn_package_id',
    :'scenario1_po_line_id',
    20
);

INSERT INTO receipts (id, project_id, receipt_number, warehouse_id, scn_id, receipt_date, status, inspected_by)
VALUES (
    :'scenario1_receipt_id',
    :'scenario1_project_id',
    'RCPT-SC1-01',
    :'scenario1_warehouse_id',
    :'scenario1_scn_id',
    DATE '2024-05-04',
    'completed',
    :'warehouse_user_id'
);

INSERT INTO receipt_line_items (id, receipt_id, scn_line_item_id, po_line_item_id, quantity_received, quantity_accepted, quantity_rejected, inspection_notes)
VALUES (
    :'scenario1_receipt_line_id',
    :'scenario1_receipt_id',
    :'scenario1_scn_line_id',
    :'scenario1_po_line_id',
    20,
    20,
    0,
    'Inspection passed; no issues.'
);

-- Inventory position
INSERT INTO warehouse_inventory (id, project_id, warehouse_id, commodity_code_id, wbs_id, quantity_available, quantity_reserved, quantity_hard_reserved, safety_stock_level, status, last_receipt_id)
VALUES (
    :'scenario1_inventory_id',
    :'scenario1_project_id',
    :'scenario1_warehouse_id',
    :'scenario1_commodity_id',
    :'scenario1_wbs_node_id',
    20,
    0,
    0,
    2,
    'available',
    :'scenario1_receipt_id'
);

INSERT INTO inventory_movements (id, inventory_id, movement_type, quantity, reference_type, reference_id, notes)
VALUES (
    uuid_generate_v5('6ba7b810-9dad-11d1-80b4-00c04fd430c8'::uuid, 'scenario1-move-receipt'),
    :'scenario1_inventory_id',
    'receipt',
    20,
    'receipt',
    :'scenario1_receipt_id',
    'Initial receipt from SCN-SC1-01.'
);

-- Field material request and issue
INSERT INTO fmrs (id, project_id, fmr_number, warehouse_id, requested_by, status, requested_date, finalized_at, updated_at)
VALUES (
    :'scenario1_fmr_id',
    :'scenario1_project_id',
    'FMR-SC1-01',
    :'scenario1_warehouse_id',
    :'incident_user_id',
    'finalized',
    DATE '2024-05-06',
    TIMESTAMP WITH TIME ZONE '2024-05-06 09:15+00',
    TIMESTAMP WITH TIME ZONE '2024-05-06 09:15+00'
);

INSERT INTO fmr_line_items (id, fmr_id, inventory_id, commodity_code_id, quantity_requested, quantity_issued, required_date, wbs_id, notes)
VALUES (
    :'scenario1_fmr_line_id',
    :'scenario1_fmr_id',
    :'scenario1_inventory_id',
    :'scenario1_commodity_id',
    5,
    5,
    DATE '2024-05-06',
    :'scenario1_wbs_node_id',
    'Issued to coastal relief team.'
);

INSERT INTO materials_issued (id, fmr_id, line_item_id, inventory_id, quantity_issued, issued_at, issued_by)
VALUES (
    uuid_generate_v5('6ba7b810-9dad-11d1-80b4-00c04fd430c8'::uuid, 'scenario1-material-issue'),
    :'scenario1_fmr_id',
    :'scenario1_fmr_line_id',
    :'scenario1_inventory_id',
    5,
    TIMESTAMP WITH TIME ZONE '2024-05-06 09:30+00',
    :'warehouse_user_id'
);

-- Emergency accommodation storyline
INSERT INTO emergency_incidents (id, project_id, scn_id, incident_type, incident_date, reported_by, description, status, resolution_notes)
VALUES (
    :'scenario1_incident_id',
    :'scenario1_project_id',
    :'scenario1_scn_id',
    'storm_response',
    TIMESTAMP WITH TIME ZONE '2024-05-06 08:00+00',
    :'incident_user_id',
    'Storm surge displaced residents along the coastal precinct.',
    'resolved',
    'Shelter kits dispatched and residents accommodated within planned ROS window.'
);

INSERT INTO emergency_accommodations (id, incident_id, original_line_item_id, source_warehouse_id, source_inventory_id, quantity_allocated, availability_score, compatibility_score, impact_level, executed_at, created_at)
VALUES (
    :'scenario1_accommodation_id',
    :'scenario1_incident_id',
    :'scenario1_po_line_id',
    :'scenario1_warehouse_id',
    :'scenario1_inventory_id',
    5,
    95,
    100,
    'no_impact',
    TIMESTAMP WITH TIME ZONE '2024-05-06 09:20+00',
    TIMESTAMP WITH TIME ZONE '2024-05-06 09:20+00'
);

-- Quick verification hooks (left commented for operators)
-- SELECT * FROM fn_emergency_inventory_search(:'scenario1_po_line_id');

