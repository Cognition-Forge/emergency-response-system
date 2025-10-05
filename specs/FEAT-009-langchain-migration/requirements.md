# FEAT-009 Requirements: LangChain Multi-Provider Migration

## Business Context

The current implementation uses OpenAI Agents SDK, which locks the system to OpenAI as the sole AI provider. This creates cost optimization challenges and limits flexibility to leverage pricing/performance characteristics of alternative providers.

**Goal:** Migrate to LangChain to enable multi-provider support (OpenAI, Anthropic, Google) while maintaining backward compatibility with existing configurations and workflows.

**Business Value:**
- **Cost Optimization:** Ability to select cost-effective providers based on scenario requirements
- **Provider Flexibility:** Switch between providers without code changes
- **Future-Proof:** Foundation for adding additional providers as needed

## User Stories

### US-001: As a system administrator, I want to configure the AI provider system-wide so that I can optimize costs across all scenarios
**Value:** Centralized provider configuration reduces operational complexity

### US-002: As an existing user, I want my current OpenAI configuration to work without changes so that the migration is seamless
**Value:** Zero downtime and zero manual reconfiguration effort

### US-003: As a developer, I want full request/response logging in JSON Lines format so that I can debug provider-specific issues
**Value:** Consistent observability regardless of provider

### US-004: As a cost-conscious user, I want to select between OpenAI, Anthropic, and Google providers so that I can choose the most cost-effective option
**Value:** Direct cost savings through provider selection

## Acceptance Criteria

### AC-001: Multi-Provider Support
- **GIVEN** the system is configured with a valid provider (openai, anthropic, or google)
- **WHEN** the CLI executes a scenario analysis
- **THEN** the system uses the configured provider for all AI requests
- **AND** structured outputs (Pydantic models) are returned consistently across providers

### AC-002: Backward Compatibility
- **GIVEN** an existing configuration using OpenAI (no `ai_provider` field in YAML)
- **WHEN** the system starts
- **THEN** it defaults to OpenAI provider
- **AND** all existing scenarios execute successfully without configuration changes
- **AND** the `OPENAI_API_KEY` environment variable is recognized

### AC-003: System-Wide Configuration
- **GIVEN** a provider is configured in `search_parameters.yaml` default section
- **WHEN** any scenario is executed
- **THEN** the system uses the configured provider from the default section
- **AND** if a scenario override includes `ai_provider`, the system raises `ConfigurationError` code C115
- **AND** the error message states: "ai_provider cannot be overridden per scenario. Configure in 'default' section only."

### AC-004: API Key Validation
- **GIVEN** a provider is configured in YAML
- **WHEN** the system starts
- **THEN** it validates the corresponding API key environment variable exists
- **AND** raises a clear error if the key is missing (e.g., "ANTHROPIC_API_KEY must be set for anthropic provider")
- **AND** does not attempt fallback to other providers

### AC-005: LLM Request/Response Logging
- **GIVEN** `LOG_LLM_CALLS=true` environment variable is set
- **WHEN** any AI request is made
- **THEN** the system logs the full request and response in JSON Lines format to `logs/llm_calls.jsonl`
- **AND** each log entry includes: timestamp, provider, model, instructions, payload, response, duration_ms, error (if any)
- **AND** logging works consistently for all three providers

### AC-006: Pydantic Schema Compatibility
- **GIVEN** any supported provider is configured
- **WHEN** the system requests structured output (_IterationDecisionPayload, _FinalRecommendationPayload)
- **THEN** the provider returns a validated Pydantic object
- **AND** the schema validation works identically across all providers
- **AND** parsing errors are caught with `OutputParserException` and reported as `AIIntegrationError` code I302

### AC-007: Environment-Based Provider Selection
- **GIVEN** the following provider-to-key mappings:
  - `openai` → `OPENAI_API_KEY`
  - `anthropic` → `ANTHROPIC_API_KEY`
  - `google` → `GOOGLE_API_KEY`
