# FEAT Tasks: Agent Class Migration

## Definition of Ready (DoR)

### Universal DoR
- [x] Requirements complete and actionable
- [x] Dependencies identified and accessible
- [x] Test scenarios defined
- [x] Security considerations documented
- [x] Performance requirements specified
- [x] Error handling defined
- [x] Rollback procedures documented (optional)

### FEAT-Specific DoR
- [x] User stories with complete acceptance criteria
- [x] API contracts specified (Agent SDK vs Async client)
- [x] Integration points and data flow documented
- [x] Performance impact assessment completed
- [x] File-based configuration compatibility verified
- [x] PostgreSQL query flow unchanged
- [x] Python professional development standards documented
- [x] Minimal-dependency approach agreed (no overengineering)

## Implementation Plan
1. Evaluate the OpenAI Agents SDK usage for structured JSON output.
2. Replace the existing `AccommodationAgent` implementation with the Agent API.
3. Adjust orchestration in `main.py` to accommodate the new agent interface.
4. Update unit and integration tests to mock the Agent API and keep deterministic coverage.
5. Refresh documentation to state the new Agent-based flow.

## Definition of Done (DoD)
- [x] All acceptance criteria verified
- [x] Test coverage >85%
- [x] Security scan passes (no hardcoded credentials, parameterized queries)
- [x] Performance benchmarks met (<30s total execution, <2s per database query)
- [x] Code review completed
- [x] Documentation updated (README, flowcharts if needed)

## Task Breakdown

### Gate 1 – Architecture & Setup
- [x] **TASK-001**: Confirm SDK requirements and update dependencies if needed
  - Identify minimum `openai` version supporting Agents/JSON parsing
  - Update `pyproject.toml` / `uv.lock`
  - Document any new environment variables

- [x] **TASK-002**: Map existing config inputs to Agent parameters
  - Determine how instructions, settings, and structured outputs map to Agent setup
  - Capture lean design notes in `design.md`

### Gate 2 – Implementation
- [x] **TASK-003**: Implement Agent-based evaluation in `ai_agent.py`
  - Instantiate Agent per scenario run with merged prompts
  - Replace manual JSON parsing with Agent SDK helpers
  - Ensure iteration decisions and final recommendations remain structured

- [x] **TASK-004**: Update CLI orchestration (`main.py`)
  - Adjust instantiation/usage of the Agent-based evaluator
  - Keep progress indicators and logging intact

### Gate 3 – Validation
- [x] **TASK-005**: Update tests for new Agent workflow
  - Revise unit tests to mock Agent responses
  - Refresh integration tests that use fakes or fixture flows
  - Ensure coverage remains ≥85%

- [x] **TASK-006**: Run live scenario tests with database
  - Execute `DATABASE_URL=… uv run python -m pytest`
  - Run manual smoke tests for `main.py --scenario scenario1|2|3`

### Gate 4 – Documentation & Handoff
- [x] **TASK-007**: Update documentation and flowcharts
  - Note Agent usage in README and troubleshooting doc
  - Update diagrams if data flow changes

- [x] **TASK-008**: Final review
  - Verify DoD checklist
  - Prepare summary for code review/merge

## Quality Gates
- **Gate 1 – Preparation**: SDK requirements verified, configuration mapping documented.
- **Gate 2 – Implementation**: Agent integration complete with tests passing locally.
- **Gate 3 – Validation**: Live database + AI smoke tests successful; coverage threshold met.
- **Gate 4 – Finalization**: Documentation updated; DoD satisfied.
