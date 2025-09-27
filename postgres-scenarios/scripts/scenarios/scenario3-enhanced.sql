\set ON_ERROR_STOP on

-- Deterministic identifiers for scenario entities
SELECT
    uuid_generate_v5('6ba7b810-9dad-11d1-80b4-00c04fd430c8'::uuid, 'scenario3-enhanced-project')               AS scenario3_project_id,
    uuid_generate_v5('6ba7b810-9dad-11d1-80b4-00c04fd430c8'::uuid, 'scenario3-enhanced-wbs-root')              AS scenario3_wbs_root_id,
    uuid_generate_v5('6ba7b810-9dad-11d1-80b4-00c04fd430c8'::uuid, 'scenario3-enhanced-wbs-usar')              AS scenario3_wbs_usar_id,
    uuid_generate_v5('6ba7b810-9dad-11d1-80b4-00c04fd430c8'::uuid, 'scenario3-enhanced-wbs-medical')           AS scenario3_wbs_medical_id,
    uuid_generate_v5('6ba7b810-9dad-11d1-80b4-00c04fd430c8'::uuid, 'scenario3-enhanced-wbs-power')             AS scenario3_wbs_power_id,
    uuid_generate_v5('6ba7b810-9dad-11d1-80b4-00c04fd430c8'::uuid, 'scenario3-enhanced-wbs-water')             AS scenario3_wbs_water_id,
    uuid_generate_v5('6ba7b810-9dad-11d1-80b4-00c04fd430c8'::uuid, 'scenario3-enhanced-wbs-comms')             AS scenario3_wbs_comms_id,
    -- Multiple suppliers across states
    uuid_generate_v5('6ba7b810-9dad-11d1-80b4-00c04fd430c8'::uuid, 'scenario3-enhanced-supplier-usar')         AS scenario3_supplier_usar_id,
    uuid_generate_v5('6ba7b810-9dad-11d1-80b4-00c04fd430c8'::uuid, 'scenario3-enhanced-supplier-medical')      AS scenario3_supplier_medical_id,
    uuid_generate_v5('6ba7b810-9dad-11d1-80b4-00c04fd430c8'::uuid, 'scenario3-enhanced-supplier-power')        AS scenario3_supplier_power_id,
    uuid_generate_v5('6ba7b810-9dad-11d1-80b4-00c04fd430c8'::uuid, 'scenario3-enhanced-supplier-water')        AS scenario3_supplier_water_id,
    uuid_generate_v5('6ba7b810-9dad-11d1-80b4-00c04fd430c8'::uuid, 'scenario3-enhanced-supplier-comms')        AS scenario3_supplier_comms_id,
    -- National strategic warehouses
    uuid_generate_v5('6ba7b810-9dad-11d1-80b4-00c04fd430c8'::uuid, 'scenario3-enhanced-warehouse-sydney')      AS scenario3_warehouse_sydney_id,
    uuid_generate_v5('6ba7b810-9dad-11d1-80b4-00c04fd430c8'::uuid, 'scenario3-enhanced-warehouse-melbourne')   AS scenario3_warehouse_melbourne_id,
    uuid_generate_v5('6ba7b810-9dad-11d1-80b4-00c04fd430c8'::uuid, 'scenario3-enhanced-warehouse-brisbane')    AS scenario3_warehouse_brisbane_id,
    uuid_generate_v5('6ba7b810-9dad-11d1-80b4-00c04fd430c8'::uuid, 'scenario3-enhanced-warehouse-perth')       AS scenario3_warehouse_perth_id,
    uuid_generate_v5('6ba7b810-9dad-11d1-80b4-00c04fd430c8'::uuid, 'scenario3-enhanced-warehouse-adelaide')    AS scenario3_warehouse_adelaide_id,
    uuid_generate_v5('6ba7b810-9dad-11d1-80b4-00c04fd430c8'::uuid, 'scenario3-enhanced-warehouse-darwin')      AS scenario3_warehouse_darwin_id,
    -- Units of measure
    uuid_generate_v5('6ba7b810-9dad-11d1-80b4-00c04fd430c8'::uuid, 'scenario3-enhanced-uom-package')           AS scenario3_uom_package_id,
    uuid_generate_v5('6ba7b810-9dad-11d1-80b4-00c04fd430c8'::uuid, 'scenario3-enhanced-uom-unit')              AS scenario3_uom_unit_id,
    uuid_generate_v5('6ba7b810-9dad-11d1-80b4-00c04fd430c8'::uuid, 'scenario3-enhanced-uom-system')            AS scenario3_uom_system_id,
    uuid_generate_v5('6ba7b810-9dad-11d1-80b4-00c04fd430c8'::uuid, 'scenario3-enhanced-uom-plant')             AS scenario3_uom_plant_id,
    uuid_generate_v5('6ba7b810-9dad-11d1-80b4-00c04fd430c8'::uuid, 'scenario3-enhanced-uom-network')           AS scenario3_uom_network_id,
    -- Commodity codes
    uuid_generate_v5('6ba7b810-9dad-11d1-80b4-00c04fd430c8'::uuid, 'scenario3-enhanced-commodity-usar')        AS scenario3_commodity_usar_id,
    uuid_generate_v5('6ba7b810-9dad-11d1-80b4-00c04fd430c8'::uuid, 'scenario3-enhanced-commodity-medical')     AS scenario3_commodity_medical_id,
    uuid_generate_v5('6ba7b810-9dad-11d1-80b4-00c04fd430c8'::uuid, 'scenario3-enhanced-commodity-power')       AS scenario3_commodity_power_id,
    uuid_generate_v5('6ba7b810-9dad-11d1-80b4-00c04fd430c8'::uuid, 'scenario3-enhanced-commodity-water')       AS scenario3_commodity_water_id,
    uuid_generate_v5('6ba7b810-9dad-11d1-80b4-00c04fd430c8'::uuid, 'scenario3-enhanced-commodity-comms')       AS scenario3_commodity_comms_id,
    -- MTOs for each commodity
    uuid_generate_v5('6ba7b810-9dad-11d1-80b4-00c04fd430c8'::uuid, 'scenario3-enhanced-mto-usar')              AS scenario3_mto_usar_id,
    uuid_generate_v5('6ba7b810-9dad-11d1-80b4-00c04fd430c8'::uuid, 'scenario3-enhanced-mto-medical')           AS scenario3_mto_medical_id,
    uuid_generate_v5('6ba7b810-9dad-11d1-80b4-00c04fd430c8'::uuid, 'scenario3-enhanced-mto-power')             AS scenario3_mto_power_id,
    uuid_generate_v5('6ba7b810-9dad-11d1-80b4-00c04fd430c8'::uuid, 'scenario3-enhanced-mto-water')             AS scenario3_mto_water_id,
    uuid_generate_v5('6ba7b810-9dad-11d1-80b4-00c04fd430c8'::uuid, 'scenario3-enhanced-mto-comms')             AS scenario3_mto_comms_id,
    -- MTO line items
    uuid_generate_v5('6ba7b810-9dad-11d1-80b4-00c04fd430c8'::uuid, 'scenario3-enhanced-mto-line-usar')         AS scenario3_mto_line_usar_id,
    uuid_generate_v5('6ba7b810-9dad-11d1-80b4-00c04fd430c8'::uuid, 'scenario3-enhanced-mto-line-medical')      AS scenario3_mto_line_medical_id,
    uuid_generate_v5('6ba7b810-9dad-11d1-80b4-00c04fd430c8'::uuid, 'scenario3-enhanced-mto-line-power')        AS scenario3_mto_line_power_id,
    uuid_generate_v5('6ba7b810-9dad-11d1-80b4-00c04fd430c8'::uuid, 'scenario3-enhanced-mto-line-water')        AS scenario3_mto_line_water_id,
    uuid_generate_v5('6ba7b810-9dad-11d1-80b4-00c04fd430c8'::uuid, 'scenario3-enhanced-mto-line-comms')        AS scenario3_mto_line_comms_id,
    -- Purchase orders
    uuid_generate_v5('6ba7b810-9dad-11d1-80b4-00c04fd430c8'::uuid, 'scenario3-enhanced-po-usar')               AS scenario3_po_usar_id,
    uuid_generate_v5('6ba7b810-9dad-11d1-80b4-00c04fd430c8'::uuid, 'scenario3-enhanced-po-medical')            AS scenario3_po_medical_id,
    uuid_generate_v5('6ba7b810-9dad-11d1-80b4-00c04fd430c8'::uuid, 'scenario3-enhanced-po-power')              AS scenario3_po_power_id,
    uuid_generate_v5('6ba7b810-9dad-11d1-80b4-00c04fd430c8'::uuid, 'scenario3-enhanced-po-water')              AS scenario3_po_water_id,
    uuid_generate_v5('6ba7b810-9dad-11d1-80b4-00c04fd430c8'::uuid, 'scenario3-enhanced-po-comms')              AS scenario3_po_comms_id,
    -- PO line items
    uuid_generate_v5('6ba7b810-9dad-11d1-80b4-00c04fd430c8'::uuid, 'scenario3-enhanced-po-line-usar')          AS scenario3_po_line_usar_id,
    uuid_generate_v5('6ba7b810-9dad-11d1-80b4-00c04fd430c8'::uuid, 'scenario3-enhanced-po-line-medical')       AS scenario3_po_line_medical_id,
    uuid_generate_v5('6ba7b810-9dad-11d1-80b4-00c04fd430c8'::uuid, 'scenario3-enhanced-po-line-power')         AS scenario3_po_line_power_id,
    uuid_generate_v5('6ba7b810-9dad-11d1-80b4-00c04fd430c8'::uuid, 'scenario3-enhanced-po-line-water')         AS scenario3_po_line_water_id,
    uuid_generate_v5('6ba7b810-9dad-11d1-80b4-00c04fd430c8'::uuid, 'scenario3-enhanced-po-line-comms')         AS scenario3_po_line_comms_id,
    -- Shipment coordination numbers documenting executive-level cancellations
    uuid_generate_v5('6ba7b810-9dad-11d1-80b4-00c04fd430c8'::uuid, 'scenario3-enhanced-scn-usar')              AS scenario3_scn_usar_id,
    uuid_generate_v5('6ba7b810-9dad-11d1-80b4-00c04fd430c8'::uuid, 'scenario3-enhanced-scn-medical')           AS scenario3_scn_medical_id,
    uuid_generate_v5('6ba7b810-9dad-11d1-80b4-00c04fd430c8'::uuid, 'scenario3-enhanced-scn-power')             AS scenario3_scn_power_id,
    uuid_generate_v5('6ba7b810-9dad-11d1-80b4-00c04fd430c8'::uuid, 'scenario3-enhanced-scn-water')             AS scenario3_scn_water_id,
    uuid_generate_v5('6ba7b810-9dad-11d1-80b4-00c04fd430c8'::uuid, 'scenario3-enhanced-scn-comms')             AS scenario3_scn_comms_id,
    uuid_generate_v5('6ba7b810-9dad-11d1-80b4-00c04fd430c8'::uuid, 'scenario3-enhanced-scn-package-usar')      AS scenario3_scn_package_usar_id,
    uuid_generate_v5('6ba7b810-9dad-11d1-80b4-00c04fd430c8'::uuid, 'scenario3-enhanced-scn-package-medical')   AS scenario3_scn_package_medical_id,
    uuid_generate_v5('6ba7b810-9dad-11d1-80b4-00c04fd430c8'::uuid, 'scenario3-enhanced-scn-package-power')     AS scenario3_scn_package_power_id,
    uuid_generate_v5('6ba7b810-9dad-11d1-80b4-00c04fd430c8'::uuid, 'scenario3-enhanced-scn-package-water')     AS scenario3_scn_package_water_id,
    uuid_generate_v5('6ba7b810-9dad-11d1-80b4-00c04fd430c8'::uuid, 'scenario3-enhanced-scn-package-comms')     AS scenario3_scn_package_comms_id,
    uuid_generate_v5('6ba7b810-9dad-11d1-80b4-00c04fd430c8'::uuid, 'scenario3-enhanced-scn-line-usar')         AS scenario3_scn_line_usar_id,
    uuid_generate_v5('6ba7b810-9dad-11d1-80b4-00c04fd430c8'::uuid, 'scenario3-enhanced-scn-line-medical')      AS scenario3_scn_line_medical_id,
    uuid_generate_v5('6ba7b810-9dad-11d1-80b4-00c04fd430c8'::uuid, 'scenario3-enhanced-scn-line-power')        AS scenario3_scn_line_power_id,
    uuid_generate_v5('6ba7b810-9dad-11d1-80b4-00c04fd430c8'::uuid, 'scenario3-enhanced-scn-line-water')        AS scenario3_scn_line_water_id,
    uuid_generate_v5('6ba7b810-9dad-11d1-80b4-00c04fd430c8'::uuid, 'scenario3-enhanced-scn-line-comms')        AS scenario3_scn_line_comms_id,
    -- Emergency incident
    uuid_generate_v5('6ba7b810-9dad-11d1-80b4-00c04fd430c8'::uuid, 'scenario3-enhanced-incident')              AS scenario3_incident_id
