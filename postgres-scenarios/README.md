# PostgreSQL Emergency Scenario Environment

This workspace delivers a TLS-enabled PostgreSQL 17 container with pre-built schema and curated datasets that exercise the emergency accommodation workflows. Use it to demo AI recommendations across three escalating scenarios (simple, conflict, critical).

## Quick Start

1. Copy the environment template and provide credentials that suit your machine:
   ```bash
   cp .env.example .env
   # edit .env before first launch (database name, user, password, tuning)
   ```
2. Bring the database online (once per fresh volume):
   ```bash
   docker compose up -d
   ```
3. Connect over TLS on `127.0.0.1:${POSTGRES_PORT:-5432}`. The init scripts already created the base schema, extensions, demo users, and audit triggers.

## Loading Scenario Data

Each scenario is represented by a standalone SQL script under `scripts/scenarios/`. Run them one at a time after the container has started. Example (replace the connection details with the values from your `.env`):

```bash
PGPASSWORD=change_me \
psql "sslmode=require host=127.0.0.1 port=5432 dbname=materials_management user=materials_admin" \
     -f scripts/scenarios/scenario1-simple.sql
```

Available datasets:
- `scenario1-simple.sql` – direct match with surplus inventory.
- `scenario2-conflict.sql` – medium-priority reservations that can be reassigned.
- `scenario3-critical.sql` – depleted stockpile requiring executive approval.
- `scenario1-enhanced.sql` – hurricane-scale response with multi-commodity shortages and geographic distribution.
- `scenario2-enhanced.sql` – regional multi-hazard event with competing agency priorities and cascading coverage gaps.
- `scenario3-enhanced.sql` – metropolitan infrastructure collapse with executive-level trade-offs.

Reuse `scripts/scenarios/cleanup.sql` when you need to purge all three projects without destroying the Docker volume.

Shortcut: `scripts/utils/load-scenario.sh` reads `.env` and runs the correct SQL file. It accepts friendly aliases (`1`, `2`, `3`, `1e`, `2e`, `3e`, `cleanup`).

```bash
./scripts/utils/load-scenario.sh scenario2
./scripts/utils/load-scenario.sh cleanup
```

## Verification Queries

Run the helper scripts in `scripts/queries/` to confirm the load:

```bash
PGPASSWORD=change_me psql "sslmode=require host=127.0.0.1 port=5432 dbname=materials_management user=materials_admin" \
     -f scripts/queries/validation-checks.sql

PGPASSWORD=change_me psql "sslmode=require host=127.0.0.1 port=5432 dbname=materials_management user=materials_admin" \
     -f scripts/queries/accommodation-analysis.sql
```

`validation-checks.sql` reports entity counts per scenario and confirms the top-ranked impact level. `accommodation-analysis.sql` feeds `fn_emergency_inventory_search` to surface recommendation details that power the AI demo.

## Resetting the Stack

- **Scenario-only reset:** `psql ... -f scripts/scenarios/cleanup.sql`
- **Full reset:** `docker compose down -v && docker compose up -d`

Refer to `docs/SETUP.md` for step-by-step setup, `docs/SCENARIOS.md` for storyline details, and `docs/TROUBLESHOOTING.md` for recovery tips.
