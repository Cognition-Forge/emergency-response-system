# AI-assisted Emergency Accommodation Workspace

This repository demonstrates an AI-assisted emergency accommodation workflow built on top of a deterministic PostgreSQL sandbox. It is organised around ticket specifications in `specs/` and split into two primary components:

- `postgres-scenarios/` — Dockerised PostgreSQL 17 stack with schema seeders, three emergency response data scenarios, and validation queries.
- `emergency_accommodation/` — Python CLI showcasing iterative search, AI-driven decision making, and rich terminal output (in-progress) for the seeded scenarios.
- Documentation updates live alongside the Python CLI (see `emergency_accommodation/README.md` and `emergency_accommodation/docs/CLI_TROUBLESHOOTING.md`).
- Visual overview diagrams are available in `docs/emergency_accommodation_flowchart.md`.

## Getting Started
1. Install [uv](https://github.com/astral-sh/uv) if it is not already on your path.
2. Create the Python environment and install dependencies:
   ```bash
   cd emergency_accommodation
   uv sync
   ```
3. Start the PostgreSQL sandbox in a separate shell:
   ```bash
   cd ../postgres-scenarios
   cp .env.example .env   # adjust credentials if desired
   docker compose up -d
   ./scripts/utils/load-scenario.sh scenario1
   ./scripts/utils/load-scenario.sh scenario2
   ./scripts/utils/load-scenario.sh scenario3
   ```
4. Export runtime environment variables before launching the CLI:
   ```bash
   cd emergency_accommodation
   cp .env.example .env   # populate DATABASE_URL and OPENAI_API_KEY (loaded automatically)
   ```
   *Alternatively, export the variables manually if you prefer not to store them in `.env`.*
5. Run the emergency accommodation CLI:
   ```bash
   cd emergency_accommodation
   uv run python main.py --scenario scenario1
   ```
   Use `--config-dir` to point at alternate configuration roots and `--max-iterations` to override iteration limits when needed.

Refer to `AGENTS.md` or `CLAUDE.md` for contributor workflow conventions.

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