\gset

-- Remove any previous run for this scenario (cascades to child records)
DELETE FROM projects WHERE id = :'scenario3_project_id';

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
    :'scenario3_project_id',
    'Enhanced Scenario 3 - Metropolitan Infrastructure Collapse',
    'Major 7.2 magnitude earthquake affecting 2M people in Sydney metropolitan area requiring executive-level resource allocation decisions with national security implications and cross-state coordination.',
    'AUD',
    FALSE,
    :'planner_user_id'
);

INSERT INTO project_users (project_id, user_id, access_level)
VALUES
    (:'scenario3_project_id', :'planner_user_id', 'admin'),
    (:'scenario3_project_id', :'warehouse_user_id', 'write'),
    (:'scenario3_project_id', :'incident_user_id', 'read');

-- Reference data scoped to the project
INSERT INTO units_of_measure (id, project_id, long_description, abbreviation, is_default)
VALUES
    (:'scenario3_uom_package_id', :'scenario3_project_id', 'Package', 'PACKAGE', FALSE),
    (:'scenario3_uom_unit_id', :'scenario3_project_id', 'Unit', 'UNIT', TRUE),
    (:'scenario3_uom_system_id', :'scenario3_project_id', 'System', 'SYSTEM', FALSE),
    (:'scenario3_uom_plant_id', :'scenario3_project_id', 'Plant', 'PLANT', FALSE),
    (:'scenario3_uom_network_id', :'scenario3_project_id', 'Network', 'NETWORK', FALSE);

