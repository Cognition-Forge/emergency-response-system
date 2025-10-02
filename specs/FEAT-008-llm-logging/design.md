# FEAT Design: LLM Call Logging

## Architecture

### Core Components

**1. LLM Call Logger (`_log_llm_call` function in `ai_agent.py`)**
- Wrapper around `Runner.run()` calls
- Captures request metadata before SDK invocation
- Captures response metadata after SDK completion
- Writes JSON Lines format to append-only file
- Handles logging failures gracefully (logs error, doesn't crash)

**2. Log File Management**
- Path: `emergency_accommodation/logs/llm_calls.jsonl`
- Auto-create directory if missing (using `Path.mkdir(parents=True, exist_ok=True)`)
- Append-only writes (open in `'a'` mode)
- No rotation or cleanup (defer to future enhancement)

**3. Environment Toggle**
- Check: `os.getenv("LOG_LLM_CALLS", "false").lower() == "true"`
- Early return if disabled (minimal overhead)
- Document in `emergency_accommodation/.env.example`

### Data Flow

```
Runner.run() call initiated
    ↓
Check LOG_LLM_CALLS env var
    ↓ (if true)
Capture request metadata:
  - timestamp (datetime.utcnow().isoformat() + "Z")
  - agent_name
  - model, temperature, max_tokens
  - instructions (combined prompt)
  - payload (JSON string)
    ↓
Execute Runner.run() (existing SDK call)
    ↓
Capture response metadata:
  - response timestamp
  - duration_ms (calculated from start time)
  - output (structured payload or None)
  - error (exception message or None)
    ↓
Write JSON line to logs/llm_calls.jsonl
    ↓
Return original Runner.run() result
```

### Log Entry Schema

```json
{
  "timestamp": "2025-10-02T10:30:45.123456Z",
  "agent": "Iteration Evaluator",
  "model": "gpt-4o-mini",
  "request": {
    "instructions": "You are an emergency accommodation...",
    "payload": "{\"scenario\":\"scenario1\",\"iteration\":1,...}",
    "settings": {
      "temperature": 0.2,
      "max_tokens": 900
    }
  },
  "response": {
    "timestamp": "2025-10-02T10:30:46.357890Z",
    "duration_ms": 1234,
    "output": {
      "continue_search": true,
      "reasoning": "...",
      "viable_options": [...]
    },
    "error": null
  }
}
```

## Dependencies

**Standard Library Only:**
- `json` - serialization/deserialization
- `datetime` - ISO 8601 timestamps
- `pathlib.Path` - directory/file management
- `os` - environment variable access
- `time` - duration calculation (perf_counter)

**No External Dependencies Added**

## Constraints

### Performance
- Single file I/O operation per LLM call (append-only)
- Synchronous writes acceptable (calls already 1-10s latency)
- No buffering or async writes (KISS principle)

### Error Handling
- Logging failure MUST NOT crash LLM call
- Wrap logging logic in try/except
- Print logging errors to stderr (`print(..., file=sys.stderr)`)
- Return original SDK result regardless of log success

### File System
- Log directory creation uses `exist_ok=True` (idempotent)
- No file locking (single-process CLI assumption)
- No log rotation (file grows indefinitely)
- Disk full scenario: log write fails, error printed, call succeeds

### Integration Points
- Modify `ai_agent.py:evaluate_iteration()` lines 121-129
- Modify `ai_agent.py:final_recommendation()` lines 171-178
- Both wrap existing `Runner.run()` calls with `_log_llm_call()`

### Code Organization
```python
# ai_agent.py structure changes:

# Add at top-level (after imports)
def _log_llm_call(
    agent_name: str,
    model: str,
    instructions: str,
    payload: str,
    settings: dict[str, Any],
    runner_callable: Callable[[], Awaitable[Any]]
) -> Any:
    """Wrapper that logs LLM calls if LOG_LLM_CALLS=true."""
    # Implementation here
    pass

# Modify evaluate_iteration() around line 122:
result = await asyncio.wait_for(
    _log_llm_call(
        agent_name="Iteration Evaluator",
        model=self._config.get("ai_model", "gpt-4o-mini"),
        instructions=template.combined,
        payload=payload,
        settings={"temperature": temperature, "max_tokens": max_tokens},
        runner_callable=lambda: Runner.run(iteration_agent, payload, run_config=self._build_run_config())
    ),
    timeout=timeout,
)

# Similar change in final_recommendation() around line 172
```

### Testing Strategy
- Unit test: verify log entry structure when `LOG_LLM_CALLS=true`
- Unit test: verify no logs written when `LOG_LLM_CALLS=false`
- Unit test: verify logging failure doesn't crash SDK call
- Integration test: run real scenario, verify `.jsonl` exists and parses
