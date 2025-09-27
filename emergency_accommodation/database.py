"""Direct async database access helpers for the emergency accommodation system."""

from __future__ import annotations

from typing import Any, Mapping, Sequence
from uuid import UUID

import asyncpg  # type: ignore[import-untyped]

from models import FailedItem, InventoryOption

# Scenario metadata used to locate project records deterministically created by seeding scripts.
_SCENARIO_METADATA: dict[str, dict[str, str]] = {
    "scenario1": {"project_name": "Scenario 1 - Coastal Relief"},
    "scenario2": {"project_name": "Scenario 2 - Regional Reassignment"},
    "scenario3": {"project_name": "Scenario 3 - Metropolitan Critical"},
    "scenario1-enhanced": {"project_name": "Enhanced Scenario 1 - Hurricane Evacuation Response"},
    "scenario2-enhanced": {"project_name": "Enhanced Scenario 2 - Regional Multi-Hazard Response"},
    "scenario3-enhanced": {"project_name": "Enhanced Scenario 3 - Metropolitan Infrastructure Collapse"},
}

_FAILED_ITEMS_QUERY = """
SELECT DISTINCT ON (pli.id)
    sli.scn_id AS scn_id,
    pli.id AS line_item_id,
    pli.description,
    CASE
        WHEN pli.quantity_ordered - pli.quantity_received > 0
            THEN pli.quantity_ordered - pli.quantity_received
        ELSE pli.quantity_ordered
    END::numeric(18,4) AS quantity,
    COALESCE(uom.abbreviation, 'EA') AS unit_of_measure,
    CASE
        WHEN ros.ros_date IS NULL THEN 'standard'
        WHEN ros.ros_date <= CURRENT_DATE + INTERVAL '7 days' THEN 'critical'
        WHEN ros.ros_date <= CURRENT_DATE + INTERVAL '21 days' THEN 'high'
        ELSE 'routine'
    END AS priority,
    ros.ros_date,
    cc.engineered_code AS commodity_code,
    eq.engineered_tag AS equipment_tag
FROM po_line_items pli
JOIN purchase_orders po ON po.id = pli.po_id
JOIN projects p ON p.id = po.project_id
JOIN scn_line_items sli ON sli.po_line_item_id = pli.id
LEFT JOIN emergency_incidents ei
    ON ei.project_id = p.id
   AND (ei.scn_id IS NULL OR ei.scn_id = sli.scn_id)
LEFT JOIN commodity_codes cc ON cc.id = pli.commodity_code_id
LEFT JOIN equipment_list eq ON eq.id = pli.equipment_id
LEFT JOIN units_of_measure uom ON uom.id = COALESCE(cc.unit_of_measure_id, eq.unit_of_measure_id)
LEFT JOIN wbs_ros_dates ros ON ros.wbs_id = pli.wbs_id
WHERE p.name = $1
  AND ei.id IS NOT NULL
ORDER BY pli.id, ros.ros_date DESC NULLS LAST;
"""

_DISTANCE_SQL = """
CASE
    WHEN tgt.latitude IS NULL OR tgt.longitude IS NULL OR w.latitude IS NULL OR w.longitude IS NULL THEN NULL
    ELSE 6371.0 * ACOS(
        GREATEST(-1.0, LEAST(
            1.0,
            SIN(RADIANS(tgt.latitude)) * SIN(RADIANS(w.latitude)) +
            COS(RADIANS(tgt.latitude)) * COS(RADIANS(w.latitude)) *
            COS(RADIANS(w.longitude - tgt.longitude))
        ))
    )
END
"""

_BASE_INVENTORY_QUERY_TEMPLATE = """
WITH base AS (
    SELECT
        search.inventory_id,
        wi.warehouse_id,
        w.name AS warehouse_name,
        COALESCE(cc.short_description, eq.description, 'Unspecified inventory') AS material_description,
        search.quantity_available AS available_quantity,
        wi.quantity_reserved AS reserved_quantity,
        search.soft_available_qty AS soft_available_quantity,
        search.hard_available_qty AS hard_available_quantity,
        CASE
            WHEN search.availability_status = 'blocked' THEN 'executive'
            WHEN search.availability_status = 'emergency_only' THEN 'manager'
            WHEN search.availability_status = 'reassignable' THEN 'supervisor'
            ELSE 'none'
        END AS approval_requirement,
        search.impact_level,
        GREATEST(
            0,
            COALESCE(
                (res.next_required_by - CURRENT_DATE),
                (ros.ros_date - CURRENT_DATE),
                CASE WHEN search.impact_level = 'critical_decision' THEN 1 ELSE 3 END
            )
        )::int AS estimated_recovery_days,
        COALESCE(
            FORMAT(
                'Next required: %s | Priority: %s',
                to_char(res.next_required_by, 'YYYY-MM-DD'),
                COALESCE(res.max_priority::text, 'none')
            ),
            'No downstream reservations'
        ) AS risk_summary,
        {_distance_sql}::double precision AS distance_km,
        res.max_priority,
        res.next_required_by,
        search.compatibility_score,
        search.urgency_score,
        search.availability_score,
        search.availability_status
    FROM fn_emergency_inventory_search($1::uuid, $2::int) AS search
    JOIN warehouse_inventory wi ON wi.id = search.inventory_id
    JOIN warehouses w ON w.id = wi.warehouse_id
    LEFT JOIN commodity_codes cc ON cc.id = wi.commodity_code_id
    LEFT JOIN equipment_list eq ON eq.id = wi.equipment_id
    LEFT JOIN LATERAL (
        SELECT
            MIN(required_by_date) AS next_required_by,
            MAX(priority_level) AS max_priority
        FROM inventory_reservations ir
        WHERE ir.inventory_id = wi.id
    ) res ON TRUE
    LEFT JOIN wbs_ros_dates ros ON ros.wbs_id = wi.wbs_id
    LEFT JOIN scns scn ON scn.id = $3::uuid
    LEFT JOIN warehouses tgt ON tgt.id = scn.delivery_warehouse_id
    WHERE wi.quantity_available > 0
)
SELECT *
FROM base
ORDER BY {order_clause}
OFFSET $4
LIMIT $5;
"""

