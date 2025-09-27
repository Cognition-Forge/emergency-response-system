\set ON_ERROR_STOP on

-- Deterministic identifiers for scenario entities
SELECT
    uuid_generate_v5('6ba7b810-9dad-11d1-80b4-00c04fd430c8'::uuid, 'scenario2-enhanced-project')               AS scenario2_project_id,
    uuid_generate_v5('6ba7b810-9dad-11d1-80b4-00c04fd430c8'::uuid, 'scenario2-enhanced-wbs-root')              AS scenario2_wbs_root_id,
    uuid_generate_v5('6ba7b810-9dad-11d1-80b4-00c04fd430c8'::uuid, 'scenario2-enhanced-wbs-fire')              AS scenario2_wbs_fire_id,
    uuid_generate_v5('6ba7b810-9dad-11d1-80b4-00c04fd430c8'::uuid, 'scenario2-enhanced-wbs-flood')             AS scenario2_wbs_flood_id,
    uuid_generate_v5('6ba7b810-9dad-11d1-80b4-00c04fd430c8'::uuid, 'scenario2-enhanced-wbs-livestock')         AS scenario2_wbs_livestock_id,
    uuid_generate_v5('6ba7b810-9dad-11d1-80b4-00c04fd430c8'::uuid, 'scenario2-enhanced-wbs-evacuation')        AS scenario2_wbs_evacuation_id,
    -- Multiple suppliers for different agencies
    uuid_generate_v5('6ba7b810-9dad-11d1-80b4-00c04fd430c8'::uuid, 'scenario2-enhanced-supplier-fire')         AS scenario2_supplier_fire_id,
    uuid_generate_v5('6ba7b810-9dad-11d1-80b4-00c04fd430c8'::uuid, 'scenario2-enhanced-supplier-flood')        AS scenario2_supplier_flood_id,
    uuid_generate_v5('6ba7b810-9dad-11d1-80b4-00c04fd430c8'::uuid, 'scenario2-enhanced-supplier-agriculture')  AS scenario2_supplier_agriculture_id,
    uuid_generate_v5('6ba7b810-9dad-11d1-80b4-00c04fd430c8'::uuid, 'scenario2-enhanced-supplier-evacuation')   AS scenario2_supplier_evacuation_id,
    -- Regional warehouses
    uuid_generate_v5('6ba7b810-9dad-11d1-80b4-00c04fd430c8'::uuid, 'scenario2-enhanced-warehouse-dubbo')       AS scenario2_warehouse_dubbo_id,
    uuid_generate_v5('6ba7b810-9dad-11d1-80b4-00c04fd430c8'::uuid, 'scenario2-enhanced-warehouse-orange')      AS scenario2_warehouse_orange_id,
    uuid_generate_v5('6ba7b810-9dad-11d1-80b4-00c04fd430c8'::uuid, 'scenario2-enhanced-warehouse-wagga')       AS scenario2_warehouse_wagga_id,
    uuid_generate_v5('6ba7b810-9dad-11d1-80b4-00c04fd430c8'::uuid, 'scenario2-enhanced-warehouse-tamworth')    AS scenario2_warehouse_tamworth_id,
    uuid_generate_v5('6ba7b810-9dad-11d1-80b4-00c04fd430c8'::uuid, 'scenario2-enhanced-warehouse-albury')      AS scenario2_warehouse_albury_id,
    -- Units of measure
    uuid_generate_v5('6ba7b810-9dad-11d1-80b4-00c04fd430c8'::uuid, 'scenario2-enhanced-uom-litre')             AS scenario2_uom_litre_id,
    uuid_generate_v5('6ba7b810-9dad-11d1-80b4-00c04fd430c8'::uuid, 'scenario2-enhanced-uom-metre')             AS scenario2_uom_metre_id,
    uuid_generate_v5('6ba7b810-9dad-11d1-80b4-00c04fd430c8'::uuid, 'scenario2-enhanced-uom-kg')                AS scenario2_uom_kg_id,
    uuid_generate_v5('6ba7b810-9dad-11d1-80b4-00c04fd430c8'::uuid, 'scenario2-enhanced-uom-unit')              AS scenario2_uom_unit_id,
    -- Commodity codes
    uuid_generate_v5('6ba7b810-9dad-11d1-80b4-00c04fd430c8'::uuid, 'scenario2-enhanced-commodity-foam')        AS scenario2_commodity_foam_id,
    uuid_generate_v5('6ba7b810-9dad-11d1-80b4-00c04fd430c8'::uuid, 'scenario2-enhanced-commodity-barriers')    AS scenario2_commodity_barriers_id,
    uuid_generate_v5('6ba7b810-9dad-11d1-80b4-00c04fd430c8'::uuid, 'scenario2-enhanced-commodity-feed')        AS scenario2_commodity_feed_id,
    uuid_generate_v5('6ba7b810-9dad-11d1-80b4-00c04fd430c8'::uuid, 'scenario2-enhanced-commodity-evacuation')  AS scenario2_commodity_evacuation_id,
    -- MTOs for each commodity
    uuid_generate_v5('6ba7b810-9dad-11d1-80b4-00c04fd430c8'::uuid, 'scenario2-enhanced-mto-fire')              AS scenario2_mto_fire_id,
    uuid_generate_v5('6ba7b810-9dad-11d1-80b4-00c04fd430c8'::uuid, 'scenario2-enhanced-mto-flood')             AS scenario2_mto_flood_id,
    uuid_generate_v5('6ba7b810-9dad-11d1-80b4-00c04fd430c8'::uuid, 'scenario2-enhanced-mto-livestock')         AS scenario2_mto_livestock_id,
    uuid_generate_v5('6ba7b810-9dad-11d1-80b4-00c04fd430c8'::uuid, 'scenario2-enhanced-mto-evacuation')        AS scenario2_mto_evacuation_id,
    -- MTO line items
    uuid_generate_v5('6ba7b810-9dad-11d1-80b4-00c04fd430c8'::uuid, 'scenario2-enhanced-mto-line-fire')         AS scenario2_mto_line_fire_id,
    uuid_generate_v5('6ba7b810-9dad-11d1-80b4-00c04fd430c8'::uuid, 'scenario2-enhanced-mto-line-flood')        AS scenario2_mto_line_flood_id,
    uuid_generate_v5('6ba7b810-9dad-11d1-80b4-00c04fd430c8'::uuid, 'scenario2-enhanced-mto-line-livestock')    AS scenario2_mto_line_livestock_id,
    uuid_generate_v5('6ba7b810-9dad-11d1-80b4-00c04fd430c8'::uuid, 'scenario2-enhanced-mto-line-evacuation')   AS scenario2_mto_line_evacuation_id,
    -- Purchase orders
    uuid_generate_v5('6ba7b810-9dad-11d1-80b4-00c04fd430c8'::uuid, 'scenario2-enhanced-po-fire')               AS scenario2_po_fire_id,
    uuid_generate_v5('6ba7b810-9dad-11d1-80b4-00c04fd430c8'::uuid, 'scenario2-enhanced-po-flood')              AS scenario2_po_flood_id,
    uuid_generate_v5('6ba7b810-9dad-11d1-80b4-00c04fd430c8'::uuid, 'scenario2-enhanced-po-livestock')          AS scenario2_po_livestock_id,
    uuid_generate_v5('6ba7b810-9dad-11d1-80b4-00c04fd430c8'::uuid, 'scenario2-enhanced-po-evacuation')         AS scenario2_po_evacuation_id,
    -- PO line items
    uuid_generate_v5('6ba7b810-9dad-11d1-80b4-00c04fd430c8'::uuid, 'scenario2-enhanced-po-line-fire')          AS scenario2_po_line_fire_id,
    uuid_generate_v5('6ba7b810-9dad-11d1-80b4-00c04fd430c8'::uuid, 'scenario2-enhanced-po-line-flood')         AS scenario2_po_line_flood_id,
    uuid_generate_v5('6ba7b810-9dad-11d1-80b4-00c04fd430c8'::uuid, 'scenario2-enhanced-po-line-livestock')     AS scenario2_po_line_livestock_id,
    uuid_generate_v5('6ba7b810-9dad-11d1-80b4-00c04fd430c8'::uuid, 'scenario2-enhanced-po-line-evacuation')    AS scenario2_po_line_evacuation_id,
    -- Shipment coordination numbers for failed deliveries
    uuid_generate_v5('6ba7b810-9dad-11d1-80b4-00c04fd430c8'::uuid, 'scenario2-enhanced-scn-foam')              AS scenario2_scn_fire_id,
    uuid_generate_v5('6ba7b810-9dad-11d1-80b4-00c04fd430c8'::uuid, 'scenario2-enhanced-scn-flood')             AS scenario2_scn_flood_id,
    uuid_generate_v5('6ba7b810-9dad-11d1-80b4-00c04fd430c8'::uuid, 'scenario2-enhanced-scn-feed')              AS scenario2_scn_feed_id,
    uuid_generate_v5('6ba7b810-9dad-11d1-80b4-00c04fd430c8'::uuid, 'scenario2-enhanced-scn-evacuation')        AS scenario2_scn_evacuation_id,
    uuid_generate_v5('6ba7b810-9dad-11d1-80b4-00c04fd430c8'::uuid, 'scenario2-enhanced-scn-package-foam')      AS scenario2_scn_package_fire_id,
    uuid_generate_v5('6ba7b810-9dad-11d1-80b4-00c04fd430c8'::uuid, 'scenario2-enhanced-scn-package-flood')     AS scenario2_scn_package_flood_id,
    uuid_generate_v5('6ba7b810-9dad-11d1-80b4-00c04fd430c8'::uuid, 'scenario2-enhanced-scn-package-feed')      AS scenario2_scn_package_feed_id,
    uuid_generate_v5('6ba7b810-9dad-11d1-80b4-00c04fd430c8'::uuid, 'scenario2-enhanced-scn-package-evac')      AS scenario2_scn_package_evacuation_id,
    uuid_generate_v5('6ba7b810-9dad-11d1-80b4-00c04fd430c8'::uuid, 'scenario2-enhanced-scn-line-foam')         AS scenario2_scn_line_fire_id,
    uuid_generate_v5('6ba7b810-9dad-11d1-80b4-00c04fd430c8'::uuid, 'scenario2-enhanced-scn-line-flood')        AS scenario2_scn_line_flood_id,
    uuid_generate_v5('6ba7b810-9dad-11d1-80b4-00c04fd430c8'::uuid, 'scenario2-enhanced-scn-line-feed')         AS scenario2_scn_line_feed_id,
    uuid_generate_v5('6ba7b810-9dad-11d1-80b4-00c04fd430c8'::uuid, 'scenario2-enhanced-scn-line-evac')         AS scenario2_scn_line_evacuation_id,
    -- Emergency incident
    uuid_generate_v5('6ba7b810-9dad-11d1-80b4-00c04fd430c8'::uuid, 'scenario2-enhanced-incident')              AS scenario2_incident_id
