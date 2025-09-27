\set ON_ERROR_STOP on

-- Deterministic identifiers for scenario entities - Enhanced scenario with unique namespace
SELECT
    uuid_generate_v5('e4b7c9d2-1a3b-4c5d-6e7f-890123456789'::uuid, 'scenario1-enhanced-project')              AS scenario1_project_id,
    uuid_generate_v5('e4b7c9d2-1a3b-4c5d-6e7f-890123456789'::uuid, 'scenario1-enhanced-wbs-root')             AS scenario1_wbs_root_id,
    uuid_generate_v5('e4b7c9d2-1a3b-4c5d-6e7f-890123456789'::uuid, 'scenario1-enhanced-wbs-shelter')          AS scenario1_wbs_shelter_id,
    uuid_generate_v5('e4b7c9d2-1a3b-4c5d-6e7f-890123456789'::uuid, 'scenario1-enhanced-wbs-power')            AS scenario1_wbs_power_id,
    uuid_generate_v5('e4b7c9d2-1a3b-4c5d-6e7f-890123456789'::uuid, 'scenario1-enhanced-wbs-water')            AS scenario1_wbs_water_id,
    uuid_generate_v5('e4b7c9d2-1a3b-4c5d-6e7f-890123456789'::uuid, 'scenario1-enhanced-wbs-medical')          AS scenario1_wbs_medical_id,
    uuid_generate_v5('e4b7c9d2-1a3b-4c5d-6e7f-890123456789'::uuid, 'scenario1-enhanced-wbs-comms')            AS scenario1_wbs_comms_id,
    -- Multiple suppliers
    uuid_generate_v5('e4b7c9d2-1a3b-4c5d-6e7f-890123456789'::uuid, 'scenario1-enhanced-supplier-shelter')      AS scenario1_supplier_shelter_id,
    uuid_generate_v5('e4b7c9d2-1a3b-4c5d-6e7f-890123456789'::uuid, 'scenario1-enhanced-supplier-power')        AS scenario1_supplier_power_id,
    uuid_generate_v5('e4b7c9d2-1a3b-4c5d-6e7f-890123456789'::uuid, 'scenario1-enhanced-supplier-water')        AS scenario1_supplier_water_id,
    uuid_generate_v5('e4b7c9d2-1a3b-4c5d-6e7f-890123456789'::uuid, 'scenario1-enhanced-supplier-medical')      AS scenario1_supplier_medical_id,
    uuid_generate_v5('e4b7c9d2-1a3b-4c5d-6e7f-890123456789'::uuid, 'scenario1-enhanced-supplier-comms')        AS scenario1_supplier_comms_id,
    -- Multiple warehouses with geographic distribution
    uuid_generate_v5('e4b7c9d2-1a3b-4c5d-6e7f-890123456789'::uuid, 'scenario1-enhanced-warehouse-newcastle')   AS scenario1_warehouse_newcastle_id,
    uuid_generate_v5('e4b7c9d2-1a3b-4c5d-6e7f-890123456789'::uuid, 'scenario1-enhanced-warehouse-sydney')      AS scenario1_warehouse_sydney_id,
    uuid_generate_v5('e4b7c9d2-1a3b-4c5d-6e7f-890123456789'::uuid, 'scenario1-enhanced-warehouse-brisbane')    AS scenario1_warehouse_brisbane_id,
    uuid_generate_v5('e4b7c9d2-1a3b-4c5d-6e7f-890123456789'::uuid, 'scenario1-enhanced-warehouse-canberra')    AS scenario1_warehouse_canberra_id,
    uuid_generate_v5('e4b7c9d2-1a3b-4c5d-6e7f-890123456789'::uuid, 'scenario1-enhanced-warehouse-adelaide')    AS scenario1_warehouse_adelaide_id,
    -- Units of measure
    uuid_generate_v5('e4b7c9d2-1a3b-4c5d-6e7f-890123456789'::uuid, 'scenario1-enhanced-uom-kit')               AS scenario1_uom_kit_id,
    uuid_generate_v5('e4b7c9d2-1a3b-4c5d-6e7f-890123456789'::uuid, 'scenario1-enhanced-uom-unit')              AS scenario1_uom_unit_id,
    uuid_generate_v5('e4b7c9d2-1a3b-4c5d-6e7f-890123456789'::uuid, 'scenario1-enhanced-uom-system')            AS scenario1_uom_system_id,
    uuid_generate_v5('e4b7c9d2-1a3b-4c5d-6e7f-890123456789'::uuid, 'scenario1-enhanced-uom-cache')             AS scenario1_uom_cache_id,
    uuid_generate_v5('e4b7c9d2-1a3b-4c5d-6e7f-890123456789'::uuid, 'scenario1-enhanced-uom-package')           AS scenario1_uom_package_id,
    -- Commodity codes
    uuid_generate_v5('e4b7c9d2-1a3b-4c5d-6e7f-890123456789'::uuid, 'scenario1-enhanced-commodity-shelter')     AS scenario1_commodity_shelter_id,
    uuid_generate_v5('e4b7c9d2-1a3b-4c5d-6e7f-890123456789'::uuid, 'scenario1-enhanced-commodity-power')       AS scenario1_commodity_power_id,
    uuid_generate_v5('e4b7c9d2-1a3b-4c5d-6e7f-890123456789'::uuid, 'scenario1-enhanced-commodity-water')       AS scenario1_commodity_water_id,
    uuid_generate_v5('e4b7c9d2-1a3b-4c5d-6e7f-890123456789'::uuid, 'scenario1-enhanced-commodity-medical')     AS scenario1_commodity_medical_id,
    uuid_generate_v5('e4b7c9d2-1a3b-4c5d-6e7f-890123456789'::uuid, 'scenario1-enhanced-commodity-comms')       AS scenario1_commodity_comms_id,
    -- MTOs for each commodity
    uuid_generate_v5('e4b7c9d2-1a3b-4c5d-6e7f-890123456789'::uuid, 'scenario1-enhanced-mto-shelter')           AS scenario1_mto_shelter_id,
    uuid_generate_v5('e4b7c9d2-1a3b-4c5d-6e7f-890123456789'::uuid, 'scenario1-enhanced-mto-power')             AS scenario1_mto_power_id,
    uuid_generate_v5('e4b7c9d2-1a3b-4c5d-6e7f-890123456789'::uuid, 'scenario1-enhanced-mto-water')             AS scenario1_mto_water_id,
    uuid_generate_v5('e4b7c9d2-1a3b-4c5d-6e7f-890123456789'::uuid, 'scenario1-enhanced-mto-medical')           AS scenario1_mto_medical_id,
    uuid_generate_v5('e4b7c9d2-1a3b-4c5d-6e7f-890123456789'::uuid, 'scenario1-enhanced-mto-comms')             AS scenario1_mto_comms_id,
    -- MTO line items
    uuid_generate_v5('e4b7c9d2-1a3b-4c5d-6e7f-890123456789'::uuid, 'scenario1-enhanced-mto-line-shelter')      AS scenario1_mto_line_shelter_id,
    uuid_generate_v5('e4b7c9d2-1a3b-4c5d-6e7f-890123456789'::uuid, 'scenario1-enhanced-mto-line-power')        AS scenario1_mto_line_power_id,
    uuid_generate_v5('e4b7c9d2-1a3b-4c5d-6e7f-890123456789'::uuid, 'scenario1-enhanced-mto-line-water')        AS scenario1_mto_line_water_id,
    uuid_generate_v5('e4b7c9d2-1a3b-4c5d-6e7f-890123456789'::uuid, 'scenario1-enhanced-mto-line-medical')      AS scenario1_mto_line_medical_id,
    uuid_generate_v5('e4b7c9d2-1a3b-4c5d-6e7f-890123456789'::uuid, 'scenario1-enhanced-mto-line-comms')        AS scenario1_mto_line_comms_id,
    -- Purchase orders
    uuid_generate_v5('e4b7c9d2-1a3b-4c5d-6e7f-890123456789'::uuid, 'scenario1-enhanced-po-shelter')            AS scenario1_po_shelter_id,
    uuid_generate_v5('e4b7c9d2-1a3b-4c5d-6e7f-890123456789'::uuid, 'scenario1-enhanced-po-power')              AS scenario1_po_power_id,
    uuid_generate_v5('e4b7c9d2-1a3b-4c5d-6e7f-890123456789'::uuid, 'scenario1-enhanced-po-water')              AS scenario1_po_water_id,
    uuid_generate_v5('e4b7c9d2-1a3b-4c5d-6e7f-890123456789'::uuid, 'scenario1-enhanced-po-medical')            AS scenario1_po_medical_id,
    uuid_generate_v5('e4b7c9d2-1a3b-4c5d-6e7f-890123456789'::uuid, 'scenario1-enhanced-po-comms')              AS scenario1_po_comms_id,
    -- PO line items
    uuid_generate_v5('e4b7c9d2-1a3b-4c5d-6e7f-890123456789'::uuid, 'scenario1-enhanced-po-line-shelter')       AS scenario1_po_line_shelter_id,
    uuid_generate_v5('e4b7c9d2-1a3b-4c5d-6e7f-890123456789'::uuid, 'scenario1-enhanced-po-line-power')         AS scenario1_po_line_power_id,
    uuid_generate_v5('e4b7c9d2-1a3b-4c5d-6e7f-890123456789'::uuid, 'scenario1-enhanced-po-line-water')         AS scenario1_po_line_water_id,
    uuid_generate_v5('e4b7c9d2-1a3b-4c5d-6e7f-890123456789'::uuid, 'scenario1-enhanced-po-line-medical')       AS scenario1_po_line_medical_id,
    uuid_generate_v5('e4b7c9d2-1a3b-4c5d-6e7f-890123456789'::uuid, 'scenario1-enhanced-po-line-comms')         AS scenario1_po_line_comms_id,
    -- Shipment coordination numbers (SCNs) and related artefacts
    uuid_generate_v5('e4b7c9d2-1a3b-4c5d-6e7f-890123456789'::uuid, 'scenario1-enhanced-scn-shelter')           AS scenario1_scn_shelter_id,
    uuid_generate_v5('e4b7c9d2-1a3b-4c5d-6e7f-890123456789'::uuid, 'scenario1-enhanced-scn-power')             AS scenario1_scn_power_id,
    uuid_generate_v5('e4b7c9d2-1a3b-4c5d-6e7f-890123456789'::uuid, 'scenario1-enhanced-scn-water')             AS scenario1_scn_water_id,
    uuid_generate_v5('e4b7c9d2-1a3b-4c5d-6e7f-890123456789'::uuid, 'scenario1-enhanced-scn-medical')           AS scenario1_scn_medical_id,
    uuid_generate_v5('e4b7c9d2-1a3b-4c5d-6e7f-890123456789'::uuid, 'scenario1-enhanced-scn-comms')             AS scenario1_scn_comms_id,
    uuid_generate_v5('e4b7c9d2-1a3b-4c5d-6e7f-890123456789'::uuid, 'scenario1-enhanced-scn-package-shelter')    AS scenario1_scn_package_shelter_id,
    uuid_generate_v5('e4b7c9d2-1a3b-4c5d-6e7f-890123456789'::uuid, 'scenario1-enhanced-scn-package-power')      AS scenario1_scn_package_power_id,
    uuid_generate_v5('e4b7c9d2-1a3b-4c5d-6e7f-890123456789'::uuid, 'scenario1-enhanced-scn-package-water')      AS scenario1_scn_package_water_id,
    uuid_generate_v5('e4b7c9d2-1a3b-4c5d-6e7f-890123456789'::uuid, 'scenario1-enhanced-scn-package-medical')    AS scenario1_scn_package_medical_id,
    uuid_generate_v5('e4b7c9d2-1a3b-4c5d-6e7f-890123456789'::uuid, 'scenario1-enhanced-scn-package-comms')      AS scenario1_scn_package_comms_id,
    uuid_generate_v5('e4b7c9d2-1a3b-4c5d-6e7f-890123456789'::uuid, 'scenario1-enhanced-scn-line-shelter')       AS scenario1_scn_line_shelter_id,
    uuid_generate_v5('e4b7c9d2-1a3b-4c5d-6e7f-890123456789'::uuid, 'scenario1-enhanced-scn-line-power')         AS scenario1_scn_line_power_id,
    uuid_generate_v5('e4b7c9d2-1a3b-4c5d-6e7f-890123456789'::uuid, 'scenario1-enhanced-scn-line-water')         AS scenario1_scn_line_water_id,
    uuid_generate_v5('e4b7c9d2-1a3b-4c5d-6e7f-890123456789'::uuid, 'scenario1-enhanced-scn-line-medical')       AS scenario1_scn_line_medical_id,
    uuid_generate_v5('e4b7c9d2-1a3b-4c5d-6e7f-890123456789'::uuid, 'scenario1-enhanced-scn-line-comms')         AS scenario1_scn_line_comms_id,
    -- Emergency incident
    uuid_generate_v5('e4b7c9d2-1a3b-4c5d-6e7f-890123456789'::uuid, 'scenario1-enhanced-incident')              AS scenario1_incident_id