_ORDER_BY_MAP = {
    "availability_first": "availability_score DESC, compatibility_score DESC, urgency_score DESC",
    "proximity_first": "distance_km ASC NULLS LAST, compatibility_score DESC, availability_score DESC",
    "urgency_first": "urgency_score DESC, compatibility_score DESC, availability_score DESC",
}


async def load_failed_items(connection_url: str, scenario_name: str) -> list[FailedItem]:
    """Load failed SCN line items related to emergency incidents for the scenario."""
    metadata = _SCENARIO_METADATA.get(scenario_name)
    if metadata is None:
        raise ValueError(f"Unknown scenario '{scenario_name}'")

    connection = await asyncpg.connect(connection_url)
    try:
        records = await connection.fetch(_FAILED_ITEMS_QUERY, metadata["project_name"])
    finally:
        await connection.close()

    failed_items: list[FailedItem] = []
    for record in records:
        payload = dict(record)
        failed_items.append(FailedItem.from_mapping(payload))
    return failed_items


async def load_inventory_by_iteration(
    connection_url: str,
    failed_items: Sequence[FailedItem],
    iteration_num: int,
    config: Mapping[str, Any],
) -> list[InventoryOption]:
    """Load inventory options incrementally using the configured strategy."""
    if not failed_items:
        return []

    scenario_order = config.get("search_order", "urgency_first")
    batch_size = int(config.get("batch_size_per_iteration", 10))
    iteration = max(1, iteration_num)
    time_window_type = config.get("time_window_type", "weekly")

    connection = await asyncpg.connect(connection_url)
    try:
        if time_window_type in {"weekly", "monthly"}:
            option_dicts = await load_by_time_window(
                connection,
                failed_items,
                iteration,
                time_window_type,
                batch_size,
                scenario_order,
            )
        elif time_window_type == "priority_based":
            option_dicts = await load_by_priority_level(
                connection,
                failed_items,
                iteration,
                batch_size,
                scenario_order,
            )
        elif time_window_type == "distance_based":
            option_dicts = await load_by_distance_band(
                connection,
                failed_items,
                iteration,
                batch_size,
                scenario_order,
            )
        else:
            option_dicts = await _baseline_inventory_load(
                connection,
                failed_items,
                iteration,
                batch_size,
                scenario_order,
            )
    finally:
        await connection.close()

    return [_to_inventory_option(option) for option in option_dicts]


async def load_by_time_window(
    connection: asyncpg.Connection,
    items: Sequence[FailedItem],
    iteration: int,
    window_type: str,
    batch_size: int,
    search_order: str,
) -> list[dict[str, Any]]:
    """Filter inventory options by time horizon windows."""
    window_map = {"weekly": 7, "monthly": 30}
    window_days = window_map.get(window_type)
    if window_days is None:
        raise ValueError(f"Unsupported time window type '{window_type}'")

    raw = await _gather_candidate_dicts(connection, items, iteration, batch_size, search_order)
    if not raw:
        return []

    threshold = window_days * iteration
    filtered = [opt for opt in raw if opt["estimated_recovery_days"] <= threshold]
    if not filtered:
        filtered = raw

    ordered = _sort_option_dicts(filtered, search_order)
    return _deduplicate_and_limit(ordered, batch_size)


async def load_by_priority_level(
    connection: asyncpg.Connection,
    items: Sequence[FailedItem],
    iteration: int,
    batch_size: int,
    search_order: str,
) -> list[dict[str, Any]]:
    """Filter candidate inventory using reservation priority thresholds."""
    thresholds = [80, 60, 0]
    min_priority = thresholds[min(iteration - 1, len(thresholds) - 1)]

    raw = await _gather_candidate_dicts(connection, items, iteration, batch_size, search_order)
    if not raw:
        return []

    filtered = [opt for opt in raw if (opt.get("max_priority") or 0) >= min_priority]
    if not filtered:
        filtered = raw

    ordered = _sort_option_dicts(filtered, search_order)
    return _deduplicate_and_limit(ordered, batch_size)