\gset

-- Remove any previous run for this scenario (cascades to child records)
DELETE FROM projects WHERE id = :'scenario2_project_id';

-- Minimal global reference data required by the scenario
INSERT INTO countries (code, name, alpha3_code)
VALUES ('AU', 'Australia', 'AUS')
ON CONFLICT (code) DO UPDATE SET name = EXCLUDED.name, alpha3_code = EXCLUDED.alpha3_code;

INSERT INTO incoterms (abbreviation, description)
VALUES ('FOB', 'Free On Board')
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
    :'scenario2_project_id',
    'Enhanced Scenario 2 - Regional Multi-Hazard Response',
    'Regional bushfire and flood response with competing agency priorities requiring multi-commodity coordination across fire suppression, flood control, agricultural protection, and evacuation systems.',
    'AUD',
    FALSE,
    :'planner_user_id'
);

INSERT INTO project_users (project_id, user_id, access_level)
VALUES
    (:'scenario2_project_id', :'planner_user_id', 'admin'),
    (:'scenario2_project_id', :'warehouse_user_id', 'write'),
    (:'scenario2_project_id', :'incident_user_id', 'read');

-- Reference data scoped to the project
INSERT INTO units_of_measure (id, project_id, long_description, abbreviation, is_default)
VALUES
    (:'scenario2_uom_litre_id', :'scenario2_project_id', 'Litre', 'LITRE', FALSE),
    (:'scenario2_uom_metre_id', :'scenario2_project_id', 'Metre', 'METRE', FALSE),
    (:'scenario2_uom_kg_id', :'scenario2_project_id', 'Kilogram', 'KG', FALSE),
    (:'scenario2_uom_unit_id', :'scenario2_project_id', 'Unit', 'UNIT', TRUE);

