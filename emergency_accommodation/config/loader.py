from __future__ import annotations

import re
from dataclasses import dataclass
from pathlib import Path
from typing import Any, Mapping

import yaml


class ConfigurationError(Exception):
    """Raised when configuration files are invalid or incomplete."""

    def __init__(self, message: str, code: str = "C100") -> None:
        super().__init__(f"{code}: {message}")
        self.code = code


DEFAULT_CONFIG_DIR = Path(__file__).resolve().parent
_PROMPT_BASE_FILENAME = "base_prompt.txt"
_SCENARIO_PATTERN = re.compile(r"^[a-z0-9_-]+$")


@dataclass(frozen=True)
class PromptTemplates:
    base: str
    scenario: str
    combined: str


def load_search_parameters(
    scenario_name: str,
    config_dir: Path | str | None = None,
) -> dict[str, Any]:
    """Load merged search parameters for the provided scenario."""
    config_path = _coerce_config_dir(config_dir)
    _validate_scenario_name(scenario_name)

    yaml_path = config_path / "search_parameters.yaml"
    if not yaml_path.is_file():
        raise ConfigurationError(
            f"Search parameter file not found at {yaml_path}",
            code="C101",
        )

    with yaml_path.open(encoding="utf-8") as fh:
        raw_data = yaml.safe_load(fh)

    data = _validate_root_mapping(raw_data, yaml_path)

    defaults = data.get("default")
    if not isinstance(defaults, Mapping):
        raise ConfigurationError("`default` section must be a mapping", code="C102")

    scenario_map = data.get("scenarios")
    if not isinstance(scenario_map, Mapping):
        raise ConfigurationError("`scenarios` section must be a mapping", code="C103")

    scenario_config = scenario_map.get(scenario_name)
    if scenario_config is None:
        raise ConfigurationError(
            f"Scenario `{scenario_name}` is not defined in configuration",
            code="C104",
        )
    if not isinstance(scenario_config, Mapping):
        raise ConfigurationError("Scenario overrides must be a mapping", code="C105")

    merged: dict[str, Any] = dict(defaults)
    merged.update(scenario_config)
    return merged


def load_prompt_templates(
    scenario_name: str,
    config_dir: Path | str | None = None,
) -> PromptTemplates:
    """Load base and scenario-specific prompt templates."""
    config_path = _coerce_config_dir(config_dir)
    _validate_scenario_name(scenario_name)

    prompts_dir = config_path / "prompts"
    if not prompts_dir.is_dir():
        raise ConfigurationError(
            f"Prompt directory not found at {prompts_dir}",
            code="C106",
        )

    base_path = prompts_dir / _PROMPT_BASE_FILENAME
    if not base_path.is_file():
        raise ConfigurationError(
            f"Base prompt file not found at {base_path}",
            code="C107",
        )

    scenario_path = prompts_dir / f"{scenario_name}.txt"
    if not scenario_path.is_file():
        raise ConfigurationError(
            f"Scenario prompt file not found at {scenario_path}",
            code="C108",
        )

    base_text = base_path.read_text(encoding="utf-8").strip()
    scenario_text = scenario_path.read_text(encoding="utf-8").strip()
    combined = f"{base_text}\n\n{scenario_text}" if scenario_text else base_text

    return PromptTemplates(
        base=base_text,
        scenario=scenario_text,
        combined=combined,
    )


def _coerce_config_dir(config_dir: Path | str | None) -> Path:
    if config_dir is None:
        return DEFAULT_CONFIG_DIR
    if isinstance(config_dir, Path):
        result = config_dir
    else:
        result = Path(config_dir)
    if not result.exists():
        raise ConfigurationError(
            f"Configuration directory not found at {result}",
            code="C109",
        )
    if not result.is_dir():
        raise ConfigurationError(
            f"Configuration path {result} is not a directory",
            code="C110",
        )
    return result


def _validate_root_mapping(raw_data: Any, yaml_path: Path) -> Mapping[str, Any]:
    if raw_data is None:
        raise ConfigurationError(
            f"Configuration file {yaml_path} is empty",
            code="C111",
        )
    if not isinstance(raw_data, Mapping):
        raise ConfigurationError(
            f"Configuration root at {yaml_path} must be a mapping",
            code="C112",
        )
    return raw_data


def _validate_scenario_name(scenario_name: str) -> None:
    if not scenario_name:
        raise ConfigurationError("Scenario name is required", code="C113")
    if not _SCENARIO_PATTERN.fullmatch(scenario_name):
        raise ConfigurationError(
            "Scenario name must contain only lowercase letters, digits, underscores, or hyphens",
            code="C114",
        )


__all__ = [
    "ConfigurationError",
    "PromptTemplates",
    "DEFAULT_CONFIG_DIR",
    "load_search_parameters",
    "load_prompt_templates",
]