async def load_by_distance_band(
    connection: asyncpg.Connection,
    items: Sequence[FailedItem],
    iteration: int,
    batch_size: int,
    search_order: str,
) -> list[dict[str, Any]]:
    """Filter inventory options based on distance bands that widen per iteration."""
    bands = [250.0, 750.0, None]
    limit_km = bands[min(iteration - 1, len(bands) - 1)]

    raw = await _gather_candidate_dicts(connection, items, iteration, batch_size, search_order)
    if not raw:
        return []

    if limit_km is not None:
        filtered = [
            opt
            for opt in raw
            if opt["distance_km"] is None or opt["distance_km"] <= limit_km
        ]
        if not filtered:
            filtered = raw
    else:
        filtered = raw

    ordered = _sort_option_dicts(filtered, search_order)
    return _deduplicate_and_limit(ordered, batch_size)


async def _baseline_inventory_load(
    connection: asyncpg.Connection,
    items: Sequence[FailedItem],
    iteration: int,
    batch_size: int,
    search_order: str,
) -> list[dict[str, Any]]:
    raw = await _gather_candidate_dicts(connection, items, iteration, batch_size, search_order)
    if not raw:
        return []
    ordered = _sort_option_dicts(raw, search_order)
    return _deduplicate_and_limit(ordered, batch_size)


async def _gather_candidate_dicts(
    connection: asyncpg.Connection,
    items: Sequence[FailedItem],
    iteration: int,
    batch_size: int,
    search_order: str,
) -> list[dict[str, Any]]:
    fetch_limit = batch_size * max(1, iteration) * 2
    offset = max(0, (iteration - 1) * batch_size)
    candidate: list[dict[str, Any]] = []

    for item in items:
        rows = await _fetch_inventory_for_item(
            connection,
            item,
            fetch_limit=fetch_limit,
            offset=offset,
            window=fetch_limit,
            search_order=search_order,
        )
        candidate.extend(rows)
    return candidate


async def _fetch_inventory_for_item(
    connection: asyncpg.Connection,
    item: FailedItem,
    *,
    fetch_limit: int,
    offset: int,
    window: int,
    search_order: str,
) -> list[dict[str, Any]]:
    order_sql = _ORDER_BY_MAP.get(search_order, _ORDER_BY_MAP["urgency_first"])
    query = _BASE_INVENTORY_QUERY_TEMPLATE.format(
        _distance_sql=_DISTANCE_SQL,
        order_clause=order_sql,
    )

    scn_id = item.scn_id
    params = (
        item.line_item_id,
        fetch_limit,
        scn_id,
        offset,
        window,
    )

    records = await connection.fetch(query, *params)
    return [dict(record) for record in records]


def _sort_option_dicts(options: Sequence[dict[str, Any]], search_order: str) -> list[dict[str, Any]]:
    if search_order == "availability_first":
        key_func = lambda opt: (
            -opt["availability_score"],
            -opt["compatibility_score"],
            opt["distance_km"] if opt["distance_km"] is not None else float("inf"),
        )
    elif search_order == "proximity_first":
        key_func = lambda opt: (
            opt["distance_km"] if opt["distance_km"] is not None else float("inf"),
            -opt["compatibility_score"],
            -opt["availability_score"],
        )
    else:
        key_func = lambda opt: (
            -opt["urgency_score"],
            -opt["compatibility_score"],
            -opt["availability_score"],
        )
    return sorted(options, key=key_func)


def _deduplicate_and_limit(options: Sequence[dict[str, Any]], batch_size: int) -> list[dict[str, Any]]:
    seen: set[UUID] = set()
    limited: list[dict[str, Any]] = []
    for option in options:
        inventory_id = option["inventory_id"]
        if inventory_id not in seen:
            seen.add(inventory_id)
            limited.append(option)
        if len(limited) >= batch_size:
            break
    return limited


def _to_inventory_option(payload: dict[str, Any]) -> InventoryOption:
    data = {
        "inventory_id": payload["inventory_id"],
        "warehouse_id": payload["warehouse_id"],
        "warehouse_name": payload["warehouse_name"],
        "material_description": payload["material_description"],
        "available_quantity": payload["available_quantity"],
        "reserved_quantity": payload["reserved_quantity"],
        "soft_available_quantity": payload["soft_available_quantity"],
        "hard_available_quantity": payload["hard_available_quantity"],
        "approval_requirement": payload["approval_requirement"],
        "impact_level": payload["impact_level"],
        "estimated_recovery_days": payload["estimated_recovery_days"],
        "risk_summary": payload["risk_summary"],
        "distance_km": payload["distance_km"],
    }
    return InventoryOption.from_mapping(data)


__all__ = [
    "load_failed_items",
    "load_inventory_by_iteration",
    "load_by_time_window",
    "load_by_priority_level",
    "load_by_distance_band",
]
