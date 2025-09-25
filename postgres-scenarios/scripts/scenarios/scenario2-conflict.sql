\set ON_ERROR_STOP on

SELECT
    uuid_generate_v5('6ba7b810-9dad-11d1-80b4-00c04fd430c8'::uuid, 'scenario2-project')                 AS scenario2_project_id,
    uuid_generate_v5('6ba7b810-9dad-11d1-80b4-00c04fd430c8'::uuid, 'scenario2-wbs-root')                AS scenario2_wbs_root_id,
    uuid_generate_v5('6ba7b810-9dad-11d1-80b4-00c04fd430c8'::uuid, 'scenario2-wbs-node-critical')       AS scenario2_wbs_primary_id,
    uuid_generate_v5('6ba7b810-9dad-11d1-80b4-00c04fd430c8'::uuid, 'scenario2-wbs-node-backlog')        AS scenario2_wbs_backlog_id,
    uuid_generate_v5('6ba7b810-9dad-11d1-80b4-00c04fd430c8'::uuid, 'scenario2-supplier-northwind')      AS scenario2_supplier_id,
    uuid_generate_v5('6ba7b810-9dad-11d1-80b4-00c04fd430c8'::uuid, 'scenario2-warehouse-regional')      AS scenario2_warehouse_id,
    uuid_generate_v5('6ba7b810-9dad-11d1-80b4-00c04fd430c8'::uuid, 'scenario2-unit-case')               AS scenario2_uom_id,
    uuid_generate_v5('6ba7b810-9dad-11d1-80b4-00c04fd430c8'::uuid, 'scenario2-commodity-mattress')      AS scenario2_commodity_id,
    uuid_generate_v5('6ba7b810-9dad-11d1-80b4-00c04fd430c8'::uuid, 'scenario2-mto')                     AS scenario2_mto_id,
    uuid_generate_v5('6ba7b810-9dad-11d1-80b4-00c04fd430c8'::uuid, 'scenario2-mto-line')                AS scenario2_mto_line_id,
    uuid_generate_v5('6ba7b810-9dad-11d1-80b4-00c04fd430c8'::uuid, 'scenario2-po')                      AS scenario2_po_id,
    uuid_generate_v5('6ba7b810-9dad-11d1-80b4-00c04fd430c8'::uuid, 'scenario2-po-line')                 AS scenario2_po_line_id,
    uuid_generate_v5('6ba7b810-9dad-11d1-80b4-00c04fd430c8'::uuid, 'scenario2-scn')                     AS scenario2_scn_id,
    uuid_generate_v5('6ba7b810-9dad-11d1-80b4-00c04fd430c8'::uuid, 'scenario2-scn-package')             AS scenario2_scn_package_id,
    uuid_generate_v5('6ba7b810-9dad-11d1-80b4-00c04fd430c8'::uuid, 'scenario2-scn-line')                AS scenario2_scn_line_id,
    uuid_generate_v5('6ba7b810-9dad-11d1-80b4-00c04fd430c8'::uuid, 'scenario2-receipt')                 AS scenario2_receipt_id,
    uuid_generate_v5('6ba7b810-9dad-11d1-80b4-00c04fd430c8'::uuid, 'scenario2-receipt-line')            AS scenario2_receipt_line_id,
    uuid_generate_v5('6ba7b810-9dad-11d1-80b4-00c04fd430c8'::uuid, 'scenario2-inventory-primary')       AS scenario2_inventory_primary_id,
    uuid_generate_v5('6ba7b810-9dad-11d1-80b4-00c04fd430c8'::uuid, 'scenario2-inventory-backlog')       AS scenario2_inventory_backlog_id,
    uuid_generate_v5('6ba7b810-9dad-11d1-80b4-00c04fd430c8'::uuid, 'scenario2-reservation-draft')       AS scenario2_reservation_id,
    uuid_generate_v5('6ba7b810-9dad-11d1-80b4-00c04fd430c8'::uuid, 'scenario2-reservation-hold')        AS scenario2_reservation_hold_id,
    uuid_generate_v5('6ba7b810-9dad-11d1-80b4-00c04fd430c8'::uuid, 'scenario2-fmr-planned')             AS scenario2_fmr_id,
    uuid_generate_v5('6ba7b810-9dad-11d1-80b4-00c04fd430c8'::uuid, 'scenario2-fmr-line')                AS scenario2_fmr_line_id,
    uuid_generate_v5('6ba7b810-9dad-11d1-80b4-00c04fd430c8'::uuid, 'scenario2-incident')                AS scenario2_incident_id,
    uuid_generate_v5('6ba7b810-9dad-11d1-80b4-00c04fd430c8'::uuid, 'scenario2-accommodation')           AS scenario2_accommodation_id