\gset

-- Remove any previous run for this scenario (cascades to child records)
-- Enhanced scenarios use unique UUIDs to avoid conflicts with base scenarios

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
    'Enhanced Scenario 1 - Hurricane Evacuation Response',
    'Large-scale hurricane evacuation response requiring multi-commodity emergency accommodation across 5 critical resource categories.',
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
VALUES
    (:'scenario1_uom_kit_id', :'scenario1_project_id', 'Kit', 'KIT', TRUE),
    (:'scenario1_uom_unit_id', :'scenario1_project_id', 'Unit', 'UNIT', FALSE),
    (:'scenario1_uom_system_id', :'scenario1_project_id', 'System', 'SYSTEM', FALSE),
    (:'scenario1_uom_cache_id', :'scenario1_project_id', 'Cache', 'CACHE', FALSE),
    (:'scenario1_uom_package_id', :'scenario1_project_id', 'Package', 'PKG', FALSE);

INSERT INTO freight_packages (id, project_id, package_type)
VALUES
    (uuid_generate_v5('e4b7c9d2-1a3b-4c5d-6e7f-890123456789'::uuid, 'scenario1-enhanced-freight-pallet'), :'scenario1_project_id', 'Pallet'),
    (uuid_generate_v5('e4b7c9d2-1a3b-4c5d-6e7f-890123456789'::uuid, 'scenario1-enhanced-freight-container'), :'scenario1_project_id', 'Container');

