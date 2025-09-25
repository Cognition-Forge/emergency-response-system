from __future__ import annotations

from datetime import date
from decimal import Decimal
from uuid import UUID

import pytest

from models import (
    FailedItem,
    FinalRecommendation,
    InventoryOption,
    IterationDecision,
    ModelValidationError,
    OptionAssessment,
    serialize_option_sequence,
)


def build_failed_item_payload() -> dict[str, object]:
    return {
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


def build_inventory_option_payload() -> dict[str, object]:
    return {
        "inventory_id": "de7cc0d2-bc0f-4e8c-9f03-91f119626b20",
        "warehouse_id": "df49f38a-a9a6-4674-b033-71da49cfaff0",
        "warehouse_name": "Houston Regional DC",
        "material_description": "HVAC compressor",
        "available_quantity": "10",
        "reserved_quantity": "2",
        "soft_available_quantity": "5",
        "hard_available_quantity": "3",
        "distance_km": 45.2,
        "approval_requirement": "manager",
        "impact_level": "minor_impact",
        "estimated_recovery_days": 5,
        "risk_summary": "Minimal schedule risk with overtime crew",
    }


def build_option_assessment_payload() -> dict[str, object]:
    return {
        "inventory_id": "de7cc0d2-bc0f-4e8c-9f03-91f119626b20",
        "summary": "Allocate Houston stock with expedited freight",
        "impact_level": "minor_impact",
        "confidence": 0.82,
        "approvals_required": ["manager"],
        "trade_offs": ["Overtime labor", "Temporary efficiency drop"],
        "score": 7.4,
    }


def test_failed_item_from_mapping_success() -> None:
    failed_item = FailedItem.from_mapping(build_failed_item_payload())

    assert failed_item.scn_id == UUID("6a6c37f8-23dc-4f18-9581-1c31b3dd7b74")
    assert failed_item.quantity == Decimal("4")
    assert failed_item.ros_date == date(2024, 5, 1)
    assert failed_item.to_dict()["quantity"] == "4"


def test_failed_item_negative_quantity_raises() -> None:
    payload = build_failed_item_payload()
    payload["quantity"] = "-1"

    with pytest.raises(ModelValidationError) as exc:
        FailedItem.from_mapping(payload)

    assert exc.value.details[0]["loc"][-1] == "quantity"


def test_inventory_option_serialization_roundtrip() -> None:
    option = InventoryOption.from_mapping(build_inventory_option_payload())
    serialized = option.to_dict()

    assert serialized["available_quantity"] == "10"
    assert serialized["distance_km"] == 45.2

    restored = InventoryOption.from_mapping(serialized)
    assert restored.inventory_id == option.inventory_id


def test_iteration_decision_from_mapping() -> None:
    payload = {
        "continue_search": True,
        "reasoning": "Need additional options before locking",
        "viable_options": [build_option_assessment_payload()],
        "discarded_reasons": ["Insufficient quantity"],
    }

    decision = IterationDecision.from_mapping(payload)

    assert decision.continue_search is True
    assert decision.viable_options[0].confidence == pytest.approx(0.82)
    assert decision.to_dict()["viable_options"][0]["approvals_required"] == ["manager"]


def test_final_recommendation_from_mapping() -> None:
    payload = {
        "primary_option": build_option_assessment_payload(),
        "alternatives": [
            {
                "inventory_id": "5668af37-4d59-44f9-a7bd-6ddee98b41bc",
                "summary": "Broker supplier with split shipment",
                "impact_level": "moderate_impact",
                "confidence": 0.65,
                "approvals_required": ["executive"],
                "trade_offs": ["Premium freight"],
                "score": 6.1,
            }
        ],
        "executive_summary": "Allocate Houston stock while preparing contingency",
        "risk_mitigation": ["Secure bilingual coordinators", "Pre-stage QA resources"],
    }

    recommendation = FinalRecommendation.from_mapping(payload)

    assert recommendation.primary_option.summary.startswith("Allocate Houston")
    assert len(recommendation.alternatives) == 1
    assert recommendation.to_dict()["risk_mitigation"] == payload["risk_mitigation"]


def test_option_assessment_validation_error() -> None:
    payload = build_option_assessment_payload()
    payload["confidence"] = 1.5

    with pytest.raises(ModelValidationError):
        OptionAssessment.from_mapping(payload)


def test_serialize_option_sequence() -> None:
    option = InventoryOption.from_mapping(build_inventory_option_payload())
    result = serialize_option_sequence([option])
    assert result == [option.to_dict()]

