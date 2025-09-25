# PoC Tasks: Emergency Accommodation Demo Database

## Definition of Ready
- [x] PoC requirements documented (`requirements.md`).
- [x] Technical design outlined (`design.md`).
- [x] Source reference data available (docs/Claude, accommodation examples).
- [x] Docker runtime confirmed (Lima-based compose up succeeds).
- [x] Acceptance criteria scoped to three demo scenarios.

## Implementation Plan

### Phase 1 – Container & Base Schema (completed)
- [x] Provision docker-compose stack with TLS, health check, named volumes.
- [x] Implement init scripts for configuration, extensions, user creation.
- [x] Create modular schema SQL files, indexes, functions, audit triggers.

### Phase 2 – Scenario Data & Utilities
- [x] Seed Scenario 1 (simple accommodation) via `scripts/scenarios/scenario1-simple.sql`.
- [x] Seed Scenario 2 (conflict accommodation) via `scripts/scenarios/scenario2-conflict.sql`.
- [x] Seed Scenario 3 (critical emergency reserves) via `scripts/scenarios/scenario3-critical.sql`.
- [x] Implement `scripts/scenarios/cleanup.sql` for reusable resets.
- [x] Add verification queries (`scripts/queries/accommodation-analysis.sql`, `scripts/queries/validation-checks.sql`).

### Phase 3 – Documentation & Validation
- [x] Update docs (`README.md`, `docs/SETUP.md`, `docs/SCENARIOS.md`, `docs/TROUBLESHOOTING.md`) with scenario-loading steps and verification instructions.
- [x] Capture sample query outputs for each scenario to validate AI effectiveness.
- [x] Provide quick-start script or command snippets for loading individual scenarios.

## Definition of Done
- [x] Docker stack launches cleanly and passes health check after each scenario load.
- [x] All three scenarios populate expected data and verification queries pass.
- [x] Accommodation search function produces ranked results demonstrating simple, conflict, and critical outcomes.
- [x] Documentation enables a new user to reset, load, and validate scenarios without outside context.
- [x] Reset procedures (`cleanup.sql` and `docker compose down -v`) verified.