INSERT INTO document_types (id, project_id, type_name)
VALUES (uuid_generate_v5('e4b7c9d2-1a3b-4c5d-6e7f-890123456789'::uuid, 'scenario1-enhanced-doc-docket'), :'scenario1_project_id', 'Delivery Docket');

-- Work Breakdown Structure
INSERT INTO wbs (id, project_id, code, name, parent_id, level, sort_order, path)
VALUES
    (:'scenario1_wbs_root_id', :'scenario1_project_id', 'SC1E', 'Enhanced Scenario 1 Root', NULL, 0, 1, 'SC1E'),
    (:'scenario1_wbs_shelter_id', :'scenario1_project_id', 'SC1E.1', 'Emergency Shelter Systems', :'scenario1_wbs_root_id', 1, 10, 'SC1E>SC1E.1'),
    (:'scenario1_wbs_power_id', :'scenario1_project_id', 'SC1E.2', 'Power Generation Systems', :'scenario1_wbs_root_id', 1, 20, 'SC1E>SC1E.2'),
    (:'scenario1_wbs_water_id', :'scenario1_project_id', 'SC1E.3', 'Water Treatment Systems', :'scenario1_wbs_root_id', 1, 30, 'SC1E>SC1E.3'),
    (:'scenario1_wbs_medical_id', :'scenario1_project_id', 'SC1E.4', 'Medical Supply Systems', :'scenario1_wbs_root_id', 1, 40, 'SC1E>SC1E.4'),
    (:'scenario1_wbs_comms_id', :'scenario1_project_id', 'SC1E.5', 'Communications Systems', :'scenario1_wbs_root_id', 1, 50, 'SC1E>SC1E.5');

