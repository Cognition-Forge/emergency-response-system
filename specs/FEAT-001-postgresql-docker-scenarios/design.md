# PoC Design: Emergency Accommodation Demo Database

## Deployment Architecture
```
Host (macOS / Lima)
└─ Docker Compose
   └─ postgres:17-alpine (materials-db)
      • TLS via mounted self-signed certs
      • Init scripts under /docker-entrypoint-initdb.d
      • Named volumes: postgres_data, postgres_logs
```
- `docker-compose.yml` constrains the container to localhost, enforces health checks, and sets resource caps (2GB RAM, 1 CPU).
- `.env` file supplies credentials, tuning parameters, and app user secrets used by init scripts.

## Initialization Pipeline
1. `00-configure.sh` – copies TLS cert/key, applies core `ALTER SYSTEM` settings (SSL on, SCRAM auth, performance knobs, logging).
2. `01-extensions.sql` – ensures `uuid-ossp`, `pg_trgm`, `pgcrypto` are available.
3. `02-create-users.sh` – creates the demo application login.
4. `05-db.sh` – orchestrates schema creation:
   - `01_core.sql` – users, projects, project access, system settings.
   - `02_reference.sql` – countries, states, units, incoterms, WBS + ROS dates.
   - `03_supply_chain.sql` – suppliers, warehouses, materials (commodity/equipment), MTOs, POs, SCNs, receipts, inventory, FMRs, reservations, issued log.
   - `04_documents_traceability.sql` – documents, traceability certificates, emergency incidents/accommodations, commitment impacts, search audit.
   - `05_audit.sql` – central audit log table.
   - `06_indexes.sql` – performance indexes optimised for AI search workloads.
   - `07_functions.sql` – `fn_emergency_inventory_search` scoring logic.
   - `08_triggers.sql` – audit triggers applied to operational tables.

## Scenario Data Layout
```
scripts/scenarios/
├─ scenario1-simple.sql
├─ scenario2-conflict.sql
├─ scenario3-critical.sql
└─ cleanup.sql
```
Each scenario script follows the same pattern:
1. Clear existing data for the target project (idempotent deletes).
2. Insert reference entities (project, users, suppliers, warehouses, WBS, ROS dates).
3. Seed transactional data (POs, SCNs, inventory, reservations, incidents).
4. Record expected outputs (e.g. insert into a `scenario_expectations` helper table or comment block with verification queries).

`cleanup.sql` truncates scenario tables in dependency order, ready for a fresh load.

## Demo Queries & Validation
- `scripts/queries/accommodation-analysis.sql` (to be delivered in Gate 4) will call `fn_emergency_inventory_search` for each scenario, returning top 3 recommendations.
- `scripts/queries/validation-checks.sql` will assert referential integrity and row counts for scenario datasets.

## Documentation
- `README.md` – quick start.
- `docs/SETUP.md` – step-by-step bootstrap instructions.
- `docs/SCENARIOS.md` – describes each dataset and intended story.
- `docs/TROUBLESHOOTING.md` – recovery steps (including `docker compose down -v`).

## Reset & Recovery Strategy
- Preferred reset: `docker compose down -v` (drops named volumes) followed by `docker compose up`.
- Per-scenario reset: run `psql -f scripts/scenarios/cleanup.sql` then re-apply the desired scenario file.
- Logs persist in `postgres_logs` named volume for inspection between runs.
