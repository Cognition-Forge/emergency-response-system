#!/bin/sh
set -euo pipefail

CERT_SRC=${POSTGRES_SSL_CERT_FILE:-/certs/server.crt}
KEY_SRC=${POSTGRES_SSL_KEY_FILE:-/certs/server.key}
CERT_TARGET="/var/lib/postgresql/server.crt"
KEY_TARGET="/var/lib/postgresql/server.key"

if [ -f "$CERT_SRC" ] && [ -f "$KEY_SRC" ]; then
  cp "$CERT_SRC" "$CERT_TARGET"
  cp "$KEY_SRC" "$KEY_TARGET"
  chmod 600 "$KEY_TARGET"
  chmod 644 "$CERT_TARGET"
fi

SHARED_BUFFERS=${POSTGRES_SHARED_BUFFERS:-256MB}
EFFECTIVE_CACHE=${POSTGRES_EFFECTIVE_CACHE_SIZE:-1GB}
WORK_MEM=${POSTGRES_WORK_MEM:-4MB}
MAINT_WORK_MEM=${POSTGRES_MAINTENANCE_WORK_MEM:-64MB}
MAX_CONN=${POSTGRES_MAX_CONNECTIONS:-100}

psql -v ON_ERROR_STOP=1 --username "$POSTGRES_USER" --dbname "$POSTGRES_DB" <<SQL
ALTER SYSTEM SET ssl = 'on';
ALTER SYSTEM SET ssl_cert_file = '/var/lib/postgresql/server.crt';
ALTER SYSTEM SET ssl_key_file = '/var/lib/postgresql/server.key';
ALTER SYSTEM SET shared_buffers = '${SHARED_BUFFERS}';
ALTER SYSTEM SET effective_cache_size = '${EFFECTIVE_CACHE}';
ALTER SYSTEM SET work_mem = '${WORK_MEM}';
ALTER SYSTEM SET maintenance_work_mem = '${MAINT_WORK_MEM}';
ALTER SYSTEM SET max_connections = '${MAX_CONN}';
ALTER SYSTEM SET password_encryption = 'scram-sha-256';
ALTER SYSTEM SET log_connections = '${POSTGRES_LOG_CONNECTIONS:-on}';
ALTER SYSTEM SET log_disconnections = '${POSTGRES_LOG_DISCONNECTIONS:-on}';
ALTER SYSTEM SET log_statement = '${POSTGRES_LOG_STATEMENT:-all}';
ALTER SYSTEM SET log_duration = '${POSTGRES_LOG_DURATION:-on}';
SQL