INSERT INTO freight_packages (id, project_id, package_type)
VALUES
    (uuid_generate_v5('6ba7b810-9dad-11d1-80b4-00c04fd430c8'::uuid, 'scenario3-enhanced-freight-container'), :'scenario3_project_id', 'Container'),
    (uuid_generate_v5('6ba7b810-9dad-11d1-80b4-00c04fd430c8'::uuid, 'scenario3-enhanced-freight-trailer'), :'scenario3_project_id', 'Trailer'),
    (uuid_generate_v5('6ba7b810-9dad-11d1-80b4-00c04fd430c8'::uuid, 'scenario3-enhanced-freight-specialized'), :'scenario3_project_id', 'Specialized');

INSERT INTO document_types (id, project_id, type_name)
VALUES (uuid_generate_v5('6ba7b810-9dad-11d1-80b4-00c04fd430c8'::uuid, 'scenario3-enhanced-doc-clearance'), :'scenario3_project_id', 'Security Clearance');

-- Work Breakdown Structure
INSERT INTO wbs (id, project_id, code, name, parent_id, level, sort_order, path)
VALUES
    (:'scenario3_wbs_root_id', :'scenario3_project_id', 'SC3E', 'Enhanced Scenario 3 Root', NULL, 0, 1, 'SC3E'),
    (:'scenario3_wbs_usar_id', :'scenario3_project_id', 'SC3E.1', 'Urban Search & Rescue Operations', :'scenario3_wbs_root_id', 1, 10, 'SC3E>SC3E.1'),
    (:'scenario3_wbs_medical_id', :'scenario3_project_id', 'SC3E.2', 'Emergency Medical Response', :'scenario3_wbs_root_id', 1, 20, 'SC3E>SC3E.2'),
    (:'scenario3_wbs_power_id', :'scenario3_project_id', 'SC3E.3', 'Critical Infrastructure Power', :'scenario3_wbs_root_id', 1, 30, 'SC3E>SC3E.3'),
    (:'scenario3_wbs_water_id', :'scenario3_project_id', 'SC3E.4', 'Metropolitan Water Treatment', :'scenario3_wbs_root_id', 1, 40, 'SC3E>SC3E.4'),
    (:'scenario3_wbs_comms_id', :'scenario3_project_id', 'SC3E.5', 'Emergency Communications Network', :'scenario3_wbs_root_id', 1, 50, 'SC3E>SC3E.5');

