# FEAT Requirements: LLM Call Logging

## Business Context

Enable developers to debug AI agent behavior by capturing complete LLM request/response cycles. The logging system must be lightweight (stdlib-only), environment-toggled (off by default), and produce machine-parseable output for analysis.

## User Stories

**US-001: Developer Debugging**
As a developer debugging AI evaluation logic, I want complete LLM request/response logs so I can understand why the agent made specific decisions.

**US-002: Performance Analysis**
As a developer optimizing AI costs, I want timestamped logs with latency metrics so I can identify slow calls and estimate token usage.

**US-003: Non-Intrusive Logging**
As a developer running production scenarios, I want logging disabled by default so there's no performance penalty or storage overhead when not needed.

## Acceptance Criteria

### AC-001: Environment-Controlled Toggle
- **GIVEN** the system is running
- **WHEN** `LOG_LLM_CALLS` environment variable is set to `"true"`
- **THEN** all LLM calls are logged to `emergency_accommodation/logs/llm_calls.jsonl`

### AC-002: Request Payload Capture
- **GIVEN** LLM logging is enabled
- **WHEN** an iteration evaluation or final recommendation is requested
- **THEN** the log entry contains:
  - Request timestamp (ISO 8601 format)
  - Agent name ("Iteration Evaluator" or "Final Recommender")
  - Model name (e.g., "gpt-4o-mini")
  - Model settings (temperature, max_tokens)
  - Full system instructions (combined prompt)
  - Full user payload (JSON string with scenario, iteration, inventory, etc.)

### AC-003: Response Payload Capture
- **GIVEN** LLM logging is enabled
- **WHEN** an LLM call completes (success or failure)
- **THEN** the log entry contains:
  - Response timestamp (ISO 8601 format)
  - Duration in milliseconds
  - Full structured output (IterationDecisionPayload or FinalRecommendationPayload)
  - Error message if call failed (null otherwise)

### AC-004: JSON Lines Format
- **GIVEN** LLM logging is enabled
- **WHEN** logs are written
- **THEN** each log entry is a single-line valid JSON object appended to the file
- **AND** logs are parseable with standard tools (jq, Python json module)

### AC-005: Graceful Failure Handling
- **GIVEN** LLM logging is enabled
- **WHEN** log write fails (disk full, permission error, etc.)
- **THEN** the LLM call still completes successfully
- **AND** the logging error is captured in stderr/console

## Non-Functional Requirements

**NFR-001: Zero Dependencies**
- Use Python stdlib only (json, pathlib, datetime, os)
- No external logging frameworks

**NFR-002: Minimal Performance Impact**
- Logging overhead <50ms per call (synchronous file I/O acceptable)
- No impact when disabled (single environment variable check)

**NFR-003: File Management**
- Auto-create `logs/` directory if missing
- Append-only writes (no rotation, no size limits for MVP)
- Document in `.env.example`

**NFR-004: Privacy**
- No redaction in MVP (defer to future enhancement)
- Log full payloads including scenario data