INSERT INTO freight_packages (id, project_id, package_type)
VALUES
    (uuid_generate_v5('6ba7b810-9dad-11d1-80b4-00c04fd430c8'::uuid, 'scenario2-enhanced-freight-drum'), :'scenario2_project_id', 'Drum'),
    (uuid_generate_v5('6ba7b810-9dad-11d1-80b4-00c04fd430c8'::uuid, 'scenario2-enhanced-freight-pallet'), :'scenario2_project_id', 'Pallet'),
    (uuid_generate_v5('6ba7b810-9dad-11d1-80b4-00c04fd430c8'::uuid, 'scenario2-enhanced-freight-bulk'), :'scenario2_project_id', 'Bulk');

INSERT INTO document_types (id, project_id, type_name)
VALUES (uuid_generate_v5('6ba7b810-9dad-11d1-80b4-00c04fd430c8'::uuid, 'scenario2-enhanced-doc-manifest'), :'scenario2_project_id', 'Transport Manifest');

-- Work Breakdown Structure
INSERT INTO wbs (id, project_id, code, name, parent_id, level, sort_order, path)
VALUES
    (:'scenario2_wbs_root_id', :'scenario2_project_id', 'SC2E', 'Enhanced Scenario 2 Root', NULL, 0, 1, 'SC2E'),
    (:'scenario2_wbs_fire_id', :'scenario2_project_id', 'SC2E.1', 'Bushfire Suppression Operations', :'scenario2_wbs_root_id', 1, 10, 'SC2E>SC2E.1'),
    (:'scenario2_wbs_flood_id', :'scenario2_project_id', 'SC2E.2', 'Flood Protection Systems', :'scenario2_wbs_root_id', 1, 20, 'SC2E>SC2E.2'),
    (:'scenario2_wbs_livestock_id', :'scenario2_project_id', 'SC2E.3', 'Agricultural Protection', :'scenario2_wbs_root_id', 1, 30, 'SC2E>SC2E.3'),
    (:'scenario2_wbs_evacuation_id', :'scenario2_project_id', 'SC2E.4', 'Evacuation Centers', :'scenario2_wbs_root_id', 1, 40, 'SC2E>SC2E.4');

