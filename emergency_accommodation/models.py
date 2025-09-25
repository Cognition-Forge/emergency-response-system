"""Domain models and AI response parsing helpers for the emergency accommodation CLI."""

from __future__ import annotations

from dataclasses import dataclass
from datetime import date
from decimal import Decimal
from typing import Any, Mapping, Sequence
from uuid import UUID

from pydantic import BaseModel, ConfigDict, Field, ValidationError

__all__ = [
    "FailedItem",
    "InventoryOption",
    "OptionAssessment",
    "IterationDecision",
    "FinalRecommendation",
    "ModelValidationError",
    "serialize_option_sequence",
]


class ModelValidationError(ValueError):
    """Raised when converting raw payloads into validated domain models."""

    def __init__(self, message: str, *, cause: ValidationError) -> None:
        super().__init__(message)
        self.__cause__ = cause
        self.details = cause.errors()


class _FailedItemSchema(BaseModel):
    model_config = ConfigDict(frozen=True, populate_by_name=True)

    scn_id: UUID
    line_item_id: UUID
    description: str = Field(min_length=1)
    quantity: Decimal = Field(gt=Decimal("0"))
    unit_of_measure: str = Field(min_length=1)
    ros_date: date | None = None
    priority: str = Field(min_length=1)
    commodity_code: str | None = None
    equipment_tag: str | None = None


class _InventoryOptionSchema(BaseModel):
    model_config = ConfigDict(frozen=True, populate_by_name=True)

    inventory_id: UUID
    warehouse_id: UUID
    warehouse_name: str = Field(min_length=1)
    material_description: str = Field(min_length=1)
    available_quantity: Decimal = Field(ge=Decimal("0"))
    reserved_quantity: Decimal = Field(ge=Decimal("0"))
    soft_available_quantity: Decimal = Field(ge=Decimal("0"))
    hard_available_quantity: Decimal = Field(ge=Decimal("0"))
    distance_km: float | None = Field(default=None, ge=0)
    approval_requirement: str = Field(min_length=1)
    impact_level: str = Field(min_length=1)
    estimated_recovery_days: int = Field(ge=0)
    risk_summary: str = Field(min_length=1)


class _OptionAssessmentSchema(BaseModel):
    model_config = ConfigDict(frozen=True)

    inventory_id: UUID
    summary: str = Field(min_length=1)
    impact_level: str = Field(min_length=1)
    confidence: float = Field(ge=0.0, le=1.0)
    approvals_required: tuple[str, ...] = Field(default_factory=tuple)
    trade_offs: tuple[str, ...] = Field(default_factory=tuple)
    score: float = Field(ge=0.0)


class _IterationDecisionSchema(BaseModel):
    model_config = ConfigDict(frozen=True)

    continue_search: bool
    reasoning: str = Field(min_length=1)
    viable_options: tuple[_OptionAssessmentSchema, ...]
    discarded_reasons: tuple[str, ...] = Field(default_factory=tuple)


class _FinalRecommendationSchema(BaseModel):
    model_config = ConfigDict(frozen=True)

    primary_option: _OptionAssessmentSchema
    alternatives: tuple[_OptionAssessmentSchema, ...] = Field(default_factory=tuple)
    executive_summary: str = Field(min_length=1)
    risk_mitigation: tuple[str, ...] = Field(default_factory=tuple)


@dataclass(frozen=True, slots=True)
class FailedItem:
    """Represents a failed SCN line item requiring accommodation."""

    scn_id: UUID
    line_item_id: UUID
    description: str
    quantity: Decimal
    unit_of_measure: str
    priority: str
    ros_date: date | None = None
    commodity_code: str | None = None
    equipment_tag: str | None = None

    @classmethod
    def from_mapping(cls, payload: Mapping[str, Any]) -> FailedItem:
        """Validate and create a failed item from raw mapping data."""
        try:
            data = _FailedItemSchema.model_validate(payload).model_dump()
        except ValidationError as exc:  # pragma: no cover - exercised via tests
            raise ModelValidationError("Invalid failed item payload", cause=exc) from exc
        return cls(**data)

    def to_dict(self) -> dict[str, Any]:
        """Serialize the failed item to a JSON-safe dictionary."""
        return {
            "scn_id": str(self.scn_id),
            "line_item_id": str(self.line_item_id),
            "description": self.description,
            "quantity": str(self.quantity),
            "unit_of_measure": self.unit_of_measure,
            "priority": self.priority,
            "ros_date": self.ros_date.isoformat() if self.ros_date else None,
            "commodity_code": self.commodity_code,
            "equipment_tag": self.equipment_tag,
        }


