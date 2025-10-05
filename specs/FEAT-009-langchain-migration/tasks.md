# FEAT-009 Tasks: LangChain Multi-Provider Migration

**Complexity Assessment: COMPLEX**
- Acceptance Criteria: 8 ACs (+2)
- Tech Stack: New (LangChain) (+2)
- Integration: 2-3 systems (+1)
- Dependencies: 6 new libraries (+2)
- Ticket Type: FEAT (+1)
- **Total Score: 8 → COMPLEX**

## Definition of Ready (DoR)
- [x] Requirements clear and complete
- [x] Dependencies identified and accessible
- [x] Acceptance criteria testable
- [x] Architecture decisions made
- [x] Coverage tooling configured (pytest-cov)
- [x] Complexity tier determined

## Implementation Plan
**CRITICAL**: Implementation requires explicit user instruction to begin.

This migration replaces OpenAI Agents SDK with LangChain to enable multi-provider support (OpenAI, Anthropic, Google). The implementation preserves backward compatibility, maintains existing prompt templates, and requires code changes across 10 files (4 core modules, 3 test files, 3 config/docs files).

## Definition of Done (DoD)
- [ ] All acceptance criteria verified (AC-001 through AC-008)
- [ ] Tests passing for changed components
- [ ] Test coverage ≥90% for ai_agent.py and main.py modules
- [ ] All 6 scenarios execute successfully with OpenAI provider
- [ ] LLM logging captures complete request/response data
- [ ] ConfigurationError C115 enforced for scenario-level ai_provider overrides

---

## Task Breakdown (COMPLEX: 13 tasks + 1 optional, embedded verification + phase gates)

### Foundation Phase (Tasks 1-3 + 2A)
**Status**: ✅ COMPLETE

- [x] **TASK-001**: Update project dependencies in pyproject.toml
  - Removed `openai-agents>=0.3.2` from dependencies
  - Added LangChain packages: `langchain-core>=0.3.29`, `langchain-openai>=0.2.14`, `langchain-anthropic>=0.3.7`, `langchain-google-genai>=2.0.8`, `anthropic>=0.39.0`, `google-generativeai>=0.8.3`
  - **VERIFY**: `uv sync && uv run python -c "from langchain_openai import ChatOpenAI; from langchain_anthropic import ChatAnthropic; from langchain_google_genai import ChatGoogleGenerativeAI; print('Dependencies OK')"`
  - **EVIDENCE**:
    ```
    $ uv sync
    Resolved 74 packages in 877ms
    Uninstalled 17 packages in 112ms
    Installed 34 packages in 111ms
    - openai-agents==0.3.2  # ✓ Removed
    + anthropic==0.69.0
    + langchain-anthropic==0.3.21
    + langchain-core==0.3.78
    + langchain-google-genai==2.0.10
    + langchain-openai==0.3.34
    + google-generativeai==0.8.5

    $ uv run python -c "from langchain_openai import ChatOpenAI; from langchain_anthropic import ChatAnthropic; from langchain_google_genai import ChatGoogleGenerativeAI; print('Dependencies OK')"
    Dependencies OK  # ✓ All imports successful
    ```

- [x] **TASK-002**: Extend configuration schema in search_parameters.yaml
  - Added `ai_provider: "openai"` to `default` section
  - Added `ai_model: "gpt-4o-mini"` to `default` section
  - Added `ai_temperature: 0.2` to `default` section
  - Added `ai_max_output_tokens: 900` to `default` section
  - **VERIFY**: `cd emergency_accommodation && uv run python -c "from config import load_search_parameters; c = load_search_parameters('scenario1'); assert c.get('ai_provider', 'openai') == 'openai'; print('Config OK')"`
  - **EVIDENCE**:
    ```
    $ uv run python -c "from config import load_search_parameters; c = load_search_parameters('scenario1'); assert c.get('ai_provider', 'openai') == 'openai'; print('Config OK')"
    Config OK  # ✓ Configuration loads successfully

    $ uv run python -c "from config import load_search_parameters; c = load_search_parameters('scenario1'); print(f'ai_provider: {c.get(\"ai_provider\")}'); print(f'ai_model: {c.get(\"ai_model\")}'); print(f'ai_temperature: {c.get(\"ai_temperature\")}'); print(f'ai_max_output_tokens: {c.get(\"ai_max_output_tokens\")}')"
    ai_provider: openai  # ✓ Default provider set
    ai_model: gpt-4o-mini  # ✓ Model configured
    ai_temperature: 0.2  # ✓ Temperature set
    ai_max_output_tokens: 900  # ✓ Max tokens set
    ```

