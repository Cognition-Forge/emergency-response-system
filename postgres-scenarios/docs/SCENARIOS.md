# Emergency Scenario Catalogue

Each scenario can be loaded independently from `scripts/scenarios/`. Every script is idempotent: rerunning it removes the existing project and reseeds the dataset from scratch. Use the helper `./scripts/utils/load-scenario.sh <scenario>` to avoid typing the full `psql` command.

## Scenario 1 – Simple Surge (`scenario1-simple.sql`)
- **Narrative**: Coastal storm response with perfect inventory alignment. Stock is plentiful, no reservations exist, and AI recommendations should rank the staging warehouse with a *no impact* outcome.
- **Load**:
  ```bash
  PGPASSWORD=change_me psql "sslmode=require host=127.0.0.1 port=5432 dbname=materials_management user=materials_admin" \
       -f scripts/scenarios/scenario1-simple.sql
  ```
- **Highlights**:
  - 1 project, 1 PO, 1 SCN, 1 receipt, 1 inventory record, 1 finalized FMR
  - `emergency_accommodations` entry documents the successful deployment (no approval required)
- **Expected recommendation (top row)**:
  | availability_status | impact_level | soft_available_qty | hard_available_qty | compatibility_score | availability_score |
  |---------------------|--------------|--------------------|--------------------|---------------------|--------------------|
  | free                | no_impact    | 20                 | 18                 | 100                 | 100                |

## Scenario 2 – Conflict Reassignment (`scenario2-conflict.sql`)
- **Narrative**: Regional flooding overlaps with planned training allocations. Medium-priority reservations exist but can be reassigned after planner approval.
- **Load**:
  ```bash
  PGPASSWORD=change_me psql "sslmode=require host=127.0.0.1 port=5432 dbname=materials_management user=materials_admin" \
       -f scripts/scenarios/scenario2-conflict.sql
  ```
- **Highlights**:
  - Inventory split across primary and backlog WBS paths
  - Draft FMR holds 12 kits (`inventory_reservations.can_reassign = TRUE`)
  - Second reservation locks 6 kits for a strategic hold to drive the conflict narrative
- **Expected recommendation (top row)**:
  | availability_status | impact_level    | soft_available_qty | hard_available_qty | compatibility_score | availability_score |
  |---------------------|-----------------|--------------------|--------------------|---------------------|--------------------|
  | reassignable        | moderate_impact | 4                  | 0                  | 100                 | 60                 |

## Scenario 3 – Critical Stockpile Decision (`scenario3-critical.sql`)
- **Narrative**: Metropolitan blackout drains the secure warehouse. Executive sign-off is required to repurpose units that were earmarked for another program, and mitigation costs are recorded.
- **Load**:
  ```bash
  PGPASSWORD=change_me psql "sslmode=require host=127.0.0.1 port=5432 dbname=materials_management user=materials_admin" \
       -f scripts/scenarios/scenario3-critical.sql
  ```
- **Highlights**:
  - Multiple reservations leave demand greater than remaining stock (`quantity_reserved > quantity_available`)
  - `emergency_accommodations` references the displaced reservation and captures executive approval timestamps
  - `commitment_impacts` quantifies the downstream cost of the decision
- **Expected recommendation (top row)**:
  | availability_status | impact_level       | soft_available_qty | hard_available_qty | compatibility_score | availability_score |
  |---------------------|--------------------|--------------------|--------------------|---------------------|--------------------|
  | emergency_only      | critical_decision  | 0                  | 0                  | 95                  | 25                 |

## Validation Workflow

1. Load all three scenario scripts (order doesn’t matter).
2. Run `scripts/queries/validation-checks.sql` to confirm row counts and impact-level expectations. The script looks up each scenario’s PO line, so running it with only a subset of scenarios loaded will raise “PO line item … not found”.
3. Run `scripts/queries/accommodation-analysis.sql` to review the full recommendation stack returned by `fn_emergency_inventory_search`.

Use `scripts/scenarios/cleanup.sql` between demos to reset all three projects without rebuilding the Docker volume.

## Sample Query Output

The helper `scripts/queries/accommodation-analysis.sql` will return results similar to the following (UUIDs truncated for readability):

```
Scenario 1 – Simple Surge
 inventory_id | warehouse_id | quantity_available | soft_available_qty | hard_available_qty | availability_status | compatibility_score | urgency_score | availability_score | impact_level 
--------------+--------------+--------------------+--------------------+--------------------+---------------------+---------------------+---------------+--------------------+--------------
 f7ac…        | 6c88…        |                 20 |                 20 |                 18 | free                |                 100 |            80 |                 100 | no_impact

Scenario 2 – Conflict and Reassignment
 inventory_id | warehouse_id | quantity_available | soft_available_qty | hard_available_qty | availability_status | compatibility_score | urgency_score | availability_score | impact_level 
--------------+--------------+--------------------+--------------------+--------------------+---------------------+---------------------+---------------+--------------------+--------------
 9c31…        | 0f12…        |                 22 |                  4 |                  0 | reassignable        |                 100 |            60 |                  60 | moderate_impact
 3bf4…        | 0f12…        |                 18 |                 18 |                 18 | free                |                  80 |            90 |                 100 | no_impact

Scenario 3 – Critical Stockpile Decision
 inventory_id | warehouse_id | quantity_available | soft_available_qty | hard_available_qty | availability_status | compatibility_score | urgency_score | availability_score | impact_level 
--------------+--------------+--------------------+--------------------+--------------------+---------------------+---------------------+---------------+--------------------+--------------
 6d9a…        | a541…        |                  8 |                  0 |                  0 | emergency_only      |                  95 |            50 |                  25 | critical_decision
```
