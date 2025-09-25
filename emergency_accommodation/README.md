# Emergency Accommodation CLI

AI-guided command-line workflow for triaging failed supply chain shipments and recommending accommodation plans across three seeded project scenarios.

## Prerequisites
- Python 3.11+
- [`uv`](https://github.com/astral-sh/uv) for environment management
- Local PostgreSQL stack from `postgres-scenarios/` (see below)
- OpenAI API key exposed as `OPENAI_API_KEY`
- TLS-enabled database URL exported as `DATABASE_URL` (e.g. `postgresql://user:pass@127.0.0.1:5432/materials_management`)

## Project Setup
```bash
cd emergency_accommodation
uv sync
```

All project dependencies (asyncpg, pydantic, openai, rich, etc.) and dev tooling (pytest, mypy, pytest-cov) are pinned in `pyproject.toml`. `uv sync` creates a `.venv/` and downloads exact versions.

## Database & Scenarios
The CLI expects the demo database from `postgres-scenarios/`:

```bash
cd ../postgres-scenarios
cp .env.example .env   # edit credentials as needed
docker compose up -d
./scripts/utils/load-scenario.sh scenario1
./scripts/utils/load-scenario.sh scenario2
./scripts/utils/load-scenario.sh scenario3
```

Stop and reset with `docker compose down -v` when finished. Use `./scripts/utils/load-scenario.sh cleanup` to purge projects without destroying volumes.

## Configuration
- Search parameters live in `config/search_parameters.yaml`, with defaults plus per-scenario overrides.
- AI prompt templates reside under `config/prompts/` (`base_prompt.txt` plus posture-specific files).
- Early stopping thresholds, iteration limits, and AI model overrides can be set via YAML and additional environment variables:
  - `AI_MODEL` (default `gpt-4o-mini`)
  - `AI_TEMPERATURE` (default `0.2`)
  - `AI_MAX_OUTPUT_TOKENS` (default `900`)
  - `AI_TIMEOUT_SECONDS` (default `12.0`)

## Running the CLI
```bash
cd emergency_accommodation
uv run python main.py --scenario scenario1
```

Optional arguments:
- `--config-dir` to point at an alternate configuration root

The workflow loads failed shipments, iteratively fetches candidate accommodations, evaluates them with the AI agent, and prints a rich summary (Gate 4 implementation pending).

## Testing
Unit tests (mocked AI + in-memory DB fakes):
```bash
uv run python -m pytest
```

Full integration tests (requires running PostgreSQL and `DATABASE_URL` export):
```bash
DATABASE_URL=postgresql://materials_admin:change_me@127.0.0.1:5432/materials_management \
uv run python -m pytest
```

All suites target strict asyncio mode; ensure the database stack is healthy before running live tests.

## Linting & Type Checks
`mypy` is included but not yet wired into automated scripts. Run manually when needed:
```bash
uv run python -m mypy .
```

## Troubleshooting
- **AI timeouts**: adjust `AI_TIMEOUT_SECONDS` in the environment or YAML.
- **Empty recommendations**: verify scenarios are loaded and `early_stopping_threshold` is not overly aggressive.
- **Database auth failures**: confirm TLS paths in `postgres-scenarios/.env` and that `DATABASE_URL` matches the generated credentials.
