"""Rich console formatting for emergency accommodation CLI output."""

from typing import List, Dict
from rich.console import Console
from rich.table import Table
from rich.progress import Progress
from rich.panel import Panel
from models import AccommodationOption, IterationDecision, FinalRecommendation

console = Console()


def display_iteration_results(iteration: int, decision: IterationDecision) -> None:
    """Display results of current iteration."""
    # Implementation placeholder
    pass


def display_final_recommendation(recommendation: FinalRecommendation) -> None:
    """Display final accommodation recommendation."""
    # Implementation placeholder
    pass


def display_scenario_header(scenario_name: str, config: dict) -> None:
    """Display scenario header with configuration."""
    # Implementation placeholder
    pass


def display_progress_bar(description: str, total: int) -> Progress:
    """Create and return progress bar for operations."""
    # Implementation placeholder
    pass


def display_error(message: str, error_type: str = "Error") -> None:
    """Display error message with rich formatting."""
    console.print(f"[red]{error_type}:[/red] {message}")


def display_success(message: str) -> None:
    """Display success message with rich formatting."""
    console.print(f"[green]✓[/green] {message}")