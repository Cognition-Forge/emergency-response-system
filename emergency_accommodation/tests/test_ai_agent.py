from __future__ import annotations

import asyncio
import json
import os
from pathlib import Path
from typing import Any

import pytest
from langchain_core.exceptions import OutputParserException
from langchain_openai import ChatOpenAI
from langchain_anthropic import ChatAnthropic
from langchain_google_genai import ChatGoogleGenerativeAI

from ai_agent import (
    AIIntegrationError,
    AccommodationAgent,
    _FinalRecommendationPayload,
    _IterationDecisionPayload,
    _OptionAssessmentPayload,
    _create_llm_client,
    load_prompt_templates,
)
from config import load_search_parameters
from models import FailedItem, InventoryOption


@pytest.fixture
def sample_config():
    """Sample configuration for tests."""
    return {
        "ai_provider": "openai",
        "ai_model": "gpt-4o-mini",
        "ai_temperature": 0.2,
        "ai_max_output_tokens": 900,
        "ai_timeout_seconds": 30,
        "early_stopping_threshold": 5,
    }


@pytest.fixture
def mock_llm(monkeypatch):
    """Mock LangChain LLM with structured output."""
    from unittest.mock import MagicMock, AsyncMock

    mock_llm_client = MagicMock(spec=ChatOpenAI)
    mock_structured = AsyncMock()
    mock_llm_client.with_structured_output.return_value = mock_structured
    return mock_llm_client, mock_structured


def _failed_item() -> FailedItem:
    return FailedItem.from_mapping(
        {
            "scn_id": "6a6c37f8-23dc-4f18-9581-1c31b3dd7b74",
            "line_item_id": "7fbf34d4-64fa-4ec0-9fb8-47d3a9bf5b8a",
            "description": "HVAC compressor",
            "quantity": "2",
            "unit_of_measure": "EA",
            "priority": "critical",
            "ros_date": "2024-05-01",
        }
    )


def _inventory_option() -> InventoryOption:
    return InventoryOption.from_mapping(
        {
            "inventory_id": "de7cc0d2-bc0f-4e8c-9f03-91f119626b20",
            "warehouse_id": "df49f38a-a9a6-4674-b033-71da49cfaff0",
            "warehouse_name": "Regional Hub",
            "material_description": "HVAC compressor",
            "available_quantity": "5",
            "reserved_quantity": "1",
            "soft_available_quantity": "4",
            "hard_available_quantity": "3",
            "approval_requirement": "manager",
            "impact_level": "minor_impact",
            "estimated_recovery_days": 4,
            "risk_summary": "Next required: 2024-05-20 | Priority: 70",
            "distance_km": 120.0,
        }
    )


def _iteration_payload() -> _IterationDecisionPayload:
    option = _OptionAssessmentPayload(
        inventory_id="de7cc0d2-bc0f-4e8c-9f03-91f119626b20",
        summary="Allocate Regional Hub compressors",
        impact_level="minor_impact",
        confidence=0.82,
        approvals_required=["manager"],
        trade_offs=["Weekend freight"],
        score=7.4,
    )
    return _IterationDecisionPayload(
        continue_search=False,
        reasoning="Threshold met",
        viable_options=[option],
    )


def _final_payload() -> _FinalRecommendationPayload:
    option = _OptionAssessmentPayload(
        inventory_id="de7cc0d2-bc0f-4e8c-9f03-91f119626b20",
        summary="Allocate Regional Hub compressors",
        impact_level="minor_impact",
        confidence=0.9,
        approvals_required=["manager"],
        trade_offs=["Weekend freight"],
        score=8.1,
    )
    return _FinalRecommendationPayload(
        primary_option=option,
        executive_summary="Deploy Regional Hub stock with limited risk.",
        risk_mitigation=["Coordinate QA resources"],
    )


# Test provider factory


