\set ON_ERROR_STOP on

SELECT
    uuid_generate_v5('6ba7b810-9dad-11d1-80b4-00c04fd430c8'::uuid, 'scenario3-project')                      AS scenario3_project_id,
    uuid_generate_v5('6ba7b810-9dad-11d1-80b4-00c04fd430c8'::uuid, 'scenario3-wbs-root')                     AS scenario3_wbs_root_id,
    uuid_generate_v5('6ba7b810-9dad-11d1-80b4-00c04fd430c8'::uuid, 'scenario3-wbs-node-critical')            AS scenario3_wbs_node_id,
    uuid_generate_v5('6ba7b810-9dad-11d1-80b4-00c04fd430c8'::uuid, 'scenario3-supplier-urban')               AS scenario3_supplier_id,
    uuid_generate_v5('6ba7b810-9dad-11d1-80b4-00c04fd430c8'::uuid, 'scenario3-warehouse-metro')              AS scenario3_warehouse_id,
    uuid_generate_v5('6ba7b810-9dad-11d1-80b4-00c04fd430c8'::uuid, 'scenario3-unit-kit')                     AS scenario3_uom_id,
    uuid_generate_v5('6ba7b810-9dad-11d1-80b4-00c04fd430c8'::uuid, 'scenario3-commodity-powerpack')          AS scenario3_commodity_id,
    uuid_generate_v5('6ba7b810-9dad-11d1-80b4-00c04fd430c8'::uuid, 'scenario3-mto')                          AS scenario3_mto_id,
    uuid_generate_v5('6ba7b810-9dad-11d1-80b4-00c04fd430c8'::uuid, 'scenario3-mto-line')                     AS scenario3_mto_line_id,
    uuid_generate_v5('6ba7b810-9dad-11d1-80b4-00c04fd430c8'::uuid, 'scenario3-po')                           AS scenario3_po_id,
    uuid_generate_v5('6ba7b810-9dad-11d1-80b4-00c04fd430c8'::uuid, 'scenario3-po-line')                      AS scenario3_po_line_id,
    uuid_generate_v5('6ba7b810-9dad-11d1-80b4-00c04fd430c8'::uuid, 'scenario3-scn')                          AS scenario3_scn_id,
    uuid_generate_v5('6ba7b810-9dad-11d1-80b4-00c04fd430c8'::uuid, 'scenario3-scn-package')                  AS scenario3_scn_package_id,
    uuid_generate_v5('6ba7b810-9dad-11d1-80b4-00c04fd430c8'::uuid, 'scenario3-scn-line')                     AS scenario3_scn_line_id,
    uuid_generate_v5('6ba7b810-9dad-11d1-80b4-00c04fd430c8'::uuid, 'scenario3-receipt')                      AS scenario3_receipt_id,
    uuid_generate_v5('6ba7b810-9dad-11d1-80b4-00c04fd430c8'::uuid, 'scenario3-receipt-line')                 AS scenario3_receipt_line_id,
    uuid_generate_v5('6ba7b810-9dad-11d1-80b4-00c04fd430c8'::uuid, 'scenario3-inventory')                    AS scenario3_inventory_id,
    uuid_generate_v5('6ba7b810-9dad-11d1-80b4-00c04fd430c8'::uuid, 'scenario3-fmr-critical')                 AS scenario3_fmr_id,
    uuid_generate_v5('6ba7b810-9dad-11d1-80b4-00c04fd430c8'::uuid, 'scenario3-fmr-line')                     AS scenario3_fmr_line_id,
    uuid_generate_v5('6ba7b810-9dad-11d1-80b4-00c04fd430c8'::uuid, 'scenario3-reservation-hard')             AS scenario3_reservation_hard_id,
    uuid_generate_v5('6ba7b810-9dad-11d1-80b4-00c04fd430c8'::uuid, 'scenario3-reservation-displaced')        AS scenario3_reservation_displaced_id,
    uuid_generate_v5('6ba7b810-9dad-11d1-80b4-00c04fd430c8'::uuid, 'scenario3-incident')                     AS scenario3_incident_id,
    uuid_generate_v5('6ba7b810-9dad-11d1-80b4-00c04fd430c8'::uuid, 'scenario3-accommodation')                AS scenario3_accommodation_id,
    uuid_generate_v5('6ba7b810-9dad-11d1-80b4-00c04fd430c8'::uuid, 'scenario3-commitment-impact')            AS scenario3_commitment_impact_id,
    uuid_generate_v5('6ba7b810-9dad-11d1-80b4-00c04fd430c8'::uuid, 'scenario3-material-issue')               AS scenario3_material_issue_id,
    uuid_generate_v5('6ba7b810-9dad-11d1-80b4-00c04fd430c8'::uuid, 'scenario3-search-audit')                 AS scenario3_search_audit_id
