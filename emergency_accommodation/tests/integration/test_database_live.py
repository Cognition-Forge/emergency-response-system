from __future__ import annotations

import os
import time

import pytest

from config import load_search_parameters
from database import load_failed_items, load_inventory_by_iteration

DATABASE_URL = os.getenv("DATABASE_URL")
if not DATABASE_URL:
    pytest.skip("DATABASE_URL is required for live database integration tests", allow_module_level=True)

SCENARIOS = ("scenario1", "scenario2", "scenario3")


@pytest.mark.asyncio
@pytest.mark.parametrize("scenario", SCENARIOS)
async def test_live_failed_items_have_positive_quantity(scenario: str) -> None:
    items = await load_failed_items(DATABASE_URL, scenario)
    assert items, f"expected failed items for {scenario}"
    for item in items:
        assert item.quantity > 0
        assert item.description


@pytest.mark.asyncio
@pytest.mark.parametrize("scenario", SCENARIOS)
async def test_live_inventory_iterations_respect_batch_size(scenario: str) -> None:
    config = load_search_parameters(scenario)
    config = {**config, "batch_size_per_iteration": 4}

    failed_items = await load_failed_items(DATABASE_URL, scenario)
    assert failed_items

    start = time.perf_counter()
    first_iteration = await load_inventory_by_iteration(
        DATABASE_URL,
        failed_items,
        iteration_num=1,
        config=config,
    )
    duration = time.perf_counter() - start

    assert duration < 2, f"iteration 1 exceeded performance threshold: {duration:.2f}s"
    assert 0 < len(first_iteration) <= config["batch_size_per_iteration"]

    second_iteration = await load_inventory_by_iteration(
        DATABASE_URL,
        failed_items,
        iteration_num=2,
        config=config,
    )
    assert len(second_iteration) <= config["batch_size_per_iteration"]
    if len(first_iteration) > 1 and len(second_iteration) > 1:
        assert [opt.inventory_id for opt in first_iteration] != [
            opt.inventory_id for opt in second_iteration
        ]


@pytest.mark.asyncio
async def test_live_distance_strategy_widens_per_iteration() -> None:
    config = load_search_parameters("scenario3")
    config = {
        **config,
        "batch_size_per_iteration": 5,
        "time_window_type": "distance_based",
        "search_order": "proximity_first",
    }

    failed_items = await load_failed_items(DATABASE_URL, "scenario3")
    assert failed_items

    first_iter = await load_inventory_by_iteration(
        DATABASE_URL,
        failed_items,
        iteration_num=1,
        config=config,
    )
    assert first_iter
    max_distance_first = max((opt.distance_km or 0) for opt in first_iter)

    second_iter = await load_inventory_by_iteration(
        DATABASE_URL,
        failed_items,
        iteration_num=2,
        config=config,
    )
    if not second_iter:
        pytest.skip("scenario3 only exposes one viable inventory option in iteration 1")

    max_distance_second = max((opt.distance_km or 0) for opt in second_iter)

    assert max_distance_second >= max_distance_first