@dataclass(frozen=True, slots=True)
class InventoryOption:
    """Represents an available inventory record usable for accommodation."""

    inventory_id: UUID
    warehouse_id: UUID
    warehouse_name: str
    material_description: str
    available_quantity: Decimal
    reserved_quantity: Decimal
    soft_available_quantity: Decimal
    hard_available_quantity: Decimal
    approval_requirement: str
    impact_level: str
    estimated_recovery_days: int
    risk_summary: str
    distance_km: float | None = None

    @classmethod
    def from_mapping(cls, payload: Mapping[str, Any]) -> InventoryOption:
        """Validate and create an inventory option from raw mapping data."""
        try:
            data = _InventoryOptionSchema.model_validate(payload).model_dump()
        except ValidationError as exc:  # pragma: no cover - exercised via tests
            raise ModelValidationError("Invalid inventory option payload", cause=exc) from exc
        return cls(**data)

    def to_dict(self) -> dict[str, Any]:
        """Serialize the inventory option to a JSON-safe dictionary."""
        return {
            "inventory_id": str(self.inventory_id),
            "warehouse_id": str(self.warehouse_id),
            "warehouse_name": self.warehouse_name,
            "material_description": self.material_description,
            "available_quantity": str(self.available_quantity),
            "reserved_quantity": str(self.reserved_quantity),
            "soft_available_quantity": str(self.soft_available_quantity),
            "hard_available_quantity": str(self.hard_available_quantity),
            "approval_requirement": self.approval_requirement,
            "impact_level": self.impact_level,
            "estimated_recovery_days": self.estimated_recovery_days,
            "risk_summary": self.risk_summary,
            "distance_km": self.distance_km,
        }


@dataclass(frozen=True, slots=True)
class OptionAssessment:
    """AI evaluation metadata for a specific inventory option."""

    inventory_id: UUID
    summary: str
    impact_level: str
    confidence: float
    approvals_required: tuple[str, ...]
    trade_offs: tuple[str, ...]
    score: float

    @classmethod
    def from_mapping(cls, payload: Mapping[str, Any]) -> OptionAssessment:
        try:
            data = _OptionAssessmentSchema.model_validate(payload).model_dump()
        except ValidationError as exc:  # pragma: no cover - exercised via tests
            raise ModelValidationError("Invalid option assessment payload", cause=exc) from exc
        return cls(**data)

    def to_dict(self) -> dict[str, Any]:
        return {
            "inventory_id": str(self.inventory_id),
            "summary": self.summary,
            "impact_level": self.impact_level,
            "confidence": self.confidence,
            "approvals_required": list(self.approvals_required),
            "trade_offs": list(self.trade_offs),
            "score": self.score,
        }


@dataclass(frozen=True, slots=True)
class IterationDecision:
    """AI decision output for a single search iteration."""

    continue_search: bool
    reasoning: str
    viable_options: tuple[OptionAssessment, ...]
    discarded_reasons: tuple[str, ...] = ()

    @classmethod
    def from_mapping(cls, payload: Mapping[str, Any]) -> IterationDecision:
        try:
            data = _IterationDecisionSchema.model_validate(payload)
        except ValidationError as exc:  # pragma: no cover - exercised via tests
            raise ModelValidationError("Invalid iteration decision payload", cause=exc) from exc

        options = tuple(OptionAssessment.from_mapping(opt.model_dump()) for opt in data.viable_options)
        return cls(
            continue_search=data.continue_search,
            reasoning=data.reasoning,
            viable_options=options,
            discarded_reasons=data.discarded_reasons,
        )

    def to_dict(self) -> dict[str, Any]:
        return {
            "continue_search": self.continue_search,
            "reasoning": self.reasoning,
            "viable_options": [option.to_dict() for option in self.viable_options],
            "discarded_reasons": list(self.discarded_reasons),
        }


@dataclass(frozen=True, slots=True)
class FinalRecommendation:
    """AI final recommendation payload combining all iterations."""

    primary_option: OptionAssessment
    executive_summary: str
    risk_mitigation: tuple[str, ...]
    alternatives: tuple[OptionAssessment, ...] = ()

    @classmethod
    def from_mapping(cls, payload: Mapping[str, Any]) -> FinalRecommendation:
        try:
            data = _FinalRecommendationSchema.model_validate(payload)
        except ValidationError as exc:  # pragma: no cover - exercised via tests
            raise ModelValidationError("Invalid final recommendation payload", cause=exc) from exc

        primary = OptionAssessment.from_mapping(data.primary_option.model_dump())
        alternatives = tuple(
            OptionAssessment.from_mapping(option.model_dump()) for option in data.alternatives
        )

        return cls(
            primary_option=primary,
            executive_summary=data.executive_summary,
            risk_mitigation=data.risk_mitigation,
            alternatives=alternatives,
        )

    def to_dict(self) -> dict[str, Any]:
        return {
            "primary_option": self.primary_option.to_dict(),
            "alternatives": [option.to_dict() for option in self.alternatives],
            "executive_summary": self.executive_summary,
            "risk_mitigation": list(self.risk_mitigation),
        }


def serialize_option_sequence(options: Sequence[InventoryOption]) -> list[dict[str, Any]]:
    """Convert a sequence of inventory options into JSON-safe dictionaries."""
    return [option.to_dict() for option in options]