INSERT INTO wbs_ros_dates (wbs_id, ros_date)
VALUES
    (:'scenario2_wbs_fire_id', DATE '2024-06-01'),
    (:'scenario2_wbs_flood_id', DATE '2024-06-01'),
    (:'scenario2_wbs_livestock_id', DATE '2024-06-01'),
    (:'scenario2_wbs_evacuation_id', DATE '2024-06-01');

-- Supply chain master data - Multiple suppliers representing different agencies
INSERT INTO suppliers (id, project_id, supplier_code, name, contact_name, contact_email, country_code, incoterm)
VALUES
    (:'scenario2_supplier_fire_id', :'scenario2_project_id', 'SUP-FIRE', 'FireTech Emergency Solutions', 'River Martinez', 'river.martinez@firetech.example', 'AU', 'FOB'),
    (:'scenario2_supplier_flood_id', :'scenario2_project_id', 'SUP-FLOOD', 'FloodGuard Systems Australia', 'Sage Thompson', 'sage.thompson@floodguard.example', 'AU', 'FOB'),
    (:'scenario2_supplier_agriculture_id', :'scenario2_project_id', 'SUP-AGRI', 'Rural Emergency Supplies Co', 'Quinn Foster', 'quinn.foster@rurales.example', 'AU', 'FOB'),
    (:'scenario2_supplier_evacuation_id', :'scenario2_project_id', 'SUP-EVAC', 'Emergency Shelter Dynamics', 'Avery Kim', 'avery.kim@shelterdyn.example', 'AU', 'FOB');

-- Regional warehouses with geographic distribution
INSERT INTO warehouses (id, project_id, name, warehouse_code, description, city, country_code, is_active)
VALUES
    (:'scenario2_warehouse_dubbo_id', :'scenario2_project_id', 'Dubbo Regional Emergency Hub', 'WH-DUBBO', 'Central west NSW emergency response coordination center.', 'Dubbo', 'AU', TRUE),
    (:'scenario2_warehouse_orange_id', :'scenario2_project_id', 'Orange Agricultural Response Centre', 'WH-ORANGE', 'Agricultural emergency response facility for central tablelands.', 'Orange', 'AU', TRUE),
    (:'scenario2_warehouse_wagga_id', :'scenario2_project_id', 'Wagga Wagga Emergency Logistics', 'WH-WAGGA', 'Riverina region emergency logistics coordination center.', 'Wagga Wagga', 'AU', TRUE),
    (:'scenario2_warehouse_tamworth_id', :'scenario2_project_id', 'Tamworth Agricultural Hub', 'WH-TAMWORTH', 'Northern NSW agricultural emergency response facility.', 'Tamworth', 'AU', TRUE),
    (:'scenario2_warehouse_albury_id', :'scenario2_project_id', 'Albury Border Emergency Facility', 'WH-ALBURY', 'NSW-Victoria border emergency coordination facility.', 'Albury', 'AU', TRUE);

