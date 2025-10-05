# FEAT-009 Design: LangChain Multi-Provider Migration

## Architecture

### Current Architecture (OpenAI Agents SDK)
```
main.py
  ├─> validate_environment() → requires OPENAI_API_KEY
  ├─> create_openai_client() → AsyncOpenAI client
  └─> AccommodationAgent(config, client, templates)
        ├─> evaluate_iteration()
        │     ├─> _create_agent(output_type=Pydantic)
        │     ├─> Runner.run(agent, payload)
        │     └─> result.final_output → Pydantic object
        └─> final_recommendation()
              ├─> _create_agent(output_type=Pydantic)
              └─> Runner.run(agent, payload)
```

### Target Architecture (LangChain)
```
main.py
  ├─> validate_environment(provider) → checks provider-specific API key
  └─> AccommodationAgent(config, templates)  [no client param]
        ├─> __init__()
        │     └─> _create_llm_client(config) → BaseChatModel
        ├─> evaluate_iteration()
        │     ├─> llm.with_structured_output(Pydantic)
        │     ├─> structured_llm.ainvoke(messages)
        │     └─> result → Pydantic object (direct)
        └─> final_recommendation()
              ├─> llm.with_structured_output(Pydantic)
              └─> structured_llm.ainvoke(messages)

_create_llm_client(config) → BaseChatModel
  ├─> if provider == "openai" → ChatOpenAI(model, temp, max_tokens)
  ├─> if provider == "anthropic" → ChatAnthropic(model, temp, max_tokens)
  └─> if provider == "google" → ChatGoogleGenerativeAI(model, temp, max_output_tokens)
```

### Key Architectural Changes

1. **Provider Abstraction Layer**
   - New function: `_create_llm_client(config)` returns LangChain `BaseChatModel`
   - Factory pattern based on `config["ai_provider"]`
   - Each provider reads API key from environment (no explicit passing)

2. **Simplified Client Management**
   - Remove `create_openai_client()` context manager
   - Remove `_openai_shared` global state management
   - LangChain handles client lifecycle internally

3. **Structured Output Pattern**
   - Replace `Agent(output_type=Pydantic)` with `llm.with_structured_output(schema=Pydantic)`
   - Replace `Runner.run()` with `structured_llm.ainvoke(messages)`
   - Remove `.final_output` extraction (returns Pydantic directly)

4. **Unchanged Components** (Backward Compatibility)
   - Payload building: `_build_iteration_payload()`, `_build_final_payload()` return JSON strings
   - Model conversion: `_convert_iteration()`, `_convert_final()` receive same Pydantic objects
   - Prompt templates: All `.txt` files in `config/prompts/` unchanged
   - Domain models: `FailedItem`, `InventoryOption`, etc. unchanged

---

## Dependencies

### Removed Dependencies
```toml
# DELETE from pyproject.toml
"openai-agents>=0.3.2"
```

### Added Dependencies
```toml
# ADD to pyproject.toml
"langchain-core>=0.3.29"           # Core abstractions
"langchain-openai>=0.2.14"         # OpenAI integration
"langchain-anthropic>=0.3.7"       # Anthropic integration
"langchain-google-genai>=2.0.8"    # Google integration
"anthropic>=0.39.0"                # Anthropic SDK (required by langchain-anthropic)
"google-generativeai>=0.8.3"       # Google SDK (required by langchain-google-genai)
```

### Kept Dependencies (Unchanged)
```toml
"asyncpg>=0.30.0"
"openai>=1.109.1"       # Used by langchain-openai
"pydantic>=2.11.9"
"python-dotenv>=1.1.1"
"pyyaml>=6.0.2"
"rich>=14.1.0"
```

---

## Constraints

### Technical Constraints

1. **Provider Selection Mechanism**
   - System-wide only (no per-scenario override)
   - Read from `search_parameters.yaml` → `default.ai_provider`
   - Default to `"openai"` if field missing (backward compatibility)

2. **API Key Management**
   - All providers read from environment variables
   - Mapping: `{"openai": "OPENAI_API_KEY", "anthropic": "ANTHROPIC_API_KEY", "google": "GOOGLE_API_KEY"}`
   - Validation on startup (fail fast if missing)