INSERT INTO wbs_ros_dates (wbs_id, ros_date)
VALUES
    (:'scenario1_wbs_shelter_id', DATE '2024-05-12'),
    (:'scenario1_wbs_power_id', DATE '2024-05-12'),
    (:'scenario1_wbs_water_id', DATE '2024-05-12'),
    (:'scenario1_wbs_medical_id', DATE '2024-05-12'),
    (:'scenario1_wbs_comms_id', DATE '2024-05-12');

-- Supply chain master data - Multiple suppliers
INSERT INTO suppliers (id, project_id, supplier_code, name, contact_name, contact_email, country_code, incoterm)
VALUES
    (:'scenario1_supplier_shelter_id', :'scenario1_project_id', 'SUP-SHELTER', 'Emergency Shelter Solutions', 'Morgan Taylor', 'morgan.taylor@shelter.example', 'AU', 'DAP'),
    (:'scenario1_supplier_power_id', :'scenario1_project_id', 'SUP-POWER', 'PowerTech Emergency Systems', 'Jordan Cross', 'jordan.cross@powertech.example', 'AU', 'DAP'),
    (:'scenario1_supplier_water_id', :'scenario1_project_id', 'SUP-WATER', 'AquaFlow Emergency Solutions', 'Riley Santos', 'riley.santos@aquaflow.example', 'AU', 'DAP'),
    (:'scenario1_supplier_medical_id', :'scenario1_project_id', 'SUP-MEDICAL', 'MedResponse Australia', 'Casey Liu', 'casey.liu@medresponse.example', 'AU', 'DAP'),
    (:'scenario1_supplier_comms_id', :'scenario1_project_id', 'SUP-COMMS', 'CommLink Emergency Networks', 'Sage Mitchell', 'sage.mitchell@commlink.example', 'AU', 'DAP');

-- Multiple warehouses with geographic distribution
INSERT INTO warehouses (id, project_id, name, warehouse_code, description, city, country_code, is_active)
VALUES
    (:'scenario1_warehouse_newcastle_id', :'scenario1_project_id', 'Newcastle Regional Emergency Depot', 'WH-NEWCASTLE', 'Primary emergency response depot for NSW coastal region.', 'Newcastle', 'AU', TRUE),
    (:'scenario1_warehouse_sydney_id', :'scenario1_project_id', 'Sydney Metropolitan Reserve', 'WH-SYDNEY', 'Metropolitan emergency supply reserve for greater Sydney area.', 'Sydney', 'AU', TRUE),
    (:'scenario1_warehouse_brisbane_id', :'scenario1_project_id', 'Brisbane Emergency Logistics Hub', 'WH-BRISBANE', 'Queensland emergency logistics coordination center.', 'Brisbane', 'AU', TRUE),
    (:'scenario1_warehouse_canberra_id', :'scenario1_project_id', 'Canberra Strategic Reserve', 'WH-CANBERRA', 'National strategic emergency equipment reserve.', 'Canberra', 'AU', TRUE),
    (:'scenario1_warehouse_adelaide_id', :'scenario1_project_id', 'Adelaide Emergency Coordination Centre', 'WH-ADELAIDE', 'South Australia emergency response coordination facility.', 'Adelaide', 'AU', TRUE);