\gset

DELETE FROM projects WHERE id = :'scenario3_project_id';

INSERT INTO countries (code, name, alpha3_code)
VALUES ('AU', 'Australia', 'AUS')
ON CONFLICT (code) DO UPDATE SET name = EXCLUDED.name, alpha3_code = EXCLUDED.alpha3_code;

INSERT INTO incoterms (abbreviation, description)
VALUES ('CIP', 'Carriage and Insurance Paid')
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

INSERT INTO users (username, email, password_hash, first_name, last_name, organization, is_active)
VALUES ('executive', 'executive@demo.local', 'demo-hash', 'Jordan', 'Lee', 'Emergency Demo', TRUE)
ON CONFLICT (email) DO UPDATE SET
    username = EXCLUDED.username,
    first_name = EXCLUDED.first_name,
    last_name = EXCLUDED.last_name,
    organization = EXCLUDED.organization,
    is_active = TRUE
RETURNING id AS executive_user_id
\gset

INSERT INTO projects (id, name, description, default_currency, include_gst, created_by)
VALUES (
    :'scenario3_project_id',
    'Scenario 3 - Metropolitan Critical',
    'Emergency stockpile depletion requiring executive approval to displace commitments.',
    'AUD',
    FALSE,
    :'planner_user_id'
);

INSERT INTO project_users (project_id, user_id, access_level)
VALUES
    (:'scenario3_project_id', :'planner_user_id', 'admin'),
    (:'scenario3_project_id', :'warehouse_user_id', 'write'),
    (:'scenario3_project_id', :'incident_user_id', 'read'),
    (:'scenario3_project_id', :'executive_user_id', 'admin');

INSERT INTO units_of_measure (id, project_id, long_description, abbreviation, is_default)
VALUES (:'scenario3_uom_id', :'scenario3_project_id', 'Power Kit', 'KIT', TRUE);

INSERT INTO freight_packages (id, project_id, package_type)
VALUES (uuid_generate_v5('6ba7b810-9dad-11d1-80b4-00c04fd430c8'::uuid, 'scenario3-freight-case'), :'scenario3_project_id', 'Shockproof Case');

INSERT INTO document_types (id, project_id, type_name)
VALUES (uuid_generate_v5('6ba7b810-9dad-11d1-80b4-00c04fd430c8'::uuid, 'scenario3-doc-approval'), :'scenario3_project_id', 'Executive Approval Memo');

INSERT INTO wbs (id, project_id, code, name, parent_id, level, sort_order, path)
VALUES
    (:'scenario3_wbs_root_id', :'scenario3_project_id', 'SC3', 'Scenario 3 Root', NULL, 0, 1, 'SC3'),
    (:'scenario3_wbs_node_id', :'scenario3_project_id', 'SC3.1', 'Metro Emergency Power', :'scenario3_wbs_root_id', 1, 10, 'SC3>SC3.1');

INSERT INTO wbs_ros_dates (wbs_id, ros_date)
VALUES (:'scenario3_wbs_node_id', DATE '2024-06-30');

INSERT INTO suppliers (id, project_id, supplier_code, name, contact_name, contact_email, country_code, incoterm)
VALUES (
    :'scenario3_supplier_id',
    :'scenario3_project_id',
    'SUP-URBAN',
    'Urban Resilience Group',
    'Jamie Patel',
    'j.patel@urbanresilience.example',
    'AU',
    'CIP'
);

INSERT INTO warehouses (id, project_id, name, warehouse_code, description, city, country_code, is_active)
VALUES (
    :'scenario3_warehouse_id',
    :'scenario3_project_id',
    'Metro Emergency Vault',
    'WH-METRO',
    'Secure stockpile for metropolitan emergency response assets.',
    'Sydney',
    'AU',
    TRUE
);

INSERT INTO commodity_codes (id, project_id, engineered_code, short_description, long_description, commodity_class, unit_of_measure_id)
VALUES (
    :'scenario3_commodity_id',
    :'scenario3_project_id',
    'COM-POWER-PACK',
    'Portable Power Pack',
    'Battery-backed power systems supporting critical-care shelters.',
    'Power',
    :'scenario3_uom_id'
);

INSERT INTO mtos (id, project_id, mto_number, title, revision, status, issued_date, created_by)
VALUES (
    :'scenario3_mto_id',
    :'scenario3_project_id',
    'MTO-SC3-010',
    'Critical power supply requirements',
    'A',
    'issued',
    DATE '2024-05-10',
    :'planner_user_id'
);

INSERT INTO mto_line_items (id, mto_id, line_number, commodity_code_id, description, quantity, unit_of_measure_id, wbs_id)
VALUES (
    :'scenario3_mto_line_id',
    :'scenario3_mto_id',
    '10',
    :'scenario3_commodity_id',
    'Portable Power Pack',
    24,
    :'scenario3_uom_id',
    :'scenario3_wbs_node_id'
);

