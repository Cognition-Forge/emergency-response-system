# FEAT Requirements: Agent Class Migration

## Business Context
The emergency accommodation CLI currently orchestrates OpenAI calls via the low-level `AsyncOpenAI` client, manually managing prompts, JSON parsing, and iteration logic. We want to migrate to the higher-level OpenAI Agents SDK to reduce boilerplate, improve maintainability, and align with modern structured output features while keeping the existing database-driven workflow and configuration files intact. The change must remain lean—no overengineering or unnecessary abstractions.

## User Stories

### US-001: CLI Maintainer
**As a** CLI maintainer
**I want** the AI evaluation to run through the OpenAI `Agent` interface
**So that** I can rely on the SDK to manage structured responses and future tooling support.

### US-002: Configuration Editor
**As a** configuration editor
**I want** scenario prompts and search parameters to keep working without code changes
**So that** operators can continue tuning the system through YAML and text files.

### US-003: Database Engineer
**As a** database engineer
**I want** the iterative PostgreSQL queries to remain untouched
**So that** existing performance characteristics and access patterns stay consistent.

### US-004: QA Engineer
**As a** QA engineer
**I want** existing unit and integration tests to pass with the new agent flow
**So that** regression risk stays low during the migration.

## Acceptance Criteria

### AC-001: Agent-backed Evaluation
- **GIVEN** the CLI runs with a valid `.env`
- **WHEN** I execute `uv run python main.py --scenario scenario1`
- **THEN** the AI evaluation uses the OpenAI `Agent` class and produces a final recommendation without errors.

### AC-002: Configuration Compatibility
- **GIVEN** existing YAML search parameters and prompt text files
- **WHEN** scenarios 1–3 are executed through the CLI
- **THEN** the prompts and iteration settings are honored without additional code configuration.

### AC-003: Database Interaction Integrity
- **GIVEN** the migration is complete
- **WHEN** inventory batches are loaded during iterations
- **THEN** the same PostgreSQL functions and parameterized queries execute as before, with no schema or query changes.

### AC-004: Test Suite Stability
- **GIVEN** the agent migration code is in place
- **WHEN** I run `uv run python -m pytest` and the live suite with `DATABASE_URL`
- **THEN** all unit and integration tests pass, including new coverage for the agent workflow.

## Non-Functional Requirements
- Performance: Maintain current iteration speed (<2s per batch) and total scenario run time (<30s).
- Security: Keep API keys in environment variables/.env; no secrets committed; continue using parameterized SQL.
- Usability: Preserve command-line interface and configuration-driven tuning; documentation must be updated to describe the Agent usage and any new environment variables if needed.
