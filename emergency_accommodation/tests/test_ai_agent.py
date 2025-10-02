from __future__ import annotations

import json
import os
from pathlib import Path
from types import SimpleNamespace
from typing import Any

import pytest
from pydantic import BaseModel

from ai_agent import (
    AIIntegrationError,
    AccommodationAgent,
    _FinalRecommendationPayload,
    _IterationDecisionPayload,
    _OptionAssessmentPayload,
    load_prompt_templates,
)
from config import load_search_parameters
from models import FailedItem, InventoryOption


class _RunnerStub:
    def __init__(self, payloads: list[Any]) -> None:
        self.payloads = payloads
        self.calls: list[dict[str, Any]] = []

    async def __call__(self, agent: Any, payload: str, *, run_config: Any) -> Any:
        self.calls.append({"agent": agent, "payload": payload, "run_config": run_config})
        output = self.payloads.pop(0)
        return SimpleNamespace(final_output=output)


def _failed_item() -> FailedItem:
    return FailedItem.from_mapping(
        {
            "scn_id": "6a6c37f8-23dc-4f18-9581-1c31b3dd7b74",
            "line_item_id": "7fbf34d4-64fa-4ec0-9fb8-47d3a9bf5b8a",
            "description": "HVAC compressor",
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


def _iteration_payload() -> _IterationDecisionPayload:
    option = _OptionAssessmentPayload(
        inventory_id="de7cc0d2-bc0f-4e8c-9f03-91f119626b20",
        summary="Allocate Regional Hub compressors",
        impact_level="minor_impact",
        confidence=0.82,
        approvals_required=["manager"],
        trade_offs=["Weekend freight"],
        score=7.4,
    )
    return _IterationDecisionPayload(
        continue_search=False,
        reasoning="Threshold met",
        viable_options=[option],
    )


def _final_payload() -> _FinalRecommendationPayload:
    option = _OptionAssessmentPayload(
        inventory_id="de7cc0d2-bc0f-4e8c-9f03-91f119626b20",
        summary="Allocate Regional Hub compressors",
        impact_level="minor_impact",
        confidence=0.9,
        approvals_required=["manager"],
        trade_offs=["Weekend freight"],
        score=8.1,
    )
    return _FinalRecommendationPayload(
        primary_option=option,
        executive_summary="Deploy Regional Hub stock with limited risk.",
        risk_mitigation=["Coordinate QA resources"],
    )


@pytest.mark.asyncio
async def test_evaluate_iteration_uses_agent(monkeypatch: pytest.MonkeyPatch) -> None:
    runner_stub = _RunnerStub([_iteration_payload()])
    monkeypatch.setattr("ai_agent.Runner.run", runner_stub)

    templates = load_prompt_templates()
    config = load_search_parameters("scenario1")
    agent = AccommodationAgent(config, openai_client=None, prompt_templates=templates)  # type: ignore[arg-type]

    decision = await agent.evaluate_iteration(
        iteration_num=1,
        inventory_batch=[_inventory_option()],
        failed_items=[_failed_item()],
        scenario_name="scenario1",
    )

    assert decision.continue_search is False
    assert decision.viable_options[0].summary.startswith("Allocate")
    assert runner_stub.calls, "expected Runner.run to be invoked"


@pytest.mark.asyncio
async def test_final_recommendation_returns_structured_output(monkeypatch: pytest.MonkeyPatch) -> None:
    runner_stub = _RunnerStub([_iteration_payload(), _final_payload()])
    monkeypatch.setattr("ai_agent.Runner.run", runner_stub)

    templates = load_prompt_templates()
    config = load_search_parameters("scenario1")
    agent = AccommodationAgent(config, openai_client=None, prompt_templates=templates)  # type: ignore[arg-type]

    await agent.evaluate_iteration(
        iteration_num=1,
        inventory_batch=[_inventory_option()],
        failed_items=[_failed_item()],
        scenario_name="scenario1",
    )

    recommendation = await agent.final_recommendation()
    assert recommendation.primary_option.score == pytest.approx(8.1)
    assert recommendation.executive_summary.startswith("Deploy")


@pytest.mark.asyncio
async def test_agent_failure_propagates(monkeypatch: pytest.MonkeyPatch) -> None:
    async def _raise(*args, **kwargs):
        raise RuntimeError("agent failed")

    monkeypatch.setattr("ai_agent.Runner.run", _raise)

    templates = load_prompt_templates()
    config = load_search_parameters("scenario1")
    agent = AccommodationAgent(config, openai_client=None, prompt_templates=templates)  # type: ignore[arg-type]

    with pytest.raises(AIIntegrationError) as exc:
        await agent.evaluate_iteration(
            iteration_num=1,
            inventory_batch=[_inventory_option()],
            failed_items=[_failed_item()],
            scenario_name="scenario1",
        )
    assert exc.value.code == "I307"


@pytest.mark.asyncio
async def test_llm_logging_enabled(monkeypatch: pytest.MonkeyPatch, tmp_path: Path) -> None:
    """Verify log file created and contains expected fields when LOG_LLM_CALLS=true."""
    runner_stub = _RunnerStub([_iteration_payload()])
    monkeypatch.setattr("ai_agent.Runner.run", runner_stub)
    monkeypatch.setenv("LOG_LLM_CALLS", "true")

    # Override log directory to tmp_path
    log_file = tmp_path / "llm_calls.jsonl"
    monkeypatch.setattr("ai_agent.Path", lambda x: tmp_path if x == "logs" else Path(x))

    templates = load_prompt_templates()
    config = load_search_parameters("scenario1")
    agent = AccommodationAgent(config, openai_client=None, prompt_templates=templates)  # type: ignore[arg-type]

    await agent.evaluate_iteration(
        iteration_num=1,
        inventory_batch=[_inventory_option()],
        failed_items=[_failed_item()],
        scenario_name="scenario1",
    )

    # Verify log file exists
    assert log_file.exists(), "Log file should be created when LOG_LLM_CALLS=true"

    # Verify log entry structure
    log_content = log_file.read_text()
    log_entry = json.loads(log_content.strip())

    # Verify required fields from AC-002 and AC-003
    assert "timestamp" in log_entry
    assert "agent" in log_entry
    assert log_entry["agent"] == "Iteration Evaluator"
    assert "model" in log_entry
    assert "request" in log_entry
    assert "instructions" in log_entry["request"]
    assert "payload" in log_entry["request"]
    assert "settings" in log_entry["request"]
    assert "temperature" in log_entry["request"]["settings"]
    assert "max_tokens" in log_entry["request"]["settings"]
    assert "response" in log_entry
    assert "timestamp" in log_entry["response"]
    assert "duration_ms" in log_entry["response"]
    assert "output" in log_entry["response"]
    assert "error" in log_entry["response"]


@pytest.mark.asyncio
async def test_llm_logging_disabled(monkeypatch: pytest.MonkeyPatch, tmp_path: Path) -> None:
    """Verify no log file created when LOG_LLM_CALLS is false or unset."""
    runner_stub = _RunnerStub([_iteration_payload()])
    monkeypatch.setattr("ai_agent.Runner.run", runner_stub)
    monkeypatch.setenv("LOG_LLM_CALLS", "false")

    log_file = tmp_path / "llm_calls.jsonl"
    monkeypatch.setattr("ai_agent.Path", lambda x: tmp_path if x == "logs" else Path(x))

    templates = load_prompt_templates()
    config = load_search_parameters("scenario1")
    agent = AccommodationAgent(config, openai_client=None, prompt_templates=templates)  # type: ignore[arg-type]

    await agent.evaluate_iteration(
        iteration_num=1,
        inventory_batch=[_inventory_option()],
        failed_items=[_failed_item()],
        scenario_name="scenario1",
    )

    # Verify log file was NOT created
    assert not log_file.exists(), "Log file should not be created when LOG_LLM_CALLS=false"


@pytest.mark.asyncio
async def test_llm_logging_failure_does_not_crash(monkeypatch: pytest.MonkeyPatch, tmp_path: Path) -> None:
    """Verify logging failure doesn't crash LLM call - graceful degradation."""
    runner_stub = _RunnerStub([_iteration_payload()])
    monkeypatch.setattr("ai_agent.Runner.run", runner_stub)
    monkeypatch.setenv("LOG_LLM_CALLS", "true")

    # Make log directory read-only to force write failure
    log_dir = tmp_path / "readonly_logs"
    log_dir.mkdir()
    log_dir.chmod(0o444)  # Read-only
    monkeypatch.setattr("ai_agent.Path", lambda x: log_dir if x == "logs" else Path(x))

    templates = load_prompt_templates()
    config = load_search_parameters("scenario1")
    agent = AccommodationAgent(config, openai_client=None, prompt_templates=templates)  # type: ignore[arg-type]

    # Should not raise exception even if logging fails
    decision = await agent.evaluate_iteration(
        iteration_num=1,
        inventory_batch=[_inventory_option()],
        failed_items=[_failed_item()],
        scenario_name="scenario1",
    )

    # Verify LLM call succeeded despite logging failure
    assert decision.continue_search is False
    assert decision.viable_options[0].summary.startswith("Allocate")
    assert runner_stub.calls, "expected Runner.run to be invoked"

    # Cleanup
    log_dir.chmod(0o755)