3. **Structured Output Compatibility**
   - Use `method="function_calling"` for consistency
   - All providers must return validated Pydantic objects
   - Error handling: `OutputParserException` → `AIIntegrationError(code="I302")`

4. **Timeout Handling**
   - Continue using `asyncio.wait_for()` wrapper
   - Timeout from `config["ai_timeout_seconds"]` (default: 30s)
   - New error code: `I309` for timeout errors

5. **Logging Preservation**
   - Existing `_log_llm_call()` function unchanged in interface
   - Wraps new `structured_llm.ainvoke()` instead of `Runner.run()`
   - Logs include provider name from `config["ai_provider"]`

### Backward Compatibility Constraints

1. **Configuration File**
   - Existing `search_parameters.yaml` works without `ai_provider` field
   - New fields optional: `ai_provider`, `ai_model` (already present in some scenarios)
   - No breaking changes to scenario overrides

2. **Environment Variables**
   - `OPENAI_API_KEY` still recognized as default
   - New keys (`ANTHROPIC_API_KEY`, `GOOGLE_API_KEY`) optional unless provider configured

3. **Prompt Templates**
   - All files in `config/prompts/*.txt` unchanged
   - Same base + scenario concatenation logic
   - No provider-specific prompt adjustments

4. **Data Models**
   - Pydantic schemas in `ai_agent.py` unchanged:
     - `_OptionAssessmentPayload`
     - `_IterationDecisionPayload`
     - `_FinalRecommendationPayload`
   - Domain models in `models.py` unchanged

---

## File Change Mapping

### Modified Files (Core Changes)

#### 1. `pyproject.toml`
**Changes:**
- Remove `openai-agents` dependency
- Add 6 LangChain dependencies

**Impact:** Dependency installation only

---

#### 2. `config/search_parameters.yaml`
**Changes:**
- Add `ai_provider: "openai"` to `default` section
- Optional: Add `ai_model: "gpt-4o-mini"` (may already exist)

**Example:**
```yaml
default:
  max_iterations: 3
  ai_provider: "openai"              # NEW
  ai_model: "gpt-4o-mini"            # NEW (or updated)
  ai_temperature: 0.2
  ai_max_output_tokens: 900
  ai_timeout_seconds: 30
```

**Impact:** Configuration schema extension

---

#### 3. `config/loader.py` (~10 lines added)
**Changes:**
- Add validation in `load_search_parameters()` to prevent scenario-level `ai_provider` overrides
- Raise `ConfigurationError` code C115 if `ai_provider` found in scenario config

**Implementation:**
```python
# In load_search_parameters(), after line 69 (after scenario_config validation):
if "ai_provider" in scenario_config:
    raise ConfigurationError(
        "ai_provider cannot be overridden per scenario. Configure in 'default' section only.",
        code="C115",
    )

merged: dict[str, Any] = dict(defaults)
merged.update(scenario_config)
return merged
```

**Impact:** Enforces system-wide provider configuration (AC-003)

---

#### 4. `ai_agent.py` (~100 lines changed)
**Changes:**

**A. Imports**
- Remove: `from agents import Agent, Runner, model_settings`, `from openai import AsyncOpenAI`
- Add: `from langchain_core.language_models import BaseChatModel`, `from langchain_core.exceptions import OutputParserException`
- Add: `from langchain_openai import ChatOpenAI`, `from langchain_anthropic import ChatAnthropic`, `from langchain_google_genai import ChatGoogleGenerativeAI`

**B. New Function** (add before `AccommodationAgent` class)
```python
def _create_llm_client(config: Mapping[str, Any]) -> BaseChatModel:
    """Create LangChain LLM client based on provider configuration.

    Note: Google uses max_output_tokens parameter, OpenAI/Anthropic use max_tokens.
    """
    provider = config.get("ai_provider", "openai").lower()
    model = config.get("ai_model", "gpt-4o-mini")
    temperature = float(config.get("ai_temperature", 0.2))
    max_tokens = int(config.get("ai_max_output_tokens", 900))

    if provider == "openai":
        return ChatOpenAI(model=model, temperature=temperature, max_tokens=max_tokens)
    elif provider == "anthropic":
        return ChatAnthropic(model=model, temperature=temperature, max_tokens=max_tokens)
    elif provider == "google":
        # Google uses max_output_tokens instead of max_tokens
        return ChatGoogleGenerativeAI(model=model, temperature=temperature, max_output_tokens=max_tokens)
    else:
        raise AIIntegrationError(f"Unsupported provider: {provider}", code="I308")
```