-- Commodity codes for multiple commodity types
INSERT INTO commodity_codes (id, project_id, engineered_code, short_description, long_description, commodity_class, unit_of_measure_id)
VALUES
    (:'scenario1_commodity_shelter_id', :'scenario1_project_id', 'COM-EMERG-SHELTER-FAMILY', 'Emergency Family Shelter Kit', 'Complete family shelter kit including weatherproof frame, canopy, ground cover, and anchoring hardware for 4-person capacity.', 'Emergency Shelters', :'scenario1_uom_kit_id'),
    (:'scenario1_commodity_power_id', :'scenario1_project_id', 'COM-POWER-GEN-5KW', 'Portable Power Generation Unit 5kW', 'Diesel-powered portable generator system with 5kW output capacity, fuel tank, and distribution panel.', 'Power Generation', :'scenario1_uom_unit_id'),
    (:'scenario1_commodity_water_id', :'scenario1_project_id', 'COM-WATER-PURIFY-MOB', 'Water Purification System - Mobile', 'Mobile water treatment and purification system capable of processing 1000L/hour from contaminated sources.', 'Water Systems', :'scenario1_uom_system_id'),
    (:'scenario1_commodity_medical_id', :'scenario1_project_id', 'COM-MED-EMERGENCY-CACHE', 'Emergency Medical Supply Cache', 'Comprehensive emergency medical supply cache including trauma supplies, medications, and basic surgical equipment.', 'Medical Supplies', :'scenario1_uom_cache_id'),
    (:'scenario1_commodity_comms_id', :'scenario1_project_id', 'COM-COMM-EMERGENCY-PKG', 'Communications Equipment Package', 'Emergency communications package including satellite uplink, radio systems, and emergency broadcast capability.', 'Communications', :'scenario1_uom_package_id');

-- Planning artefacts - Multiple MTOs
INSERT INTO mtos (id, project_id, mto_number, title, revision, status, issued_date, created_by)
VALUES
    (:'scenario1_mto_shelter_id', :'scenario1_project_id', 'MTO-SC1E-001', 'Hurricane Emergency Shelter Requirements', 'A', 'issued', DATE '2024-04-25', :'planner_user_id'),
    (:'scenario1_mto_power_id', :'scenario1_project_id', 'MTO-SC1E-002', 'Emergency Power Generation Requirements', 'A', 'issued', DATE '2024-04-25', :'planner_user_id'),
    (:'scenario1_mto_water_id', :'scenario1_project_id', 'MTO-SC1E-003', 'Water Treatment System Requirements', 'A', 'issued', DATE '2024-04-25', :'planner_user_id'),
    (:'scenario1_mto_medical_id', :'scenario1_project_id', 'MTO-SC1E-004', 'Emergency Medical Supply Requirements', 'A', 'issued', DATE '2024-04-25', :'planner_user_id'),
    (:'scenario1_mto_comms_id', :'scenario1_project_id', 'MTO-SC1E-005', 'Emergency Communications Requirements', 'A', 'issued', DATE '2024-04-25', :'planner_user_id');

-- MTO line items with realistic hurricane-scale quantities
INSERT INTO mto_line_items (id, mto_id, line_number, commodity_code_id, description, quantity, unit_of_measure_id, wbs_id)
VALUES
    (:'scenario1_mto_line_shelter_id', :'scenario1_mto_shelter_id', '10', :'scenario1_commodity_shelter_id', 'Emergency Family Shelter Kit', 2500, :'scenario1_uom_kit_id', :'scenario1_wbs_shelter_id'),
    (:'scenario1_mto_line_power_id', :'scenario1_mto_power_id', '10', :'scenario1_commodity_power_id', 'Portable Power Generation Unit 5kW', 150, :'scenario1_uom_unit_id', :'scenario1_wbs_power_id'),
    (:'scenario1_mto_line_water_id', :'scenario1_mto_water_id', '10', :'scenario1_commodity_water_id', 'Water Purification System - Mobile', 25, :'scenario1_uom_system_id', :'scenario1_wbs_water_id'),
    (:'scenario1_mto_line_medical_id', :'scenario1_mto_medical_id', '10', :'scenario1_commodity_medical_id', 'Emergency Medical Supply Cache', 75, :'scenario1_uom_cache_id', :'scenario1_wbs_medical_id'),
    (:'scenario1_mto_line_comms_id', :'scenario1_mto_comms_id', '10', :'scenario1_commodity_comms_id', 'Communications Equipment Package', 40, :'scenario1_uom_package_id', :'scenario1_wbs_comms_id');

-- Purchase orders
INSERT INTO purchase_orders (id, project_id, po_number, supplier_id, mto_id, status, currency, order_date, expected_delivery_date, total_value, created_by)
VALUES
    (:'scenario1_po_shelter_id', :'scenario1_project_id', 'SC1E-PO-1001', :'scenario1_supplier_shelter_id', :'scenario1_mto_shelter_id', 'delivered', 'AUD', DATE '2024-04-26', DATE '2024-05-05', 15625000, :'planner_user_id'),
    (:'scenario1_po_power_id', :'scenario1_project_id', 'SC1E-PO-1002', :'scenario1_supplier_power_id', :'scenario1_mto_power_id', 'cancelled', 'AUD', DATE '2024-04-26', DATE '2024-05-05', 2250000, :'planner_user_id'),
    (:'scenario1_po_water_id', :'scenario1_project_id', 'SC1E-PO-1003', :'scenario1_supplier_water_id', :'scenario1_mto_water_id', 'cancelled', 'AUD', DATE '2024-04-26', DATE '2024-05-05', 875000, :'planner_user_id'),
    (:'scenario1_po_medical_id', :'scenario1_project_id', 'SC1E-PO-1004', :'scenario1_supplier_medical_id', :'scenario1_mto_medical_id', 'cancelled', 'AUD', DATE '2024-04-26', DATE '2024-05-05', 1125000, :'planner_user_id'),
    (:'scenario1_po_comms_id', :'scenario1_project_id', 'SC1E-PO-1005', :'scenario1_supplier_comms_id', :'scenario1_mto_comms_id', 'cancelled', 'AUD', DATE '2024-04-26', DATE '2024-05-05', 800000, :'planner_user_id');