INSERT INTO wbs_ros_dates (wbs_id, ros_date)
VALUES
    (:'scenario3_wbs_usar_id', DATE '2024-06-30'),
    (:'scenario3_wbs_medical_id', DATE '2024-06-30'),
    (:'scenario3_wbs_power_id', DATE '2024-06-30'),
    (:'scenario3_wbs_water_id', DATE '2024-06-30'),
    (:'scenario3_wbs_comms_id', DATE '2024-06-30');

-- Supply chain master data - National strategic suppliers
INSERT INTO suppliers (id, project_id, supplier_code, name, contact_name, contact_email, country_code, incoterm)
VALUES
    (:'scenario3_supplier_usar_id', :'scenario3_project_id', 'SUP-USAR', 'National USAR Equipment Consortium', 'Devon Park', 'devon.park@usar.example', 'AU', 'DAP'),
    (:'scenario3_supplier_medical_id', :'scenario3_project_id', 'SUP-TRAUMA', 'Emergency Medical Systems Australia', 'Harper Wells', 'harper.wells@emsa.example', 'AU', 'DAP'),
    (:'scenario3_supplier_power_id', :'scenario3_project_id', 'SUP-GRID', 'Grid Emergency Power Solutions', 'Rowan Blake', 'rowan.blake@gridpower.example', 'AU', 'DAP'),
    (:'scenario3_supplier_water_id', :'scenario3_project_id', 'SUP-METRO-WATER', 'Metropolitan Water Emergency Systems', 'Sydney Chen', 'sydney.chen@metrowater.example', 'AU', 'DAP'),
    (:'scenario3_supplier_comms_id', :'scenario3_project_id', 'SUP-SECURE-COMMS', 'Secure Communications Australia', 'Finley Morgan', 'finley.morgan@securecomms.example', 'AU', 'DAP');

-- National strategic warehouses across all states
INSERT INTO warehouses (id, project_id, name, warehouse_code, description, city, country_code, is_active)
VALUES
    (:'scenario3_warehouse_sydney_id', :'scenario3_project_id', 'Sydney Metro Emergency Vault', 'WH-SYD-METRO', 'Metropolitan emergency response vault with high-security clearance requirements.', 'Sydney', 'AU', TRUE),
    (:'scenario3_warehouse_melbourne_id', :'scenario3_project_id', 'Melbourne Strategic Reserve', 'WH-MELB-STRAT', 'Victorian strategic emergency equipment reserve with international aid capability.', 'Melbourne', 'AU', TRUE),
    (:'scenario3_warehouse_brisbane_id', :'scenario3_project_id', 'Brisbane Emergency Command', 'WH-BRIS-CMD', 'Queensland emergency command coordination facility with trauma response capability.', 'Brisbane', 'AU', TRUE),
    (:'scenario3_warehouse_perth_id', :'scenario3_project_id', 'Perth Critical Infrastructure Hub', 'WH-PERTH-INFRA', 'Western Australia critical infrastructure support facility.', 'Perth', 'AU', TRUE),
    (:'scenario3_warehouse_adelaide_id', :'scenario3_project_id', 'Adelaide Water Security Centre', 'WH-ADEL-WATER', 'South Australia water security and emergency treatment facility.', 'Adelaide', 'AU', TRUE),
    (:'scenario3_warehouse_darwin_id', :'scenario3_project_id', 'Darwin Strategic Assets', 'WH-DARWIN-STRAT', 'Northern Territory strategic emergency asset facility.', 'Darwin', 'AU', TRUE);

-- Commodity codes for critical infrastructure response
INSERT INTO commodity_codes (id, project_id, engineered_code, short_description, long_description, commodity_class, unit_of_measure_id)
VALUES
    (:'scenario3_commodity_usar_id', :'scenario3_project_id', 'COM-USAR-HEAVY-PKG', 'Urban Search & Rescue Equipment Package - Heavy', 'Heavy urban search and rescue equipment package including hydraulic cutting tools, concrete breaking equipment, structural shoring systems, and victim location technology.', 'Heavy Rescue Equipment', :'scenario3_uom_package_id'),
    (:'scenario3_commodity_medical_id', :'scenario3_project_id', 'COM-HOSP-MOBILE-L1', 'Mobile Emergency Hospital Unit - Level 1 Trauma', 'Mobile Level 1 trauma hospital unit with surgical capability, blood bank, intensive care, and emergency department facilities.', 'Medical Surge Supplies', :'scenario3_uom_unit_id'),
    (:'scenario3_commodity_power_id', :'scenario3_project_id', 'COM-POWER-GRID-500KW', 'Emergency Power Generation System - 500kW Grid Tie', 'Grid-tie emergency power generation system with 500kW capacity, automatic transfer switching, and utility interconnection capability.', 'Power Generation', :'scenario3_uom_system_id'),
    (:'scenario3_commodity_water_id', :'scenario3_project_id', 'COM-WATER-TREATMENT-METRO', 'Metropolitan Water Treatment Plant - Portable', 'Portable metropolitan-scale water treatment plant capable of processing 50,000L/hour from multiple contaminated sources with distribution capability.', 'Water Treatment', :'scenario3_uom_plant_id'),
    (:'scenario3_commodity_comms_id', :'scenario3_project_id', 'COM-COMM-METRO-NETWORK', 'Emergency Communications Network - Metropolitan Scale', 'Metropolitan-scale emergency communications network with satellite uplink, cellular backup, emergency broadcast, and interagency coordination capability.', 'Communications', :'scenario3_uom_network_id');

