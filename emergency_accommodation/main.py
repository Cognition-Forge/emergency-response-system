"""Main CLI entry point for emergency accommodation system."""

import argparse
import asyncio
from pathlib import Path
from cli_display import console, display_error, display_success


async def run_accommodation_analysis(scenario_name: str) -> None:
    """Run complete accommodation analysis for scenario."""
    # Implementation placeholder
    console.print(f"Running accommodation analysis for {scenario_name}...")


def main() -> None:
    """Main CLI entry point."""
    parser = argparse.ArgumentParser(
        description="Emergency Accommodation CLI - AI-driven supply chain disruption response"
    )
    parser.add_argument(
        "--scenario",
        choices=["scenario1", "scenario2", "scenario3"],
        required=True,
        help="Scenario to analyze (scenario1=conservative, scenario2=balanced, scenario3=aggressive)"
    )
    parser.add_argument(
        "--config-dir",
        default="config",
        help="Configuration directory path (default: config)"
    )

    args = parser.parse_args()

    try:
        # Validate configuration directory exists
        config_path = Path(args.config_dir)
        if not config_path.exists():
            display_error(f"Configuration directory not found: {config_path}")
            return

        display_success(f"Starting emergency accommodation analysis for {args.scenario}")

        # Run async analysis
        asyncio.run(run_accommodation_analysis(args.scenario))

    except Exception as e:
        display_error(f"Application error: {e}")
        return


if __name__ == "__main__":
    main()