-- PO line items - Failed shipments (cancelled orders)
INSERT INTO po_line_items (id, po_id, line_number, commodity_code_id, description, quantity_ordered, unit_price, line_value, contractual_delivery_date, forecast_delivery_date, wbs_id, line_type)
VALUES
    (:'scenario1_po_line_shelter_id', :'scenario1_po_shelter_id', '10', :'scenario1_commodity_shelter_id', 'Emergency Family Shelter Kit', 2500, 6250, 15625000, DATE '2024-05-05', DATE '2024-05-05', :'scenario1_wbs_shelter_id', 'standard'),
    (:'scenario1_po_line_power_id', :'scenario1_po_power_id', '10', :'scenario1_commodity_power_id', 'Portable Power Generation Unit 5kW', 150, 15000, 2250000, DATE '2024-05-05', DATE '2024-05-05', :'scenario1_wbs_power_id', 'standard'),
    (:'scenario1_po_line_water_id', :'scenario1_po_water_id', '10', :'scenario1_commodity_water_id', 'Water Purification System - Mobile', 25, 35000, 875000, DATE '2024-05-05', DATE '2024-05-05', :'scenario1_wbs_water_id', 'standard'),
    (:'scenario1_po_line_medical_id', :'scenario1_po_medical_id', '10', :'scenario1_commodity_medical_id', 'Emergency Medical Supply Cache', 75, 15000, 1125000, DATE '2024-05-05', DATE '2024-05-05', :'scenario1_wbs_medical_id', 'standard'),
    (:'scenario1_po_line_comms_id', :'scenario1_po_comms_id', '10', :'scenario1_commodity_comms_id', 'Communications Equipment Package', 40, 20000, 800000, DATE '2024-05-05', DATE '2024-05-05', :'scenario1_wbs_comms_id', 'standard');

-- Cancelled shipments recorded for traceability (no quantities received)
INSERT INTO scns (id, project_id, scn_number, description, collection_supplier_id, delivery_warehouse_id, forecast_collection_date, forecast_delivery_date, actual_collection_date, actual_delivery_date, status, created_by)
VALUES
    (:'scenario1_scn_shelter_id', :'scenario1_project_id', 'SC1E-SCN-1001', 'Cancelled shelter kit dispatch — supplier unable to fulfill before landfall.', :'scenario1_supplier_shelter_id', :'scenario1_warehouse_newcastle_id', DATE '2024-05-02', DATE '2024-05-04', NULL, NULL, 'cancelled', :'planner_user_id'),
    (:'scenario1_scn_power_id', :'scenario1_project_id', 'SC1E-SCN-1002', 'Portable generator convoy cancelled due to factory outage.', :'scenario1_supplier_power_id', :'scenario1_warehouse_brisbane_id', DATE '2024-05-02', DATE '2024-05-05', NULL, NULL, 'cancelled', :'planner_user_id'),
    (:'scenario1_scn_water_id', :'scenario1_project_id', 'SC1E-SCN-1003', 'Mobile water purification systems withheld pending QA failure.', :'scenario1_supplier_water_id', :'scenario1_warehouse_canberra_id', DATE '2024-05-02', DATE '2024-05-05', NULL, NULL, 'cancelled', :'planner_user_id'),
    (:'scenario1_scn_medical_id', :'scenario1_project_id', 'SC1E-SCN-1004', 'Emergency medical cache shipment cancelled — cold chain breach.', :'scenario1_supplier_medical_id', :'scenario1_warehouse_sydney_id', DATE '2024-05-02', DATE '2024-05-05', NULL, NULL, 'cancelled', :'planner_user_id'),
    (:'scenario1_scn_comms_id', :'scenario1_project_id', 'SC1E-SCN-1005', 'Communications equipment export licence revoked pre-dispatch.', :'scenario1_supplier_comms_id', :'scenario1_warehouse_brisbane_id', DATE '2024-05-02', DATE '2024-05-05', NULL, NULL, 'cancelled', :'planner_user_id');

