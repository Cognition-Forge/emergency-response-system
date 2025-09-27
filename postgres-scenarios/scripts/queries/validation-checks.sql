\set ON_ERROR_STOP on

WITH scenario_projects AS (
    SELECT *
    FROM (
        VALUES
            ('Scenario 1 (base)'::text,
             uuid_generate_v5('6ba7b810-9dad-11d1-80b4-00c04fd430c8'::uuid, 'scenario1-project')),
            ('Scenario 2 (base)',
             uuid_generate_v5('6ba7b810-9dad-11d1-80b4-00c04fd430c8'::uuid, 'scenario2-project')),
            ('Scenario 3 (base)',
             uuid_generate_v5('6ba7b810-9dad-11d1-80b4-00c04fd430c8'::uuid, 'scenario3-project')),
            ('Scenario 1 Enhanced',
             uuid_generate_v5('e4b7c9d2-1a3b-4c5d-6e7f-890123456789'::uuid, 'scenario1-enhanced-project')),
            ('Scenario 2 Enhanced',
             uuid_generate_v5('6ba7b810-9dad-11d1-80b4-00c04fd430c8'::uuid, 'scenario2-enhanced-project')),
            ('Scenario 3 Enhanced',
             uuid_generate_v5('6ba7b810-9dad-11d1-80b4-00c04fd430c8'::uuid, 'scenario3-enhanced-project'))
    ) AS scenarios(label, project_id)
)
SELECT
    sp.label AS scenario_label,
    p.name AS project_name,
    COUNT(DISTINCT po.id)          AS purchase_orders,
    COUNT(DISTINCT scn.id)         AS scns,
    COUNT(DISTINCT wi.id)          AS inventory_records,
    COUNT(DISTINCT fmrs.id)        AS fmrs,
    COUNT(DISTINCT ea.id)          AS emergency_accommodations
FROM scenario_projects sp
JOIN projects p ON p.id = sp.project_id
LEFT JOIN purchase_orders po ON po.project_id = p.id
LEFT JOIN scns scn ON scn.project_id = p.id
LEFT JOIN warehouse_inventory wi ON wi.project_id = p.id
LEFT JOIN fmrs ON fmrs.project_id = p.id
LEFT JOIN emergency_accommodations ea ON ea.incident_id IN (
    SELECT id FROM emergency_incidents WHERE project_id = p.id
)
GROUP BY sp.label, p.name
ORDER BY sp.label;

\echo ''
\echo 'Top-ranked impact level per scenario'
WITH scenario_po_lines AS (
    SELECT *
    FROM (
        VALUES
            ('Scenario 1 (base)',
             uuid_generate_v5('6ba7b810-9dad-11d1-80b4-00c04fd430c8'::uuid, 'scenario1-po-line')),
            ('Scenario 2 (base)',
             uuid_generate_v5('6ba7b810-9dad-11d1-80b4-00c04fd430c8'::uuid, 'scenario2-po-line')),
            ('Scenario 3 (base)',
             uuid_generate_v5('6ba7b810-9dad-11d1-80b4-00c04fd430c8'::uuid, 'scenario3-po-line')),
            ('Scenario 1 Enhanced - Shelter',
             uuid_generate_v5('e4b7c9d2-1a3b-4c5d-6e7f-890123456789'::uuid, 'scenario1-enhanced-po-line-shelter')),
            ('Scenario 1 Enhanced - Power',
             uuid_generate_v5('e4b7c9d2-1a3b-4c5d-6e7f-890123456789'::uuid, 'scenario1-enhanced-po-line-power')),
            ('Scenario 2 Enhanced - Foam',
             uuid_generate_v5('6ba7b810-9dad-11d1-80b4-00c04fd430c8'::uuid, 'scenario2-enhanced-po-line-fire')),
            ('Scenario 2 Enhanced - Flood Barriers',
             uuid_generate_v5('6ba7b810-9dad-11d1-80b4-00c04fd430c8'::uuid, 'scenario2-enhanced-po-line-flood')),
            ('Scenario 3 Enhanced - USAR',
             uuid_generate_v5('6ba7b810-9dad-11d1-80b4-00c04fd430c8'::uuid, 'scenario3-enhanced-po-line-usar')),
            ('Scenario 3 Enhanced - Power',
             uuid_generate_v5('6ba7b810-9dad-11d1-80b4-00c04fd430c8'::uuid, 'scenario3-enhanced-po-line-power'))
    ) AS po_lines(label, po_line_id)
)
SELECT
    sp.label AS scenario,
    search.availability_status,
    search.impact_level
FROM scenario_po_lines sp
CROSS JOIN LATERAL (
    SELECT availability_status, impact_level
    FROM fn_emergency_inventory_search(sp.po_line_id, 1)
    ORDER BY compatibility_score DESC, availability_score DESC
    LIMIT 1
) AS search
ORDER BY sp.label;