-- Planning artefacts - Multiple MTOs for major earthquake response
INSERT INTO mtos (id, project_id, mto_number, title, revision, status, issued_date, created_by)
VALUES
    (:'scenario3_mto_usar_id', :'scenario3_project_id', 'MTO-SC3E-001', 'Metropolitan Earthquake USAR Requirements', 'A', 'issued', DATE '2024-06-15', :'planner_user_id'),
    (:'scenario3_mto_medical_id', :'scenario3_project_id', 'MTO-SC3E-002', 'Mass Casualty Medical Response Requirements', 'A', 'issued', DATE '2024-06-15', :'planner_user_id'),
    (:'scenario3_mto_power_id', :'scenario3_project_id', 'MTO-SC3E-003', 'Critical Infrastructure Power Requirements', 'A', 'issued', DATE '2024-06-15', :'planner_user_id'),
    (:'scenario3_mto_water_id', :'scenario3_project_id', 'MTO-SC3E-004', 'Metropolitan Water Treatment Requirements', 'A', 'issued', DATE '2024-06-15', :'planner_user_id'),
    (:'scenario3_mto_comms_id', :'scenario3_project_id', 'MTO-SC3E-005', 'Emergency Communications Network Requirements', 'A', 'issued', DATE '2024-06-15', :'planner_user_id');

-- MTO line items with metropolitan earthquake-scale quantities
INSERT INTO mto_line_items (id, mto_id, line_number, commodity_code_id, description, quantity, unit_of_measure_id, wbs_id)
VALUES
    (:'scenario3_mto_line_usar_id', :'scenario3_mto_usar_id', '10', :'scenario3_commodity_usar_id', 'Urban Search & Rescue Equipment Package - Heavy', 25, :'scenario3_uom_package_id', :'scenario3_wbs_usar_id'),
    (:'scenario3_mto_line_medical_id', :'scenario3_mto_medical_id', '10', :'scenario3_commodity_medical_id', 'Mobile Emergency Hospital Unit - Level 1 Trauma', 8, :'scenario3_uom_unit_id', :'scenario3_wbs_medical_id'),
    (:'scenario3_mto_line_power_id', :'scenario3_mto_power_id', '10', :'scenario3_commodity_power_id', 'Emergency Power Generation System - 500kW Grid Tie', 12, :'scenario3_uom_system_id', :'scenario3_wbs_power_id'),
    (:'scenario3_mto_line_water_id', :'scenario3_mto_water_id', '10', :'scenario3_commodity_water_id', 'Metropolitan Water Treatment Plant - Portable', 4, :'scenario3_uom_plant_id', :'scenario3_wbs_water_id'),
    (:'scenario3_mto_line_comms_id', :'scenario3_mto_comms_id', '10', :'scenario3_commodity_comms_id', 'Emergency Communications Network - Metropolitan Scale', 3, :'scenario3_uom_network_id', :'scenario3_wbs_comms_id');

-- Purchase orders
INSERT INTO purchase_orders (id, project_id, po_number, supplier_id, mto_id, status, currency, order_date, expected_delivery_date, total_value, created_by)
VALUES
    (:'scenario3_po_usar_id', :'scenario3_project_id', 'SC3E-PO-3001', :'scenario3_supplier_usar_id', :'scenario3_mto_usar_id', 'cancelled', 'AUD', DATE '2024-06-16', DATE '2024-06-25', 12500000, :'planner_user_id'),
    (:'scenario3_po_medical_id', :'scenario3_project_id', 'SC3E-PO-3002', :'scenario3_supplier_medical_id', :'scenario3_mto_medical_id', 'cancelled', 'AUD', DATE '2024-06-16', DATE '2024-06-25', 24000000, :'planner_user_id'),
    (:'scenario3_po_power_id', :'scenario3_project_id', 'SC3E-PO-3003', :'scenario3_supplier_power_id', :'scenario3_mto_power_id', 'cancelled', 'AUD', DATE '2024-06-16', DATE '2024-06-25', 18000000, :'planner_user_id'),
    (:'scenario3_po_water_id', :'scenario3_project_id', 'SC3E-PO-3004', :'scenario3_supplier_water_id', :'scenario3_mto_water_id', 'cancelled', 'AUD', DATE '2024-06-16', DATE '2024-06-25', 8000000, :'planner_user_id'),
    (:'scenario3_po_comms_id', :'scenario3_project_id', 'SC3E-PO-3005', :'scenario3_supplier_comms_id', :'scenario3_mto_comms_id', 'cancelled', 'AUD', DATE '2024-06-16', DATE '2024-06-25', 15000000, :'planner_user_id');

-- PO line items - Failed shipments (cancelled orders for major earthquake response)
INSERT INTO po_line_items (id, po_id, line_number, commodity_code_id, description, quantity_ordered, unit_price, line_value, contractual_delivery_date, forecast_delivery_date, wbs_id, line_type)
VALUES
    (:'scenario3_po_line_usar_id', :'scenario3_po_usar_id', '10', :'scenario3_commodity_usar_id', 'Urban Search & Rescue Equipment Package - Heavy', 25, 500000, 12500000, DATE '2024-06-25', DATE '2024-06-25', :'scenario3_wbs_usar_id', 'standard'),
    (:'scenario3_po_line_medical_id', :'scenario3_po_medical_id', '10', :'scenario3_commodity_medical_id', 'Mobile Emergency Hospital Unit - Level 1 Trauma', 8, 3000000, 24000000, DATE '2024-06-25', DATE '2024-06-25', :'scenario3_wbs_medical_id', 'standard'),
    (:'scenario3_po_line_power_id', :'scenario3_po_power_id', '10', :'scenario3_commodity_power_id', 'Emergency Power Generation System - 500kW Grid Tie', 12, 1500000, 18000000, DATE '2024-06-25', DATE '2024-06-25', :'scenario3_wbs_power_id', 'standard'),
    (:'scenario3_po_line_water_id', :'scenario3_po_water_id', '10', :'scenario3_commodity_water_id', 'Metropolitan Water Treatment Plant - Portable', 4, 2000000, 8000000, DATE '2024-06-25', DATE '2024-06-25', :'scenario3_wbs_water_id', 'standard'),
    (:'scenario3_po_line_comms_id', :'scenario3_po_comms_id', '10', :'scenario3_commodity_comms_id', 'Emergency Communications Network - Metropolitan Scale', 3, 5000000, 15000000, DATE '2024-06-25', DATE '2024-06-25', :'scenario3_wbs_comms_id', 'standard');