INSERT INTO scn_packages (id, scn_id, package_number, freight_package_id, gross_weight, net_weight, dimensions)
VALUES
    (:'scenario1_scn_package_shelter_id', :'scenario1_scn_shelter_id', 'PKG-SC1E-1001', uuid_generate_v5('e4b7c9d2-1a3b-4c5d-6e7f-890123456789'::uuid, 'scenario1-enhanced-freight-pallet'), 0, 0, 'Cancelled'),
    (:'scenario1_scn_package_power_id', :'scenario1_scn_power_id', 'PKG-SC1E-1002', uuid_generate_v5('e4b7c9d2-1a3b-4c5d-6e7f-890123456789'::uuid, 'scenario1-enhanced-freight-container'), 0, 0, 'Cancelled'),
    (:'scenario1_scn_package_water_id', :'scenario1_scn_water_id', 'PKG-SC1E-1003', uuid_generate_v5('e4b7c9d2-1a3b-4c5d-6e7f-890123456789'::uuid, 'scenario1-enhanced-freight-pallet'), 0, 0, 'Cancelled'),
    (:'scenario1_scn_package_medical_id', :'scenario1_scn_medical_id', 'PKG-SC1E-1004', uuid_generate_v5('e4b7c9d2-1a3b-4c5d-6e7f-890123456789'::uuid, 'scenario1-enhanced-freight-pallet'), 0, 0, 'Cancelled'),
    (:'scenario1_scn_package_comms_id', :'scenario1_scn_comms_id', 'PKG-SC1E-1005', uuid_generate_v5('e4b7c9d2-1a3b-4c5d-6e7f-890123456789'::uuid, 'scenario1-enhanced-freight-container'), 0, 0, 'Cancelled');

INSERT INTO scn_line_items (id, scn_id, package_id, po_line_item_id, quantity)
VALUES
    (:'scenario1_scn_line_shelter_id', :'scenario1_scn_shelter_id', :'scenario1_scn_package_shelter_id', :'scenario1_po_line_shelter_id', 0),
    (:'scenario1_scn_line_power_id', :'scenario1_scn_power_id', :'scenario1_scn_package_power_id', :'scenario1_po_line_power_id', 0),
    (:'scenario1_scn_line_water_id', :'scenario1_scn_water_id', :'scenario1_scn_package_water_id', :'scenario1_po_line_water_id', 0),
    (:'scenario1_scn_line_medical_id', :'scenario1_scn_medical_id', :'scenario1_scn_package_medical_id', :'scenario1_po_line_medical_id', 0),
    (:'scenario1_scn_line_comms_id', :'scenario1_scn_comms_id', :'scenario1_scn_package_comms_id', :'scenario1_po_line_comms_id', 0);

-- Warehouse inventory - Available options across multiple warehouses
INSERT INTO warehouse_inventory (id, project_id, warehouse_id, commodity_code_id, wbs_id, quantity_available, quantity_reserved, quantity_hard_reserved, safety_stock_level, status, last_receipt_id)
VALUES
    -- Newcastle Regional Emergency Depot
    (uuid_generate_v5('e4b7c9d2-1a3b-4c5d-6e7f-890123456789'::uuid, 'scenario1-enhanced-inventory-newcastle-shelter'), :'scenario1_project_id', :'scenario1_warehouse_newcastle_id', :'scenario1_commodity_shelter_id', :'scenario1_wbs_shelter_id', 1800, 200, 0, 50, 'available', NULL),
    (uuid_generate_v5('e4b7c9d2-1a3b-4c5d-6e7f-890123456789'::uuid, 'scenario1-enhanced-inventory-newcastle-power'), :'scenario1_project_id', :'scenario1_warehouse_newcastle_id', :'scenario1_commodity_power_id', :'scenario1_wbs_power_id', 85, 15, 0, 5, 'available', NULL),
    (uuid_generate_v5('e4b7c9d2-1a3b-4c5d-6e7f-890123456789'::uuid, 'scenario1-enhanced-inventory-newcastle-water'), :'scenario1_project_id', :'scenario1_warehouse_newcastle_id', :'scenario1_commodity_water_id', :'scenario1_wbs_water_id', 18, 2, 0, 1, 'available', NULL),
    (uuid_generate_v5('e4b7c9d2-1a3b-4c5d-6e7f-890123456789'::uuid, 'scenario1-enhanced-inventory-newcastle-comms'), :'scenario1_project_id', :'scenario1_warehouse_newcastle_id', :'scenario1_commodity_comms_id', :'scenario1_wbs_comms_id', 22, 2, 0, 2, 'available', NULL),

    -- Sydney Metropolitan Reserve
    (uuid_generate_v5('e4b7c9d2-1a3b-4c5d-6e7f-890123456789'::uuid, 'scenario1-enhanced-inventory-sydney-shelter'), :'scenario1_project_id', :'scenario1_warehouse_sydney_id', :'scenario1_commodity_shelter_id', :'scenario1_wbs_shelter_id', 950, 50, 0, 25, 'available', NULL),
    (uuid_generate_v5('e4b7c9d2-1a3b-4c5d-6e7f-890123456789'::uuid, 'scenario1-enhanced-inventory-sydney-medical'), :'scenario1_project_id', :'scenario1_warehouse_sydney_id', :'scenario1_commodity_medical_id', :'scenario1_wbs_medical_id', 45, 5, 0, 3, 'available', NULL),

    -- Brisbane Emergency Logistics Hub
    (uuid_generate_v5('e4b7c9d2-1a3b-4c5d-6e7f-890123456789'::uuid, 'scenario1-enhanced-inventory-brisbane-power'), :'scenario1_project_id', :'scenario1_warehouse_brisbane_id', :'scenario1_commodity_power_id', :'scenario1_wbs_power_id', 120, 90, 5, 115, 'available', NULL),
    (uuid_generate_v5('e4b7c9d2-1a3b-4c5d-6e7f-890123456789'::uuid, 'scenario1-enhanced-inventory-brisbane-comms'), :'scenario1_project_id', :'scenario1_warehouse_brisbane_id', :'scenario1_commodity_comms_id', :'scenario1_wbs_comms_id', 35, 5, 0, 3, 'available', NULL),

    -- Canberra Strategic Reserve
    (uuid_generate_v5('e4b7c9d2-1a3b-4c5d-6e7f-890123456789'::uuid, 'scenario1-enhanced-inventory-canberra-water'), :'scenario1_project_id', :'scenario1_warehouse_canberra_id', :'scenario1_commodity_water_id', :'scenario1_wbs_water_id', 12, 10, 10, 2, 'available', NULL),

    -- Adelaide Emergency Coordination Centre
    (uuid_generate_v5('e4b7c9d2-1a3b-4c5d-6e7f-890123456789'::uuid, 'scenario1-enhanced-inventory-adelaide-medical'), :'scenario1_project_id', :'scenario1_warehouse_adelaide_id', :'scenario1_commodity_medical_id', :'scenario1_wbs_medical_id', 65, 10, 0, 5, 'available', NULL);

