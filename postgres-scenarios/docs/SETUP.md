# Setup Guide

Follow these steps to provision the emergency accommodation demo database on your workstation.

## 1. Prerequisites

- Docker Desktop or Lima with Docker Engine 24+
- `psql` client (v14+ recommended for TLS/SCRAM support)
- OpenSSL (only required if you regenerate certificates)

## 2. Configure Environment Variables

1. Create a working copy of the environment template:
   ```bash
   cp .env.example .env
   ```
2. Update the following keys in `.env`:
   - `POSTGRES_DB`, `POSTGRES_USER`, `POSTGRES_PASSWORD`
   - Optional tuning (`POSTGRES_SHARED_BUFFERS`, `POSTGRES_EFFECTIVE_CACHE_SIZE`, etc.)
   - `POSTGRES_PORT` if the default `5432` clashes with a local installation

The repository ships with self-signed certificates under `certs/`. Replace them if your security policy requires different credentials (point `POSTGRES_SSL_CERT_FILE` / `POSTGRES_SSL_KEY_FILE` to the new paths).

## 3. Launch the Stack

From `postgres-scenarios/` run:

```bash
docker compose up -d
```

The init pipeline automatically runs:
- `00-configure.sh` – enables TLS and performance knobs.
- `01-extensions.sql` – installs `uuid-ossp`, `pg_trgm`, `pgcrypto`.
- `02-create-users.sh` – provisions the demo application role.
- `05-db.sh` – creates the lean materials-management schema, functions, and audit triggers.

Check readiness:

```bash
docker compose logs -f materials-db
```

Once `database system is ready to accept connections` appears, continue.

## 4. Load a Scenario Dataset

Use the `psql` client from your host so that the SQL file can be read directly from the workspace. Replace the connection details with the values from your `.env` file.

```bash
PGPASSWORD=change_me \
psql "sslmode=require host=127.0.0.1 port=5432 dbname=materials_management user=materials_admin" \
     -f scripts/scenarios/scenario1-simple.sql
```

Repeat with `scenario2-conflict.sql` or `scenario3-critical.sql` as needed. Each script is idempotent and will first delete the matching project before reseeding. Alternatively, use the helper:

```bash
./scripts/utils/load-scenario.sh scenario3
```

## 5. Run Verification Queries

After loading a scenario, confirm the dataset with:

```bash
PGPASSWORD=change_me psql "sslmode=require host=127.0.0.1 port=5432 dbname=materials_management user=materials_admin" \
     -f scripts/queries/validation-checks.sql

PGPASSWORD=change_me psql "sslmode=require host=127.0.0.1 port=5432 dbname=materials_management user=materials_admin" \
     -f scripts/queries/accommodation-analysis.sql
```

The first script reports row counts and impact levels per scenario; the second surfaces recommendation rankings from `fn_emergency_inventory_search`. Load all three scenario datasets before running the validation script—verification references each project’s PO line item and will raise “PO line item … not found” if any scenario is missing.

## 6. Resetting Data

- Remove the seeded projects while keeping the container running:
  ```bash
  PGPASSWORD=change_me psql "sslmode=require host=127.0.0.1 port=5432 dbname=materials_management user=materials_admin" \
       -f scripts/scenarios/cleanup.sql
  ```
- Rebuild everything from scratch (drops volumes):
  ```bash
  docker compose down -v
  docker compose up -d
  ```

Consult `docs/SCENARIOS.md` for storytelling context and `docs/TROUBLESHOOTING.md` if anything fails during bootstrap.
