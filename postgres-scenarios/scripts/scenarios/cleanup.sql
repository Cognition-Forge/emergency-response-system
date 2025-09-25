\set ON_ERROR_STOP on

-- Remove projects associated with the emergency accommodation demo scenarios.
DELETE FROM projects
WHERE id IN (
    uuid_generate_v5('6ba7b810-9dad-11d1-80b4-00c04fd430c8'::uuid, 'scenario1-project'),
    uuid_generate_v5('6ba7b810-9dad-11d1-80b4-00c04fd430c8'::uuid, 'scenario2-project'),
    uuid_generate_v5('6ba7b810-9dad-11d1-80b4-00c04fd430c8'::uuid, 'scenario3-project')
);

-- Optional: clear related audit/search noise retained after project deletion
DELETE FROM search_audit_log
WHERE project_id NOT IN (SELECT id FROM projects);

DELETE FROM audit_log
WHERE project_id IS NOT NULL AND project_id NOT IN (SELECT id FROM projects);

