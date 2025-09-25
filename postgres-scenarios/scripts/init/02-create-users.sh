#!/bin/sh
set -euo pipefail

APP_USER=${MATERIALS_APP_USER:-materials_app}
APP_PASSWORD=${MATERIALS_APP_PASSWORD:-materials_app_password}

psql \
  -v ON_ERROR_STOP=1 \
  --username "$POSTGRES_USER" --dbname "$POSTGRES_DB" <<SQL
DO \$\$DECLARE
  v_role_exists BOOLEAN;
BEGIN
  SELECT EXISTS (SELECT 1 FROM pg_roles WHERE rolname = '${APP_USER}') INTO v_role_exists;

  IF NOT v_role_exists THEN
    EXECUTE format('CREATE ROLE %I LOGIN PASSWORD %L', '${APP_USER}', '${APP_PASSWORD}');
  ELSE
    EXECUTE format('ALTER ROLE %I WITH PASSWORD %L', '${APP_USER}', '${APP_PASSWORD}');
  END IF;

  EXECUTE format('GRANT CONNECT ON DATABASE %I TO %I', '${POSTGRES_DB}', '${APP_USER}');
END \$\$;
SQL
