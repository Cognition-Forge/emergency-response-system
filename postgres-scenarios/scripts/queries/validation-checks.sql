\set ON_ERROR_STOP on

WITH scenario_projects AS (
    SELECT
        uuid_generate_v5('6ba7b810-9dad-11d1-80b4-00c04fd430c8'::uuid, 'scenario1-project') AS scenario1_id,
        uuid_generate_v5('6ba7b810-9dad-11d1-80b4-00c04fd430c8'::uuid, 'scenario2-project') AS scenario2_id,
        uuid_generate_v5('6ba7b810-9dad-11d1-80b4-00c04fd430c8'::uuid, 'scenario3-project') AS scenario3_id
)
SELECT
    p.name AS project_name,
    COUNT(DISTINCT po.id)          AS purchase_orders,
    COUNT(DISTINCT scn.id)         AS scns,
    COUNT(DISTINCT wi.id)          AS inventory_records,
    COUNT(DISTINCT fmrs.id)        AS fmrs,
    COUNT(DISTINCT ea.id)          AS emergency_accommodations
FROM scenario_projects sp
JOIN projects p ON p.id IN (sp.scenario1_id, sp.scenario2_id, sp.scenario3_id)
LEFT JOIN purchase_orders po ON po.project_id = p.id
LEFT JOIN scns scn ON scn.project_id = p.id
LEFT JOIN warehouse_inventory wi ON wi.project_id = p.id
LEFT JOIN fmrs ON fmrs.project_id = p.id
LEFT JOIN emergency_accommodations ea ON ea.incident_id IN (
    SELECT id FROM emergency_incidents WHERE project_id = p.id
)
GROUP BY p.name
ORDER BY p.name;

\echo ''
\echo 'Top-ranked impact level per scenario'
SELECT scenario, availability_status, impact_level
FROM (
    SELECT 'Scenario 1' AS scenario,
           r.availability_status,
           r.impact_level,
           row_number() OVER (ORDER BY r.compatibility_score DESC, r.availability_score DESC) AS rn
    FROM fn_emergency_inventory_search(
             uuid_generate_v5('6ba7b810-9dad-11d1-80b4-00c04fd430c8'::uuid, 'scenario1-po-line'),
             1
         ) r
    UNION ALL
    SELECT 'Scenario 2' AS scenario,
           r.availability_status,
           r.impact_level,
           row_number() OVER (ORDER BY r.compatibility_score DESC, r.availability_score DESC) AS rn
    FROM fn_emergency_inventory_search(
             uuid_generate_v5('6ba7b810-9dad-11d1-80b4-00c04fd430c8'::uuid, 'scenario2-po-line'),
             1
         ) r
    UNION ALL
    SELECT 'Scenario 3' AS scenario,
           r.availability_status,
           r.impact_level,
           row_number() OVER (ORDER BY r.compatibility_score DESC, r.availability_score DESC) AS rn
    FROM fn_emergency_inventory_search(
             uuid_generate_v5('6ba7b810-9dad-11d1-80b4-00c04fd430c8'::uuid, 'scenario3-po-line'),
             1
         ) r
) ranked
WHERE rn = 1
ORDER BY scenario;