**C. Update `__init__` method**
- Remove `openai_client` parameter
- Replace `self._client = openai_client` with `self._llm = _create_llm_client(config)`

**D. Update `evaluate_iteration` method**
- Remove `_create_agent()` call
- Replace `Runner.run()` with:
  ```python
  structured_llm = self._llm.with_structured_output(
      schema=_IterationDecisionPayload,
      method="function_calling",
  )
  messages = [
      {"role": "system", "content": template.combined},
      {"role": "user", "content": payload}
  ]
  result = await asyncio.wait_for(
      structured_llm.ainvoke(messages),
      timeout=timeout,
  )
  ```
- Add `OutputParserException` handling
- Add `asyncio.TimeoutError` handling (code I309)
- Remove `.final_output` extraction

**E. Update `final_recommendation` method**
- Same pattern as `evaluate_iteration`

**F. Delete Methods**
- `_create_agent()` (entire method)
- `_build_run_config()` (entire method)

**G. Improve Logging Robustness** (in `_log_llm_call()` function)
- Add error handling for log directory creation failures
- Fail gracefully if logging cannot be initialized (permissions, disk full, etc.)
- Add try/except around log directory creation:
  ```python
  try:
      log_dir = Path("logs")
      log_dir.mkdir(parents=True, exist_ok=True)
      log_file = log_dir / "llm_calls.jsonl"
  except OSError as exc:
      logger.warning(f"Cannot create logs directory: {exc}. LLM logging disabled.")
      return await runner_coro()
  ```

**Impact:** Core logic refactor + improved observability

---

#### 5. `main.py` (~25 lines removed)
**Changes:**

**A. Remove Imports**
- Delete: `from agents.models import _openai_shared`, `from openai import AsyncOpenAI`

**B. Remove Function**
- Delete: `create_openai_client()` context manager

**C. Update `validate_environment()` signature**
```python
# Before:
def validate_environment() -> tuple[str, str]:
    # Returns (database_url, api_key)

# After:
def validate_environment(provider: str = "openai") -> str:
    # Returns only database_url
    # Validates provider-specific API key
```

**D. Update `validate_environment()` body**
```python
def validate_environment(provider: str = "openai") -> str:
    database_url = os.getenv("DATABASE_URL")
    if not database_url:
        raise RuntimeError("DATABASE_URL must be set")

    provider = provider.lower()
    env_keys = {
        "openai": "OPENAI_API_KEY",
        "anthropic": "ANTHROPIC_API_KEY",
        "google": "GOOGLE_API_KEY",
    }

    env_key = env_keys.get(provider)
    if not env_key:
        raise RuntimeError(f"Unsupported provider: {provider}")

    if not os.getenv(env_key):
        raise RuntimeError(f"{env_key} must be set for {provider} provider")

    return database_url
```

**E. Update `run_accommodation_analysis()` signature**
- Remove `openai_api_key: str` parameter

**F. Update `run_accommodation_analysis()` body**
```python
# Before:
async with create_openai_client(openai_api_key) as client:
    _openai_shared.set_default_openai_key(openai_api_key)
    _openai_shared.set_default_openai_client(client)
    agent = AccommodationAgent(search_config, client, prompt_templates)

# After:
agent = AccommodationAgent(search_config, prompt_templates)
```

**G. Update `main()` function**
```python
# Before:
database_url, api_key = validate_environment()
asyncio.run(run_accommodation_analysis(..., openai_api_key=api_key, ...))

# After:
search_config = load_search_parameters(args.scenario, config_dir)
provider = search_config.get("ai_provider", "openai")
database_url = validate_environment(provider)
asyncio.run(run_accommodation_analysis(...))  # No api_key param
```

**Impact:** Simplified entry point

---

#### 6. `tests/test_ai_agent.py` (~80 lines changed)
**Changes:**