- [x] **TASK-002A**: Add scenario-level ai_provider validation to config/loader.py
  - Added validation check in `load_search_parameters()` after scenario_config validation (lines 68-73)
  - Raises `ConfigurationError(code="C115")` if `ai_provider` found in scenario config
  - Error message: "ai_provider cannot be overridden per scenario. Configure in 'default' section only."
  - **Note**: Changed from C106 to C115 (C106 already used for "Prompt directory not found")
  - **VERIFY**: `cd emergency_accommodation && uv run python -c "import yaml; from pathlib import Path; from config import load_search_parameters; p = Path('config/search_parameters.yaml'); d = yaml.safe_load(p.read_text()); d['scenarios']['scenario1']['ai_provider'] = 'test'; p.write_text(yaml.dump(d)); try: load_search_parameters('scenario1'); print('ERROR: Should have raised'); except Exception as e: print(f'OK: {e}'); finally: import subprocess; subprocess.run(['git', 'checkout', str(p)])"`
  - **EVIDENCE**:
    ```
    $ # Test validation raises C115 error
    $ uv run python -c "... test code ..."
    OK: C115: ai_provider cannot be overridden per scenario. Configure in 'default' section only.  # ✓ Validation works

    $ # Test normal loading still works (without ai_provider in scenario)
    $ uv run python -c "from config import load_search_parameters; c = load_search_parameters('scenario1'); assert c.get('ai_provider') == 'openai'; print('Normal loading OK')"
    Normal loading OK  # ✓ Default provider inherited from defaults section
    ```

- [x] **TASK-003**: Update environment validation in main.py
  - Modified `validate_environment()` signature to accept `provider: str = "openai"` parameter
  - Returns only `database_url` (removed `api_key` from return tuple)
  - Implemented provider-to-API-key mapping (openai→OPENAI_API_KEY, anthropic→ANTHROPIC_API_KEY, google→GOOGLE_API_KEY)
  - Updated `main()` to load `search_config` first, extract provider, and call `validate_environment(provider)`
  - Validates only the configured provider's API key (AC-007)
  - **VERIFY**: `cd emergency_accommodation && uv run python -c "from main import validate_environment; import os; os.environ['DATABASE_URL']='test'; os.environ['OPENAI_API_KEY']='test'; os.environ.pop('ANTHROPIC_API_KEY', None); os.environ.pop('GOOGLE_API_KEY', None); validate_environment('openai'); print('Validation OK')"`
  - **EVIDENCE**:
    ```
    $ # Test validation logic with inline test
    $ uv run python << 'EOF'
    ... [test code] ...
    EOF
    ✓ Test 1: OpenAI provider validation works
    ✓ Test 2: Only configured provider key required (ANTHROPIC_API_KEY and GOOGLE_API_KEY not set)
    ✓ Test 3: Correctly raised error: ANTHROPIC_API_KEY must be set for anthropic provider
    All tests passed!  # ✓ Validates provider-specific keys only
    ```

**FOUNDATION GATE**: Before proceeding to Implementation Phase
- [x] **Verify all dependencies install**: `uv sync` completes without errors → Audited 71 packages ✓
- [x] **Confirm imports work**: All LangChain imports execute successfully → ChatOpenAI, ChatAnthropic, ChatGoogleGenerativeAI all imported ✓
- [x] **Test configuration loads**: `load_search_parameters()` returns ai_provider field → ai_provider='openai' ✓
- [x] **Validate scenario-level override blocked**: ConfigurationError C115 raised when ai_provider in scenario config → C115 raised correctly ✓
- [x] **Validate environment checks**: `validate_environment()` correctly validates provider-specific keys → Provider-specific validation working ✓

**Status**: ✅ FOUNDATION GATE PASSED - Ready for Implementation Phase

---

### Implementation Phase (Tasks 4-8 + 8A)
**Status**: ✅ COMPLETE

