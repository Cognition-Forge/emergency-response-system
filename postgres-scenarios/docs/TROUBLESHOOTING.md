# Troubleshooting Guide

Common fixes while working with the emergency accommodation demo stack.

## Container & Bootstrap

- **Container fails on startup** – Inspect logs with `docker compose logs materials-db`. Certificate copy failures or syntax errors in the init scripts are the usual culprit. Regenerate certs or rerun after fixing the script.
- **Health check remains unhealthy** – The first boot can take ~30s. If it never transitions, run `docker compose down -v` to remove volumes, then start again from a clean slate.
- **Permission denials in init scripts** – Ensure the shell scripts under `scripts/init/` remain executable (`chmod +x scripts/init/*.sh`).

## Connectivity

- **`psql` rejects TLS/SCRAM** – Confirm you are passing `sslmode=require` and that the certificate paths in `.env` match the files under `certs/`.
- **Auth failures** – Use the credentials from `.env`. When scripting, prefix commands with `PGPASSWORD=…` (or set `PGPASSFILE`) so that password prompts do not break automation.

## Scenario Seeding

- **Scenario script aborts** – The scripts are idempotent but depend on the base schema. Make sure the container completed its first boot before running them. Re-run the script; it deletes the existing project before reloading the data.
- **Need a partial reset** – Run:
  ```bash
  PGPASSWORD=change_me psql "sslmode=require host=127.0.0.1 port=5432 dbname=materials_management user=materials_admin" \
       -f scripts/scenarios/cleanup.sql
  ```
  This leaves the core schema intact but removes all seeded projects, incidents, reservations, and audit entries tied to them.

## Verification Issues

- **Validation script shows unexpected counts** – Ensure you loaded the intended scenario file. The counts in `docs/SCENARIOS.md` provide the reference numbers for each dataset.
- **Recommendation impact level differs** – Check outstanding reservations in `inventory_reservations`. Scenario 2 requires one `can_reassign = TRUE` entry; Scenario 3 requires `quantity_reserved > quantity_available`.

## When All Else Fails

1. Collect logs: `docker compose logs materials-db > logs.txt`.
2. Reset volumes: `docker compose down -v`.
3. Relaunch: `docker compose up -d` and reapply the desired scenarios.

If problems persist, verify that local extensions (`uuid-ossp`, `pgcrypto`, `pg_trgm`) are available on your platform; the init scripts will fail if the PostgreSQL build omits them.
