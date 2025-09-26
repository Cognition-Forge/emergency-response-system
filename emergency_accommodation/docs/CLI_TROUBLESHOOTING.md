# CLI Troubleshooting Guide

## Database Connectivity
- **Symptoms:** `database unavailable`, `connection refused`, or SSL errors.
- **Resolution:**
  1. Ensure `postgres-scenarios` Docker container is running (`docker compose ps`).
  2. Confirm `DATABASE_URL` uses `sslmode=require` implicitly by pointing at the TLS-enabled port (default `127.0.0.1:5432`).
  3. Regenerate credentials by re-copying `.env.example` if the password has changed.

## Missing Scenario Data
- **Symptoms:** CLI reports “No failed items found for the selected scenario.”
- **Resolution:**
  1. Rerun `./scripts/utils/load-scenario.sh <scenario>` from the `postgres-scenarios/` directory.
  2. Verify the `config/search_parameters.yaml` contains an entry for the scenario name.

## AI Evaluation Failures
- **Symptoms:** `I307: simulated failure` or timeout errors.
- **Resolution:**
  1. Confirm `OPENAI_API_KEY` is set and valid.
  2. Increase `AI_TIMEOUT_SECONDS` when using slower models.
  3. Use a smaller `batch_size_per_iteration` or `max_iterations` to shorten prompt payloads.

## Empty Recommendations
- **Symptoms:** CLI stops without producing a final recommendation.
- **Resolution:**
  1. Raise `max_iterations` (CLI flag or YAML) and reduce `early_stopping_threshold`.
  2. Confirm the prompt overlays in `config/prompts/` do not discourage viable allocations (e.g., remove overly strict wording).

## Configuration Overrides Not Detected
- **Symptoms:** CLI still uses default values after pointing to a custom directory.
- **Resolution:**
  1. Use `--config-dir` to reference the folder containing both `search_parameters.yaml` and `prompts/`.
  2. Check YAML indentation—incorrect indentation causes fall-back to defaults.

For additional issues, rerun with `LOG_LEVEL=DEBUG` to surface the structured log entries emitted by the CLI orchestrator.