def test_create_llm_client_openai(sample_config, monkeypatch):
    """Test OpenAI provider creation."""
    from unittest.mock import MagicMock

    # Mock the provider classes to avoid API key validation
    mock_openai = MagicMock(spec=ChatOpenAI)
    monkeypatch.setattr("ai_agent.ChatOpenAI", lambda **kwargs: mock_openai)

    sample_config["ai_provider"] = "openai"
    client = _create_llm_client(sample_config)
    assert client == mock_openai


def test_create_llm_client_anthropic(sample_config, monkeypatch):
    """Test Anthropic provider creation."""
    from unittest.mock import MagicMock

    # Mock the provider classes to avoid API key validation
    mock_anthropic = MagicMock(spec=ChatAnthropic)
    monkeypatch.setattr("ai_agent.ChatAnthropic", lambda **kwargs: mock_anthropic)

    sample_config["ai_provider"] = "anthropic"
    client = _create_llm_client(sample_config)
    assert client == mock_anthropic


def test_create_llm_client_google(sample_config, monkeypatch):
    """Test Google provider creation."""
    from unittest.mock import MagicMock

    # Mock the provider classes to avoid API key validation
    mock_google = MagicMock(spec=ChatGoogleGenerativeAI)
    monkeypatch.setattr("ai_agent.ChatGoogleGenerativeAI", lambda **kwargs: mock_google)

    sample_config["ai_provider"] = "google"
    client = _create_llm_client(sample_config)
    assert client == mock_google


def test_create_llm_client_unsupported_provider(sample_config):
    """Test unsupported provider raises I308 error."""
    sample_config["ai_provider"] = "unsupported"
    with pytest.raises(AIIntegrationError) as exc:
        _create_llm_client(sample_config)
    assert exc.value.code == "I308"
    assert "Unsupported provider" in str(exc.value)


# Test evaluate_iteration


@pytest.mark.asyncio
async def test_evaluate_iteration_success(monkeypatch, sample_config, mock_llm):
    """Test successful iteration evaluation."""
    mock_llm_client, mock_structured = mock_llm
    monkeypatch.setattr("ai_agent._create_llm_client", lambda config: mock_llm_client)

    # Mock ainvoke to return iteration payload
    mock_structured.ainvoke.return_value = _iteration_payload()

    templates = load_prompt_templates()
    agent = AccommodationAgent(sample_config, prompt_templates=templates)

    decision = await agent.evaluate_iteration(
        iteration_num=1,
        inventory_batch=[_inventory_option()],
        failed_items=[_failed_item()],
        scenario_name="scenario1",
    )

    assert decision.continue_search is False
    assert decision.viable_options[0].summary.startswith("Allocate")
    mock_llm_client.with_structured_output.assert_called_once()
    mock_structured.ainvoke.assert_called_once()


@pytest.mark.parametrize("provider", ["openai", "anthropic", "google"])
@pytest.mark.asyncio
async def test_evaluate_iteration_all_providers(monkeypatch, sample_config, mock_llm, provider):
    """Test all providers work with same interface."""
    sample_config["ai_provider"] = provider
    mock_llm_client, mock_structured = mock_llm
    monkeypatch.setattr("ai_agent._create_llm_client", lambda config: mock_llm_client)

    # Mock ainvoke to return iteration payload
    mock_structured.ainvoke.return_value = _iteration_payload()

    templates = load_prompt_templates()
    agent = AccommodationAgent(sample_config, prompt_templates=templates)

    decision = await agent.evaluate_iteration(
        iteration_num=1,
        inventory_batch=[_inventory_option()],
        failed_items=[_failed_item()],
        scenario_name="scenario1",
    )

    assert decision.continue_search is False
    assert decision.viable_options[0].summary.startswith("Allocate")
    mock_structured.ainvoke.assert_called_once()