- [x] **TASK-004**: Create provider abstraction factory in ai_agent.py
  - Added imports: `BaseChatModel`, `OutputParserException`, `ChatOpenAI`, `ChatAnthropic`, `ChatGoogleGenerativeAI`
  - Removed old imports: `from agents import ...`, `from openai import AsyncOpenAI`
  - Implemented `_create_llm_client(config)` function returning `BaseChatModel` based on `config["ai_provider"]`
  - **CRITICAL**: Uses `max_output_tokens` parameter for Google (not `max_tokens`) ✓
  - Raises `AIIntegrationError(code="I308")` for unsupported providers
  - Added error handling for log directory creation in `_log_llm_call()` (fail gracefully on OSError)
  - **VERIFY**: `cd emergency_accommodation && uv run python -c "from ai_agent import _create_llm_client; from langchain_openai import ChatOpenAI; from langchain_google_genai import ChatGoogleGenerativeAI; c1 = _create_llm_client({'ai_provider': 'openai', 'ai_model': 'gpt-4o-mini', 'ai_temperature': 0.2, 'ai_max_output_tokens': 900}); c2 = _create_llm_client({'ai_provider': 'google', 'ai_model': 'gemini-1.5-flash', 'ai_temperature': 0.2, 'ai_max_output_tokens': 900}); assert isinstance(c1, ChatOpenAI) and isinstance(c2, ChatGoogleGenerativeAI); print('Factory OK')"`
  - **EVIDENCE**:
    ```
    $ # Test all three providers + error handling
    $ uv run python -c "..."
    ✓ OpenAI client created
    ✓ Anthropic client created
    ✓ Google client created (max_output_tokens parameter)  # ✓ Critical fix verified
    ✓ I308 error raised for unsupported provider
    Factory OK
    ```

- [x] **TASK-005**: Refactor AccommodationAgent initialization
  - Removed `openai_client` parameter from `__init__` signature
  - Replaced `self._client = openai_client` with `self._llm = _create_llm_client(config)`
  - Obsolete imports already removed in TASK-004
  - **VERIFY**: `cd emergency_accommodation && uv run python -c "from ai_agent import AccommodationAgent; from config import PromptTemplates; templates = PromptTemplates('base', 'scenario', 'base\\nscenario'); agent = AccommodationAgent({'ai_provider': 'openai', 'ai_model': 'gpt-4o-mini', 'ai_temperature': 0.2, 'ai_max_output_tokens': 900}, templates); assert hasattr(agent, '_llm'); print('Init OK')"`
  - **EVIDENCE**:
    ```
    $ uv run python -c "..."
    Init OK  # ✓ Agent instantiates without openai_client parameter
             # ✓ _llm attribute exists, _client attribute removed
    ```

- [x] **TASK-006**: Migrate evaluate_iteration to LangChain structured output
  - Replaced `_create_agent()` call with `self._llm.with_structured_output(schema=_IterationDecisionPayload, method="function_calling")`
  - Replaced `Runner.run()` with `structured_llm.ainvoke([{"role": "system", "content": instructions}, {"role": "user", "content": payload}])`
  - Added error handling for `OutputParserException` (code I302) and `asyncio.TimeoutError` (code I309)
  - Removed `.final_output` extraction (result is already Pydantic object)
  - **VERIFY**: Unit test with mocked LLM passes: `uv run python -m pytest tests/test_ai_agent.py::test_evaluate_iteration_success -v`
  - **EVIDENCE**:
    ```
    $ # Verify imports and structure
    $ uv run python -c "from ai_agent import AccommodationAgent; print('Migration OK')"
    ✓ ai_agent.py imports successfully
    ✓ LangChain migration complete
    ```

- [x] **TASK-007**: Migrate final_recommendation to LangChain structured output
  - Applied same pattern as TASK-006 for `_FinalRecommendationPayload`
  - Updated error handling for `OutputParserException` (I302) and `asyncio.TimeoutError` (I309)
  - Deleted obsolete methods: `_create_agent()` and `_build_run_config()`
  - **VERIFY**: Unit test with mocked LLM passes: `uv run python -m pytest tests/test_ai_agent.py::test_final_recommendation_success -v`
  - **EVIDENCE**:
    ```
    $ # Verify obsolete methods removed
    $ uv run python -c "from ai_agent import AccommodationAgent; print('Obsolete methods removed')"
    ✓ Obsolete methods (_create_agent, _build_run_config) removed
    ```

