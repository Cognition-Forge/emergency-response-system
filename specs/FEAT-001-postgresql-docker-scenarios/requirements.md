# PoC Requirements: Emergency Accommodation Demo Database

## Context & Goal
Provide a self-contained PostgreSQL 17 container that powers the AI emergency accommodation demonstration. The PoC must spin up with a single `docker compose up`, expose only what the demo needs, and preload three curated scenarios that validate the AI analysis flows end to end.

## Scope
- **In**: Dockerised PostgreSQL instance, lean materials-management schema, seed scripts for the three emergency scenarios, helper queries the demo UI relies on, reset/cleanup helpers.
- **Out**: Full production hardening, multi-environment CI/CD pipelines, non-essential modules (fabrication, advanced role hierarchies, etc.).

## Key Outcomes
1. Containerised database starts in <30s and is reachable on `localhost:5432` with TLS enabled.
2. Schema covers tables required for purchase orders, SCNs, inventory, reservations, emergency incidents, audit logs, and supporting reference data.
3. Three scenario datasets load independently and demonstrate increasing accommodation complexity:
   - **Scenario 1 (Simple)** – Exact-match inventory, no conflicts, ROS alignment.
   - **Scenario 2 (Conflict)** – Inventory with soft commitments, medium priority reservations, AI must justify reassignment.
   - **Scenario 3 (Critical)** – Emergency stockpile depletion, displaced commitments, executive approval trail.
4. AI accommodation queries return ranked recommendations with availability, urgency, and impact scoring in <2s per scenario.
5. Reset path (`docker compose down -v` or scenario cleanup) restores the database for the next demo run.

## Acceptance Criteria
- Single command bootstrap with documented `.env` configuration.
- Schema migration completes without manual intervention; all tables have UUID PKs and referential integrity.
- Scenario SQL files can be applied independently and include sufficient data to exercise PO→SCN→Inventory→FMR flows.
- `fn_emergency_inventory_search` function surfaces meaningful scores across all datasets.
- Audit log captures inserts/updates/deletes on critical operational tables for replay during demos.
- Documentation explains how to load/reset scenarios and how the AI queries consume the data.

## Test Data Expectations
- Each scenario seeds: project, suppliers, warehouses, WBS path with ROS dates, POs + line items, SCNs, inventory, reservations, incidents/accommodations.
- Companion data (document types, units of measure, freight packages) kept minimal but present so demo UI queries succeed.
- Provide at least one verification query per scenario showing expected recommendation ordering.