@pytest.mark.asyncio
async def test_evaluate_iteration_parser_error(monkeypatch, sample_config, mock_llm):
    """Test OutputParserException is mapped to I302 error."""
    mock_llm_client, mock_structured = mock_llm
    monkeypatch.setattr("ai_agent._create_llm_client", lambda config: mock_llm_client)

    # Mock ainvoke to raise OutputParserException
    mock_structured.ainvoke.side_effect = OutputParserException("Invalid schema")

    templates = load_prompt_templates()
    agent = AccommodationAgent(sample_config, prompt_templates=templates)

    with pytest.raises(AIIntegrationError) as exc:
        await agent.evaluate_iteration(
            iteration_num=1,
            inventory_batch=[_inventory_option()],
            failed_items=[_failed_item()],
            scenario_name="scenario1",
        )

    assert exc.value.code == "I302"
    assert "Response validation failed" in str(exc.value)


@pytest.mark.asyncio
async def test_evaluate_iteration_timeout(monkeypatch, sample_config, mock_llm):
    """Test timeout is mapped to I309 error."""
    mock_llm_client, mock_structured = mock_llm
    monkeypatch.setattr("ai_agent._create_llm_client", lambda config: mock_llm_client)

    # Mock ainvoke to hang (timeout)
    async def _hang(*args, **kwargs):
        await asyncio.sleep(100)

    mock_structured.ainvoke.side_effect = _hang
    sample_config["ai_timeout_seconds"] = 0.1  # Very short timeout

    templates = load_prompt_templates()
    agent = AccommodationAgent(sample_config, prompt_templates=templates)

    with pytest.raises(AIIntegrationError) as exc:
        await agent.evaluate_iteration(
            iteration_num=1,
            inventory_batch=[_inventory_option()],
            failed_items=[_failed_item()],
            scenario_name="scenario1",
        )

    assert exc.value.code == "I309"
    assert "timed out" in str(exc.value).lower()


@pytest.mark.asyncio
async def test_evaluate_iteration_generic_error(monkeypatch, sample_config, mock_llm):
    """Test generic error is mapped to I307."""
    mock_llm_client, mock_structured = mock_llm
    monkeypatch.setattr("ai_agent._create_llm_client", lambda config: mock_llm_client)

    # Mock ainvoke to raise RuntimeError
    mock_structured.ainvoke.side_effect = RuntimeError("API error")

    templates = load_prompt_templates()
    agent = AccommodationAgent(sample_config, prompt_templates=templates)

    with pytest.raises(AIIntegrationError) as exc:
        await agent.evaluate_iteration(
            iteration_num=1,
            inventory_batch=[_inventory_option()],
            failed_items=[_failed_item()],
            scenario_name="scenario1",
        )

    assert exc.value.code == "I307"


@pytest.mark.asyncio
async def test_evaluate_iteration_empty_inventory(monkeypatch, sample_config, mock_llm):
    """Test error when inventory batch is empty."""
    mock_llm_client, mock_structured = mock_llm
    monkeypatch.setattr("ai_agent._create_llm_client", lambda config: mock_llm_client)

    templates = load_prompt_templates()
    agent = AccommodationAgent(sample_config, prompt_templates=templates)

    with pytest.raises(AIIntegrationError) as exc:
        await agent.evaluate_iteration(
            iteration_num=1,
            inventory_batch=[],  # Empty batch
            failed_items=[_failed_item()],
            scenario_name="scenario1",
        )

    assert exc.value.code == "I301"


# Test final_recommendation


@pytest.mark.asyncio
async def test_final_recommendation_returns_structured_output(monkeypatch, sample_config, mock_llm):
    """Test final recommendation returns structured output."""
    mock_llm_client, mock_structured = mock_llm
    monkeypatch.setattr("ai_agent._create_llm_client", lambda config: mock_llm_client)

    # Mock ainvoke to return payloads in sequence
    mock_structured.ainvoke.side_effect = [_iteration_payload(), _final_payload()]

    templates = load_prompt_templates()
    agent = AccommodationAgent(sample_config, prompt_templates=templates)

    await agent.evaluate_iteration(
        iteration_num=1,
        inventory_batch=[_inventory_option()],
        failed_items=[_failed_item()],
        scenario_name="scenario1",
    )

    recommendation = await agent.final_recommendation()
    assert recommendation.primary_option.score == pytest.approx(8.1)
    assert recommendation.executive_summary.startswith("Deploy")


