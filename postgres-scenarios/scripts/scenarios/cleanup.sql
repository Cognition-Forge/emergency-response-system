\set ON_ERROR_STOP on

-- Clear audit logs first to avoid foreign key constraint violations
DELETE FROM audit_log
WHERE project_id IN (
    uuid_generate_v5('6ba7b810-9dad-11d1-80b4-00c04fd430c8'::uuid, 'scenario1-project'),
    uuid_generate_v5('6ba7b810-9dad-11d1-80b4-00c04fd430c8'::uuid, 'scenario2-project'),
    uuid_generate_v5('6ba7b810-9dad-11d1-80b4-00c04fd430c8'::uuid, 'scenario3-project'),
    uuid_generate_v5('e4b7c9d2-1a3b-4c5d-6e7f-890123456789'::uuid, 'scenario1-enhanced-project'),
    uuid_generate_v5('f5c8d3e4-2b4c-5d6e-7f89-012345678901'::uuid, 'scenario2-enhanced-project'),
    uuid_generate_v5('a6d9e5f6-3c5d-6e7f-8901-234567890123'::uuid, 'scenario3-enhanced-project')
);

DELETE FROM search_audit_log
WHERE project_id IN (
    uuid_generate_v5('6ba7b810-9dad-11d1-80b4-00c04fd430c8'::uuid, 'scenario1-project'),
    uuid_generate_v5('6ba7b810-9dad-11d1-80b4-00c04fd430c8'::uuid, 'scenario2-project'),
    uuid_generate_v5('6ba7b810-9dad-11d1-80b4-00c04fd430c8'::uuid, 'scenario3-project'),
    uuid_generate_v5('e4b7c9d2-1a3b-4c5d-6e7f-890123456789'::uuid, 'scenario1-enhanced-project'),
    uuid_generate_v5('f5c8d3e4-2b4c-5d6e-7f89-012345678901'::uuid, 'scenario2-enhanced-project'),
    uuid_generate_v5('a6d9e5f6-3c5d-6e7f-8901-234567890123'::uuid, 'scenario3-enhanced-project')
);

-- Remove projects associated with the emergency accommodation demo scenarios.
DELETE FROM projects
WHERE id IN (
    uuid_generate_v5('6ba7b810-9dad-11d1-80b4-00c04fd430c8'::uuid, 'scenario1-project'),
    uuid_generate_v5('6ba7b810-9dad-11d1-80b4-00c04fd430c8'::uuid, 'scenario2-project'),
    uuid_generate_v5('6ba7b810-9dad-11d1-80b4-00c04fd430c8'::uuid, 'scenario3-project'),
    uuid_generate_v5('e4b7c9d2-1a3b-4c5d-6e7f-890123456789'::uuid, 'scenario1-enhanced-project'),
    uuid_generate_v5('f5c8d3e4-2b4c-5d6e-7f89-012345678901'::uuid, 'scenario2-enhanced-project'),
    uuid_generate_v5('a6d9e5f6-3c5d-6e7f-8901-234567890123'::uuid, 'scenario3-enhanced-project')
);