-- Commodity codes for multi-hazard response
INSERT INTO commodity_codes (id, project_id, engineered_code, short_description, long_description, commodity_class, unit_of_measure_id)
VALUES
    (:'scenario2_commodity_foam_id', :'scenario2_project_id', 'COM-FIRE-FOAM-CLASSA', 'Class A Foam Concentrate for Bushfire Suppression', 'High-performance Class A firefighting foam concentrate for bushfire suppression with biodegradable formulation.', 'Fire Suppression', :'scenario2_uom_litre_id'),
    (:'scenario2_commodity_barriers_id', :'scenario2_project_id', 'COM-FLOOD-BARRIER-MOD', 'Portable Flood Barriers - Modular System', 'Modular flood barrier system with interlocking panels for rapid deployment flood protection.', 'Flood Response', :'scenario2_uom_metre_id'),
    (:'scenario2_commodity_feed_id', :'scenario2_project_id', 'COM-LIVESTOCK-FEED-EMERG', 'Emergency Livestock Feed Supply', 'High-nutrition emergency feed suitable for cattle, sheep, and horses during drought or disaster conditions.', 'Agricultural Protection', :'scenario2_uom_kg_id'),
    (:'scenario2_commodity_evacuation_id', :'scenario2_project_id', 'COM-EVAC-CENTER-RAPID', 'Rapid Deployment Evacuation Centers', 'Rapid-assembly evacuation center with accommodation for 200+ persons including sanitation and power systems.', 'Emergency Accommodation', :'scenario2_uom_unit_id');

-- Planning artefacts - Multiple MTOs
INSERT INTO mtos (id, project_id, mto_number, title, revision, status, issued_date, created_by)
VALUES
    (:'scenario2_mto_fire_id', :'scenario2_project_id', 'MTO-SC2E-001', 'Bushfire Suppression Foam Requirements', 'A', 'issued', DATE '2024-05-20', :'planner_user_id'),
    (:'scenario2_mto_flood_id', :'scenario2_project_id', 'MTO-SC2E-002', 'Flood Protection Barrier Requirements', 'A', 'issued', DATE '2024-05-20', :'planner_user_id'),
    (:'scenario2_mto_livestock_id', :'scenario2_project_id', 'MTO-SC2E-003', 'Emergency Livestock Feed Requirements', 'A', 'issued', DATE '2024-05-20', :'planner_user_id'),
    (:'scenario2_mto_evacuation_id', :'scenario2_project_id', 'MTO-SC2E-004', 'Evacuation Center Requirements', 'A', 'issued', DATE '2024-05-20', :'planner_user_id');

-- MTO line items with regional multi-hazard scale quantities
INSERT INTO mto_line_items (id, mto_id, line_number, commodity_code_id, description, quantity, unit_of_measure_id, wbs_id)
VALUES
    (:'scenario2_mto_line_fire_id', :'scenario2_mto_fire_id', '10', :'scenario2_commodity_foam_id', 'Class A Foam Concentrate for Bushfire Suppression', 8000, :'scenario2_uom_litre_id', :'scenario2_wbs_fire_id'),
    (:'scenario2_mto_line_flood_id', :'scenario2_mto_flood_id', '10', :'scenario2_commodity_barriers_id', 'Portable Flood Barriers - Modular System', 2500, :'scenario2_uom_metre_id', :'scenario2_wbs_flood_id'),
    (:'scenario2_mto_line_livestock_id', :'scenario2_mto_livestock_id', '10', :'scenario2_commodity_feed_id', 'Emergency Livestock Feed Supply', 15000, :'scenario2_uom_kg_id', :'scenario2_wbs_livestock_id'),
    (:'scenario2_mto_line_evacuation_id', :'scenario2_mto_evacuation_id', '10', :'scenario2_commodity_evacuation_id', 'Rapid Deployment Evacuation Centers', 45, :'scenario2_uom_unit_id', :'scenario2_wbs_evacuation_id');

-- Purchase orders
INSERT INTO purchase_orders (id, project_id, po_number, supplier_id, mto_id, status, currency, order_date, expected_delivery_date, total_value, created_by)
VALUES
    (:'scenario2_po_fire_id', :'scenario2_project_id', 'SC2E-PO-2001', :'scenario2_supplier_fire_id', :'scenario2_mto_fire_id', 'cancelled', 'AUD', DATE '2024-05-21', DATE '2024-05-30', 480000, :'planner_user_id'),
    (:'scenario2_po_flood_id', :'scenario2_project_id', 'SC2E-PO-2002', :'scenario2_supplier_flood_id', :'scenario2_mto_flood_id', 'cancelled', 'AUD', DATE '2024-05-21', DATE '2024-05-30', 375000, :'planner_user_id'),
    (:'scenario2_po_livestock_id', :'scenario2_project_id', 'SC2E-PO-2003', :'scenario2_supplier_agriculture_id', :'scenario2_mto_livestock_id', 'cancelled', 'AUD', DATE '2024-05-21', DATE '2024-05-30', 225000, :'planner_user_id'),
    (:'scenario2_po_evacuation_id', :'scenario2_project_id', 'SC2E-PO-2004', :'scenario2_supplier_evacuation_id', :'scenario2_mto_evacuation_id', 'cancelled', 'AUD', DATE '2024-05-21', DATE '2024-05-30', 1350000, :'planner_user_id');

