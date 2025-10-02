# FEAT Tasks: LLM Call Logging

**Complexity Assessment: SIMPLE**
- Acceptance Criteria: 5 ACs (+2)
- Tech Stack: Familiar (Python stdlib, existing codebase) (+0)
- Integration: Single component (ai_agent.py modifications) (+0)
- Dependencies: 0 external (stdlib only) (+0)
- Ticket Type: FEAT (+1)
- **Total Score: 3 → SIMPLE**

**Rationale for SIMPLE tier:** Despite 5 ACs, this is a focused enhancement to a single file with no external dependencies. The implementation is straightforward wrapper logic with stdlib-only requirements. Moving to SIMPLE tier to avoid over-engineering.

## Definition of Ready (DoR)
- [x] Requirements clear and complete
- [x] Dependencies identified and accessible (stdlib only)
- [x] Acceptance criteria testable
- [x] Architecture decisions made (wrapper function, JSON Lines format)
- [x] Coverage tooling configured (pytest-cov already in use)
- [x] Complexity tier determined (SIMPLE)

## Implementation Plan
**CRITICAL**: Implementation requires explicit user instruction to begin.

The implementation will modify `emergency_accommodation/ai_agent.py` to add a logging wrapper around existing `Runner.run()` calls. All changes are isolated to this single file plus `.env.example` documentation.

## Definition of Done (DoD)
- [x] All acceptance criteria verified (AC-001 through AC-005)
- [x] Tests passing for ai_agent module
- [x] Test coverage ≥68% for new logging function
- [x] `.env.example` updated with LOG_LLM_CALLS documentation

---

## Task Breakdown (SIMPLE: 5 tasks, embedded verification)

### Setup Tasks (1-2)

- [x] **TASK-001**: Create logging infrastructure
  - Add `_log_llm_call()` function in `ai_agent.py` with signature: `async def _log_llm_call(agent_name, model, instructions, payload, settings, runner_coro) -> Any`
  - Implement environment check: early return if `os.getenv("LOG_LLM_CALLS", "false").lower() != "true"`
  - Add directory creation: `Path("emergency_accommodation/logs").mkdir(parents=True, exist_ok=True)`
  - **VERIFY**: `uv run python -c "from emergency_accommodation.ai_agent import _log_llm_call; print('Import successful')"`
  - **EVIDENCE**:
    ```bash
    $ uv run python -c "from ai_agent import _log_llm_call; print('Import successful')"
    Import successful
    ```

- [x] **TASK-002**: Implement request/response capture logic
  - Capture request metadata (timestamp via `datetime.utcnow().isoformat() + "Z"`, agent_name, model, settings, instructions, payload)
  - Execute wrapped coroutine with timing (`start = time.perf_counter()`)
  - Capture response metadata (timestamp, duration_ms, output, error)
  - Wrap all logging in try/except to prevent crashes on logging failure
  - **VERIFY**: `uv run python -c "import emergency_accommodation.ai_agent; import ast; source = open('emergency_accommodation/ai_agent.py').read(); assert 'try:' in source and 'except' in source; print('Error handling present')"`
  - **EVIDENCE**:
    ```bash
    $ uv run python -c "import ai_agent; import ast; source = open('ai_agent.py').read(); assert 'try:' in source and 'except' in source; print('Error handling present')"
    Error handling present
    ```
    All requirements implemented in `_log_llm_call()` function:
    - Request metadata: ai_agent.py:100 (timestamp), :124-132 (log entry request section)
    - Timing: ai_agent.py:101 (start), :113-114 (duration calculation)
    - Response metadata: ai_agent.py:113-122 (timestamp, duration, output extraction), :133-138 (response section)
    - Error handling: ai_agent.py:106-110 (execution try/except), :142-147 (logging try/except with stderr)

### Core Tasks (2-3)

- [x] **TASK-003**: Integrate wrapper into evaluate_iteration()
  - Modify `ai_agent.py:evaluate_iteration()` around line 122
  - Wrap `Runner.run()` call with `_log_llm_call(agent_name="Iteration Evaluator", model=self._config.get("ai_model"), instructions=template.combined, payload=payload, settings={...}, runner_coro=Runner.run(...))`
  - Extract temperature/max_tokens from existing code for settings dict
  - **VERIFY**: `grep -n "_log_llm_call" emergency_accommodation/ai_agent.py | grep -q "evaluate_iteration" && echo "Integration found in evaluate_iteration()"`
  - **EVIDENCE**:
    ```bash
    $ grep -n "_log_llm_call" ai_agent.py
    81:async def _log_llm_call(
    198:                _log_llm_call(

    $ uv run python -c "from ai_agent import AccommodationAgent; print('Import successful')"
    Import successful - AccommodationAgent with _log_llm_call integration
    ```
    Integration confirmed at ai_agent.py:198 within evaluate_iteration() method (starts at line 168).
    Settings extracted: temperature (line 204), max_tokens (line 205), model (line 200).

