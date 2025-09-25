#!/bin/sh
set -euo pipefail

psql -v ON_ERROR_STOP=1 --username "$POSTGRES_USER" --dbname "$POSTGRES_DB" <<'SQL'
    \ir /docker-entrypoint-initdb.d/schema/01_core.sql
    \ir /docker-entrypoint-initdb.d/schema/02_reference.sql
    \ir /docker-entrypoint-initdb.d/schema/03_supply_chain.sql
    \ir /docker-entrypoint-initdb.d/schema/04_documents_traceability.sql
    \ir /docker-entrypoint-initdb.d/schema/05_audit.sql
    \ir /docker-entrypoint-initdb.d/schema/06_indexes.sql
    \ir /docker-entrypoint-initdb.d/schema/07_functions.sql
    \ir /docker-entrypoint-initdb.d/schema/08_triggers.sql
SQL
