"""OpenAI-powered accommodation agent with file-based prompt management."""

from __future__ import annotations

import asyncio
import json
import os
import sys
import time
from dataclasses import dataclass
from datetime import datetime, timezone
from pathlib import Path
from typing import Any, Awaitable, Callable, Mapping, Sequence

from langchain_anthropic import ChatAnthropic
from langchain_core.exceptions import OutputParserException
from langchain_core.language_models import BaseChatModel
from langchain_google_genai import ChatGoogleGenerativeAI
from langchain_openai import ChatOpenAI
from pydantic import BaseModel, Field

from config import DEFAULT_CONFIG_DIR, PromptTemplates
from config.loader import ConfigurationError
from models import (
    FailedItem,
    FinalRecommendation,
    IterationDecision,
    InventoryOption,
    ModelValidationError,
    OptionAssessment,
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


class _OptionAssessmentPayload(BaseModel):
    inventory_id: str
    summary: str
    impact_level: str
    confidence: float
    approvals_required: list[str] = Field(default_factory=list)
    trade_offs: list[str] = Field(default_factory=list)
    score: float


class _IterationDecisionPayload(BaseModel):
    continue_search: bool
    reasoning: str
    viable_options: list[_OptionAssessmentPayload]
    discarded_reasons: list[str] = Field(default_factory=list)


class _FinalRecommendationPayload(BaseModel):
    primary_option: _OptionAssessmentPayload
    alternatives: list[_OptionAssessmentPayload] = Field(default_factory=list)
    executive_summary: str
    risk_mitigation: list[str] = Field(default_factory=list)


async def _log_llm_call(
    agent_name: str,
    model: str,
    instructions: str,
    payload: str,
    settings: dict[str, Any],
    runner_coro: Callable[[], Awaitable[Any]],
) -> Any:
    """Wrapper that logs LLM calls if LOG_LLM_CALLS=true."""
    import logging
    logger = logging.getLogger(__name__)

    # Check if logging is enabled
    if os.getenv("LOG_LLM_CALLS", "false").lower() != "true":
        return await runner_coro()

    # Prepare log directory (relative to working directory) with error handling
    try:
        log_dir = Path("logs")
        log_dir.mkdir(parents=True, exist_ok=True)
        log_file = log_dir / "llm_calls.jsonl"
    except OSError as exc:
        logger.warning(f"Cannot create logs directory: {exc}. LLM logging disabled.")
        return await runner_coro()

    # Capture request metadata
    request_timestamp = datetime.now(timezone.utc).isoformat().replace("+00:00", "Z")
    start_time = time.perf_counter()

    # Execute the LLM call
    result = None
    error = None
    try:
        result = await runner_coro()
    except Exception as exc:
        error = str(exc)
        raise
    finally:
        # Capture response metadata
        end_time = time.perf_counter()
        duration_ms = int((end_time - start_time) * 1000)
        response_timestamp = datetime.now(timezone.utc).isoformat().replace("+00:00", "Z")

        # Build log entry
        output_data = None
        if result is not None and hasattr(result, "final_output"):
            final_output = result.final_output
            if final_output is not None:
                output_data = final_output.model_dump() if hasattr(final_output, "model_dump") else final_output

        log_entry = {
            "timestamp": request_timestamp,
            "agent": agent_name,
            "model": model,
            "request": {
                "instructions": instructions,
                "payload": payload,
                "settings": settings,
            },
            "response": {
                "timestamp": response_timestamp,
                "duration_ms": duration_ms,
                "output": output_data,
                "error": error,
            },
        }

        # Write to log file (graceful failure)
        try:
            with log_file.open("a", encoding="utf-8") as f:
                json.dump(log_entry, f, ensure_ascii=False)
                f.write("\n")
        except Exception as log_error:
            print(f"Failed to write LLM log: {log_error}", file=sys.stderr)

    return result


def _create_llm_client(config: Mapping[str, Any]) -> BaseChatModel:
    """Create LangChain LLM client based on provider configuration.

    Note: Google uses max_output_tokens parameter, OpenAI/Anthropic use max_tokens.

    Args:
        config: Configuration mapping containing ai_provider, ai_model, etc.

    Returns:
        LangChain BaseChatModel instance for the configured provider

    Raises:
        AIIntegrationError: If provider is unsupported (code I308)
    """
    provider = config.get("ai_provider", "openai").lower()
    model = config.get("ai_model", "gpt-4o-mini")
    temperature = float(config.get("ai_temperature", 0.2))
    max_tokens = int(config.get("ai_max_output_tokens", 900))

    if provider == "openai":
        return ChatOpenAI(model=model, temperature=temperature, max_tokens=max_tokens)
    elif provider == "anthropic":
        return ChatAnthropic(model=model, temperature=temperature, max_tokens=max_tokens)
    elif provider == "google":
        # Google uses max_output_tokens instead of max_tokens
        return ChatGoogleGenerativeAI(model=model, temperature=temperature, max_output_tokens=max_tokens)
    else:
        raise AIIntegrationError(f"Unsupported provider: {provider}", code="I308")


class AccommodationAgent:
    """Drives AI-assisted decision making for emergency accommodations."""

    def __init__(
        self,
        config: Mapping[str, Any],
        prompt_templates: Mapping[str, PromptTemplates],
    ) -> None:
        self._config = dict(config)
        self._llm = _create_llm_client(config)
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

        payload = self._build_iteration_payload(
            scenario=scenario_name,
            iteration=iteration_num,
            failed_items=failed_payload,
            inventory_options=inventory_payload,
        )

        # Create structured LLM using LangChain
        structured_llm = self._llm.with_structured_output(
            schema=_IterationDecisionPayload,
            method="function_calling",
        )

        # Build messages for LangChain
        messages = [
            {"role": "system", "content": template.combined},
            {"role": "user", "content": payload},
        ]

        timeout = float(self._config.get("ai_timeout_seconds", 12.0))
        try:
            structured = await asyncio.wait_for(
                _log_llm_call(
                    agent_name="Iteration Evaluator",
                    model=self._config.get("ai_model", "gpt-4o-mini"),
                    instructions=template.combined,
                    payload=payload,
                    settings={
                        "temperature": float(self._config.get("ai_temperature", 0.2)),
                        "max_tokens": int(self._config.get("ai_max_output_tokens", 900)),
                    },
                    runner_coro=lambda: structured_llm.ainvoke(messages),
                ),
                timeout=timeout,
            )
        except OutputParserException as exc:
            raise AIIntegrationError("Response validation failed", code="I302", cause=exc) from exc
        except asyncio.TimeoutError as exc:
            raise AIIntegrationError(
                f"AI request timed out after {timeout}s",
                code="I309",
                cause=exc,
            ) from exc
        except Exception as exc:
            raise AIIntegrationError("AI request failed", code="I307", cause=exc) from exc

        parsed = self._convert_iteration(structured)

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
        payload = self._build_final_payload(template, scenario)

        # Create structured LLM using LangChain
        structured_llm = self._llm.with_structured_output(
            schema=_FinalRecommendationPayload,
            method="function_calling",
        )

        # Build messages for LangChain
        messages = [
            {"role": "system", "content": template.combined},
            {"role": "user", "content": payload},
        ]

        timeout = float(self._config.get("ai_timeout_seconds", 12.0))
        try:
            structured = await asyncio.wait_for(
                _log_llm_call(
                    agent_name="Final Recommender",
                    model=self._config.get("ai_model", "gpt-4o-mini"),
                    instructions=template.combined,
                    payload=payload,
                    settings={
                        "temperature": float(self._config.get("ai_temperature", 0.2)),
                        "max_tokens": int(self._config.get("ai_max_output_tokens", 900)),
                    },
                    runner_coro=lambda: structured_llm.ainvoke(messages),
                ),
                timeout=timeout,
            )
        except OutputParserException as exc:
            raise AIIntegrationError("Response validation failed", code="I302", cause=exc) from exc
        except asyncio.TimeoutError as exc:
            raise AIIntegrationError(
                f"AI request timed out after {timeout}s",
                code="I309",
                cause=exc,
            ) from exc
        except Exception as exc:
            raise AIIntegrationError("AI request failed", code="I307", cause=exc) from exc

        return self._convert_final(structured)

    def _load_prompt_template(self, scenario_name: str) -> PromptTemplates:
        try:
            return self._templates[scenario_name]
        except KeyError as exc:  # pragma: no cover - defensive
            raise AIIntegrationError(
                f"Prompt template for scenario '{scenario_name}' is not loaded",
                code="I306",
            ) from exc

    def _build_iteration_payload(
        self,
        *,
        scenario: str,
        iteration: int,
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
        return json.dumps(payload)

    def _build_final_payload(self, template: PromptTemplates, scenario: str) -> str:
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
        return json.dumps(payload)

    def _collect_option_assessments(self) -> list[dict[str, Any]]:
        assessments: list[dict[str, Any]] = []
        for decision in self._decisions:
            assessments.extend(option.to_dict() for option in decision.viable_options)
        return assessments

    def _convert_iteration(self, payload: _IterationDecisionPayload) -> IterationDecision:
        try:
            viable = tuple(
                OptionAssessment.from_mapping(option.model_dump())
                for option in payload.viable_options
            )
        except ModelValidationError as exc:  # pragma: no cover - defensive
            raise AIIntegrationError("AI iteration payload failed validation", code="I311", cause=exc) from exc

        return IterationDecision(
            continue_search=payload.continue_search,
            reasoning=payload.reasoning,
            viable_options=viable,
            discarded_reasons=tuple(payload.discarded_reasons),
        )

    def _convert_final(self, payload: _FinalRecommendationPayload) -> FinalRecommendation:
        try:
            primary = OptionAssessment.from_mapping(payload.primary_option.model_dump())
            alternatives = tuple(
                OptionAssessment.from_mapping(option.model_dump())
                for option in payload.alternatives
            )
        except ModelValidationError as exc:  # pragma: no cover - defensive
            raise AIIntegrationError("AI final payload failed validation", code="I311", cause=exc) from exc

        return FinalRecommendation(
            primary_option=primary,
            executive_summary=payload.executive_summary,
            risk_mitigation=tuple(payload.risk_mitigation),
            alternatives=alternatives,
        )

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