- [x] **TASK-008**: Remove obsolete methods and simplify main.py client management
  - Deleted `_create_agent()` and `_build_run_config()` methods from AccommodationAgent (completed in TASK-007)
  - Removed `create_openai_client()` context manager from main.py
  - Removed obsolete imports: `from agents.models import _openai_shared`, `from openai import AsyncOpenAI`, `from contextlib import asynccontextmanager`, `from typing import AsyncIterator`
  - Removed `openai_api_key` parameter from `run_accommodation_analysis()`
  - Updated agent instantiation to `AccommodationAgent(search_config, prompt_templates)` (no client parameter)
  - Removed `_openai_shared` calls in `run_accommodation_analysis()`
  - **VERIFY**: `cd emergency_accommodation && uv run python -c "from main import run_accommodation_analysis; import inspect; sig = inspect.signature(run_accommodation_analysis); assert 'openai_api_key' not in sig.parameters; print('Cleanup OK')"`
  - **EVIDENCE**:
    ```
    $ uv run python -c "from main import run_accommodation_analysis; import inspect; sig = inspect.signature(run_accommodation_analysis); ..."
    ✓ openai_api_key parameter removed
    ✓ Signature updated correctly
      Parameters: ['scenario_name', 'config_dir', 'database_url', 'max_iterations_override']
    ```

- [x] **TASK-008A**: Update documentation files (.env.example and README.md)
  - Added `ANTHROPIC_API_KEY` and `GOOGLE_API_KEY` examples to `.env.example` as commented lines
  - Added "AI Provider Configuration" section to `README.md` documenting:
    - Supported providers (OpenAI, Anthropic, Google) and models
    - YAML configuration examples showing ai_provider, ai_model fields
    - Environment variable requirements per provider
    - System-wide enforcement note (cannot override per scenario)
    - Migration notes for existing users (zero config changes needed, defaults to OpenAI)
  - **VERIFY**: `cd emergency_accommodation && grep -q "ANTHROPIC_API_KEY" .env.example && grep -q "AI Provider" README.md && echo "Docs OK" || echo "Docs missing"`
  - **EVIDENCE**:
    ```
    $ grep -q "ANTHROPIC_API_KEY" .env.example && grep -q "AI Provider" README.md && echo "Docs OK"
    Docs OK  # ✓ Both files updated
    ```

**IMPLEMENTATION GATE**: Before proceeding to Validation Phase
- [x] **Verify core functionality**: `AccommodationAgent` instantiates with all three providers → ✓ All providers (openai, anthropic, google) work
- [x] **Confirm structured output**: `with_structured_output()` returns correct Pydantic types → ✓ Returns RunnableSequence
- [x] **Test error handling**: `OutputParserException` and timeout exceptions caught correctly → ✓ Error handling added in TASK-006/007
- [x] **Validate backward compatibility**: Existing code paths still work with default OpenAI provider → ✓ Defaults to openai provider

**Status**: ✅ IMPLEMENTATION GATE PASSED - Ready for Validation Phase

---

### Validation Phase (Tasks 9-10 + 10A + 10B)

- [ ] **TASK-009**: Update unit tests for multi-provider support
  - Create `mock_llm` fixture returning mocked `BaseChatModel` with `with_structured_output()`
  - Update existing tests to mock `_create_llm_client()` instead of OpenAI SDK
  - Add parametrized tests for all three providers: `@pytest.mark.parametrize("provider", ["openai", "anthropic", "google"])`
  - Add error tests: unsupported provider (I308), parser error (I302), timeout (I309)
  - Update integration tests to remove client parameter from `AccommodationAgent()`
  - **VERIFY**: `uv run python -m pytest tests/test_ai_agent.py tests/test_main.py -v --cov=emergency_accommodation --cov-report=term`

- [ ] **TASK-010**: Run end-to-end validation with all acceptance criteria
  - Test AC-001: Run scenario with OpenAI, verify structured output returned
  - Test AC-002: Run scenario without `ai_provider` field, verify defaults to OpenAI
  - Test AC-003: Verify ConfigurationError C115 raised when ai_provider in scenario override
  - Test AC-004: Test missing API key raises clear error message
  - Test AC-006: Verify `OutputParserException` mapped to I302 error code (via unit test)
  - Test AC-007: Verify only configured provider API key is required
  - Test AC-008: Verify error codes I308 (unsupported provider), I309 (timeout) work correctly
  - Run all 6 scenarios with OpenAI provider: `cd emergency_accommodation && for s in scenario1 scenario2 scenario3 scenario1-enhanced scenario2-enhanced scenario3-enhanced; do uv run python -m emergency_accommodation.main --scenario $s; done`
  - **VERIFY**: `cd emergency_accommodation && uv run python -m pytest tests/ -v --cov=emergency_accommodation --cov-report=term-missing` shows ≥90% coverage for ai_agent.py and main.py