-- Capture executive-level cancellations to feed incident analytics
INSERT INTO scns (id, project_id, scn_number, description, collection_supplier_id, delivery_warehouse_id, forecast_collection_date, forecast_delivery_date, actual_collection_date, actual_delivery_date, status, created_by)
VALUES
    (:'scenario3_scn_usar_id', :'scenario3_project_id', 'SC3E-SCN-3001', 'USAR heavy equipment redeployed to international aid commitment; domestic shipment cancelled.', :'scenario3_supplier_usar_id', :'scenario3_warehouse_melbourne_id', DATE '2024-06-24', DATE '2024-06-26', NULL, NULL, 'cancelled', :'planner_user_id'),
    (:'scenario3_scn_medical_id', :'scenario3_project_id', 'SC3E-SCN-3002', 'Mobile trauma hospitals held pending executive approval; cold chain not mobilised.', :'scenario3_supplier_medical_id', :'scenario3_warehouse_brisbane_id', DATE '2024-06-24', DATE '2024-06-26', NULL, NULL, 'cancelled', :'planner_user_id'),
    (:'scenario3_scn_power_id', :'scenario3_project_id', 'SC3E-SCN-3003', 'Grid-tie power systems requisitioned for defence exercise — delivery cancelled.', :'scenario3_supplier_power_id', :'scenario3_warehouse_melbourne_id', DATE '2024-06-24', DATE '2024-06-27', NULL, NULL, 'cancelled', :'planner_user_id'),
    (:'scenario3_scn_water_id', :'scenario3_project_id', 'SC3E-SCN-3004', 'Metropolitan water treatment assets diverted to drought program.', :'scenario3_supplier_water_id', :'scenario3_warehouse_adelaide_id', DATE '2024-06-24', DATE '2024-06-27', NULL, NULL, 'cancelled', :'planner_user_id'),
    (:'scenario3_scn_comms_id', :'scenario3_project_id', 'SC3E-SCN-3005', 'Secure communications network export licence suspended.', :'scenario3_supplier_comms_id', :'scenario3_warehouse_sydney_id', DATE '2024-06-24', DATE '2024-06-27', NULL, NULL, 'cancelled', :'planner_user_id');

INSERT INTO scn_packages (id, scn_id, package_number, freight_package_id, gross_weight, net_weight, dimensions)
VALUES
    (:'scenario3_scn_package_usar_id', :'scenario3_scn_usar_id', 'PKG-SC3E-3001', uuid_generate_v5('6ba7b810-9dad-11d1-80b4-00c04fd430c8'::uuid, 'scenario3-enhanced-freight-specialized'), 0, 0, 'Cancelled'),
    (:'scenario3_scn_package_medical_id', :'scenario3_scn_medical_id', 'PKG-SC3E-3002', uuid_generate_v5('6ba7b810-9dad-11d1-80b4-00c04fd430c8'::uuid, 'scenario3-enhanced-freight-container'), 0, 0, 'Cancelled'),
    (:'scenario3_scn_package_power_id', :'scenario3_scn_power_id', 'PKG-SC3E-3003', uuid_generate_v5('6ba7b810-9dad-11d1-80b4-00c04fd430c8'::uuid, 'scenario3-enhanced-freight-trailer'), 0, 0, 'Cancelled'),
    (:'scenario3_scn_package_water_id', :'scenario3_scn_water_id', 'PKG-SC3E-3004', uuid_generate_v5('6ba7b810-9dad-11d1-80b4-00c04fd430c8'::uuid, 'scenario3-enhanced-freight-specialized'), 0, 0, 'Cancelled'),
    (:'scenario3_scn_package_comms_id', :'scenario3_scn_comms_id', 'PKG-SC3E-3005', uuid_generate_v5('6ba7b810-9dad-11d1-80b4-00c04fd430c8'::uuid, 'scenario3-enhanced-freight-container'), 0, 0, 'Cancelled');

INSERT INTO scn_line_items (id, scn_id, package_id, po_line_item_id, quantity)
VALUES
    (:'scenario3_scn_line_usar_id', :'scenario3_scn_usar_id', :'scenario3_scn_package_usar_id', :'scenario3_po_line_usar_id', 0),
    (:'scenario3_scn_line_medical_id', :'scenario3_scn_medical_id', :'scenario3_scn_package_medical_id', :'scenario3_po_line_medical_id', 0),
    (:'scenario3_scn_line_power_id', :'scenario3_scn_power_id', :'scenario3_scn_package_power_id', :'scenario3_po_line_power_id', 0),
    (:'scenario3_scn_line_water_id', :'scenario3_scn_water_id', :'scenario3_scn_package_water_id', :'scenario3_po_line_water_id', 0),
    (:'scenario3_scn_line_comms_id', :'scenario3_scn_comms_id', :'scenario3_scn_package_comms_id', :'scenario3_po_line_comms_id', 0);