INSERT INTO purchase_orders (id, project_id, po_number, supplier_id, mto_id, status, currency, order_date, expected_delivery_date, total_value, created_by)
VALUES (
    :'scenario3_po_id',
    :'scenario3_project_id',
    'SC3-PO-3010',
    :'scenario3_supplier_id',
    :'scenario3_mto_id',
    'open',
    'AUD',
    DATE '2024-05-12',
    DATE '2024-06-05',
    216000,
    :'planner_user_id'
);

INSERT INTO po_line_items (id, po_id, line_number, commodity_code_id, description, quantity_ordered, unit_price, line_value, contractual_delivery_date, forecast_delivery_date, wbs_id, line_type)
VALUES (
    :'scenario3_po_line_id',
    :'scenario3_po_id',
    '10',
    :'scenario3_commodity_id',
    'Portable Power Pack',
    24,
    9000,
    216000,
    DATE '2024-06-05',
    DATE '2024-06-07',
    :'scenario3_wbs_node_id',
    'standard'
);

INSERT INTO scns (id, project_id, scn_number, description, collection_supplier_id, delivery_warehouse_id, forecast_collection_date, forecast_delivery_date, actual_collection_date, actual_delivery_date, status, created_by)
VALUES (
    :'scenario3_scn_id',
    :'scenario3_project_id',
    'SCN-SC3-05',
    'Power packs inbound for metro stockpile',
    :'scenario3_supplier_id',
    :'scenario3_warehouse_id',
    DATE '2024-06-02',
    DATE '2024-06-08',
    DATE '2024-06-02',
    DATE '2024-06-06',
    'delivered',
    :'planner_user_id'
);

INSERT INTO scn_packages (id, scn_id, package_number, freight_package_id, gross_weight, net_weight, dimensions)
VALUES (
    :'scenario3_scn_package_id',
    :'scenario3_scn_id',
    'PKG-021',
    uuid_generate_v5('6ba7b810-9dad-11d1-80b4-00c04fd430c8'::uuid, 'scenario3-freight-case'),
    2500,
    2200,
    '2.2m x 1.3m x 1.3m'
);

INSERT INTO scn_line_items (id, scn_id, package_id, po_line_item_id, quantity)
VALUES (
    :'scenario3_scn_line_id',
    :'scenario3_scn_id',
    :'scenario3_scn_package_id',
    :'scenario3_po_line_id',
    24
);

INSERT INTO receipts (id, project_id, receipt_number, warehouse_id, scn_id, receipt_date, status, inspected_by)
VALUES (
    :'scenario3_receipt_id',
    :'scenario3_project_id',
    'RCPT-SC3-05',
    :'scenario3_warehouse_id',
    :'scenario3_scn_id',
    DATE '2024-06-06',
    'completed',
    :'warehouse_user_id'
);

INSERT INTO receipt_line_items (id, receipt_id, scn_line_item_id, po_line_item_id, quantity_received, quantity_accepted, quantity_rejected, inspection_notes)
VALUES (
    :'scenario3_receipt_line_id',
    :'scenario3_receipt_id',
    :'scenario3_scn_line_id',
    :'scenario3_po_line_id',
    24,
    24,
    0,
    'All units passed QA and moved to secure vault.'
);

INSERT INTO warehouse_inventory (id, project_id, warehouse_id, commodity_code_id, wbs_id, quantity_available, quantity_reserved, quantity_hard_reserved, safety_stock_level, status, last_receipt_id)
VALUES (
    :'scenario3_inventory_id',
    :'scenario3_project_id',
    :'scenario3_warehouse_id',
    :'scenario3_commodity_id',
    :'scenario3_wbs_node_id',
    8,
    10,
    6,
    6,
    'available',
    :'scenario3_receipt_id'
);

INSERT INTO inventory_movements (id, inventory_id, movement_type, quantity, reference_type, reference_id, notes)
VALUES
    (
        uuid_generate_v5('6ba7b810-9dad-11d1-80b4-00c04fd430c8'::uuid, 'scenario3-move-receipt'),
        :'scenario3_inventory_id',
        'receipt',
        24,
        'receipt',
        :'scenario3_receipt_id',
        'Initial receipt from SCN-SC3-05.'
    ),
    (
        uuid_generate_v5('6ba7b810-9dad-11d1-80b4-00c04fd430c8'::uuid, 'scenario3-move-issue'),
        :'scenario3_inventory_id',
        'issue',
        -16,
        'fmr',
        :'scenario3_fmr_id',
        'Deployments and maintenance pulls prior to emergency event.'
    );