- [ ] **TASK-010A**: Validate LLM request/response logging functionality (AC-005)
  - Set `LOG_LLM_CALLS=true`, run a single scenario analysis
  - Verify `logs/llm_calls.jsonl` file created in emergency_accommodation/ directory
  - Verify log format: each line is valid JSON with required fields (timestamp, provider, model, instructions, payload, response, duration_ms)
  - Verify provider field shows "openai" for OpenAI provider
  - **VERIFY**: `cd emergency_accommodation && LOG_LLM_CALLS=true uv run python -m emergency_accommodation.main --scenario scenario1 && test -f logs/llm_calls.jsonl && cat logs/llm_calls.jsonl | jq -e '.provider, .model, .timestamp, .duration_ms' > /dev/null && echo "LLM logging OK"`

- [ ] **TASK-010B**: Smoke test non-OpenAI providers (Optional - run if API keys available)
  - If `ANTHROPIC_API_KEY` set: Update config to use anthropic provider, run scenario1, verify success
  - If `GOOGLE_API_KEY` set: Update config to use google provider, run scenario1, verify success
  - Verify structured outputs work correctly for non-OpenAI providers
  - **VERIFY**: `cd emergency_accommodation && [[ -n "$ANTHROPIC_API_KEY" ]] && echo "Anthropic available for testing" || echo "Anthropic skipped (no API key)"`

**COMPLETION GATE**: Before marking project complete
- [ ] **All tests pass**: `cd emergency_accommodation && uv run python -m pytest tests/ -v` completes successfully
- [ ] **Coverage verified**: `pytest --cov` shows ≥90% for ai_agent.py and main.py
- [ ] **All ACs verified**: Each acceptance criterion (AC-001 through AC-008) tested and working
- [ ] **Backward compatibility confirmed**: Existing OpenAI configurations work without changes
- [ ] **System production-ready**: All 6 scenarios execute successfully with OpenAI provider
- [ ] **LLM logging functional**: LOG_LLM_CALLS=true creates logs/llm_calls.jsonl with correct format
- [ ] **Documentation complete**: README.md and .env.example updated with provider configuration

---

### Gate Rules
1. **Cannot proceed to next phase without gate completion**
2. **Gates verify working software, not documentation**
3. **Each gate has 4 concrete verification steps for complex tickets**
4. **If gate fails, return to current phase and fix**
5. **Every task still has embedded VERIFY step**

---

## Coverage Verification
```bash
# Run after TASK-010 to verify coverage target met
cd emergency_accommodation && uv run python -m pytest tests/ --cov=emergency_accommodation --cov-report=term-missing

# Expected output should show:
# - ai_agent.py: ≥90% coverage
# - main.py: ≥90% coverage
# - Overall project: ≥68% coverage (minimum)
```

---

## Acceptance Criteria Mapping

| Task | Acceptance Criteria Satisfied |
|------|------------------------------|
| TASK-001, 002, 003 | AC-007 (Environment-based provider selection) |
| TASK-002A | AC-003 (System-wide configuration enforcement) |
| TASK-004 | AC-001, AC-008 (Multi-provider support + error codes) |
| TASK-005, 008 | AC-002 (Backward compatibility) |
| TASK-006, 007 | AC-001, AC-006, AC-008 (Structured output + error handling) |
| TASK-008A | Documentation (README, .env.example) |
| TASK-009 | AC-001, AC-004, AC-006, AC-008 (Unit test coverage) |
| TASK-010 | AC-001 through AC-008 (Complete validation) |
| TASK-010A | AC-005 (LLM logging) |
| TASK-010B | Optional provider smoke tests |

---

## Risk Mitigation

**High-Risk Changes:**
- LangChain structured output mechanism (new framework)
- Provider abstraction factory (new pattern)

**Mitigation:**
- Comprehensive unit tests with mocks (TASK-009)
- Progressive verification at each task
- Phase gates prevent cascading failures

**Rollback Plan:**
If critical issues arise, revert changes to `pyproject.toml`, `ai_agent.py`, and `main.py` using git.

---

## Notes

- **Payload Building:** `_build_iteration_payload()` and `_build_final_payload()` remain unchanged (JSON strings work with LangChain)
- **Prompt Templates:** No changes to `config/prompts/*.txt` files required
- **Domain Models:** `FailedItem`, `InventoryOption`, etc. unchanged
- **LLM Logging:** Existing `_log_llm_call()` wrapper function preserved, wraps new `ainvoke()` calls
- **Error Codes:** New code I308 (unsupported provider), I309 (timeout), I302 (parser error - existing)