\gset

DELETE FROM projects WHERE id = :'scenario2_project_id';

INSERT INTO countries (code, name, alpha3_code)
VALUES ('AU', 'Australia', 'AUS')
ON CONFLICT (code) DO UPDATE SET name = EXCLUDED.name, alpha3_code = EXCLUDED.alpha3_code;

INSERT INTO incoterms (abbreviation, description)
VALUES ('FOB', 'Free On Board')
ON CONFLICT (abbreviation) DO UPDATE SET description = EXCLUDED.description;

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

INSERT INTO projects (id, name, description, default_currency, include_gst, created_by)
VALUES (
    :'scenario2_project_id',
    'Scenario 2 - Regional Reassignment',
    'Inventory held against medium-priority reservations that can be reassigned to urgent incidents.',
    'AUD',
    FALSE,
    :'planner_user_id'
);

INSERT INTO project_users (project_id, user_id, access_level)
VALUES
    (:'scenario2_project_id', :'planner_user_id', 'admin'),
    (:'scenario2_project_id', :'warehouse_user_id', 'write'),
    (:'scenario2_project_id', :'incident_user_id', 'read');

INSERT INTO units_of_measure (id, project_id, long_description, abbreviation, is_default)
VALUES (:'scenario2_uom_id', :'scenario2_project_id', 'Case', 'CASE', TRUE);

INSERT INTO freight_packages (id, project_id, package_type)
VALUES (uuid_generate_v5('6ba7b810-9dad-11d1-80b4-00c04fd430c8'::uuid, 'scenario2-freight-crate'), :'scenario2_project_id', 'Crate');

INSERT INTO document_types (id, project_id, type_name)
VALUES (uuid_generate_v5('6ba7b810-9dad-11d1-80b4-00c04fd430c8'::uuid, 'scenario2-doc-inspection'), :'scenario2_project_id', 'Inspection Report');

INSERT INTO wbs (id, project_id, code, name, parent_id, level, sort_order, path)
VALUES
    (:'scenario2_wbs_root_id', :'scenario2_project_id', 'SC2', 'Scenario 2 Root', NULL, 0, 1, 'SC2'),
    (:'scenario2_wbs_primary_id', :'scenario2_project_id', 'SC2.1', 'Regional Shelter Program', :'scenario2_wbs_root_id', 1, 10, 'SC2>SC2.1'),
    (:'scenario2_wbs_backlog_id', :'scenario2_project_id', 'SC2.9', 'Deferred Projects Backlog', :'scenario2_wbs_root_id', 1, 90, 'SC2>SC2.9');

INSERT INTO wbs_ros_dates (wbs_id, ros_date)
VALUES
    (:'scenario2_wbs_primary_id', DATE '2024-06-01'),
    (:'scenario2_wbs_backlog_id', DATE '2024-08-15');

INSERT INTO suppliers (id, project_id, supplier_code, name, contact_name, contact_email, country_code, incoterm)
VALUES (
    :'scenario2_supplier_id',
    :'scenario2_project_id',
    'SUP-NORTH',
    'Northwind Logistics',
    'Morgan Hayes',
    'm.hayes@northwind.example',
    'AU',
    'FOB'
);

INSERT INTO warehouses (id, project_id, name, warehouse_code, description, city, country_code, is_active)
VALUES (
    :'scenario2_warehouse_id',
    :'scenario2_project_id',
    'Regional Readiness Hub',
    'WH-REGION',
    'Holds rotating stock for regional deployments.',
    'Dubbo',
    'AU',
    TRUE
);

INSERT INTO commodity_codes (id, project_id, engineered_code, short_description, long_description, commodity_class, unit_of_measure_id)
VALUES (
    :'scenario2_commodity_id',
    :'scenario2_project_id',
    'COM-SLEEP-KIT',
    'Emergency Bedding Kit',
    'Inflatable mattress, bedding rolls, and hygiene pack bundled per displaced family.',
    'Accommodation',
    :'scenario2_uom_id'
);

