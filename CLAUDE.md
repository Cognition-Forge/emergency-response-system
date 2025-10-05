# Repository Guidelines

## Top Priority Instruction
- **NEVER delete any markdown files (`*.md`).** Preserve all markdown documentation unless explicitly instructed otherwise.

## Project Structure & Module Organization
- `postgres-scenarios/`: Dockerised PostgreSQL stack, init scripts, scenario data, docs.
- `specs/`: Ticket requirements, design notes, task trackers (follow before coding).
- `docs/Claude/`: Domain briefings; read sequentially when onboarding.
- `tmp/`: Scratch space; do not commit.

## Build, Test, and Development Commands
- `docker compose up -d` (run inside `postgres-scenarios/`): starts Postgres 17 with schema init.
- `./scripts/utils/load-scenario.sh <scenario>`: seeds demo data (`scenario1|scenario2|scenario3|scenario1-enhanced|scenario2-enhanced|scenario3-enhanced|cleanup`).
- `PGPASSWORD=… psql ... -f scripts/queries/validation-checks.sql`: validates scenario coverage and search results.
- `docker compose down -v`: tears down stack and purges volumes for a clean rebuild.
- `uv sync` (run inside `emergency_accommodation/`): installs CLI dependencies into `.venv/`.
- `uv run python -m pytest`: executes unit suite; add `DATABASE_URL=…` for live DB + AI integration.

## Coding Style & Naming Conventions
- SQL files use uppercase keywords, snake_case identifiers, and 4-space indents.
- Shell scripts follow `set -euo pipefail`; prefer long-form flags and quoted variables.
- UUIDs generated with `uuid_generate_v5` for deterministic seeds; keep existing namespace values.
- Documentation lives in Markdown with sentence-case headings and concise bullets.

## Testing Guidelines
- Validation relies on the helper SQL under `scripts/queries/`; load all three scenarios before running checks.
- Manual verification: run `validation-checks.sql` then `accommodation-analysis.sql` to confirm `fn_emergency_inventory_search` outputs expected impact levels.
- When adding scenario data, include deterministic UUIDs and expand validation queries with matching expectations.
- AI agent tests mock LangChain providers; live suites require exporting `DATABASE_URL` and provider-specific API key (`OPENAI_API_KEY`, `ANTHROPIC_API_KEY`, or `GOOGLE_API_KEY` based on `ai_provider` config). Timeout behaviour defaults to 30s—tune with `AI_TIMEOUT_SECONDS` if needed.
- LLM request/response logging can be enabled with `LOG_LLM_CALLS=true` (writes to `emergency_accommodation/logs/llm_calls.jsonl`). The `logs/` directory is gitignored.

## Documentation
- Project-specific instructions are maintained in `emergency_accommodation/README.md`; update it when workflows or required environment variables change.

## Commit & Pull Request Guidelines
- Commits: present-tense imperative (“Add scenario3 critical dataset”); bundle related SQL + docs edits together.
- PRs should reference the relevant ticket in `specs/`, summarize scenario/SQL changes, and attach command output screenshots if behavior changed.
- Always update `specs/.../tasks.md` checkboxes when completing scoped items; reviewers rely on that progress log.

## Security & Configuration Tips
- TLS cert/key live in `postgres-scenarios/certs/`; regenerate with OpenSSL if rotating credentials.
- Keep `.env` uncommitted; use `.env.example` as the contract for required variables.
- Avoid exposing Postgres beyond `127.0.0.1`; the compose network is already limited to localhost.
