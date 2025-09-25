#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
PROJECT_ROOT=$(cd "${SCRIPT_DIR}/../.." && pwd)
SCENARIO_DIR="${PROJECT_ROOT}/scripts/scenarios"

usage() {
  cat <<USAGE
Usage: $(basename "$0") <scenario>

Scenarios:
  1 | scenario1 | simple      Load scenario1-simple.sql
  2 | scenario2 | conflict    Load scenario2-conflict.sql
  3 | scenario3 | critical    Load scenario3-critical.sql
  cleanup                     Run cleanup.sql (removes all scenario projects)

Environment:
  Reads connection details from .env (POSTGRES_DB, POSTGRES_USER, POSTGRES_PASSWORD, POSTGRES_PORT).
  Override PGPASSWORD/POSTGRES_HOST if required before running.
USAGE
}

if [[ $# -lt 1 ]]; then
  usage
  exit 1
fi

SCENARIO_KEY=$1
case "$SCENARIO_KEY" in
  1|scenario1|simple)
    SQL_FILE="scenario1-simple.sql"
    ;;
  2|scenario2|conflict)
    SQL_FILE="scenario2-conflict.sql"
    ;;
  3|scenario3|critical)
    SQL_FILE="scenario3-critical.sql"
    ;;
  cleanup)
    SQL_FILE="cleanup.sql"
    ;;
  -h|--help|help)
    usage
    exit 0
    ;;
  *)
    echo "Unknown scenario '${SCENARIO_KEY}'." >&2
    usage
    exit 1
    ;;
 esac

ENV_FILE="${PROJECT_ROOT}/.env"
if [[ -f "${ENV_FILE}" ]]; then
  # shellcheck disable=SC2046
  set -a
  source "${ENV_FILE}"
  set +a
else
  echo "Warning: .env not found – relying on ambient environment variables." >&2
fi

POSTGRES_HOST=${POSTGRES_HOST:-127.0.0.1}
POSTGRES_PORT=${POSTGRES_PORT:-5432}
: "${POSTGRES_DB:?POSTGRES_DB must be set}"
: "${POSTGRES_USER:?POSTGRES_USER must be set}"
: "${POSTGRES_PASSWORD:?POSTGRES_PASSWORD must be set}"

export PGPASSWORD=${PGPASSWORD:-$POSTGRES_PASSWORD}

SQL_PATH="${SCENARIO_DIR}/${SQL_FILE}"
if [[ ! -f "${SQL_PATH}" ]]; then
  echo "Scenario file not found: ${SQL_PATH}" >&2
  exit 1
fi

echo "Running ${SQL_FILE} against ${POSTGRES_DB} on ${POSTGRES_HOST}:${POSTGRES_PORT}" >&2

psql \
  "sslmode=require host=${POSTGRES_HOST} port=${POSTGRES_PORT} dbname=${POSTGRES_DB} user=${POSTGRES_USER}" \
  -v ON_ERROR_STOP=1 \
  -f "${SQL_PATH}"
