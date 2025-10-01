# FEAT Requirements: Quick Fix - Multi-Iteration Configuration

## Business Context
The emergency accommodation system currently stops after 1 iteration instead of executing 2-3 iterations as configured. This reduces the quality of AI decision-making by preventing progressive exploration of inventory options across multiple search phases.

The quick fix adjusts configuration thresholds to force the AI to continue searching beyond the first batch of viable options, enabling more sophisticated trade-off analysis between immediate availability and downstream impact.

## User Stories

### US-001: System Executes Multiple Iterations
**As a** emergency response coordinator
**I want** the system to execute 2-3 search iterations as configured
**So that** I can evaluate more inventory options with varying availability, impact, and approval requirements

### US-002: Higher Quality Recommendations
**As a** emergency response coordinator
**I want** the AI to consider more options before stopping
**So that** I receive recommendations that balance immediate needs with downstream impacts

## Acceptance Criteria

### AC-001: Scenario 1 Enhanced Executes 2 Iterations
- **GIVEN** scenario1-enhanced is configured with `max_iterations: 2`
- **WHEN** I run `uv run python main.py --scenario scenario1-enhanced`
- **THEN** the system executes exactly 2 iterations before stopping
- **AND** iteration 1 returns 15 inventory options (batch_size)
- **AND** iteration 2 returns different inventory options (no duplicates from iteration 1)

### AC-002: Scenario 2 Enhanced Executes 2-3 Iterations
- **GIVEN** scenario2-enhanced is configured with `max_iterations: 3`
- **WHEN** I run `uv run python main.py --scenario scenario2-enhanced`
- **THEN** the system executes at least 2 iterations (may stop at 2 or 3 based on AI decision)
- **AND** each iteration returns up to 12 inventory options (batch_size)
- **AND** early stopping threshold of 15 requires significant options before stopping

### AC-003: Scenario 3 Enhanced Executes 2-3 Iterations
- **GIVEN** scenario3-enhanced is configured with `max_iterations: 3`
- **WHEN** I run `uv run python main.py --scenario scenario3-enhanced`
- **THEN** the system executes at least 2 iterations (may stop at 2 or 3 based on AI decision)
- **AND** each iteration returns up to 15 inventory options (batch_size)
- **AND** early stopping threshold of 12 requires substantial options before stopping

### AC-004: Configuration Changes Applied
- **GIVEN** the updated `search_parameters.yaml` file
- **WHEN** I inspect the configuration for enhanced scenarios
- **THEN** `early_stopping_threshold` is increased for all three enhanced scenarios:
  - scenario1-enhanced: 4 → 8
  - scenario2-enhanced: 8 → 15
  - scenario3-enhanced: 5 → 12

### AC-005: Backward Compatibility Maintained
- **GIVEN** the configuration changes
- **WHEN** I run base scenarios (scenario1, scenario2, scenario3)
- **THEN** their behavior remains unchanged from previous runs
- **AND** base scenario configurations are not modified

## Non-Functional Requirements

### Performance
- Configuration load time: < 100ms
- No impact on AI inference time per iteration
- Total execution time may increase proportionally with additional iterations

### Maintainability
- Configuration changes are isolated to `search_parameters.yaml`
- No code changes required
- Changes are reversible by restoring previous threshold values