-- PO line items - Failed shipments (cancelled orders)
INSERT INTO po_line_items (id, po_id, line_number, commodity_code_id, description, quantity_ordered, unit_price, line_value, contractual_delivery_date, forecast_delivery_date, wbs_id, line_type)
VALUES
    (:'scenario2_po_line_fire_id', :'scenario2_po_fire_id', '10', :'scenario2_commodity_foam_id', 'Class A Foam Concentrate for Bushfire Suppression', 8000, 60, 480000, DATE '2024-05-30', DATE '2024-05-30', :'scenario2_wbs_fire_id', 'standard'),
    (:'scenario2_po_line_flood_id', :'scenario2_po_flood_id', '10', :'scenario2_commodity_barriers_id', 'Portable Flood Barriers - Modular System', 2500, 150, 375000, DATE '2024-05-30', DATE '2024-05-30', :'scenario2_wbs_flood_id', 'standard'),
    (:'scenario2_po_line_livestock_id', :'scenario2_po_livestock_id', '10', :'scenario2_commodity_feed_id', 'Emergency Livestock Feed Supply', 15000, 15, 225000, DATE '2024-05-30', DATE '2024-05-30', :'scenario2_wbs_livestock_id', 'standard'),
    (:'scenario2_po_line_evacuation_id', :'scenario2_po_evacuation_id', '10', :'scenario2_commodity_evacuation_id', 'Rapid Deployment Evacuation Centers', 45, 30000, 1350000, DATE '2024-05-30', DATE '2024-05-30', :'scenario2_wbs_evacuation_id', 'standard');

-- Log cancelled shipments to tie PO failures to incidents
INSERT INTO scns (id, project_id, scn_number, description, collection_supplier_id, delivery_warehouse_id, forecast_collection_date, forecast_delivery_date, actual_collection_date, actual_delivery_date, status, created_by)
VALUES
    (:'scenario2_scn_fire_id', :'scenario2_project_id', 'SC2E-SCN-2001', 'Fire foam uplift cancelled after chemical certification issue.', :'scenario2_supplier_fire_id', :'scenario2_warehouse_dubbo_id', DATE '2024-05-25', DATE '2024-05-28', NULL, NULL, 'cancelled', :'planner_user_id'),
    (:'scenario2_scn_flood_id', :'scenario2_project_id', 'SC2E-SCN-2002', 'Flood barrier convoy stood down due to major road closures.', :'scenario2_supplier_flood_id', :'scenario2_warehouse_orange_id', DATE '2024-05-26', DATE '2024-05-29', NULL, NULL, 'cancelled', :'planner_user_id'),
    (:'scenario2_scn_feed_id', :'scenario2_project_id', 'SC2E-SCN-2003', 'Emergency livestock feed shipment cancelled owing to contamination.', :'scenario2_supplier_agriculture_id', :'scenario2_warehouse_tamworth_id', DATE '2024-05-25', DATE '2024-05-30', NULL, NULL, 'cancelled', :'planner_user_id'),
    (:'scenario2_scn_evacuation_id', :'scenario2_project_id', 'SC2E-SCN-2004', 'Rapid deployment camp delayed indefinitely — supplier workforce reassigned.', :'scenario2_supplier_evacuation_id', :'scenario2_warehouse_wagga_id', DATE '2024-05-26', DATE '2024-05-31', NULL, NULL, 'cancelled', :'planner_user_id');

INSERT INTO scn_packages (id, scn_id, package_number, freight_package_id, gross_weight, net_weight, dimensions)
VALUES
    (:'scenario2_scn_package_fire_id', :'scenario2_scn_fire_id', 'PKG-SC2E-2001', uuid_generate_v5('6ba7b810-9dad-11d1-80b4-00c04fd430c8'::uuid, 'scenario2-enhanced-freight-drum'), 0, 0, 'Cancelled'),
    (:'scenario2_scn_package_flood_id', :'scenario2_scn_flood_id', 'PKG-SC2E-2002', uuid_generate_v5('6ba7b810-9dad-11d1-80b4-00c04fd430c8'::uuid, 'scenario2-enhanced-freight-pallet'), 0, 0, 'Cancelled'),
    (:'scenario2_scn_package_feed_id', :'scenario2_scn_feed_id', 'PKG-SC2E-2003', uuid_generate_v5('6ba7b810-9dad-11d1-80b4-00c04fd430c8'::uuid, 'scenario2-enhanced-freight-bulk'), 0, 0, 'Cancelled'),
    (:'scenario2_scn_package_evacuation_id', :'scenario2_scn_evacuation_id', 'PKG-SC2E-2004', uuid_generate_v5('6ba7b810-9dad-11d1-80b4-00c04fd430c8'::uuid, 'scenario2-enhanced-freight-pallet'), 0, 0, 'Cancelled');

