from __future__ import annotations

import json
import asyncio
from dataclasses import dataclass
from typing import Any

import pytest

from ai_agent import AIIntegrationError, AccommodationAgent, load_prompt_templates
from config import load_search_parameters
from models import FailedItem, InventoryOption


@dataclass
class _FakeContent:
    text: str


@dataclass
class _FakeSegment:
    content: list[_FakeContent]


@dataclass
class _FakeResponse:
    output_text: str | None = None
    output: list[_FakeSegment] | None = None


class _FakeResponsesClient:
    def __init__(self, payloads: list[str]) -> None:
        self.payloads = payloads
        self.calls: list[dict[str, Any]] = []

    async def create(self, **kwargs: Any) -> _FakeResponse:
        self.calls.append(kwargs)
        payload = self.payloads.pop(0)
        return _FakeResponse(output_text=payload)


class _FakeOpenAIClient:
    def __init__(self, payloads: list[str]) -> None:
        self.responses = _FakeResponsesClient(payloads)


class _SlowResponsesClient(_FakeResponsesClient):
    def __init__(self, delay: float) -> None:
        super().__init__(payloads=[])
        self._delay = delay

    async def create(self, **kwargs: Any) -> _FakeResponse:  # type: ignore[override]
        self.calls.append(kwargs)
        await asyncio.sleep(self._delay)
        return _FakeResponse(output_text=None)


class _SlowOpenAIClient:
    def __init__(self, delay: float) -> None:
        self.responses = _SlowResponsesClient(delay)


def _build_failed_item() -> FailedItem:
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


def _build_inventory_option() -> InventoryOption:
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


@pytest.mark.asyncio
async def test_evaluate_iteration_returns_decision(monkeypatch: pytest.MonkeyPatch) -> None:
    payload = json.dumps(
        {
            "continue_search": True,
            "reasoning": "Collect more options for redundancy.",
            "viable_options": [
                {
                    "inventory_id": "de7cc0d2-bc0f-4e8c-9f03-91f119626b20",
                    "summary": "Allocate compressors from Regional Hub",
                    "impact_level": "minor_impact",
                    "confidence": 0.8,
                    "approvals_required": ["manager"],
                    "trade_offs": ["Overtime crew"],
                    "score": 7.5,
                }
            ],
        }
    )
    fake_client = _FakeOpenAIClient([payload])
    templates = load_prompt_templates()
    config = load_search_parameters("scenario1")

    agent = AccommodationAgent(config, fake_client, templates)

    decision = await agent.evaluate_iteration(
        iteration_num=1,
        inventory_batch=[_build_inventory_option()],
        failed_items=[_build_failed_item()],
        scenario_name="scenario1",
    )

    assert decision.continue_search is True
    assert decision.viable_options[0].summary.startswith("Allocate compressors")
    assert fake_client.responses.calls[0]["model"] == config.get("ai_model", "gpt-4o-mini")


@pytest.mark.asyncio
async def test_final_recommendation_returns_payload() -> None:
    iteration_payload = json.dumps(
        {
            "continue_search": False,
            "reasoning": "Identified sufficient coverage.",
            "viable_options": [
                {
                    "inventory_id": "de7cc0d2-bc0f-4e8c-9f03-91f119626b20",
                    "summary": "Allocate Regional Hub compressors",
                    "impact_level": "minor_impact",
                    "confidence": 0.9,
                    "approvals_required": ["manager"],
                    "trade_offs": ["Weekend freight"],
                    "score": 8.1,
                }
            ],
        }
    )
    final_payload = json.dumps(
        {
            "primary_option": {
                "inventory_id": "de7cc0d2-bc0f-4e8c-9f03-91f119626b20",
                "summary": "Allocate Regional Hub compressors",
                "impact_level": "minor_impact",
                "confidence": 0.92,
                "approvals_required": ["manager"],
                "trade_offs": ["Weekend freight"],
                "score": 8.4,
            },
            "alternatives": [],
            "executive_summary": "Deploy stock from Regional Hub with minimal disruption.",
            "risk_mitigation": ["Notify maintenance for expedited QA"],
        }
    )
    fake_client = _FakeOpenAIClient([iteration_payload, final_payload])
    templates = load_prompt_templates()
    config = load_search_parameters("scenario1")
    agent = AccommodationAgent(config, fake_client, templates)

    await agent.evaluate_iteration(
        iteration_num=1,
        inventory_batch=[_build_inventory_option()],
        failed_items=[_build_failed_item()],
        scenario_name="scenario1",
    )

    recommendation = await agent.final_recommendation()
    assert recommendation.primary_option.score == pytest.approx(8.4)
    assert recommendation.executive_summary.startswith("Deploy stock")


@pytest.mark.asyncio
async def test_invalid_json_raises_error() -> None:
    fake_client = _FakeOpenAIClient(["not-json"])
    templates = load_prompt_templates()
    config = load_search_parameters("scenario1")
    agent = AccommodationAgent(config, fake_client, templates)

    with pytest.raises(AIIntegrationError) as exc:
        await agent.evaluate_iteration(
            iteration_num=1,
            inventory_batch=[_build_inventory_option()],
            failed_items=[_build_failed_item()],
            scenario_name="scenario1",
        )
    assert exc.value.code == "I309"


@pytest.mark.asyncio
async def test_early_stopping_threshold_enforced() -> None:
    payload = json.dumps(
        {
            "continue_search": True,
            "reasoning": "Gather more data.",
            "viable_options": [
                {
                    "inventory_id": "de7cc0d2-bc0f-4e8c-9f03-91f119626b20",
                    "summary": "Allocate compressors",
                    "impact_level": "minor_impact",
                    "confidence": 0.88,
                    "approvals_required": ["manager"],
                    "trade_offs": ["Weekend freight"],
                    "score": 7.8,
                }
            ],
        }
    )
    fake_client = _FakeOpenAIClient([payload])
    templates = load_prompt_templates()
    config = {**load_search_parameters("scenario1"), "early_stopping_threshold": 1}
    agent = AccommodationAgent(config, fake_client, templates)

    decision = await agent.evaluate_iteration(
        iteration_num=1,
        inventory_batch=[_build_inventory_option()],
        failed_items=[_build_failed_item()],
        scenario_name="scenario1",
    )

    assert decision.continue_search is False
    assert "threshold" in decision.reasoning.lower()


@pytest.mark.asyncio
async def test_ai_timeout_triggers_error() -> None:
    slow_client = _SlowOpenAIClient(delay=0.05)
    templates = load_prompt_templates()
    config = {**load_search_parameters("scenario1"), "ai_timeout_seconds": 0.01}
    agent = AccommodationAgent(config, slow_client, templates)

    with pytest.raises(AIIntegrationError) as exc:
        await agent.evaluate_iteration(
            iteration_num=1,
            inventory_batch=[_build_inventory_option()],
            failed_items=[_build_failed_item()],
            scenario_name="scenario1",
        )
    assert exc.value.code == "I313"


def test_load_prompt_templates_discovers_all_scenarios(tmp_path) -> None:
    prompts_dir = tmp_path / "prompts"
    prompts_dir.mkdir()
    (prompts_dir / "base_prompt.txt").write_text("Base instructions", encoding="utf-8")
    (prompts_dir / "scenario_custom.txt").write_text("Custom", encoding="utf-8")

    templates = load_prompt_templates(tmp_path)
    assert "scenario_custom" in templates
    assert templates["scenario_custom"].combined.startswith("Base instructions")