-- Warehouse inventory - National strategic reserves with executive approval requirements
INSERT INTO warehouse_inventory (id, project_id, warehouse_id, commodity_code_id, wbs_id, quantity_available, quantity_reserved, quantity_hard_reserved, safety_stock_level, status, last_receipt_id)
VALUES
    -- Sydney Metro Emergency Vault
    (uuid_generate_v5('6ba7b810-9dad-11d1-80b4-00c04fd430c8'::uuid, 'scenario3-enhanced-inventory-sydney-usar'), :'scenario3_project_id', :'scenario3_warehouse_sydney_id', :'scenario3_commodity_usar_id', :'scenario3_wbs_usar_id', 8, 2, 0, 1, 'executive_approval', NULL),
    (uuid_generate_v5('6ba7b810-9dad-11d1-80b4-00c04fd430c8'::uuid, 'scenario3-enhanced-inventory-sydney-medical'), :'scenario3_project_id', :'scenario3_warehouse_sydney_id', :'scenario3_commodity_medical_id', :'scenario3_wbs_medical_id', 3, 0, 0, 1, 'executive_approval', NULL),
    (uuid_generate_v5('6ba7b810-9dad-11d1-80b4-00c04fd430c8'::uuid, 'scenario3-enhanced-inventory-sydney-comms'), :'scenario3_project_id', :'scenario3_warehouse_sydney_id', :'scenario3_commodity_comms_id', :'scenario3_wbs_comms_id', 1, 0, 0, 0, 'executive_approval', NULL),

    -- Melbourne Strategic Reserve
    (uuid_generate_v5('6ba7b810-9dad-11d1-80b4-00c04fd430c8'::uuid, 'scenario3-enhanced-inventory-melbourne-usar'), :'scenario3_project_id', :'scenario3_warehouse_melbourne_id', :'scenario3_commodity_usar_id', :'scenario3_wbs_usar_id', 22, 0, 0, 2, 'executive_approval', NULL),
    (uuid_generate_v5('6ba7b810-9dad-11d1-80b4-00c04fd430c8'::uuid, 'scenario3-enhanced-inventory-melbourne-power'), :'scenario3_project_id', :'scenario3_warehouse_melbourne_id', :'scenario3_commodity_power_id', :'scenario3_wbs_power_id', 15, 3, 0, 2, 'executive_approval', NULL),
    (uuid_generate_v5('6ba7b810-9dad-11d1-80b4-00c04fd430c8'::uuid, 'scenario3-enhanced-inventory-melbourne-comms'), :'scenario3_project_id', :'scenario3_warehouse_melbourne_id', :'scenario3_commodity_comms_id', :'scenario3_wbs_comms_id', 4, 1, 0, 1, 'executive_approval', NULL),

    -- Brisbane Emergency Command
    (uuid_generate_v5('6ba7b810-9dad-11d1-80b4-00c04fd430c8'::uuid, 'scenario3-enhanced-inventory-brisbane-medical'), :'scenario3_project_id', :'scenario3_warehouse_brisbane_id', :'scenario3_commodity_medical_id', :'scenario3_wbs_medical_id', 6, 1, 0, 1, 'executive_approval', NULL),

    -- Perth Critical Infrastructure Hub
    (uuid_generate_v5('6ba7b810-9dad-11d1-80b4-00c04fd430c8'::uuid, 'scenario3-enhanced-inventory-perth-power'), :'scenario3_project_id', :'scenario3_warehouse_perth_id', :'scenario3_commodity_power_id', :'scenario3_wbs_power_id', 9, 0, 0, 1, 'executive_approval', NULL),

    -- Adelaide Water Security Centre
    (uuid_generate_v5('6ba7b810-9dad-11d1-80b4-00c04fd430c8'::uuid, 'scenario3-enhanced-inventory-adelaide-water'), :'scenario3_project_id', :'scenario3_warehouse_adelaide_id', :'scenario3_commodity_water_id', :'scenario3_wbs_water_id', 2, 0, 0, 1, 'executive_approval', NULL),

    -- Darwin Strategic Assets
    (uuid_generate_v5('6ba7b810-9dad-11d1-80b4-00c04fd430c8'::uuid, 'scenario3-enhanced-inventory-darwin-water'), :'scenario3_project_id', :'scenario3_warehouse_darwin_id', :'scenario3_commodity_water_id', :'scenario3_wbs_water_id', 5, 1, 0, 1, 'executive_approval', NULL);