INSERT INTO scn_line_items (id, scn_id, package_id, po_line_item_id, quantity)
VALUES
    (:'scenario2_scn_line_fire_id', :'scenario2_scn_fire_id', :'scenario2_scn_package_fire_id', :'scenario2_po_line_fire_id', 0),
    (:'scenario2_scn_line_flood_id', :'scenario2_scn_flood_id', :'scenario2_scn_package_flood_id', :'scenario2_po_line_flood_id', 0),
    (:'scenario2_scn_line_feed_id', :'scenario2_scn_feed_id', :'scenario2_scn_package_feed_id', :'scenario2_po_line_livestock_id', 0),
    (:'scenario2_scn_line_evacuation_id', :'scenario2_scn_evacuation_id', :'scenario2_scn_package_evacuation_id', :'scenario2_po_line_evacuation_id', 0);

-- Warehouse inventory - Available options across regional warehouses
INSERT INTO warehouse_inventory (id, project_id, warehouse_id, commodity_code_id, wbs_id, quantity_available, quantity_reserved, quantity_hard_reserved, safety_stock_level, status, last_receipt_id)
VALUES
    -- Dubbo Regional Emergency Hub
    (uuid_generate_v5('6ba7b810-9dad-11d1-80b4-00c04fd430c8'::uuid, 'scenario2-enhanced-inventory-dubbo-foam'), :'scenario2_project_id', :'scenario2_warehouse_dubbo_id', :'scenario2_commodity_foam_id', :'scenario2_wbs_fire_id', 6500, 6000, 400, 6100, 'available', NULL),
    (uuid_generate_v5('6ba7b810-9dad-11d1-80b4-00c04fd430c8'::uuid, 'scenario2-enhanced-inventory-dubbo-evacuation'), :'scenario2_project_id', :'scenario2_warehouse_dubbo_id', :'scenario2_commodity_evacuation_id', :'scenario2_wbs_evacuation_id', 22, 2, 0, 2, 'available', NULL),

    -- Orange Agricultural Response Centre
    (uuid_generate_v5('6ba7b810-9dad-11d1-80b4-00c04fd430c8'::uuid, 'scenario2-enhanced-inventory-orange-barriers'), :'scenario2_project_id', :'scenario2_warehouse_orange_id', :'scenario2_commodity_barriers_id', :'scenario2_wbs_flood_id', 1800, 200, 0, 100, 'available', NULL),
    (uuid_generate_v5('6ba7b810-9dad-11d1-80b4-00c04fd430c8'::uuid, 'scenario2-enhanced-inventory-orange-barriers-ext'), :'scenario2_project_id', :'scenario2_warehouse_orange_id', :'scenario2_commodity_barriers_id', :'scenario2_wbs_flood_id', 1200, 0, 0, 50, 'available', NULL),

    -- Wagga Wagga Emergency Logistics
    (uuid_generate_v5('6ba7b810-9dad-11d1-80b4-00c04fd430c8'::uuid, 'scenario2-enhanced-inventory-wagga-feed'), :'scenario2_project_id', :'scenario2_warehouse_wagga_id', :'scenario2_commodity_feed_id', :'scenario2_wbs_livestock_id', 8500, 500, 0, 500, 'available', NULL),
    (uuid_generate_v5('6ba7b810-9dad-11d1-80b4-00c04fd430c8'::uuid, 'scenario2-enhanced-inventory-wagga-evacuation'), :'scenario2_project_id', :'scenario2_warehouse_wagga_id', :'scenario2_commodity_evacuation_id', :'scenario2_wbs_evacuation_id', 85, 5, 0, 5, 'available', NULL),

    -- Tamworth Agricultural Hub
    (uuid_generate_v5('6ba7b810-9dad-11d1-80b4-00c04fd430c8'::uuid, 'scenario2-enhanced-inventory-tamworth-feed'), :'scenario2_project_id', :'scenario2_warehouse_tamworth_id', :'scenario2_commodity_feed_id', :'scenario2_wbs_livestock_id', 12000, 2000, 0, 1000, 'available', NULL),

    -- Albury Border Emergency Facility
    (uuid_generate_v5('6ba7b810-9dad-11d1-80b4-00c04fd430c8'::uuid, 'scenario2-enhanced-inventory-albury-foam'), :'scenario2_project_id', :'scenario2_warehouse_albury_id', :'scenario2_commodity_foam_id', :'scenario2_wbs_fire_id', 9500, 9000, 300, 9200, 'available', NULL);

