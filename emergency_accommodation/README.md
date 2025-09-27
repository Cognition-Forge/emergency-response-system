# Emergency Accommodation CLI

AI-guided command-line workflow for triaging failed supply chain shipments and recommending accommodation plans across the baseline and enhanced demo scenarios.

## Prerequisites
- Python 3.11+
- [`uv`](https://github.com/astral-sh/uv) for environment management
- Local PostgreSQL stack from `postgres-scenarios/` (see below)
- OpenAI API key exposed as `OPENAI_API_KEY`
- TLS-enabled database URL exported as `DATABASE_URL` (e.g. `postgresql://user:pass@127.0.0.1:5432/materials_management`)
- Recommended: copy `.env.example` to `.env` and populate the variables (the CLI auto-loads `.env` files via `python-dotenv`).

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
# optional large-scale datasets
./scripts/utils/load-scenario.sh scenario1-enhanced
./scripts/utils/load-scenario.sh scenario2-enhanced
./scripts/utils/load-scenario.sh scenario3-enhanced
```

Stop and reset with `docker compose down -v` when finished. Use `./scripts/utils/load-scenario.sh cleanup` to purge projects without destroying volumes.

## Configuration

Search parameters live in `config/search_parameters.yaml`. Each scenario inherits the `default` block and may override individual keys:

```yaml
default:
  max_iterations: 3
  time_window_type: "weekly"
  batch_size_per_iteration: 10
  early_stopping_threshold: 5
  search_order: "urgency_first"
  ai_timeout_seconds: 30

scenarios:
  scenario1:
    risk_tolerance: "conservative"
    max_iterations: 2
  scenario2:
    risk_tolerance: "moderate"
    early_stopping_threshold: 8
  scenario3:
    time_window_type: "priority_based"
    search_order: "availability_first"
  scenario1-enhanced:
    risk_tolerance: "conservative"
    approval_preference: "minimize"
    max_iterations: 2
    early_stopping_threshold: 4
    batch_size_per_iteration: 15
  scenario2-enhanced:
    risk_tolerance: "moderate"
    approval_preference: "minimize"
    max_iterations: 3
    batch_size_per_iteration: 12
    early_stopping_threshold: 8
    search_order: "availability_first"
  scenario3-enhanced:
    risk_tolerance: "aggressive"
    approval_preference: "accept_higher"
    max_iterations: 3
    batch_size_per_iteration: 15
    search_order: "availability_first"
    time_window_type: "priority_based"
```

Prompt templates live under `config/prompts/`. The agent loads `base_prompt.txt` and appends the scenario posture file:

```
config/prompts/base_prompt.txt
config/prompts/scenario1.txt           # Conservative posture overlay
config/prompts/scenario2.txt           # Balanced posture overlay
config/prompts/scenario3.txt           # Aggressive posture overlay
config/prompts/scenario1-enhanced.txt  # Conservative hurricane response expertise
config/prompts/scenario2-enhanced.txt  # Balanced multi-hazard coordination
config/prompts/scenario3-enhanced.txt  # Aggressive executive decision framing
```

Each prompt file is plain text. A minimal scenario overlay can look like:

```
Scenario posture: Conservative.
Minimize approval overhead and protect schedule commitments above all else.
Recommend continuing search unless options meet strict compliance and risk thresholds.
```

Runtime knobs may also be supplied as environment variables (fallbacks shown in parentheses):
- `AI_MODEL` (`gpt-4o-mini`)
- `AI_TEMPERATURE` (`0.2`)
- `AI_MAX_OUTPUT_TOKENS` (`900`)
- `AI_TIMEOUT_SECONDS` (`30.0`)
- `EARLY_STOPPING_THRESHOLD` (optional override of YAML value)
- `LOG_LEVEL` (`INFO`)

## Environment Setup
The CLI automatically loads `.env` if present. A starter file is included:

```bash
cd emergency_accommodation
cp .env.example .env
# edit DATABASE_URL and OPENAI_API_KEY before running the CLI
```

## Running the CLI
```bash
cd emergency_accommodation
uv run python main.py --scenario scenario1
```

Optional arguments:
- `--config-dir` to point at an alternate configuration root

The workflow loads failed shipments, iteratively fetches candidate accommodations, evaluates them with the AI agent, and prints a rich summary.

Common launch patterns:

- Override configuration directory:
  ```bash
  uv run python main.py --scenario scenario2 --config-dir ../custom-config
  ```
- Limit iterations from the command line:
  ```bash
  uv run python main.py --scenario scenario3 --max-iterations 1
  ```

Architecture overviews are available in [`docs/emergency_accommodation_flowchart.md`](../docs/emergency_accommodation_flowchart.md).

## AI Agent Internals
- The CLI now relies on the OpenAI Agents SDK (`openai-agents`) to evaluate each iteration and produce a final recommendation.
- Prompt text files are merged into the Agent’s `instructions`, while iteration payloads (failed items + candidate inventory) are passed as JSON.
- Structured outputs from the Agent are parsed into the existing domain models (`IterationDecision`, `FinalRecommendation`), so downstream display logic remains unchanged.
- Timeout, temperature, and token limits are still controlled through YAML/env overrides listed above.

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
- **AI timeouts**: adjust `AI_TIMEOUT_SECONDS` or connect to a faster model tier.
- **Empty recommendations**: ensure scenarios are loaded and `early_stopping_threshold` is not overly aggressive; rerun with `--max-iterations 3` to broaden search.
- **Database auth failures**: confirm TLS paths in `postgres-scenarios/.env` and that `DATABASE_URL` matches the generated credentials.
- **Missing prompts**: check the scenario file names under `config/prompts/` and confirm they match the `--scenario` argument.

More scenarios are covered in `docs/CLI_TROUBLESHOOTING.md`.
