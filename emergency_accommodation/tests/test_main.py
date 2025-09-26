from __future__ import annotations

import asyncio
from contextlib import asynccontextmanager
from pathlib import Path
from types import SimpleNamespace

import pytest

from ai_agent import PromptTemplates
from models import FailedItem, FinalRecommendation, InventoryOption, IterationDecision, OptionAssessment

import main as cli_main


@pytest.fixture(autouse=True)
def _env_isolation(monkeypatch: pytest.MonkeyPatch) -> None:
    monkeypatch.delenv("DATABASE_URL", raising=False)
    monkeypatch.delenv("OPENAI_API_KEY", raising=False)


def _failed_item() -> FailedItem:
    return FailedItem.from_mapping(
        {
            "scn_id": "6a6c37f8-23dc-4f18-9581-1c31b3dd7b74",
            "line_item_id": "7fbf34d4-64fa-4ec0-9fb8-47d3a9bf5b8a",
            "description": "HVAC compressor failure",
            "quantity": "2",
            "unit_of_measure": "EA",
            "priority": "critical",
            "ros_date": "2024-05-01",
        }
    )


def _inventory_option() -> InventoryOption:
    return InventoryOption.from_mapping(
        {
            "inventory_id": "de7cc0d2-bc0f-4e8c-9f03-91f119626b20",
            "warehouse_id": "df49f38a-a9a6-4674-b033-71da49cfaff0",
            "warehouse_name": "Regional Hub",
            "material_description": "HVAC compressor",
            "available_quantity": "5",
            "reserved_quantity": "1",
            "soft_available_quantity": "4",
            "hard_available_quantity": "3",
            "approval_requirement": "manager",
            "impact_level": "minor_impact",
            "estimated_recovery_days": 4,
            "risk_summary": "Next required: 2024-05-20 | Priority: 70",
            "distance_km": 120.0,
        }
    )


def _option_assessment(summary: str, score: float, impact: str = "minor_impact") -> OptionAssessment:
    return OptionAssessment.from_mapping(
        {
            "inventory_id": "de7cc0d2-bc0f-4e8c-9f03-91f119626b20",
            "summary": summary,
            "impact_level": impact,
            "confidence": 0.9,
            "approvals_required": ["manager"],
            "trade_offs": ["Weekend freight"],
            "score": score,
        }
    )


def test_validate_environment_success(monkeypatch: pytest.MonkeyPatch) -> None:
    monkeypatch.setenv("DATABASE_URL", "postgresql://example")
    monkeypatch.setenv("OPENAI_API_KEY", "sk-test")

    db_url, api_key = cli_main.validate_environment()
    assert db_url == "postgresql://example"
    assert api_key == "sk-test"


def test_validate_environment_missing(monkeypatch: pytest.MonkeyPatch) -> None:
    monkeypatch.setenv("DATABASE_URL", "postgresql://example")
    with pytest.raises(RuntimeError):
        cli_main.validate_environment()