-- Complex inventory reservations with competing agency priorities
INSERT INTO inventory_reservations (id, inventory_id, reserved_quantity, reserved_for_entity_type, reserved_for_entity_id, reservation_type, priority_level, required_by_date, can_reassign, created_by)
VALUES
    (uuid_generate_v5('6ba7b810-9dad-11d1-80b4-00c04fd430c8'::uuid, 'scenario2-enhanced-reservation-dubbo-foam'),
     uuid_generate_v5('6ba7b810-9dad-11d1-80b4-00c04fd430c8'::uuid, 'scenario2-enhanced-inventory-dubbo-foam'),
     6000, 'project', :'scenario2_project_id', 'soft', 60, DATE '2024-06-15', FALSE, :'planner_user_id'),
    (uuid_generate_v5('6ba7b810-9dad-11d1-80b4-00c04fd430c8'::uuid, 'scenario2-enhanced-reservation-orange-barriers'),
     uuid_generate_v5('6ba7b810-9dad-11d1-80b4-00c04fd430c8'::uuid, 'scenario2-enhanced-inventory-orange-barriers'),
     200, 'project', :'scenario2_project_id', 'soft', 35, DATE '2024-06-25', TRUE, :'planner_user_id'),
    (uuid_generate_v5('6ba7b810-9dad-11d1-80b4-00c04fd430c8'::uuid, 'scenario2-enhanced-reservation-wagga-feed'),
     uuid_generate_v5('6ba7b810-9dad-11d1-80b4-00c04fd430c8'::uuid, 'scenario2-enhanced-inventory-wagga-feed'),
     500, 'project', :'scenario2_project_id', 'soft', 45, DATE '2024-06-20', TRUE, :'planner_user_id'),
    (uuid_generate_v5('6ba7b810-9dad-11d1-80b4-00c04fd430c8'::uuid, 'scenario2-enhanced-reservation-wagga-evacuation'),
     uuid_generate_v5('6ba7b810-9dad-11d1-80b4-00c04fd430c8'::uuid, 'scenario2-enhanced-inventory-wagga-evacuation'),
     5, 'project', :'scenario2_project_id', 'soft', 50, DATE '2024-06-18', TRUE, :'planner_user_id'),
    (uuid_generate_v5('6ba7b810-9dad-11d1-80b4-00c04fd430c8'::uuid, 'scenario2-enhanced-reservation-tamworth-feed'),
     uuid_generate_v5('6ba7b810-9dad-11d1-80b4-00c04fd430c8'::uuid, 'scenario2-enhanced-inventory-tamworth-feed'),
     2000, 'project', :'scenario2_project_id', 'soft', 40, DATE '2024-06-22', FALSE, :'planner_user_id'),
    (uuid_generate_v5('6ba7b810-9dad-11d1-80b4-00c04fd430c8'::uuid, 'scenario2-enhanced-reservation-albury-foam'),
     uuid_generate_v5('6ba7b810-9dad-11d1-80b4-00c04fd430c8'::uuid, 'scenario2-enhanced-inventory-albury-foam'),
     9000, 'project', :'scenario2_project_id', 'soft', 85, DATE '2024-06-10', FALSE, :'planner_user_id');

-- Emergency accommodation storyline
INSERT INTO emergency_incidents (id, project_id, scn_id, incident_type, incident_date, reported_by, description, status, resolution_notes)
VALUES (
    :'scenario2_incident_id',
    :'scenario2_project_id',
    NULL,
    'multi_hazard_emergency',
    TIMESTAMP WITH TIME ZONE '2024-06-01 07:00+00',
    :'incident_user_id',
    'Simultaneous bushfire and flood emergency affecting rural communities across central NSW. Competing agency priorities for fire suppression foam, flood barriers, livestock protection, and evacuation resources requiring coordinated multi-agency response.',
    'active',
    'Multi-iteration accommodation search initiated for fire suppression, flood control, agricultural protection, and evacuation systems with agency priority coordination.'
);

-- Quick verification hooks (left commented for operators)
-- SELECT * FROM fn_emergency_inventory_search(:'scenario2_po_line_fire_id');
-- SELECT * FROM fn_emergency_inventory_search(:'scenario2_po_line_flood_id');
-- SELECT * FROM fn_emergency_inventory_search(:'scenario2_po_line_livestock_id');
-- SELECT * FROM fn_emergency_inventory_search(:'scenario2_po_line_evacuation_id');
