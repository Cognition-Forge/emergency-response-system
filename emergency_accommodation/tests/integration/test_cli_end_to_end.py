from __future__ import annotations

import asyncio
import json
import os
from contextlib import asynccontextmanager
from pathlib import Path
from shutil import copytree
from typing import Any, Literal, cast

import pytest

import main as cli_main
from ai_agent import AIIntegrationError, PromptTemplates
from models import (
    FinalRecommendation,
    IterationDecision,
    InventoryOption,
    OptionAssessment,
)

_database_url = os.getenv("DATABASE_URL")
if not _database_url:
    pytest.skip("DATABASE_URL is required for CLI integration tests", allow_module_level=True)
DATABASE_URL = cast(str, _database_url)

DEFAULT_CONFIG_DIR = Path(__file__).resolve().parents[2] / "config"


class _FakeProgress:
    def __enter__(self) -> "_FakeProgress":
        return self

    def __exit__(self, exc_type, exc, tb) -> Literal[False]:
        return False

    def update(self, *args, **kwargs) -> None:
        pass

    def advance(self, *args, **kwargs) -> None:
        pass


def _option_from_inventory(inventory: InventoryOption) -> OptionAssessment:
    return OptionAssessment.from_mapping(
        {
            "inventory_id": str(inventory.inventory_id),
            "summary": f"Allocate {inventory.warehouse_name} stock",
            "impact_level": inventory.impact_level,
            "confidence": 0.9,
            "approvals_required": [inventory.approval_requirement],
            "trade_offs": ["Expedited freight"],
            "score": 8.0,
        }
    )


class _FakeAgent:
    def __init__(self, config: dict[str, Any], client: Any, templates: dict[str, PromptTemplates]) -> None:
        self._last_option: OptionAssessment | None = None
        self._config = config

    async def evaluate_iteration(
        self,
        *,
        iteration_num: int,
        inventory_batch: list[InventoryOption],
        failed_items: list[Any],
        scenario_name: str,
    ) -> IterationDecision:
        option = _option_from_inventory(inventory_batch[0])
        self._last_option = option
        continue_search = iteration_num < int(self._config.get("max_iterations", 3))
        return IterationDecision(
            continue_search=continue_search,
            reasoning="Sufficient coverage identified" if not continue_search else "Collecting additional options",
            viable_options=(option,),
        )

    async def final_recommendation(self) -> FinalRecommendation:
        option = self._last_option or _option_from_inventory(_build_placeholder_inventory())
        return FinalRecommendation(
            primary_option=option,
            executive_summary="Deploy available stock with expedited approvals.",
            risk_mitigation=("Confirm QA resources",),
        )


def _build_placeholder_inventory() -> InventoryOption:
    return InventoryOption.from_mapping(
        {
            "inventory_id": "de7cc0d2-bc0f-4e8c-9f03-91f119626b20",
            "warehouse_id": "df49f38a-a9a6-4674-b033-71da49cfaff0",
            "warehouse_name": "Placeholder",
            "material_description": "Placeholder",
            "available_quantity": "1",
            "reserved_quantity": "0",
            "soft_available_quantity": "1",
            "hard_available_quantity": "1",
            "approval_requirement": "manager",
            "impact_level": "minor_impact",
            "estimated_recovery_days": 1,
            "risk_summary": "N/A",
            "distance_km": 10.0,
        }
    )


@pytest.fixture(autouse=True)
def _no_real_openai(monkeypatch: pytest.MonkeyPatch) -> None:
    @asynccontextmanager
    async def _fake_client(api_key: str):
        yield object()

    monkeypatch.setattr(cli_main, "create_openai_client", _fake_client)
    monkeypatch.setattr(cli_main, "display_progress_bar", lambda description, total: (_FakeProgress(), 1))
    monkeypatch.setenv("OPENAI_API_KEY", "sk-test")


@pytest.mark.asyncio
@pytest.mark.parametrize("scenario", ["scenario1", "scenario2", "scenario3"])
async def test_run_analysis_for_all_scenarios(monkeypatch: pytest.MonkeyPatch, scenario: str) -> None:
    monkeypatch.setattr(cli_main, "AccommodationAgent", _FakeAgent)
    monkeypatch.setattr(cli_main, "display_scenario_header", lambda *args, **kwargs: None)

    iteration_calls: list[int] = []
    final_calls: list[str] = []
    monkeypatch.setattr(cli_main, "display_iteration_results", lambda iteration, decision: iteration_calls.append(iteration))
    monkeypatch.setattr(cli_main, "display_final_recommendation", lambda recommendation: final_calls.append(recommendation.primary_option.summary))
    monkeypatch.setattr(cli_main, "display_success", lambda *args, **kwargs: None)
    monkeypatch.setattr(cli_main, "display_error", lambda *args, **kwargs: None)

    await cli_main.run_accommodation_analysis(
        scenario_name=scenario,
        config_dir=DEFAULT_CONFIG_DIR,
        database_url=DATABASE_URL,
        openai_api_key="sk-test",
    )

    assert iteration_calls, "Expected at least one iteration"
    assert final_calls, "Expected final recommendation call"


