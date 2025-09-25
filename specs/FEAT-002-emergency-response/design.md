# FEAT Design: Emergency Response Python CLI Application

## Technical Architecture

### System Overview
The `emergency_accommodation` application follows a streamlined, async-first architecture with clear separation of concerns. The system uses AI-driven decision making through file-based configurable prompts rather than rigid mathematical algorithms, enabling realistic emergency coordinator workflows.

```
┌─────────────────┐    ┌──────────────────┐    ┌─────────────────┐
│   CLI Interface │    │  AI Coordinator  │    │ Database Layer  │
│   (Rich Output) │◄──►│   (OpenAI SDK)   │◄──►│ (Async asyncpg) │
└─────────────────┘    └──────────────────┘    └─────────────────┘
          │                       │                       │
          ▼                       ▼                       ▼
┌─────────────────┐    ┌──────────────────┐    ┌─────────────────┐
│  Configuration  │    │   Data Models    │    │ Iterative Query │
│    (Prompts &   │    │  (Dataclasses)   │    │   (3 Batches)   │
│   Parameters)   │    │                  │    │                 │
└─────────────────┘    └──────────────────┘    └─────────────────┘
```

### Module Structure
```
emergency_accommodation/
├── main.py                     # CLI entry point and orchestration
├── config/
│   ├── search_parameters.yaml  # Search configuration for all scenarios
│   ├── prompts/
│   │   ├── base_prompt.txt     # Base AI instruction template
│   │   ├── scenario1.txt       # Conservative scenario prompt additions
│   │   ├── scenario2.txt       # Balanced scenario prompt additions
│   │   └── scenario3.txt       # Aggressive scenario prompt additions
│   └── __init__.py
├── database.py                 # Direct async database queries
├── ai_agent.py                 # AccommodationAgent with OpenAI integration
├── models.py                   # FailedItem, InventoryOption, IterationDecision, FinalRecommendation
├── cli_display.py              # Rich console formatting with progress bars and tables
├── pyproject.toml              # uv-managed dependencies and project configuration
└── README.md                   # Setup and usage instructions
```

## Dependencies

### External Dependencies
- **asyncpg**: PostgreSQL async driver for database connectivity
- **rich**: Professional CLI formatting, progress bars, and color-coded output
- **openai**: OpenAI SDK for AI agent integration
- **python-dotenv**: Environment variable management for credentials
- **pyyaml**: YAML configuration file parsing
- **pydantic**: Data validation and settings management

### Internal Dependencies
- **PostgreSQL Database**: Uses existing schema from FEAT-001 with scenario data
- **Configuration Files**: YAML search parameters and text-based prompt templates
- **Environment Configuration**: DATABASE_URL and OPENAI_API_KEY required
- **Scenario Data**: Depends on scenario1, scenario2, scenario3 being loaded in database

### Development Dependencies
- **pytest**: Unit testing framework with async support
- **pytest-asyncio**: Async test execution
- **pytest-cov**: Code coverage reporting (target: 85%+)
- **mypy**: Static type checking

## Data Flow

### 1. Initialization Flow
```
CLI Start → Load Configuration → Connect Database → Initialize AI Agent
    ↓              ↓                    ↓                  ↓
Parse Args → Load YAML + Prompts → asyncpg.connect → AccommodationAgent
```

### 2. Iterative Search Flow
```
Load Failed Items → Iteration 1 → AI Evaluation → Continue?
        ↓               ↓             ↓            ↓
    Database Query → Batch Load → Decision Logic → Early Stop or Next
        ↓               ↓             ↓            ↓
    SCN Analysis → Inventory Filter → Viable Options → Iteration 2/3
```

### 3. AI Decision Process
```
Inventory Batch → Prompt Template → OpenAI API → Decision Response
       ↓               ↓               ↓            ↓
   Format Data → Business Context → AI Analysis → Continue/Stop + Rankings
```

### 4. Output Generation
```
AI Recommendations → Rich Formatting → CLI Display → Final Summary
        ↓                  ↓             ↓            ↓
   Business Analysis → Color Coding → Progress Bars → Executive Summary
```

## Component Details

### File-Based Configuration Management
```yaml
# config/search_parameters.yaml
default:
  max_iterations: 3
  time_window_type: "weekly"  # weekly, monthly, priority_based, distance_based
  batch_size_per_iteration: 10
  search_order: "urgency_first"  # urgency_first, proximity_first, availability_first
  early_stopping_threshold: 5
  risk_tolerance: "moderate"  # conservative, moderate, aggressive
  approval_preference: "minimize"  # minimize, balance, accept_higher

scenarios:
  scenario1:
    risk_tolerance: "conservative"
    approval_preference: "minimize"
    max_iterations: 2
  scenario2:
    risk_tolerance: "moderate"
    early_stopping_threshold: 8
    max_iterations: 3
  scenario3:
    risk_tolerance: "aggressive"
    approval_preference: "accept_higher"
    max_iterations: 3
    search_order: "availability_first"
```

### Streamlined Database Layer
```python
# database.py - Direct async queries without complex abstractions
async def load_failed_items(connection_url: str, scenario_name: str) -> List[FailedItem]:
    """Load failed SCN items for scenario"""

async def load_inventory_by_iteration(connection_url: str, failed_items: List[FailedItem], iteration_num: int, config: dict) -> List[InventoryOption]:
    """Load inventory options incrementally based on iteration strategy"""

async def load_by_time_window(connection, items, iteration, window_type):
    """Time-based incremental loading"""

async def load_by_priority_level(connection, items, iteration):
    """Priority-based incremental loading"""
```