INSERT INTO mtos (id, project_id, mto_number, title, revision, status, issued_date, created_by)
VALUES (
    :'scenario2_mto_id',
    :'scenario2_project_id',
    'MTO-SC2-005',
    'Bedding stock requirements',
    'B',
    'issued',
    DATE '2024-04-12',
    :'planner_user_id'
);

INSERT INTO mto_line_items (id, mto_id, line_number, commodity_code_id, description, quantity, unit_of_measure_id, wbs_id)
VALUES (
    :'scenario2_mto_line_id',
    :'scenario2_mto_id',
    '20',
    :'scenario2_commodity_id',
    'Emergency Bedding Kit',
    60,
    :'scenario2_uom_id',
    :'scenario2_wbs_primary_id'
);

INSERT INTO purchase_orders (id, project_id, po_number, supplier_id, mto_id, status, currency, order_date, expected_delivery_date, total_value, created_by)
VALUES (
    :'scenario2_po_id',
    :'scenario2_project_id',
    'SC2-PO-2003',
    :'scenario2_supplier_id',
    :'scenario2_mto_id',
    'open',
    'AUD',
    DATE '2024-04-15',
    DATE '2024-05-10',
    90000,
    :'planner_user_id'
);

INSERT INTO po_line_items (id, po_id, line_number, commodity_code_id, description, quantity_ordered, unit_price, line_value, contractual_delivery_date, forecast_delivery_date, wbs_id, line_type)
VALUES (
    :'scenario2_po_line_id',
    :'scenario2_po_id',
    '20',
    :'scenario2_commodity_id',
    'Emergency Bedding Kit',
    60,
    1500,
    90000,
    DATE '2024-05-10',
    DATE '2024-05-12',
    :'scenario2_wbs_primary_id',
    'standard'
);

INSERT INTO scns (id, project_id, scn_number, description, collection_supplier_id, delivery_warehouse_id, forecast_collection_date, forecast_delivery_date, actual_collection_date, actual_delivery_date, status, created_by)
VALUES (
    :'scenario2_scn_id',
    :'scenario2_project_id',
    'SCN-SC2-02',
    'Bedding kits inbound for regional program',
    :'scenario2_supplier_id',
    :'scenario2_warehouse_id',
    DATE '2024-05-08',
    DATE '2024-05-12',
    DATE '2024-05-08',
    DATE '2024-05-11',
    'delivered',
    :'planner_user_id'
);

INSERT INTO scn_packages (id, scn_id, package_number, freight_package_id, gross_weight, net_weight, dimensions)
VALUES (
    :'scenario2_scn_package_id',
    :'scenario2_scn_id',
    'PKG-010',
    uuid_generate_v5('6ba7b810-9dad-11d1-80b4-00c04fd430c8'::uuid, 'scenario2-freight-crate'),
    2200,
    2000,
    '2.0m x 1.5m x 1.4m'
);

INSERT INTO scn_line_items (id, scn_id, package_id, po_line_item_id, quantity)
VALUES (
    :'scenario2_scn_line_id',
    :'scenario2_scn_id',
    :'scenario2_scn_package_id',
    :'scenario2_po_line_id',
    60
);

INSERT INTO receipts (id, project_id, receipt_number, warehouse_id, scn_id, receipt_date, status, inspected_by)
VALUES (
    :'scenario2_receipt_id',
    :'scenario2_project_id',
    'RCPT-SC2-02',
    :'scenario2_warehouse_id',
    :'scenario2_scn_id',
    DATE '2024-05-11',
    'completed',
    :'warehouse_user_id'
);

INSERT INTO receipt_line_items (id, receipt_id, scn_line_item_id, po_line_item_id, quantity_received, quantity_accepted, quantity_rejected, inspection_notes)
VALUES (
    :'scenario2_receipt_line_id',
    :'scenario2_receipt_id',
    :'scenario2_scn_line_id',
    :'scenario2_po_line_id',
    60,
    58,
    2,
    'Two kits flagged for rework; rest stored as available stock.'
);

INSERT INTO warehouse_inventory (id, project_id, warehouse_id, commodity_code_id, wbs_id, quantity_available, quantity_reserved, quantity_hard_reserved, safety_stock_level, status, last_receipt_id)
VALUES
    (
        :'scenario2_inventory_primary_id',
        :'scenario2_project_id',
        :'scenario2_warehouse_id',
        :'scenario2_commodity_id',
        :'scenario2_wbs_primary_id',
        22,
        18,
        12,
        10,
        'available',
        :'scenario2_receipt_id'
    ),
    (
        :'scenario2_inventory_backlog_id',
        :'scenario2_project_id',
        :'scenario2_warehouse_id',
        :'scenario2_commodity_id',
        :'scenario2_wbs_backlog_id',
        18,
        0,
        0,
        2,
        'available',
        :'scenario2_receipt_id'
    );