@pytest.mark.asyncio
async def test_run_accommodation_analysis_happy_path(monkeypatch: pytest.MonkeyPatch) -> None:
    monkeypatch.setattr(cli_main, "load_search_parameters", lambda scenario, config_dir: {
        "max_iterations": 2,
        "batch_size_per_iteration": 10,
        "early_stopping_threshold": 5,
        "search_order": "urgency_first",
    })

    monkeypatch.setattr(
        cli_main,
        "load_prompt_templates",
        lambda config_dir: {
            "scenario1": PromptTemplates(base="base", scenario="scenario", combined="combined"),
        },
    )

    async def fake_load_failed_items(database_url: str, scenario_name: str):
        assert database_url == "postgresql://example"
        assert scenario_name == "scenario1"
        return [_failed_item()]

    async def fake_load_inventory(*args, **kwargs):
        return [_inventory_option()]

    monkeypatch.setattr(cli_main, "load_failed_items", fake_load_failed_items)
    monkeypatch.setattr(cli_main, "load_inventory_by_iteration", fake_load_inventory)

    iteration_called = []
    final_called = []

    def fake_display_iteration_results(iteration: int, decision: IterationDecision, *, console_override=None):
        iteration_called.append(iteration)

    def fake_display_final_recommendation(recommendation: FinalRecommendation, *, console_override=None):
        final_called.append(recommendation.primary_option.summary)

    monkeypatch.setattr(cli_main, "display_iteration_results", fake_display_iteration_results)
    monkeypatch.setattr(cli_main, "display_final_recommendation", fake_display_final_recommendation)
    monkeypatch.setattr(cli_main, "display_scenario_header", lambda *args, **kwargs: None)
    monkeypatch.setattr(cli_main, "display_success", lambda *args, **kwargs: None)
    monkeypatch.setattr(cli_main, "display_error", lambda *args, **kwargs: None)

    class FakeProgress:
        def __enter__(self):
            return self

        def __exit__(self, exc_type, exc, tb):
            return False

        def update(self, *args, **kwargs):
            pass

        def advance(self, *args, **kwargs):
            pass

    monkeypatch.setattr(cli_main, "display_progress_bar", lambda description, total: (FakeProgress(), 1))

    class FakeAgent:
        def __init__(self, config, client, templates):
            self._decision = IterationDecision(
                continue_search=False,
                reasoning="Threshold met",
                viable_options=(_option_assessment("Allocate Regional Hub compressors", 7.5),),
            )

        async def evaluate_iteration(self, *args, **kwargs) -> IterationDecision:
            return self._decision

        async def final_recommendation(self) -> FinalRecommendation:
            return FinalRecommendation(
                primary_option=_option_assessment("Allocate Regional Hub compressors", 8.1),
                executive_summary="Deploy Regional Hub stock.",
                risk_mitigation=("Coordinate QA resources",),
            )

    monkeypatch.setattr(cli_main, "AccommodationAgent", FakeAgent)

    @asynccontextmanager
    async def fake_client(api_key: str):
        yield object()

    monkeypatch.setattr(cli_main, "create_openai_client", fake_client)

    await cli_main.run_accommodation_analysis(
        scenario_name="scenario1",
        config_dir=Path("."),
        database_url="postgresql://example",
        openai_api_key="sk-test",
    )

    assert iteration_called == [1]
    assert final_called == ["Allocate Regional Hub compressors"]


@pytest.mark.asyncio
async def test_run_accommodation_analysis_no_failed_items(monkeypatch: pytest.MonkeyPatch) -> None:
    monkeypatch.setattr(cli_main, "load_search_parameters", lambda *args, **kwargs: {
        "max_iterations": 1,
    })
    monkeypatch.setattr(cli_main, "load_prompt_templates", lambda *args, **kwargs: {
        "scenario1": PromptTemplates(base="b", scenario="s", combined="c"),
    })
    async def _no_failed(*args, **kwargs):
        return []

    monkeypatch.setattr(cli_main, "load_failed_items", _no_failed)

    errors = []
    monkeypatch.setattr(cli_main, "display_error", lambda message, error_type="Error": errors.append((message, error_type)))
    monkeypatch.setattr(cli_main, "display_scenario_header", lambda *args, **kwargs: None)

    await cli_main.run_accommodation_analysis(
        scenario_name="scenario1",
        config_dir=Path("."),
        database_url="postgresql://example",
        openai_api_key="sk-test",
    )

    assert errors and "No failed items" in errors[0][0]


def test_parse_args_parses_values() -> None:
    args = cli_main.parse_args([
        "--scenario",
        "scenario2",
        "--config-dir",
        "configs",
        "--max-iterations",
        "5",
    ])

    assert args.scenario == "scenario2"
    assert args.config_dir == "configs"
    assert args.max_iterations == 5