### Streamlined AI Agent
```python
# ai_agent.py - Simple OpenAI integration with file-based prompts
class AccommodationAgent:
    def __init__(self, config: dict, openai_client: OpenAI, prompt_templates: dict)
    async def evaluate_iteration(self, iteration_num: int, inventory_batch: List[InventoryOption], failed_items: List[FailedItem], scenario_name: str) -> IterationDecision
    async def final_recommendation(self) -> FinalRecommendation
    def _load_prompt_template(self, scenario_name: str) -> str
    def _build_iteration_prompt(self, template: str, **kwargs) -> str
    def _parse_ai_response(self, response: str) -> Union[IterationDecision, FinalRecommendation]

# Prompt templates loaded from config/prompts/
def load_prompt_templates() -> dict:
    """Load base and scenario-specific prompt templates from text files"""
```

## Security Considerations

### Credential Management
- **OpenAI API Key**: Stored in `OPENAI_API_KEY` environment variable
- **Database URL**: Stored in `DATABASE_URL` environment variable with embedded credentials
- **No hardcoded secrets**: All sensitive data externalized through environment configuration
- **Secure defaults**: Connection timeouts and retry limits to prevent credential exposure

### Data Protection
- **Database queries**: Parameterized queries prevent SQL injection
- **AI prompts**: Input sanitization for user-provided scenario names and file paths
- **Configuration files**: Validate YAML structure and prompt file contents
- **Logging**: No sensitive data (API keys, database credentials) logged
- **Error handling**: Clear error messages with guidance for file-based configuration issues

### Network Security
- **Database connections**: SSL/TLS required for PostgreSQL connections
- **API calls**: HTTPS only for OpenAI API communication
- **Connection management**: Secure connection handling with proper cleanup

## Performance Constraints

### Database Performance
- **Connection management**: Simple async connection with proper resource cleanup
- **Query optimization**: Indexed queries on commodity_code_id, equipment_id, warehouse_id, ros_date
- **Incremental loading**: Maximum 3 iterations with configurable batch sizes (default: 10)
- **Early stopping**: Configurable threshold (default: 5 viable options) to minimize database load

### AI Performance
- **Rate limiting**: Respect OpenAI API rate limits with exponential backoff
- **Prompt optimization**: Efficient prompt design to minimize token usage
- **Response caching**: Cache AI responses within single execution for consistency
- **Timeout handling**: 30-second timeout for AI responses with graceful fallback

### Memory Management
- **Streaming data**: Process inventory batches individually, not bulk loading
- **Connection cleanup**: Proper async context management for database connections
- **Configuration caching**: Load YAML and prompt files once at startup
- **Object lifecycle**: Clear dataclass instances between iterations to prevent memory leaks

### Response Time Targets
- **Complete scenario analysis**: Under 30 seconds for all three iterations
- **Database queries**: Under 2 seconds per batch query
- **AI evaluation**: Under 10 seconds per iteration
- **CLI output**: Real-time progress updates during processing

## Error Handling Architecture

### Simplified Error Handling
- **Configuration Errors**: Missing environment variables, invalid YAML, missing prompt files
- **Database Errors**: Connection failures, query errors, no data found
- **AI Integration Errors**: API failures, response parsing issues, timeout errors

### Error Recovery Strategies
- **Configuration errors**: Clear error messages with file path guidance
- **Database failures**: Simple retry with clear failure messages
- **AI API failures**: Graceful fallback with user notification
- **File system errors**: Validate configuration file paths and permissions

## Integration Points

### PostgreSQL Database Schema
- **Primary tables**: `scns`, `scn_line_items`, `po_line_items`, `warehouse_inventory`, `wbs_ros_dates`
- **Emergency tables**: `emergency_incidents`, `emergency_accommodations`, `inventory_reservations`
- **Query patterns**: Joins across materials, inventory, and commitment data
- **Data types**: UUIDs for primary keys, DECIMAL for quantities, TIMESTAMP for dates

### OpenAI Integration
- **API version**: Using latest OpenAI Python SDK (v1.x)
- **Model selection**: Configurable (default: gpt-4)
- **Prompt engineering**: Structured prompts with business context and scenario-specific instructions
- **Response format**: Structured JSON responses parsed into dataclasses

### Environment Configuration
```bash
# Required environment variables
DATABASE_URL=postgresql://user:pass@localhost:5432/materials_management
OPENAI_API_KEY=sk-...
# Optional configuration (defaults in YAML)
AI_MODEL=gpt-4
```

## Extensibility Design

### Adding New Scenarios
1. Add scenario configuration to `config/search_parameters.yaml` under scenarios section
2. Create new prompt template file `config/prompts/new_scenario.txt`
3. Load scenario data into PostgreSQL database
4. Test with `python main.py --scenario new_scenario`

### Adding New Search Strategies
1. Implement new function in `database.py` (e.g., `load_by_cost_zones`)
2. Add strategy option to YAML configuration `time_window_type`
3. Update configuration validation and documentation

### Adding New AI Models
1. Update `AI_MODEL` environment variable (defaults to gpt-4)
2. Adjust prompt templates in text files if needed for model-specific optimization

This streamlined design ensures a maintainable, configurable system that demonstrates realistic emergency accommodation workflows while avoiding overengineering and maintaining simplicity.