-- Inventory reservations to create complexity
INSERT INTO inventory_reservations (id, inventory_id, reserved_quantity, reserved_for_entity_type, reserved_for_entity_id, reservation_type, priority_level, required_by_date, can_reassign, created_by)
VALUES
    (uuid_generate_v5('e4b7c9d2-1a3b-4c5d-6e7f-890123456789'::uuid, 'scenario1-enhanced-reservation-sydney-shelter'),
     uuid_generate_v5('e4b7c9d2-1a3b-4c5d-6e7f-890123456789'::uuid, 'scenario1-enhanced-inventory-sydney-shelter'),
     50, 'project', :'scenario1_project_id', 'soft', 65, DATE '2024-06-15', TRUE, :'planner_user_id'),
    (uuid_generate_v5('e4b7c9d2-1a3b-4c5d-6e7f-890123456789'::uuid, 'scenario1-enhanced-reservation-brisbane-power'),
     uuid_generate_v5('e4b7c9d2-1a3b-4c5d-6e7f-890123456789'::uuid, 'scenario1-enhanced-inventory-brisbane-power'),
     90, 'project', :'scenario1_project_id', 'soft', 45, DATE '2024-06-20', FALSE, :'planner_user_id'),
    (uuid_generate_v5('e4b7c9d2-1a3b-4c5d-6e7f-890123456789'::uuid, 'scenario1-enhanced-reservation-canberra-water'),
     uuid_generate_v5('e4b7c9d2-1a3b-4c5d-6e7f-890123456789'::uuid, 'scenario1-enhanced-inventory-canberra-water'),
     10, 'project', :'scenario1_project_id', 'soft', 85, DATE '2024-05-25', FALSE, :'planner_user_id'),
    (uuid_generate_v5('e4b7c9d2-1a3b-4c5d-6e7f-890123456789'::uuid, 'scenario1-enhanced-reservation-adelaide-medical'),
     uuid_generate_v5('e4b7c9d2-1a3b-4c5d-6e7f-890123456789'::uuid, 'scenario1-enhanced-inventory-adelaide-medical'),
     10, 'project', :'scenario1_project_id', 'soft', 70, DATE '2024-06-01', TRUE, :'planner_user_id'),
    (uuid_generate_v5('e4b7c9d2-1a3b-4c5d-6e7f-890123456789'::uuid, 'scenario1-enhanced-reservation-brisbane-comms'),
     uuid_generate_v5('e4b7c9d2-1a3b-4c5d-6e7f-890123456789'::uuid, 'scenario1-enhanced-inventory-brisbane-comms'),
     5, 'project', :'scenario1_project_id', 'soft', 55, DATE '2024-05-30', TRUE, :'planner_user_id');

-- Emergency accommodation storyline
INSERT INTO emergency_incidents (id, project_id, scn_id, incident_type, incident_date, reported_by, description, status, resolution_notes)
VALUES (
    :'scenario1_incident_id',
    :'scenario1_project_id',
    NULL,
    'hurricane_evacuation',
    TIMESTAMP WITH TIME ZONE '2024-05-12 06:00+00',
    :'incident_user_id',
    'Category 4 hurricane approaching coastline requiring massive evacuation and emergency accommodation for estimated 10,000 displaced residents across 5 critical resource categories.',
    'active',
    'Multi-commodity accommodation search initiated for shelter, power, water, medical, and communications systems.'
);

-- Quick verification hooks (left commented for operators)
-- SELECT * FROM fn_emergency_inventory_search(:'scenario1_po_line_shelter_id');
-- SELECT * FROM fn_emergency_inventory_search(:'scenario1_po_line_power_id');
-- SELECT * FROM fn_emergency_inventory_search(:'scenario1_po_line_water_id');
-- SELECT * FROM fn_emergency_inventory_search(:'scenario1_po_line_medical_id');
-- SELECT * FROM fn_emergency_inventory_search(:'scenario1_po_line_comms_id');
