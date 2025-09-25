\set ON_ERROR_STOP on

\echo 'Scenario 1 – Simple Surge'
SELECT
    r.inventory_id,
    r.warehouse_id,
    r.quantity_available,
    r.soft_available_qty,
    r.hard_available_qty,
    r.availability_status,
    r.compatibility_score,
    r.urgency_score,
    r.availability_score,
    r.impact_level
FROM fn_emergency_inventory_search(
         uuid_generate_v5('6ba7b810-9dad-11d1-80b4-00c04fd430c8'::uuid, 'scenario1-po-line'),
         3
     ) r;

\echo 'Scenario 2 – Conflict and Reassignment'
SELECT
    r.inventory_id,
    r.warehouse_id,
    r.quantity_available,
    r.soft_available_qty,
    r.hard_available_qty,
    r.availability_status,
    r.compatibility_score,
    r.urgency_score,
    r.availability_score,
    r.impact_level
FROM fn_emergency_inventory_search(
         uuid_generate_v5('6ba7b810-9dad-11d1-80b4-00c04fd430c8'::uuid, 'scenario2-po-line'),
         3
     ) r;

\echo 'Scenario 3 – Critical Stockpile Decision'
SELECT
    r.inventory_id,
    r.warehouse_id,
    r.quantity_available,
    r.soft_available_qty,
    r.hard_available_qty,
    r.availability_status,
    r.compatibility_score,
    r.urgency_score,
    r.availability_score,
    r.impact_level
FROM fn_emergency_inventory_search(
         uuid_generate_v5('6ba7b810-9dad-11d1-80b4-00c04fd430c8'::uuid, 'scenario3-po-line'),
         3
     ) r;