INSERT INTO inventory_movements (id, inventory_id, movement_type, quantity, reference_type, reference_id, notes)
VALUES
    (
        uuid_generate_v5('6ba7b810-9dad-11d1-80b4-00c04fd430c8'::uuid, 'scenario2-move-primary'),
        :'scenario2_inventory_primary_id',
        'receipt',
        22,
        'receipt',
        :'scenario2_receipt_id',
        'Accepted inventory allocated to regional program.'
    ),
    (
        uuid_generate_v5('6ba7b810-9dad-11d1-80b4-00c04fd430c8'::uuid, 'scenario2-move-backlog'),
        :'scenario2_inventory_backlog_id',
        'receipt',
        18,
        'receipt',
        :'scenario2_receipt_id',
        'Balance moved to backlog holding location.'
    );

INSERT INTO fmrs (id, project_id, fmr_number, warehouse_id, requested_by, status, requested_date, updated_at)
VALUES (
    :'scenario2_fmr_id',
    :'scenario2_project_id',
    'FMR-SC2-PLANNED',
    :'scenario2_warehouse_id',
    :'planner_user_id',
    'draft',
    DATE '2024-05-20',
    TIMESTAMP WITH TIME ZONE '2024-05-20 05:00+00'
);

INSERT INTO fmr_line_items (id, fmr_id, inventory_id, commodity_code_id, quantity_requested, quantity_issued, required_date, wbs_id, notes)
VALUES (
    :'scenario2_fmr_line_id',
    :'scenario2_fmr_id',
        :'scenario2_inventory_primary_id',
        :'scenario2_commodity_id',
        12,
        0,
        DATE '2024-05-28',
        :'scenario2_wbs_primary_id',
        'Pre-planned distribution for June training exercise.'
);

INSERT INTO inventory_reservations (id, inventory_id, reservation_type, reserved_quantity, reserved_for_entity_type, reserved_for_entity_id, reservation_date, required_by_date, priority_level, can_reassign, created_by)
VALUES (
    :'scenario2_reservation_id',
    :'scenario2_inventory_primary_id',
    'soft_commitment',
    12,
    'fmr',
    :'scenario2_fmr_line_id',
    TIMESTAMP WITH TIME ZONE '2024-05-15 10:00+00',
    DATE '2024-05-28',
    55,
    TRUE,
    :'planner_user_id'
), (
    :'scenario2_reservation_hold_id',
    :'scenario2_inventory_primary_id',
    'strategic_hold',
    6,
    'program',
    NULL,
    TIMESTAMP WITH TIME ZONE '2024-05-16 08:30+00',
    DATE '2024-06-15',
    70,
    FALSE,
    :'planner_user_id'
);

INSERT INTO emergency_incidents (id, project_id, incident_type, incident_date, reported_by, description, status, created_at)
VALUES (
    :'scenario2_incident_id',
    :'scenario2_project_id',
    'regional_flood',
    TIMESTAMP WITH TIME ZONE '2024-05-18 21:30+00',
    :'incident_user_id',
    'Flash flooding displaced 80 people in the Macquarie catchment.',
    'active',
    TIMESTAMP WITH TIME ZONE '2024-05-18 21:30+00'
);

INSERT INTO emergency_accommodations (id, incident_id, original_line_item_id, source_warehouse_id, source_inventory_id, quantity_allocated, availability_score, compatibility_score, impact_level, displaced_commitment_id, approved_by, approved_at, created_at)
VALUES (
    :'scenario2_accommodation_id',
    :'scenario2_incident_id',
    :'scenario2_po_line_id',
    :'scenario2_warehouse_id',
    :'scenario2_inventory_primary_id',
    10,
    70,
    100,
    'moderate_impact',
    :'scenario2_reservation_id',
    :'planner_user_id',
    TIMESTAMP WITH TIME ZONE '2024-05-18 22:15+00',
    TIMESTAMP WITH TIME ZONE '2024-05-18 22:15+00'
);

-- Suggested operator check
-- SELECT * FROM fn_emergency_inventory_search(:'scenario2_po_line_id');
