"""OpenAI-powered accommodation agent with file-based prompt management."""

from __future__ import annotations

import asyncio
import json
from dataclasses import dataclass
from pathlib import Path
from typing import Any, Mapping, MutableMapping, Sequence
from openai import AsyncOpenAI

from config import DEFAULT_CONFIG_DIR, PromptTemplates
from config.loader import ConfigurationError
from models import (
    FailedItem,
    FinalRecommendation,
    IterationDecision,
    InventoryOption,
    ModelValidationError,
    serialize_option_sequence,
)

__all__ = [
    "AIIntegrationError",
    "AccommodationAgent",
    "load_prompt_templates",
]


class AIIntegrationError(RuntimeError):
    """Raised for failures while interacting with the AI coordinator."""

    def __init__(self, message: str, code: str = "I300", *, cause: Exception | None = None) -> None:
        super().__init__(f"{code}: {message}")
        self.code = code
        self.__cause__ = cause


@dataclass(frozen=True)
class _IterationContext:
    iteration: int
    scenario: str
    failed_items: tuple[dict[str, Any], ...]
    inventory_batch: tuple[dict[str, Any], ...]
    decision: IterationDecision | None = None


class AccommodationAgent:
    """Drives AI-assisted decision making for emergency accommodations."""

    def __init__(
        self,
        config: Mapping[str, Any],
        openai_client: AsyncOpenAI,
        prompt_templates: Mapping[str, PromptTemplates],
    ) -> None:
        self._config = dict(config)
        self._client = openai_client
        self._templates: Mapping[str, PromptTemplates] = prompt_templates
        self._iteration_history: list[_IterationContext] = []
        self._decisions: list[IterationDecision] = []
        self._scenario: str | None = None

    async def evaluate_iteration(
        self,
        iteration_num: int,
        inventory_batch: Sequence[InventoryOption],
        failed_items: Sequence[FailedItem],
        scenario_name: str,
    ) -> IterationDecision:
        if not inventory_batch:
            raise AIIntegrationError("Inventory batch is required for evaluation", code="I301")

        template = self._load_prompt_template(scenario_name)
        failed_payload = tuple(item.to_dict() for item in failed_items)
        inventory_payload = tuple(serialize_option_sequence(inventory_batch))

        prompt = self._build_iteration_prompt(
            template=template,
            iteration=iteration_num,
            scenario=scenario_name,
            failed_items=failed_payload,
            inventory_options=inventory_payload,
        )

        response_text = await self._invoke_model(prompt)
        parsed = self._parse_ai_response(response_text)
        if not isinstance(parsed, IterationDecision):
            raise AIIntegrationError("Iteration response did not contain decision payload", code="I302")

        parsed = self._apply_early_stopping(parsed)

        context = _IterationContext(
            iteration=iteration_num,
            scenario=scenario_name,
            failed_items=failed_payload,
            inventory_batch=inventory_payload,
            decision=parsed,
        )
        self._iteration_history.append(context)
        self._decisions.append(parsed)
        self._scenario = scenario_name
        return parsed

    async def final_recommendation(self) -> FinalRecommendation:
        if not self._iteration_history:
            raise AIIntegrationError("No iterations have been evaluated", code="I303")
        scenario = self._scenario
        if scenario is None:
            raise AIIntegrationError("Scenario context is not available", code="I304")

        template = self._load_prompt_template(scenario)
        prompt = self._build_final_prompt(template, scenario)
        response_text = await self._invoke_model(prompt)
        parsed = self._parse_ai_response(response_text)
        if not isinstance(parsed, FinalRecommendation):
            raise AIIntegrationError("Final response did not contain recommendation payload", code="I305")
        return parsed

    def _load_prompt_template(self, scenario_name: str) -> PromptTemplates:
        try:
            return self._templates[scenario_name]
        except KeyError as exc:  # pragma: no cover - defensive
            raise AIIntegrationError(
                f"Prompt template for scenario '{scenario_name}' is not loaded",
                code="I306",
            ) from exc

    def _build_iteration_prompt(
        self,
        *,
        template: PromptTemplates,
        iteration: int,
        scenario: str,
        failed_items: Sequence[Mapping[str, Any]],
        inventory_options: Sequence[Mapping[str, Any]],
    ) -> str:
        payload = {
            "scenario": scenario,
            "iteration": iteration,
            "search_config": self._config,
            "failed_items": list(failed_items),
            "inventory_options": list(inventory_options),
            "prior_decisions": [decision.to_dict() for decision in self._decisions],
        }
        return self._compose_prompt(template.combined, payload)

    def _build_final_prompt(self, template: PromptTemplates, scenario: str) -> str:
        payload = {
            "scenario": scenario,
            "search_config": self._config,
            "iteration_history": [
                {
                    "iteration": ctx.iteration,
                    "failed_items": list(ctx.failed_items),
                    "inventory_options": list(ctx.inventory_batch),
                    "decision": ctx.decision.to_dict() if ctx.decision else None,
                }
                for ctx in self._iteration_history
            ],
            "collated_options": self._collect_option_assessments(),
        }
        return self._compose_prompt(template.combined, payload)

    def _collect_option_assessments(self) -> list[dict[str, Any]]:
        assessments: list[dict[str, Any]] = []
        for decision in self._decisions:
            assessments.extend(option.to_dict() for option in decision.viable_options)
        return assessments

    def _compose_prompt(self, template_text: str, payload: Mapping[str, Any]) -> str:
        encoded = json.dumps(payload, indent=2)
        return (
            f"{template_text}\n\nContext JSON:\n{encoded}\n\n"
            "Respond with JSON containing iteration decisions or final recommendations."
        )

    async def _invoke_model(self, prompt: str) -> str:
        timeout = float(self._config.get("ai_timeout_seconds", 12.0))
        try:
            response = await asyncio.wait_for(
                self._client.responses.create(  # type: ignore[arg-type,call-overload]
                    model=self._config.get("ai_model", "gpt-4o-mini"),
                    input=[
                        {"role": "system", "content": "You are an emergency accommodation strategist."},
                        {"role": "user", "content": prompt},
                    ],
                    temperature=float(self._config.get("ai_temperature", 0.2)),
                    max_output_tokens=int(self._config.get("ai_max_output_tokens", 900)),
                    response_format={"type": "json_object"},
                ),
                timeout=timeout,
            )
        except asyncio.TimeoutError as exc:
            raise AIIntegrationError("AI request exceeded timeout", code="I313", cause=exc) from exc
        except Exception as exc:  # pragma: no cover - network failures
            raise AIIntegrationError("AI request failed", code="I307", cause=exc) from exc

        text = self._extract_text(response)
        if not text:
            raise AIIntegrationError("AI response did not contain text output", code="I308")
        return text

    def _extract_text(self, response: Any) -> str:
        if hasattr(response, "output_text") and response.output_text:
            return response.output_text
        output = getattr(response, "output", None)
        if not output:
            return ""
        for segment in output:
            content = getattr(segment, "content", None)
            if not content:
                continue
            for block in content:
                text = getattr(block, "text", None)
                if text:
                    return text
        return ""

    def _parse_ai_response(self, response_text: str) -> IterationDecision | FinalRecommendation:
        try:
            data = json.loads(response_text)
        except json.JSONDecodeError as exc:
            raise AIIntegrationError("AI response was not valid JSON", code="I309", cause=exc) from exc

        if not isinstance(data, MutableMapping):
            raise AIIntegrationError("AI response JSON must be an object", code="I310")

        try:
            if "continue_search" in data:
                return IterationDecision.from_mapping(data)
            if "primary_option" in data:
                return FinalRecommendation.from_mapping(data)
        except ModelValidationError as exc:
            raise AIIntegrationError("AI response failed validation", code="I311", cause=exc) from exc

        raise AIIntegrationError("AI response missing required fields", code="I312")

    def _apply_early_stopping(self, decision: IterationDecision) -> IterationDecision:
        threshold = int(self._config.get("early_stopping_threshold", 0) or 0)
        if threshold <= 0:
            return decision

        count = len(decision.viable_options)
        if decision.continue_search and count >= threshold:
            reason = (
                f"{decision.reasoning} | Early stopping threshold met ({count}/{threshold})"
            )
            return IterationDecision(
                continue_search=False,
                reasoning=reason,
                viable_options=decision.viable_options,
                discarded_reasons=decision.discarded_reasons,
            )
        return decision


def load_prompt_templates(
    config_dir: Path | str | None = None,
) -> dict[str, PromptTemplates]:
    base_dir = Path(config_dir) if config_dir is not None else DEFAULT_CONFIG_DIR
    prompts_dir = base_dir / "prompts"
    if not prompts_dir.is_dir():
        raise ConfigurationError(
            f"Prompt directory not found at {prompts_dir}",
            code="C106",
        )

    base_path = prompts_dir / "base_prompt.txt"
    if not base_path.is_file():
        raise ConfigurationError(
            f"Base prompt file not found at {base_path}",
            code="C107",
        )

    scenario_templates: dict[str, PromptTemplates] = {}
    base_text = base_path.read_text(encoding="utf-8").strip()

    for path in prompts_dir.glob("*.txt"):
        if path.name == "base_prompt.txt":
            continue
        scenario_name = path.stem
        scenario_text = path.read_text(encoding="utf-8").strip()
        combined = f"{base_text}\n\n{scenario_text}" if scenario_text else base_text
        scenario_templates[scenario_name] = PromptTemplates(
            base=base_text,
            scenario=scenario_text,
            combined=combined,
        )

    if not scenario_templates:
        raise ConfigurationError("No scenario prompt templates discovered", code="C115")

    return scenario_templates