@pytest.mark.asyncio
async def test_final_recommendation_no_iterations(monkeypatch, sample_config, mock_llm):
    """Test final_recommendation raises error when called without iterations."""
    mock_llm_client, mock_structured = mock_llm
    monkeypatch.setattr("ai_agent._create_llm_client", lambda config: mock_llm_client)

    templates = load_prompt_templates()
    agent = AccommodationAgent(sample_config, prompt_templates=templates)

    with pytest.raises(AIIntegrationError) as exc:
        await agent.final_recommendation()

    assert exc.value.code == "I303"


@pytest.mark.asyncio
async def test_final_recommendation_timeout(monkeypatch, sample_config, mock_llm):
    """Test timeout in final_recommendation is mapped to I309."""
    from unittest.mock import AsyncMock

    mock_llm_client, mock_structured = mock_llm
    monkeypatch.setattr("ai_agent._create_llm_client", lambda config: mock_llm_client)

    # Create a new AsyncMock that will hang for final recommendation
    hanging_mock = AsyncMock()
    async def _hang(*args, **kwargs):
        await asyncio.sleep(100)
    hanging_mock.side_effect = _hang

    # Return iteration payload first, then switch to hanging mock
    first_call = True
    original_invoke = mock_structured.ainvoke

    async def _conditional_invoke(*args, **kwargs):
        nonlocal first_call
        if first_call:
            first_call = False
            return _iteration_payload()
        else:
            await asyncio.sleep(100)

    mock_structured.ainvoke = _conditional_invoke
    sample_config["ai_timeout_seconds"] = 0.1

    templates = load_prompt_templates()
    agent = AccommodationAgent(sample_config, prompt_templates=templates)

    await agent.evaluate_iteration(
        iteration_num=1,
        inventory_batch=[_inventory_option()],
        failed_items=[_failed_item()],
        scenario_name="scenario1",
    )

    with pytest.raises(AIIntegrationError) as exc:
        await agent.final_recommendation()

    assert exc.value.code == "I309"


@pytest.mark.asyncio
async def test_early_stopping_threshold_triggers(monkeypatch, sample_config, mock_llm):
    """Test early stopping threshold triggers when enough options found."""
    from uuid import uuid4

    mock_llm_client, mock_structured = mock_llm
    monkeypatch.setattr("ai_agent._create_llm_client", lambda config: mock_llm_client)

    # Create payload with continue_search=True and 5 options (matches threshold)
    options = [
        _OptionAssessmentPayload(
            inventory_id=str(uuid4()),
            summary=f"Option {i}",
            impact_level="minor_impact",
            confidence=0.8,
            approvals_required=[],
            trade_offs=[],
            score=7.0,
        )
        for i in range(5)
    ]
    payload = _IterationDecisionPayload(
        continue_search=True,  # Agent wants to continue
        reasoning="Need more options",
        viable_options=options,
    )

    mock_structured.ainvoke.return_value = payload
    sample_config["early_stopping_threshold"] = 5

    templates = load_prompt_templates()
    agent = AccommodationAgent(sample_config, prompt_templates=templates)

    decision = await agent.evaluate_iteration(
        iteration_num=1,
        inventory_batch=[_inventory_option()],
        failed_items=[_failed_item()],
        scenario_name="scenario1",
    )

    # Early stopping should have triggered (flipped to False)
    assert decision.continue_search is False
    assert "Early stopping threshold met" in decision.reasoning
    assert len(decision.viable_options) == 5


# Test LLM logging