INSERT INTO inventory_reservations (id, inventory_id, reservation_type, reserved_quantity, reserved_for_entity_type, reserved_for_entity_id, reservation_date, required_by_date, priority_level, can_reassign, created_by)
VALUES
    (
        :'scenario3_reservation_hard_id',
        :'scenario3_inventory_id',
        'critical_program',
        6,
        'program',
        NULL,
        TIMESTAMP WITH TIME ZONE '2024-06-07 09:00+00',
        DATE '2024-06-30',
        95,
        FALSE,
        :'planner_user_id'
    ),
    (
        :'scenario3_reservation_displaced_id',
        :'scenario3_inventory_id',
        'executive_hold',
        4,
        'program',
        NULL,
        TIMESTAMP WITH TIME ZONE '2024-06-07 09:15+00',
        DATE '2024-06-20',
        85,
        FALSE,
        :'planner_user_id'
    );

INSERT INTO fmrs (id, project_id, fmr_number, warehouse_id, requested_by, status, requested_date, finalized_at, updated_at)
VALUES (
    :'scenario3_fmr_id',
    :'scenario3_project_id',
    'FMR-SC3-CRITICAL',
    :'scenario3_warehouse_id',
    :'incident_user_id',
    'finalized',
    DATE '2024-06-08',
    TIMESTAMP WITH TIME ZONE '2024-06-08 04:25+00',
    TIMESTAMP WITH TIME ZONE '2024-06-08 04:25+00'
);

INSERT INTO fmr_line_items (id, fmr_id, inventory_id, commodity_code_id, quantity_requested, quantity_issued, required_date, wbs_id, notes)
VALUES (
    :'scenario3_fmr_line_id',
    :'scenario3_fmr_id',
    :'scenario3_inventory_id',
    :'scenario3_commodity_id',
    4,
    4,
    DATE '2024-06-08',
    :'scenario3_wbs_node_id',
    'Emergency allocation to metro shelters pending grid restoration.'
);

INSERT INTO materials_issued (id, fmr_id, line_item_id, inventory_id, quantity_issued, issued_at, issued_by)
VALUES (
    :'scenario3_material_issue_id',
    :'scenario3_fmr_id',
    :'scenario3_fmr_line_id',
    :'scenario3_inventory_id',
    4,
    TIMESTAMP WITH TIME ZONE '2024-06-08 05:10+00',
    :'warehouse_user_id'
);

INSERT INTO emergency_incidents (id, project_id, incident_type, incident_date, reported_by, description, status, resolution_notes, created_at)
VALUES (
    :'scenario3_incident_id',
    :'scenario3_project_id',
    'urban_blackout',
    TIMESTAMP WITH TIME ZONE '2024-06-08 03:45+00',
    :'incident_user_id',
    'City-wide blackout affecting hospital surge wards; immediate power packs required.',
    'active',
    'Power packs dispatched while grid restoration underway.',
    TIMESTAMP WITH TIME ZONE '2024-06-08 03:45+00'
);

INSERT INTO emergency_accommodations (id, incident_id, original_line_item_id, source_warehouse_id, source_inventory_id, quantity_allocated, availability_score, compatibility_score, impact_level, displaced_commitment_id, approved_by, approved_at, executed_at, created_at)
VALUES (
    :'scenario3_accommodation_id',
    :'scenario3_incident_id',
    :'scenario3_po_line_id',
    :'scenario3_warehouse_id',
    :'scenario3_inventory_id',
    4,
    30,
    95,
    'critical_decision',
    :'scenario3_reservation_displaced_id',
    :'executive_user_id',
    TIMESTAMP WITH TIME ZONE '2024-06-08 04:05+00',
    TIMESTAMP WITH TIME ZONE '2024-06-08 04:20+00',
    TIMESTAMP WITH TIME ZONE '2024-06-08 04:00+00'
);

INSERT INTO commitment_impacts (id, original_reservation_id, impacted_entity_type, impacted_entity_id, impact_severity, impact_description, alternative_suggested, mitigation_cost)
VALUES (
    :'scenario3_commitment_impact_id',
    :'scenario3_reservation_displaced_id',
    'program',
    :'scenario3_reservation_displaced_id',
    'high',
    'Deferred maintenance program loses backup coverage; contractor overtime required.',
    TRUE,
    18500
);

INSERT INTO search_audit_log (id, project_id, user_id, search_type, parameters, results_count, executed_at)
VALUES (
    :'scenario3_search_audit_id',
    :'scenario3_project_id',
    :'planner_user_id',
    'emergency_inventory',
    jsonb_build_object('po_line_item_id', :'scenario3_po_line_id', 'limit', 3),
    2,
    TIMESTAMP WITH TIME ZONE '2024-06-08 03:55+00'
);

-- SELECT * FROM fn_emergency_inventory_search(:'scenario3_po_line_id');