**A. Update Fixtures**
```python
@pytest.fixture
def mock_llm(mocker):
    """Mock LangChain LLM with structured output."""
    mock_llm_client = mocker.MagicMock(spec=ChatOpenAI)
    mock_structured = mocker.AsyncMock()
    mock_llm_client.with_structured_output.return_value = mock_structured
    return mock_llm_client, mock_structured

@pytest.fixture
def sample_config():
    return {
        "ai_provider": "openai",
        "ai_model": "gpt-4o-mini",
        "ai_temperature": 0.2,
        "ai_max_output_tokens": 900,
        "ai_timeout_seconds": 30,
        "early_stopping_threshold": 5,
    }
```

**B. Update Existing Tests**
- Replace `mocker.patch("ai_agent.AsyncOpenAI")` with `mocker.patch("ai_agent._create_llm_client")`
- Update assertions to match new invocation pattern

**C. Add Multi-Provider Tests**
```python
@pytest.mark.parametrize("provider", ["openai", "anthropic", "google"])
@pytest.mark.asyncio
async def test_evaluate_iteration_all_providers(mocker, sample_config, mock_llm, provider):
    # Test all providers work with same interface
```

**D. Add Error Tests**
- `test_create_llm_client_unsupported_provider()`
- `test_evaluate_iteration_parser_error()`
- `test_evaluate_iteration_timeout()`

**Impact:** Test coverage for new behavior

---

### Modified Files (Minor Adjustments)

#### 7. `tests/integration/test_ai_agent_live.py`
**Changes:**
- Remove `openai_client` fixture
- Update `AccommodationAgent` instantiation to remove client parameter
- Ensure tests use `OPENAI_API_KEY` from environment

**Impact:** Integration test compatibility

---

#### 8. `tests/test_main.py`
**Changes:**
- Update tests for new `validate_environment(provider)` signature
- Add tests for provider-specific API key validation
- Remove tests for `create_openai_client()`

**Impact:** Entry point test coverage

---

### New Files (Documentation)

#### 9. `.env.example`
**Changes:**
- Add comments for `ANTHROPIC_API_KEY` and `GOOGLE_API_KEY`

**Example:**
```bash
DATABASE_URL=postgresql://...
OPENAI_API_KEY=sk-...
# ANTHROPIC_API_KEY=sk-ant-...
# GOOGLE_API_KEY=...
```

**Impact:** User guidance

---

#### 10. `README.md`
**Changes:**
- Add "AI Provider Configuration" section
- Document supported providers and models
- Show YAML configuration examples

**Impact:** User documentation

---

## Data Flow

### Request Flow (Iteration Evaluation)

```
1. CLI invokes agent.evaluate_iteration()
   ↓
2. Load prompt template (unchanged)
   ↓
3. Build JSON payload (unchanged: _build_iteration_payload)
   ↓
4. Create structured LLM:
   llm.with_structured_output(schema=_IterationDecisionPayload)
   ↓
5. Build messages:
   [{"role": "system", "content": instructions},
    {"role": "user", "content": json_payload}]
   ↓
6. Invoke with logging wrapper:
   _log_llm_call(..., runner_coro=lambda: structured_llm.ainvoke(messages))
   ↓
7. LangChain executes provider-specific API call
   (OpenAI function calling | Anthropic tool use | Google response_schema)
   ↓
8. LangChain validates response → Pydantic object
   ↓
9. Convert to domain model (unchanged: _convert_iteration)
   ↓
10. Apply early stopping (unchanged)
    ↓
11. Return IterationDecision
```

### Error Handling Flow

```
try:
    result = await asyncio.wait_for(
        structured_llm.ainvoke(messages),
        timeout=30.0
    )
except OutputParserException as exc:
    # Pydantic validation failed
    raise AIIntegrationError("Response validation failed", code="I302", cause=exc)
except asyncio.TimeoutError as exc:
    # Request timed out
    raise AIIntegrationError("Timed out after 30s", code="I309", cause=exc)
except Exception as exc:
    # API errors, network issues, etc.
    raise AIIntegrationError("AI request failed", code="I307", cause=exc)
```

---

## Configuration Schema