@pytest.mark.asyncio
async def test_run_analysis_respects_custom_config(tmp_path: Path, monkeypatch: pytest.MonkeyPatch) -> None:
    config_dir = tmp_path / "config"
    copytree(DEFAULT_CONFIG_DIR, config_dir)

    yaml_path = config_dir / "search_parameters.yaml"
    text = yaml_path.read_text(encoding="utf-8")
    text = text.replace("max_iterations: 3", "max_iterations: 1")
    yaml_path.write_text(text, encoding="utf-8")

    monkeypatch.setattr(cli_main, "AccommodationAgent", _FakeAgent)
    monkeypatch.setattr(cli_main, "display_scenario_header", lambda *args, **kwargs: None)
    monkeypatch.setattr(cli_main, "display_final_recommendation", lambda *args, **kwargs: None)
    monkeypatch.setattr(cli_main, "display_success", lambda *args, **kwargs: None)
    monkeypatch.setattr(cli_main, "display_error", lambda *args, **kwargs: None)

    iterations: list[int] = []
    monkeypatch.setattr(cli_main, "display_iteration_results", lambda iteration, decision: iterations.append(iteration))

    await cli_main.run_accommodation_analysis(
        scenario_name="scenario1",
        config_dir=config_dir,
        database_url=DATABASE_URL,
        openai_api_key="sk-test",
    )

    assert iterations == [1], "Expected single iteration due to max_iterations=1"


def test_main_handles_missing_config(monkeypatch: pytest.MonkeyPatch) -> None:
    monkeypatch.setattr(cli_main, "parse_args", lambda argv=None: cli_main.argparse.Namespace(
        scenario="scenario1",
        config_dir="missing-dir",
        max_iterations=None,
    ))
    monkeypatch.setattr(cli_main, "validate_environment", lambda: ("postgresql://example", "sk-test"))

    errors: list[str] = []
    monkeypatch.setattr(cli_main, "display_error", lambda message: errors.append(message))
    monkeypatch.setattr(cli_main, "display_success", lambda *args, **kwargs: None)

    cli_main.main()

    assert errors and "Configuration directory" in errors[0]


@pytest.mark.asyncio
async def test_run_analysis_ai_failure(monkeypatch: pytest.MonkeyPatch) -> None:
    class FailingAgent:
        def __init__(self, *args, **kwargs) -> None:
            pass

        async def evaluate_iteration(self, *args, **kwargs):
            raise AIIntegrationError("I307: simulated failure")

        async def final_recommendation(self):  # pragma: no cover - never reached
            raise AssertionError("Should not reach final recommendation")

    monkeypatch.setattr(cli_main, "AccommodationAgent", FailingAgent)
    monkeypatch.setattr(cli_main, "display_scenario_header", lambda *args, **kwargs: None)

    errors: list[str] = []
    monkeypatch.setattr(cli_main, "display_error", lambda message: errors.append(message))
    monkeypatch.setattr(cli_main, "display_iteration_results", lambda *args, **kwargs: None)
    monkeypatch.setattr(cli_main, "display_final_recommendation", lambda *args, **kwargs: None)
    monkeypatch.setattr(cli_main, "display_success", lambda *args, **kwargs: None)

    await cli_main.run_accommodation_analysis(
        scenario_name="scenario1",
        config_dir=DEFAULT_CONFIG_DIR,
        database_url=DATABASE_URL,
        openai_api_key="sk-test",
    )

    assert errors and "I307" in errors[0]


@pytest.mark.asyncio
async def test_run_analysis_database_failure(monkeypatch: pytest.MonkeyPatch) -> None:
    async def _load_failed_items(*args, **kwargs):
        raise RuntimeError("database unavailable")

    monkeypatch.setattr(cli_main, "load_search_parameters", lambda *args, **kwargs: {
        "max_iterations": 1,
    })
    monkeypatch.setattr(cli_main, "load_prompt_templates", lambda *args, **kwargs: {
        "scenario1": PromptTemplates(base="b", scenario="s", combined="c"),
    })
    monkeypatch.setattr(cli_main, "load_failed_items", _load_failed_items)

    errors: list[str] = []
    monkeypatch.setattr(cli_main, "display_error", lambda message: errors.append(message))
    monkeypatch.setattr(cli_main, "display_scenario_header", lambda *args, **kwargs: None)

    with pytest.raises(RuntimeError):
        await cli_main.run_accommodation_analysis(
            scenario_name="scenario1",
            config_dir=DEFAULT_CONFIG_DIR,
            database_url=DATABASE_URL,
            openai_api_key="sk-test",
        )

    assert errors == []  # Error propagated; display_error not invoked