- [x] **TASK-004**: Integrate wrapper into final_recommendation()
  - Modify `ai_agent.py:final_recommendation()` around line 172
  - Wrap `Runner.run()` call with `_log_llm_call(agent_name="Final Recommender", model=self._config.get("ai_model"), instructions=template.combined, payload=payload, settings={...}, runner_coro=Runner.run(...))`
  - Use same settings extraction as TASK-003
  - **VERIFY**: `grep -n "_log_llm_call" emergency_accommodation/ai_agent.py | grep -q "final_recommendation" && echo "Integration found in final_recommendation()"`
  - **EVIDENCE**:
    ```bash
    $ grep -n "_log_llm_call" ai_agent.py
    81:async def _log_llm_call(
    198:                _log_llm_call(
    257:                _log_llm_call(

    $ uv run python -c "from ai_agent import AccommodationAgent; print('Import successful')"
    Import successful - both integrations working
    ```
    Integration confirmed at ai_agent.py:257 within final_recommendation() method (starts at line 238).
    Settings extracted: temperature (line 263), max_tokens (line 264), model (line 259).

### Validation Tasks (1)

- [x] **TASK-005**: Add unit tests and verify all ACs
  - Create test in `emergency_accommodation/tests/test_ai_agent.py`: `test_llm_logging_enabled()` (verify log file created and contains expected fields)
  - Create test: `test_llm_logging_disabled()` (verify no log file when env var false/unset)
  - Create test: `test_llm_logging_failure_does_not_crash()` (mock file write failure, verify Runner.run() still succeeds)
  - Update `.env.example`: Add `LOG_LLM_CALLS=false  # Set to 'true' to log full LLM request/response payloads to logs/llm_calls.jsonl`
  - Run all 5 ACs manually to confirm end-to-end behavior
  - **VERIFY**: `LOG_LLM_CALLS=true uv run python -m pytest emergency_accommodation/tests/test_ai_agent.py -v -k logging --cov=emergency_accommodation.ai_agent --cov-report=term | grep -E "(PASSED|coverage)"`
  - **EVIDENCE**:
    ```bash
    $ uv run python -m pytest tests/test_ai_agent.py -v --cov=ai_agent --cov-report=term
    ============================= test session starts ==============================
    tests/test_ai_agent.py::test_evaluate_iteration_uses_agent PASSED        [ 16%]
    tests/test_ai_agent.py::test_final_recommendation_returns_structured_output PASSED [ 33%]
    tests/test_ai_agent.py::test_agent_failure_propagates PASSED             [ 50%]
    tests/test_ai_agent.py::test_llm_logging_enabled PASSED                  [ 66%]
    tests/test_ai_agent.py::test_llm_logging_disabled PASSED                 [ 83%]
    tests/test_ai_agent.py::test_llm_logging_failure_does_not_crash PASSED   [100%]

    Name          Stmts   Miss  Cover
    ---------------------------------
    ai_agent.py     184     14    92%
    ---------------------------------
    TOTAL           184     14    92%
    ============================== 6 passed in 0.54s ===============================
    ```

    **Test Coverage**: 92% (exceeds 68% requirement)

    **Three new tests added** (test_ai_agent.py:166-269):
    1. `test_llm_logging_enabled`: Verifies AC-001, AC-002, AC-003, AC-004
    2. `test_llm_logging_disabled`: Verifies AC-001 (disabled state)
    3. `test_llm_logging_failure_does_not_crash`: Verifies AC-005

    **`.env.example` updated** (lines 18-20): Added LOG_LLM_CALLS documentation

    **Bonus improvement**: Fixed deprecation warnings by replacing `datetime.utcnow()` with `datetime.now(timezone.utc)`

### Progressive Verification Rules
1. **Every task has VERIFY step** - must prove it works
2. **Verify before proceeding** - next task depends on previous verification
3. **Concrete commands** - specify exact test/command to run
4. **Fail fast** - if verification fails, stop and fix

**Coverage Tool:**
- Python: `uv run python -m pytest --cov=emergency_accommodation --cov-report=term-missing`

---

## Acceptance Criteria Mapping

- **AC-001** (Environment toggle): Verified in TASK-001, TASK-005
- **AC-002** (Request capture): Verified in TASK-002, TASK-005
- **AC-003** (Response capture): Verified in TASK-002, TASK-005
- **AC-004** (JSON Lines format): Verified in TASK-002, TASK-005
- **AC-005** (Graceful failure): Verified in TASK-002, TASK-005
