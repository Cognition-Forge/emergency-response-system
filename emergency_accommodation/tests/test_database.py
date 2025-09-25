from __future__ import annotations

from datetime import date
from decimal import Decimal
from typing import Any
from uuid import UUID

import pytest

from database import (
    load_failed_items,
    load_inventory_by_iteration,
)
from models import FailedItem


class FakeConnection:
    def __init__(self, record_groups: list[list[dict[str, Any]]]) -> None:
        self._records = record_groups
        self._calls: list[tuple[str, tuple[Any, ...]]] = []
        self._idx = 0
        self.closed = False

    async def fetch(self, query: str, *params: Any) -> list[dict[str, Any]]:
        self._calls.append((query, params))
        if not self._records:
            return []
        index = min(self._idx, len(self._records) - 1)
        self._idx += 1
        return self._records[index]

    async def close(self) -> None:
        self.closed = True


@pytest.mark.asyncio
async def test_load_failed_items_returns_models(monkeypatch: pytest.MonkeyPatch) -> None:
    scn_id = UUID("6a6c37f8-23dc-4f18-9581-1c31b3dd7b74")
    line_id = UUID("7fbf34d4-64fa-4ec0-9fb8-47d3a9bf5b8a")
    records = [
        {
            "scn_id": scn_id,
            "line_item_id": line_id,
            "description": "HVAC compressor failure",
            "quantity": Decimal("4"),
            "unit_of_measure": "EA",
            "priority": "critical",
            "ros_date": date(2024, 5, 1),
            "commodity_code": "HVAC-001",
            "equipment_tag": "HVAC-CMP-01",
        }
    ]

    async def fake_connect(url: str) -> FakeConnection:  # type: ignore[override]
        return FakeConnection([records])

    monkeypatch.setattr("asyncpg.connect", fake_connect)

    result = await load_failed_items("postgres://example", "scenario1")
    assert len(result) == 1
    assert result[0].line_item_id == line_id
    assert result[0].priority == "critical"


@pytest.mark.asyncio
async def test_load_failed_items_unknown_scenario() -> None:
    with pytest.raises(ValueError):
        await load_failed_items("postgres://example", "unknown")


def _build_failed_item() -> FailedItem:
    payload = {
        "scn_id": "6a6c37f8-23dc-4f18-9581-1c31b3dd7b74",
        "line_item_id": "7fbf34d4-64fa-4ec0-9fb8-47d3a9bf5b8a",
        "description": "HVAC compressor failure",
        "quantity": "4",
        "unit_of_measure": "EA",
        "priority": "critical",
        "ros_date": "2024-05-01",
        "commodity_code": "HVAC-001",
        "equipment_tag": "HVAC-CMP-01",
    }
    return FailedItem.from_mapping(payload)


def _option_dict(
    *,
    inventory_id: str,
    availability_score: int,
    urgency_score: int,
    distance_km: float | None,
    estimated_recovery_days: int,
    max_priority: int,
) -> dict[str, Any]:
    return {
        "inventory_id": UUID(inventory_id),
        "warehouse_id": UUID("df49f38a-a9a6-4674-b033-71da49cfaff0"),
        "warehouse_name": "Regional Hub",
        "material_description": "HVAC compressor",
        "available_quantity": Decimal("10"),
        "reserved_quantity": Decimal("2"),
        "soft_available_quantity": Decimal("8"),
        "hard_available_quantity": Decimal("6"),
        "approval_requirement": "manager",
        "impact_level": "minor_impact",
        "estimated_recovery_days": estimated_recovery_days,
        "risk_summary": "Next required: 2024-05-20 | Priority: 70",
        "distance_km": distance_km,
        "max_priority": max_priority,
        "next_required_by": date(2024, 5, 20),
        "compatibility_score": 96,
        "urgency_score": urgency_score,
        "availability_score": availability_score,
        "availability_status": "free",
    }


@pytest.mark.asyncio
async def test_load_inventory_by_iteration_time_window_filters(monkeypatch: pytest.MonkeyPatch) -> None:
    records = [
        _option_dict(
            inventory_id="de7cc0d2-bc0f-4e8c-9f03-91f119626b20",
            availability_score=92,
            urgency_score=88,
            distance_km=120.0,
            estimated_recovery_days=5,
            max_priority=70,
        ),
        _option_dict(
            inventory_id="1b10928a-2f66-4f9d-9ea5-00b357f0e6aa",
            availability_score=85,
            urgency_score=70,
            distance_km=150.0,
            estimated_recovery_days=12,
            max_priority=60,
        ),
    ]

    async def fake_connect(url: str) -> FakeConnection:  # type: ignore[override]
        return FakeConnection([records])

    monkeypatch.setattr("asyncpg.connect", fake_connect)

    config = {
        "time_window_type": "weekly",
        "batch_size_per_iteration": 5,
        "search_order": "urgency_first",
    }

    options = await load_inventory_by_iteration(
        "postgres://example",
        [_build_failed_item()],
        iteration_num=1,
        config=config,
    )

    assert len(options) == 1
    assert options[0].warehouse_name == "Regional Hub"


@pytest.mark.asyncio
async def test_load_inventory_by_iteration_priority_filters(monkeypatch: pytest.MonkeyPatch) -> None:
    records = [
        _option_dict(
            inventory_id="de7cc0d2-bc0f-4e8c-9f03-91f119626b20",
            availability_score=90,
            urgency_score=80,
            distance_km=110.0,
            estimated_recovery_days=6,
            max_priority=55,
        ),
        _option_dict(
            inventory_id="1b10928a-2f66-4f9d-9ea5-00b357f0e6aa",
            availability_score=88,
            urgency_score=78,
            distance_km=140.0,
            estimated_recovery_days=6,
            max_priority=90,
        ),
    ]

    async def fake_connect(url: str) -> FakeConnection:  # type: ignore[override]
        return FakeConnection([records])

    monkeypatch.setattr("asyncpg.connect", fake_connect)

    config = {
        "time_window_type": "priority_based",
        "batch_size_per_iteration": 5,
        "search_order": "availability_first",
    }

    options = await load_inventory_by_iteration(
        "postgres://example",
        [_build_failed_item()],
        iteration_num=1,
        config=config,
    )

    assert len(options) == 1
    assert options[0].warehouse_name == "Regional Hub"
    assert options[0].impact_level == "minor_impact"


@pytest.mark.asyncio
async def test_load_inventory_by_iteration_distance_filters(monkeypatch: pytest.MonkeyPatch) -> None:
    records = [
        _option_dict(
            inventory_id="de7cc0d2-bc0f-4e8c-9f03-91f119626b20",
            availability_score=90,
            urgency_score=80,
            distance_km=180.0,
            estimated_recovery_days=6,
            max_priority=70,
        ),
        _option_dict(
            inventory_id="1b10928a-2f66-4f9d-9ea5-00b357f0e6aa",
            availability_score=88,
            urgency_score=78,
            distance_km=420.0,
            estimated_recovery_days=6,
            max_priority=70,
        ),
    ]

    async def fake_connect(url: str) -> FakeConnection:  # type: ignore[override]
        return FakeConnection([records])

    monkeypatch.setattr("asyncpg.connect", fake_connect)

    config = {
        "time_window_type": "distance_based",
        "batch_size_per_iteration": 5,
        "search_order": "proximity_first",
    }

    options = await load_inventory_by_iteration(
        "postgres://example",
        [_build_failed_item()],
        iteration_num=1,
        config=config,
    )

    assert len(options) == 1
    assert options[0].warehouse_name == "Regional Hub"
    assert options[0].distance_km == pytest.approx(180.0)

