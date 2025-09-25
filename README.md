# AI-assisted Emergency Accommodation Workspace

This repository demonstrates an AI-assisted emergency accommodation workflow built on top of a deterministic PostgreSQL sandbox. It is organised around ticket specifications in `specs/` and split into two primary components:

- `postgres-scenarios/` — Dockerised PostgreSQL 17 stack with schema seeders, three emergency response data scenarios, and validation queries.
- `emergency_accommodation/` — Python CLI showcasing iterative search, AI-driven decision making, and rich terminal output (in-progress) for the seeded scenarios.

## Getting Started
1. Clone the repo and install [uv](https://github.com/astral-sh/uv) if not already available.
2. Bootstrap the Python environment:
   ```bash
   cd emergency_accommodation
   uv sync
   ```
3. Bring the database online in a separate shell:
   ```bash
   cd ../postgres-scenarios
   cp .env.example .env   # adjust credentials if desired
   docker compose up -d
   ./scripts/utils/load-scenario.sh scenario1
   ./scripts/utils/load-scenario.sh scenario2
   ./scripts/utils/load-scenario.sh scenario3
   ```
4. Export required environment variables before running the CLI or live tests:
   ```bash
   export OPENAI_API_KEY=...           # real key for production runs; mocked in unit tests
   export DATABASE_URL="postgresql://materials_admin:change_me@127.0.0.1:5432/materials_management"
   ```

## Development Workflow
- Follow the specification tickets under `specs/` and update their `tasks.md` checklists as progress is made.
- `AGENTS.md` summarises repo conventions, testing discipline, and documentation pointers.
- `docs/Claude/` contains domain primers that explain the accommodation storylines.
- Use the Python README at `emergency_accommodation/README.md` for CLI-specific options, configuration knobs, and troubleshooting tips.

## Testing
- Run the mocked/unit suites:
  ```bash
  cd emergency_accommodation
  uv run python -m pytest
  ```
- Execute live integration suites (requires database + env vars):
  ```bash
  DATABASE_URL=postgresql://materials_admin:change_me@127.0.0.1:5432/materials_management \
  uv run python -m pytest
  ```
- SQL validation queries live under `postgres-scenarios/scripts/queries/` and can be executed with `psql` for scenario sanity checks.

## Maintenance Notes
- Keep `.env` outside version control and regenerate TLS certs in `postgres-scenarios/certs/` when rotating credentials.
- The AI agent defaults to conservative timeouts (12s) and early stopping thresholds configurable through YAML or environment variables.
- `docker compose down -v` resets the database; `./scripts/utils/load-scenario.sh cleanup` removes scenario data while retaining volumes.

For detailed ticket requirements, consult `specs/FEAT-002-emergency-response/`. Multiple gates remain in progress—refer to the task tracker for the latest status.
