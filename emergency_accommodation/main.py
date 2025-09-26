"""CLI orchestration for the emergency accommodation workflow."""

from __future__ import annotations

import argparse
import asyncio
import logging
import os
from contextlib import asynccontextmanager
from pathlib import Path
from typing import AsyncIterator, Mapping

from openai import AsyncOpenAI

from ai_agent import AIIntegrationError, AccommodationAgent, load_prompt_templates
from cli_display import (
    console,
    display_error,
    display_final_recommendation,
    display_iteration_results,
    display_progress_bar,
    display_scenario_header,
    display_success,
)
from config import load_search_parameters
from config.loader import ConfigurationError
from database import load_failed_items, load_inventory_by_iteration

logger = logging.getLogger("emergency_accommodation.cli")


def parse_args(argv: list[str] | None = None) -> argparse.Namespace:
    parser = argparse.ArgumentParser(
        description="Emergency Accommodation CLI - AI-driven supply chain disruption response",
    )
    parser.add_argument(
        "--scenario",
        choices=["scenario1", "scenario2", "scenario3"],
        required=True,
        help="Scenario to analyze (scenario1=conservative, scenario2=balanced, scenario3=aggressive)",
    )
    parser.add_argument(
        "--config-dir",
        default="config",
        help="Configuration directory path (default: config)",
    )
    parser.add_argument(
        "--max-iterations",
        type=int,
        default=None,
        help="Override max iterations (falls back to YAML otherwise)",
    )
    return parser.parse_args(argv)


def validate_environment() -> tuple[str, str]:
    database_url = os.getenv("DATABASE_URL")
    if not database_url:
        raise RuntimeError("DATABASE_URL must be set to run the CLI")

    api_key = os.getenv("OPENAI_API_KEY")
    if not api_key:
        raise RuntimeError("OPENAI_API_KEY must be set for AI evaluation")

    return database_url, api_key


@asynccontextmanager
async def create_openai_client(api_key: str) -> AsyncIterator[AsyncOpenAI]:
    client = AsyncOpenAI(api_key=api_key)
    try:
        yield client
    finally:
        await client.close()


async def run_accommodation_analysis(
    scenario_name: str,
    config_dir: Path,
    database_url: str,
    openai_api_key: str,
    max_iterations_override: int | None = None,
) -> None:
    search_config = load_search_parameters(scenario_name, config_dir)
    if max_iterations_override is not None:
        search_config["max_iterations"] = max_iterations_override

    prompt_templates = load_prompt_templates(config_dir)
    display_scenario_header(scenario_name, search_config)

    failed_items = await load_failed_items(database_url, scenario_name)
    if not failed_items:
        display_error("No failed items found for the selected scenario", error_type="Warning")
        return

    total_iterations = int(search_config.get("max_iterations", 3))
    progress, task_id = display_progress_bar("Preparing analysis", total_iterations)

    evaluated = False

    try:
        async with create_openai_client(openai_api_key) as client:
            agent = AccommodationAgent(search_config, client, prompt_templates)

            with progress:
                for iteration in range(1, total_iterations + 1):
                    progress.update(task_id, description=f"Iteration {iteration}")

                    batch = await load_inventory_by_iteration(
                        database_url,
                        failed_items,
                        iteration_num=iteration,
                        config=search_config,
                    )

                    if not batch:
                        console.print("[yellow]No inventory options returned for this iteration.[/yellow]")
                        progress.advance(task_id)
                        continue

                    decision = await agent.evaluate_iteration(
                        iteration_num=iteration,
                        inventory_batch=batch,
                        failed_items=failed_items,
                        scenario_name=scenario_name,
                    )
                    evaluated = True
                    display_iteration_results(iteration, decision)
                    progress.advance(task_id)

                    if not decision.continue_search:
                        progress.update(task_id, completed=total_iterations)
                        break

            if not evaluated:
                display_error("Unable to evaluate accommodations; no viable inventory batches returned.", error_type="Warning")
                return

            final = await agent.final_recommendation()
            display_final_recommendation(final)
            display_success("Accommodation analysis complete")

    except AIIntegrationError as exc:
        logger.exception("AI evaluation failed")
        display_error(str(exc))


def configure_logging() -> None:
    logging.basicConfig(
        level=os.getenv("LOG_LEVEL", "INFO"),
        format="%(asctime)s %(levelname)s [%(name)s] %(message)s",
    )


def main() -> None:
    configure_logging()
    args = parse_args()

    try:
        config_dir = Path(args.config_dir)
        if not config_dir.is_dir():
            raise RuntimeError(f"Configuration directory not found: {config_dir}")

        database_url, api_key = validate_environment()

        display_success(f"Starting emergency accommodation analysis for {args.scenario}")
        asyncio.run(
            run_accommodation_analysis(
                scenario_name=args.scenario,
                config_dir=config_dir,
                database_url=database_url,
                openai_api_key=api_key,
                max_iterations_override=args.max_iterations,
            )
        )
    except (ConfigurationError, AIIntegrationError, RuntimeError) as exc:
        logger.exception("CLI execution failed")
        display_error(str(exc))
    except Exception as exc:  # pragma: no cover - unexpected failures
        logger.exception("Unexpected error")
        display_error("Unexpected error occurred. Check logs for details.")


if __name__ == "__main__":
    main()
