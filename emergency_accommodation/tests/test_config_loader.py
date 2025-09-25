from __future__ import annotations

from pathlib import Path

import pytest

from config import (
    ConfigurationError,
    PromptTemplates,
    load_prompt_templates,
    load_search_parameters,
)


@pytest.mark.parametrize(
    ("scenario", "expected"),
    [
        (
            "scenario1",
            {
                "max_iterations": 2,
                "batch_size_per_iteration": 10,
                "early_stopping_threshold": 4,
                "risk_tolerance": "conservative",
                "approval_preference": "minimize",
                "time_window_type": "weekly",
                "search_order": "urgency_first",
            },
        ),
        (
            "scenario2",
            {
                "max_iterations": 3,
                "batch_size_per_iteration": 12,
                "early_stopping_threshold": 8,
                "risk_tolerance": "moderate",
                "approval_preference": "minimize",
                "time_window_type": "weekly",
                "search_order": "availability_first",
            },
        ),
        (
            "scenario3",
            {
                "max_iterations": 3,
                "batch_size_per_iteration": 15,
                "early_stopping_threshold": 5,
                "risk_tolerance": "aggressive",
                "approval_preference": "accept_higher",
                "time_window_type": "priority_based",
                "search_order": "availability_first",
            },
        ),
    ],
)
def test_load_search_parameters_merges_defaults(scenario: str, expected: dict[str, object]) -> None:
    config = load_search_parameters(scenario)
    for key, value in expected.items():
        assert config[key] == value


@pytest.mark.parametrize("scenario", ["scenario1", "scenario2", "scenario3"])
def test_load_prompt_templates_returns_combined_text(scenario: str) -> None:
    prompts = load_prompt_templates(scenario)
    assert isinstance(prompts, PromptTemplates)
    assert prompts.base.startswith("You are the emergency accommodation AI coordinator")
    assert prompts.scenario.startswith("Scenario posture")
    assert prompts.combined.startswith(prompts.base)
    assert prompts.scenario in prompts.combined


def test_load_search_parameters_unknown_scenario_raises() -> None:
    with pytest.raises(ConfigurationError) as exc:
        load_search_parameters("missing")
    assert exc.value.code == "C104"


def test_load_prompt_templates_missing_file_raises(tmp_path: Path) -> None:
    config_dir = tmp_path / "config"
    prompts_dir = config_dir / "prompts"
    prompts_dir.mkdir(parents=True)
    (config_dir / "search_parameters.yaml").write_text("default: {}\nscenarios: {}\n", encoding="utf-8")
    (prompts_dir / "base_prompt.txt").write_text("base", encoding="utf-8")

    with pytest.raises(ConfigurationError) as exc:
        load_prompt_templates("scenario1", config_dir=config_dir)
    assert exc.value.code == "C108"