@pytest.mark.asyncio
async def test_llm_logging_enabled(monkeypatch, sample_config, mock_llm, tmp_path: Path):
    """Verify log file created and contains expected fields when LOG_LLM_CALLS=true."""
    mock_llm_client, mock_structured = mock_llm
    monkeypatch.setattr("ai_agent._create_llm_client", lambda config: mock_llm_client)
    monkeypatch.setenv("LOG_LLM_CALLS", "true")

    # Mock ainvoke to return iteration payload
    mock_structured.ainvoke.return_value = _iteration_payload()

    # Override log directory to tmp_path
    log_file = tmp_path / "llm_calls.jsonl"
    monkeypatch.setattr("ai_agent.Path", lambda x: tmp_path if x == "logs" else Path(x))

    templates = load_prompt_templates()
    agent = AccommodationAgent(sample_config, prompt_templates=templates)

    await agent.evaluate_iteration(
        iteration_num=1,
        inventory_batch=[_inventory_option()],
        failed_items=[_failed_item()],
        scenario_name="scenario1",
    )

    # Verify log file exists
    assert log_file.exists(), "Log file should be created when LOG_LLM_CALLS=true"

    # Verify log entry structure
    log_content = log_file.read_text()
    log_entry = json.loads(log_content.strip())

    # Verify required fields
    assert "timestamp" in log_entry
    assert "agent" in log_entry
    assert log_entry["agent"] == "Iteration Evaluator"
    assert "model" in log_entry
    assert "request" in log_entry
    assert "instructions" in log_entry["request"]
    assert "payload" in log_entry["request"]
    assert "settings" in log_entry["request"]
    assert "temperature" in log_entry["request"]["settings"]
    assert "max_tokens" in log_entry["request"]["settings"]
    assert "response" in log_entry
    assert "timestamp" in log_entry["response"]
    assert "duration_ms" in log_entry["response"]
    assert "output" in log_entry["response"]
    assert "error" in log_entry["response"]


@pytest.mark.asyncio
async def test_llm_logging_disabled(monkeypatch, sample_config, mock_llm, tmp_path: Path):
    """Verify no log file created when LOG_LLM_CALLS is false or unset."""
    mock_llm_client, mock_structured = mock_llm
    monkeypatch.setattr("ai_agent._create_llm_client", lambda config: mock_llm_client)
    monkeypatch.setenv("LOG_LLM_CALLS", "false")

    # Mock ainvoke to return iteration payload
    mock_structured.ainvoke.return_value = _iteration_payload()

    log_file = tmp_path / "llm_calls.jsonl"
    monkeypatch.setattr("ai_agent.Path", lambda x: tmp_path if x == "logs" else Path(x))

    templates = load_prompt_templates()
    agent = AccommodationAgent(sample_config, prompt_templates=templates)

    await agent.evaluate_iteration(
        iteration_num=1,
        inventory_batch=[_inventory_option()],
        failed_items=[_failed_item()],
        scenario_name="scenario1",
    )

    # Verify log file was NOT created
    assert not log_file.exists(), "Log file should not be created when LOG_LLM_CALLS=false"


@pytest.mark.asyncio
async def test_llm_logging_failure_does_not_crash(monkeypatch, sample_config, mock_llm, tmp_path: Path):
    """Verify logging failure doesn't crash LLM call - graceful degradation."""
    mock_llm_client, mock_structured = mock_llm
    monkeypatch.setattr("ai_agent._create_llm_client", lambda config: mock_llm_client)
    monkeypatch.setenv("LOG_LLM_CALLS", "true")

    # Mock ainvoke to return iteration payload
    mock_structured.ainvoke.return_value = _iteration_payload()

    # Make log directory read-only to force write failure
    log_dir = tmp_path / "readonly_logs"
    log_dir.mkdir()
    log_dir.chmod(0o444)  # Read-only
    monkeypatch.setattr("ai_agent.Path", lambda x: log_dir if x == "logs" else Path(x))

    templates = load_prompt_templates()
    agent = AccommodationAgent(sample_config, prompt_templates=templates)

    # Should not raise exception even if logging fails
    decision = await agent.evaluate_iteration(
        iteration_num=1,
        inventory_batch=[_inventory_option()],
        failed_items=[_failed_item()],
        scenario_name="scenario1",
    )

    # Verify LLM call succeeded despite logging failure
    assert decision.continue_search is False
    assert decision.viable_options[0].summary.startswith("Allocate")
    mock_structured.ainvoke.assert_called_once()

    # Cleanup
    log_dir.chmod(0o755)
