from __future__ import annotations

from rich.console import Console

from cli_display import (
    display_final_recommendation,
    display_iteration_results,
    display_progress_bar,
    display_scenario_header,
)
from models import FinalRecommendation, IterationDecision, OptionAssessment


def _decision() -> IterationDecision:
    option = OptionAssessment.from_mapping(
        {
            "inventory_id": "de7cc0d2-bc0f-4e8c-9f03-91f119626b20",
            "summary": "Allocate Regional Hub compressors",
            "impact_level": "minor_impact",
            "confidence": 0.82,
            "approvals_required": ["manager"],
            "trade_offs": ["Weekend freight"],
            "score": 7.4,
        }
    )
    return IterationDecision(
        continue_search=True,
        reasoning="Gather additional coverage to protect schedule.",
        viable_options=(option,),
    )


def _recommendation() -> FinalRecommendation:
    primary = OptionAssessment.from_mapping(
        {
            "inventory_id": "de7cc0d2-bc0f-4e8c-9f03-91f119626b20",
            "summary": "Allocate Regional Hub compressors",
            "impact_level": "minor_impact",
            "confidence": 0.9,
            "approvals_required": ["manager"],
            "trade_offs": ["Weekend freight"],
            "score": 8.1,
        }
    )
    alternative = OptionAssessment.from_mapping(
        {
            "inventory_id": "1b10928a-2f66-4f9d-9ea5-00b357f0e6aa",
            "summary": "Broker supplier with split shipment",
            "impact_level": "moderate_impact",
            "confidence": 0.65,
            "approvals_required": ["executive"],
            "trade_offs": ["Premium freight"],
            "score": 6.8,
        }
    )
    return FinalRecommendation(
        primary_option=primary,
        executive_summary="Deploy Regional Hub stock with limited risk.",
        risk_mitigation=("Coordinate QA resources",),
        alternatives=(alternative,),
    )


def test_display_scenario_header_outputs_key_values() -> None:
    record = Console(record=True)
    config = {
        "max_iterations": 3,
        "batch_size_per_iteration": 10,
        "early_stopping_threshold": 5,
        "search_order": "urgency_first",
        "time_window_type": "weekly",
        "risk_tolerance": "moderate",
        "approval_preference": "minimize",
    }

    display_scenario_header("scenario1", config, console_override=record)
    output = record.export_text()

    assert "Scenario: scenario1" in output
    assert "Max Iterations" in output
    assert "Risk Tolerance" in output


def test_display_iteration_results_renders_table() -> None:
    record = Console(record=True)

    display_iteration_results(1, _decision(), console_override=record)
    output = record.export_text()

    assert "Iteration 1" in output
    assert "Gather additional coverage" in output
    assert "Allocate Regional Hub" in output


def test_display_final_recommendation_shows_summary_and_alternatives() -> None:
    record = Console(record=True)

    display_final_recommendation(_recommendation(), console_override=record)
    output = record.export_text()

    assert "Final Recommendation" in output
    assert "Primary Option" in output
    assert "Alternatives" in output


def test_display_progress_bar_returns_progress_and_task_id() -> None:
    progress, task_id = display_progress_bar("Loading", total=3)
    try:
        task = progress.tasks[0]
        assert task.id == task_id
        assert task.total == 3
        assert task.description == "Loading"
    finally:
        progress.stop()
