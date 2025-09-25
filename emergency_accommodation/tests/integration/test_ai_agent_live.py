from __future__ import annotations

import json
from dataclasses import dataclass
from typing import Any

import pytest

from ai_agent import AccommodationAgent, load_prompt_templates
from config import load_search_parameters
from database import load_failed_items, load_inventory_by_iteration

DATABASE_URL = __import__("os").getenv("DATABASE_URL")
if not DATABASE_URL:
    pytest.skip("DATABASE_URL is required for live AI agent integration tests", allow_module_level=True)


@dataclass
class _FakeContent:
    text: str


@dataclass
class _FakeSegment:
    content: list[_FakeContent]


@dataclass
class _FakeResponse:
    output_text: str | None = None


class _FakeResponsesClient:
    def __init__(self, payloads: list[str]) -> None:
        self.payloads = payloads
        self.calls: list[dict[str, Any]] = []

    async def create(self, **kwargs: Any) -> _FakeResponse:
        self.calls.append(kwargs)
        payload = self.payloads.pop(0)
        return _FakeResponse(output_text=payload)


class _FakeOpenAI:
    def __init__(self, payloads: list[str]) -> None:
        self.responses = _FakeResponsesClient(payloads)


@pytest.mark.asyncio
async def test_live_agent_iteration_with_database() -> None:
    config = load_search_parameters("scenario1")
    prompts = load_prompt_templates()

    failed_items = await load_failed_items(DATABASE_URL, "scenario1")
    inventory = await load_inventory_by_iteration(
        DATABASE_URL,
        failed_items,
        iteration_num=1,
        config=config,
    )

    assert inventory, "expected live inventory options"

    iteration_payload = json.dumps(
        {
            "continue_search": False,
            "reasoning": "Sufficient coverage with Regional Hub stock.",
            "viable_options": [
                {
                    "inventory_id": str(inventory[0].inventory_id),
                    "summary": "Allocate stock from Regional Hub",
                    "impact_level": inventory[0].impact_level,
                    "confidence": 0.9,
                    "approvals_required": [inventory[0].approval_requirement],
                    "trade_offs": ["Weekend freight"],
                    "score": 8.0,
                }
            ],
        }
    )
    final_payload = json.dumps(
        {
            "primary_option": {
                "inventory_id": str(inventory[0].inventory_id),
                "summary": "Allocate stock from Regional Hub",
                "impact_level": inventory[0].impact_level,
                "confidence": 0.92,
                "approvals_required": [inventory[0].approval_requirement],
                "trade_offs": ["Weekend freight"],
                "score": 8.5,
            },
            "alternatives": [],
            "executive_summary": "Deploy Regional Hub stock with expedited freight.",
            "risk_mitigation": ["Coordinate QA resources"],
        }
    )

    agent = AccommodationAgent(config, _FakeOpenAI([iteration_payload, final_payload]), prompts)

    decision = await agent.evaluate_iteration(
        iteration_num=1,
        inventory_batch=inventory,
        failed_items=failed_items,
        scenario_name="scenario1",
    )
    assert decision.continue_search is False
    assert decision.viable_options[0].score == pytest.approx(8.0)

    recommendation = await agent.final_recommendation()
    assert recommendation.primary_option.score == pytest.approx(8.5)
    assert recommendation.executive_summary.startswith("Deploy Regional Hub")