- **WHEN** the system validates environment on startup
- **THEN** it checks only the API key for the configured provider
- **AND** ignores missing keys for unconfigured providers
- **AND** does not raise errors for missing ANTHROPIC_API_KEY when ai_provider=openai
- **AND** does not raise errors for missing GOOGLE_API_KEY when ai_provider=openai

### AC-008: Error Code Coverage
- **GIVEN** an error condition occurs during AI operations or configuration
- **WHEN** the system handles the error
- **THEN** it uses the appropriate error code from the following mapping:
  - **C115**: Scenario-level ai_provider override attempted (ConfigurationError)
  - **I302**: Pydantic validation failure (OutputParserException from LangChain)
  - **I307**: Generic AI request failure (network errors, API errors, etc.)
  - **I308**: Unsupported provider configured (not in: openai, anthropic, google)
  - **I309**: AI request timeout exceeded (beyond ai_timeout_seconds)
- **AND** error messages include actionable remediation guidance
- **AND** error codes are consistent across all three providers

## Non-Functional Requirements

### NFR-001: Backward Compatibility
- Existing YAML configurations work without modification
- Existing environment variables (`OPENAI_API_KEY`, `DATABASE_URL`) continue to work
- Existing prompt templates require no changes
- Default behavior (OpenAI provider) preserved when `ai_provider` is not specified

### NFR-002: Code Maintainability
- Minimize code changes to reduce migration risk
- Provider abstraction isolated to single module (`ai_agent.py`)
- Payload building logic (`_build_iteration_payload`, `_build_final_payload`) unchanged
- Domain model conversion logic (`_convert_iteration`, `_convert_final`) unchanged

### NFR-003: Testing Strategy
- Unit tests mock all three providers
- Integration tests use OpenAI only (default provider)
- Test coverage ≥90% for modified modules
- Existing test fixtures can be adjusted as needed

### NFR-004: Configuration Schema
```yaml
# Required fields in search_parameters.yaml
default:
  ai_provider: "openai"              # openai | anthropic | google
  ai_model: "gpt-4o-mini"            # Provider-specific model name
  ai_temperature: 0.2                # Sampling temperature
  ai_max_output_tokens: 900          # Max response tokens
  ai_timeout_seconds: 30             # Request timeout
```

### NFR-005: Supported Models
- **OpenAI:** gpt-4o-mini, gpt-4o, gpt-4-turbo
- **Anthropic:** claude-3-5-sonnet-20241022, claude-3-5-haiku-20241022
- **Google:** gemini-1.5-pro, gemini-1.5-flash, gemini-2.0-flash-exp

## Out of Scope

- ❌ Per-scenario provider overrides (system-wide only)
- ❌ Automatic fallback/retry across providers on failure
- ❌ Performance benchmarking or latency optimization
- ❌ Cost tracking or provider usage analytics
- ❌ Response caching or semantic deduplication
- ❌ Streaming responses
- ❌ Provider-specific prompt optimization

## Dependencies

- **External Libraries:**
  - `langchain-core>=0.3.29`
  - `langchain-openai>=0.2.14`
  - `langchain-anthropic>=0.3.7`
  - `langchain-google-genai>=2.0.8`
  - `anthropic>=0.39.0`
  - `google-generativeai>=0.8.3`

- **Removed:**
  - `openai-agents>=0.3.2`

- **Environment Variables:**
  - `OPENAI_API_KEY` (required if `ai_provider=openai`)
  - `ANTHROPIC_API_KEY` (required if `ai_provider=anthropic`)
  - `GOOGLE_API_KEY` (required if `ai_provider=google`)
  - `LOG_LLM_CALLS` (optional, defaults to false)

## Constraints

- Must use LangChain's `with_structured_output()` for Pydantic validation
- Provider clients read API keys from environment variables (no explicit key passing)
- No changes to existing prompt templates in `config/prompts/`
- JSON string payload format preserved for backward compatibility
- Timeout handling via `asyncio.wait_for()` (LangChain-agnostic)

## Success Metrics

- All 6 scenarios execute successfully with OpenAI provider
- Unit tests achieve ≥90% coverage on modified modules
- Integration tests pass with OpenAI (default)
- Zero configuration changes required for existing users
- LLM logging captures complete request/response data for all providers
