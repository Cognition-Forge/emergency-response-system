# FEAT Design: Agent Class Migration

## Technical Architecture
- Replace the bespoke `AccommodationAgent` logic that calls `AsyncOpenAI.responses.create` with the Agents SDK (`openai.agents.Agent`).
- Maintain the existing module boundaries: configuration loading (`config/`), database access (`database.py`), AI orchestration (`ai_agent.py`), and CLI (`main.py`).
- Introduce a thin wrapper that instantiates an Agent per run with merged prompt text, delegates iteration evaluations to the Agent, and extracts structured decisions/recommendations.
- Preserve CLI progress reporting and error handling; only the AI evaluation internals change.

## Dependencies
- `openai-agents` SDK (target ≥0.3.2 for `Agent` helpers and structured responses).
- Continue using the base `openai` client (`>=1.109.1`), `python-dotenv`, `asyncpg`, `rich`.
- No new external services or database schema changes.

### Configuration Mapping
- YAML `max_iterations`, `batch_size_per_iteration`, `early_stopping_threshold` continue to drive the iteration loop; Agent runs do not change the batching logic.
- Prompt text files (`base_prompt.txt` + scenario overlay) combine into the Agent’s `instructions` string.
- Optional YAML knobs (e.g., `ai_model`, `ai_temperature`, `ai_timeout_seconds`) map to Agent creation or run options.
- Early stopping remains a CLI concern; Agent responses should emit explicit continue/stop indicators that the CLI interprets.
- Scenario-specific metadata (risk tolerance, approval preference) is injected into the per-iteration payload supplied to the Agent so that reasoning remains contextual.
- `.env` values continue to supply `OPENAI_API_KEY` and optional overrides such as `LOG_LEVEL`.

### Agent Invocation Strategy
- Instantiate the Agent once per CLI run with merged instructions and model options.
- For each iteration, call `Runner.run` (async) with a JSON payload describing failed items and the current inventory batch.
- Define lightweight Pydantic schemas (`_IterationDecisionPayload`, `_FinalRecommendationPayload`) and map Agent outputs back into existing domain models.
- Apply CLI-managed timeouts around `Runner.run` to honour `ai_timeout_seconds`.

## Data Flow
```
YAML / prompt files --> Agent constructor (instructions, settings)
                    --> CLI orchestrator triggers Agent runs per iteration
                    --> Agent returns structured response (continue/search decision, recommendations)
                    --> CLI displays via Rich
Database (asyncpg) --> same iterative queries --> Agent inputs
```

## Security Considerations
- API keys remain in `.env` / environment; no new secrets introduced.
- Agent SDK must not log sensitive data; ensure logging remains at INFO without dumping prompts unless debug explicitly enabled.
- Continue using parameterized SQL queries; no new write operations.

## Performance Constraints
- Agent SDK responses must complete within current timeout defaults; allow configuration of timeouts through existing config entries.
- Iterative batching and early stopping thresholds remain; ensure no additional synchronous waits block the event loop.
- Avoid heavy agent tooling or multi-agent chains—single agent per scenario run keeps the implementation lean.