-- Critical executive-level inventory reservations with national security implications
-- Notes from the design are preserved in-line as comments for operator context.
INSERT INTO inventory_reservations (id, inventory_id, reserved_quantity, reserved_for_entity_type, reserved_for_entity_id, reservation_type, priority_level, required_by_date, can_reassign, created_by)
VALUES
    -- Next required: 2024-07-15 | Priority: 95 | Displaces national training program
    (uuid_generate_v5('6ba7b810-9dad-11d1-80b4-00c04fd430c8'::uuid, 'scenario3-enhanced-reservation-sydney-usar'),
     uuid_generate_v5('6ba7b810-9dad-11d1-80b4-00c04fd430c8'::uuid, 'scenario3-enhanced-inventory-sydney-usar'),
     2, 'project', :'scenario3_project_id', 'hard', 95, DATE '2024-07-15', FALSE, :'planner_user_id'),
    -- Next required: 2024-08-01 | Priority: 90 | International aid commitment
    (uuid_generate_v5('6ba7b810-9dad-11d1-80b4-00c04fd430c8'::uuid, 'scenario3-enhanced-reservation-melbourne-usar'),
     uuid_generate_v5('6ba7b810-9dad-11d1-80b4-00c04fd430c8'::uuid, 'scenario3-enhanced-inventory-melbourne-usar'),
     0, 'project', :'scenario3_project_id', 'soft', 90, DATE '2024-08-01', FALSE, :'planner_user_id'),
    -- Next required: 2024-07-01 | Priority: 98 | State health system backbone
    (uuid_generate_v5('6ba7b810-9dad-11d1-80b4-00c04fd430c8'::uuid, 'scenario3-enhanced-reservation-sydney-medical'),
     uuid_generate_v5('6ba7b810-9dad-11d1-80b4-00c04fd430c8'::uuid, 'scenario3-enhanced-inventory-sydney-medical'),
     0, 'project', :'scenario3_project_id', 'soft', 98, DATE '2024-07-01', FALSE, :'planner_user_id'),
    -- Next required: 2024-07-10 | Priority: 92 | Queensland disaster preparedness
    (uuid_generate_v5('6ba7b810-9dad-11d1-80b4-00c04fd430c8'::uuid, 'scenario3-enhanced-reservation-brisbane-medical'),
     uuid_generate_v5('6ba7b810-9dad-11d1-80b4-00c04fd430c8'::uuid, 'scenario3-enhanced-inventory-brisbane-medical'),
     1, 'project', :'scenario3_project_id', 'soft', 92, DATE '2024-07-10', FALSE, :'planner_user_id'),
    -- Next required: 2024-08-15 | Priority: 88 | Mining sector emergency backup
    (uuid_generate_v5('6ba7b810-9dad-11d1-80b4-00c04fd430c8'::uuid, 'scenario3-enhanced-reservation-perth-power'),
     uuid_generate_v5('6ba7b810-9dad-11d1-80b4-00c04fd430c8'::uuid, 'scenario3-enhanced-inventory-perth-power'),
     0, 'project', :'scenario3_project_id', 'soft', 88, DATE '2024-08-15', FALSE, :'planner_user_id'),
    -- Next required: 2024-07-05 | Priority: 85 | Victoria state emergency reserve
    (uuid_generate_v5('6ba7b810-9dad-11d1-80b4-00c04fd430c8'::uuid, 'scenario3-enhanced-reservation-melbourne-power'),
     uuid_generate_v5('6ba7b810-9dad-11d1-80b4-00c04fd430c8'::uuid, 'scenario3-enhanced-inventory-melbourne-power'),
     3, 'project', :'scenario3_project_id', 'soft', 85, DATE '2024-07-05', FALSE, :'planner_user_id'),
    -- Next required: 2024-09-01 | Priority: 96 | South Australia drought contingency
    (uuid_generate_v5('6ba7b810-9dad-11d1-80b4-00c04fd430c8'::uuid, 'scenario3-enhanced-reservation-adelaide-water'),
     uuid_generate_v5('6ba7b810-9dad-11d1-80b4-00c04fd430c8'::uuid, 'scenario3-enhanced-inventory-adelaide-water'),
     0, 'project', :'scenario3_project_id', 'soft', 96, DATE '2024-09-01', FALSE, :'planner_user_id'),
    -- Next required: 2024-08-30 | Priority: 89 | Northern Territory cyclone season
    (uuid_generate_v5('6ba7b810-9dad-11d1-80b4-00c04fd430c8'::uuid, 'scenario3-enhanced-reservation-darwin-water'),
     uuid_generate_v5('6ba7b810-9dad-11d1-80b4-00c04fd430c8'::uuid, 'scenario3-enhanced-inventory-darwin-water'),
     1, 'project', :'scenario3_project_id', 'soft', 89, DATE '2024-08-30', FALSE, :'planner_user_id'),
    -- Next required: 2025-06-30 | Priority: 99 | National security communications backup
    (uuid_generate_v5('6ba7b810-9dad-11d1-80b4-00c04fd430c8'::uuid, 'scenario3-enhanced-reservation-sydney-comms'),
     uuid_generate_v5('6ba7b810-9dad-11d1-80b4-00c04fd430c8'::uuid, 'scenario3-enhanced-inventory-sydney-comms'),
     0, 'project', :'scenario3_project_id', 'soft', 99, DATE '2025-06-30', FALSE, :'planner_user_id'),
    -- Next required: 2024-08-20 | Priority: 87 | Victoria emergency services backbone
    (uuid_generate_v5('6ba7b810-9dad-11d1-80b4-00c04fd430c8'::uuid, 'scenario3-enhanced-reservation-melbourne-comms'),
     uuid_generate_v5('6ba7b810-9dad-11d1-80b4-00c04fd430c8'::uuid, 'scenario3-enhanced-inventory-melbourne-comms'),
     1, 'project', :'scenario3_project_id', 'soft', 87, DATE '2024-08-20', FALSE, :'planner_user_id');

-- Emergency accommodation storyline
INSERT INTO emergency_incidents (id, project_id, scn_id, incident_type, incident_date, reported_by, description, status, resolution_notes)
VALUES (
    :'scenario3_incident_id',
    :'scenario3_project_id',
    NULL,
    'major_earthquake',
    TIMESTAMP WITH TIME ZONE '2024-06-30 05:45+00',
    :'incident_user_id',
    'Magnitude 7.2 earthquake struck Sydney metropolitan area at 05:45 affecting 2 million people. Major infrastructure collapse including hospitals, power grid, water treatment facilities, and communications networks. Executive-level resource allocation decisions required with national security implications and cross-state coordination. Budget constraints suspended for first 72 hours.',
    'active',
    'Executive-level emergency accommodation search initiated for USAR equipment, mobile hospitals, grid-tie power systems, water treatment plants, and communications networks with national security clearance requirements.'
);

-- Quick verification hooks (left commented for operators)
-- SELECT * FROM fn_emergency_inventory_search(:'scenario3_po_line_usar_id');
-- SELECT * FROM fn_emergency_inventory_search(:'scenario3_po_line_medical_id');
-- SELECT * FROM fn_emergency_inventory_search(:'scenario3_po_line_power_id');
-- SELECT * FROM fn_emergency_inventory_search(:'scenario3_po_line_water_id');
-- SELECT * FROM fn_emergency_inventory_search(:'scenario3_po_line_comms_id');
