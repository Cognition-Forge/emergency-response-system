# FEAT Design: Quick Fix - Multi-Iteration Configuration

## Architecture

### Current Behavior
The early stopping logic at `emergency_accommodation/ai_agent.py:303-319` forces search termination when `viable_options >= early_stopping_threshold`. Current thresholds (4, 8, 5) are too low relative to batch sizes (15, 12, 15), causing premature termination.

### Solution Strategy
Increase `early_stopping_threshold` values in `search_parameters.yaml` to require more viable options before stopping. The new thresholds will be higher than batch sizes, forcing the system to execute multiple iterations before accumulating enough options to trigger early stopping.

### Configuration Change Mapping

| Scenario | Current Threshold | New Threshold | Ratio to Batch Size |
|----------|------------------|---------------|---------------------|
| scenario1-enhanced | 4 | 8 | 0.53× (8/15) |
| scenario2-enhanced | 8 | 15 | 1.25× (15/12) |
| scenario3-enhanced | 5 | 12 | 0.80× (12/15) |

**Rationale:**
- **scenario1-enhanced**: Threshold below batch size ensures at least 2 iterations needed to reach 8 options
- **scenario2-enhanced**: Threshold above batch size ensures 2 iterations minimum (12+12=24 > 15)
- **scenario3-enhanced**: Threshold below batch size but requires accumulation across 2 batches

### No Code Changes Required
The existing `config.loader` module already supports YAML-based configuration overrides. The `_apply_early_stopping` method will automatically use the new threshold values.

## Dependencies

### Configuration System
- **File:** `emergency_accommodation/config/search_parameters.yaml`
- **Loader:** `emergency_accommodation/config/loader.py`
- **Consumer:** `emergency_accommodation/ai_agent.py:304`

### Test Environment
- PostgreSQL database with enhanced scenario data loaded
- OpenAI API key configured in environment
- All three enhanced scenarios seeded via `load-scenario.sh`

## Constraints

### Threshold Selection Constraints
1. **Must be > current value** to force additional iterations
2. **Should be achievable within max_iterations** (avoid impossible thresholds)
3. **Must account for batch_size** to ensure multi-iteration execution
4. **Conservative scenarios** should require fewer options than aggressive scenarios

### Behavioral Constraints
1. **Base scenarios unchanged** - modifications only affect `*-enhanced` scenarios
2. **AI can still stop early** - if AI determines search should not continue, it overrides threshold
3. **Max iterations respected** - threshold cannot force iterations beyond `max_iterations` config

### Testing Constraints
1. **Non-deterministic AI behavior** - AI may decide to stop before hitting threshold
2. **Database dependency** - scenarios must be properly seeded with inventory data
3. **API rate limits** - multiple test runs consume OpenAI API quota

## Configuration File Structure

```yaml
scenarios:
  scenario1-enhanced:
    early_stopping_threshold: 8      # Changed from 4
    # All other parameters unchanged
  scenario2-enhanced:
    early_stopping_threshold: 15     # Changed from 8
    # All other parameters unchanged
  scenario3-enhanced:
    early_stopping_threshold: 12     # Changed from 5
    # All other parameters unchanged
```

## Rollback Strategy
If multi-iteration behavior causes issues:
1. Revert `search_parameters.yaml` to previous threshold values
2. No code deployment needed
3. Configuration reload takes effect immediately on next run

## Verification Approach
For each enhanced scenario:
1. Run application with updated configuration
2. Capture console output showing iteration count
3. Verify iteration count ≥ 2
4. Inspect final recommendation quality
5. Confirm no errors or timeouts