### YAML Configuration
```yaml
default:
  # Existing fields (unchanged)
  max_iterations: 3
  time_window_type: "weekly"
  batch_size_per_iteration: 10
  search_order: "urgency_first"
  early_stopping_threshold: 5
  risk_tolerance: "moderate"
  approval_preference: "minimize"

  # New/Updated fields
  ai_provider: "openai"              # openai | anthropic | google
  ai_model: "gpt-4o-mini"            # Provider-specific model name
  ai_temperature: 0.2                # Sampling temperature (0.0-1.0)
  ai_max_output_tokens: 900          # Max response tokens
  ai_timeout_seconds: 30             # Request timeout

scenarios:
  scenario1:
    # Existing overrides unchanged
    risk_tolerance: "conservative"
    max_iterations: 2

    # NOTE: ai_provider cannot be overridden per scenario (raises ConfigurationError C115)
    # Must be configured in 'default' section only for system-wide enforcement
```

### Environment Variables
```bash
# Required (system-wide)
DATABASE_URL=postgresql://emergency_user:password@localhost:5432/emergency_accommodation

# Required (provider-specific, only one needed)
OPENAI_API_KEY=sk-...                      # If ai_provider=openai
ANTHROPIC_API_KEY=sk-ant-...               # If ai_provider=anthropic
GOOGLE_API_KEY=...                         # If ai_provider=google

# Optional
LOG_LLM_CALLS=true                         # Enable request/response logging
LOG_LEVEL=INFO                             # Logging verbosity
```

---

## Testing Strategy

### Unit Tests (All Providers Mocked)
- Mock `_create_llm_client()` to return mock `BaseChatModel`
- Mock `llm.with_structured_output()` to return mock structured LLM
- Mock `structured_llm.ainvoke()` to return Pydantic objects
- Test all three providers with parameterized tests
- Test error cases: unsupported provider, parser errors, timeouts

### Integration Tests (OpenAI Only)
- Use real `OPENAI_API_KEY` from environment
- Test end-to-end scenario execution
- Verify structured outputs returned correctly
- Verify LLM logging captures full request/response

### Test Coverage Target
- Modified modules: ≥90% coverage
- `ai_agent.py`: ≥90% (critical path)
- `main.py`: ≥85% (entry point validation)
- Overall project: maintain existing ≥68% minimum

---

## Migration Risk Mitigation

### Low-Risk Changes (Preserve Logic)
- Payload building: JSON string format unchanged
- Prompt templates: No modifications
- Domain models: Pydantic schemas unchanged
- Model conversion: `_convert_iteration()`, `_convert_final()` unchanged

### Medium-Risk Changes (New Dependencies)
- LangChain libraries: Well-established, stable APIs
- Provider SDKs: Official libraries from providers
- Structured output: Tested feature in LangChain

### High-Risk Changes (Architectural)
- Client management: Removed OpenAI-specific context manager
- Invocation pattern: `Runner.run()` → `structured_llm.ainvoke()`
- Error handling: New exception types (`OutputParserException`)

**Mitigation:**
- Comprehensive unit tests with mocks
- Integration tests validate real API behavior
- Existing test suite adjusted to match new patterns
- Progressive verification at each implementation step

---

## Provider-Specific Notes

### OpenAI
- Uses function calling for structured outputs
- Most reliable structured output mechanism
- Existing behavior preserved (default provider)
- Supports `{"role": "system"}` messages natively

### Anthropic
- Uses tool use for structured outputs
- Comparable reliability to OpenAI
- May have slightly different error messages
- Recent models support system messages (LangChain handles conversion)

### Google
- Uses `response_schema` parameter
- Newer feature, slightly lower reliability
- May require additional validation in edge cases
- No native system role (LangChain converts to user message prefix)

### Message Format Compatibility
**LangChain Abstraction:** The message format `[{"role": "system", "content": "..."}, {"role": "user", "content": "..."}]` is handled by LangChain's provider integrations. LangChain automatically converts:
- OpenAI: Passes system messages directly
- Anthropic: Converts system message to `system` parameter in API call
- Google: Prepends system content to first user message

**Design Decision:** Use LangChain's abstraction to normalize differences. If provider-specific issues arise, handle in `_create_llm_client()` factory function or message construction logic.
