"""Rich console formatting helpers for the emergency accommodation CLI."""

from __future__ import annotations

from typing import Mapping

from rich.console import Console
from rich.panel import Panel
from rich.progress import (
    BarColumn,
    Progress,
    SpinnerColumn,
    TextColumn,
    TimeElapsedColumn,
)
from rich.progress import TaskID
from rich.table import Table
from rich.text import Text

from models import FinalRecommendation, IterationDecision

console = Console()

_IMPACT_STYLES: Mapping[str, str] = {
    "no_impact": "green",
    "minor_impact": "yellow",
    "moderate_impact": "orange1",
    "major_impact": "red3",
    "critical_decision": "bright_red",
}


def _get_console(override: Console | None) -> Console:
    return override or console


def display_iteration_results(
    iteration: int,
    decision: IterationDecision,
    *,
    console_override: Console | None = None,
) -> None:
    """Pretty-print the AI decision for a specific iteration."""

    out_console = _get_console(console_override)
    header = Text(f"Iteration {iteration}", style="bold sky_blue1")
    out_console.rule(header)

    reasoning_panel = Panel(decision.reasoning, title="AI Reasoning", border_style="cyan")
    out_console.print(reasoning_panel)

    if not decision.viable_options:
        out_console.print("[bold red]No viable options identified in this iteration.[/bold red]")
        return

    table = Table(show_header=True, header_style="bold magenta")
    table.add_column("Rank", justify="right")
    table.add_column("Summary", overflow="fold")
    table.add_column("Impact")
    table.add_column("Confidence", justify="right")
    table.add_column("Approvals", overflow="fold")
    table.add_column("Score", justify="right")

    for idx, option in enumerate(decision.viable_options, start=1):
        impact_style = _IMPACT_STYLES.get(option.impact_level, "white")
        impact_text = Text(option.impact_level.replace("_", " ").title(), style=impact_style)
        confidence_pct = f"{option.confidence * 100:.0f}%"
        approvals = ", ".join(option.approvals_required) if option.approvals_required else "None"
        table.add_row(
            str(idx),
            option.summary,
            impact_text,
            confidence_pct,
            approvals,
            f"{option.score:.1f}",
        )

    out_console.print(table)


def display_final_recommendation(
    recommendation: FinalRecommendation,
    *,
    console_override: Console | None = None,
) -> None:
    """Display the final AI-generated accommodation recommendation."""

    out_console = _get_console(console_override)
    out_console.rule(Text("Final Recommendation", style="bold green"))

    primary = recommendation.primary_option
    impact_style = _IMPACT_STYLES.get(primary.impact_level, "white")

    summary_table = Table.grid(padding=(0, 1))
    summary_table.add_row("Summary", primary.summary)
    summary_table.add_row("Impact", Text(primary.impact_level.replace("_", " ").title(), style=impact_style))
    summary_table.add_row("Confidence", f"{primary.confidence * 100:.0f}%")
    approvals = ", ".join(primary.approvals_required) if primary.approvals_required else "None"
    summary_table.add_row("Approvals", approvals)
    summary_table.add_row("Score", f"{primary.score:.1f}")

    mitigation = "\n".join(f"• {item}" for item in recommendation.risk_mitigation) or "None"

    panel = Panel.fit(
        summary_table,
        title="Primary Option",
        border_style="green",
    )
    out_console.print(panel)
    out_console.print(Panel(recommendation.executive_summary, title="Executive Summary", border_style="cyan"))
    out_console.print(Panel(mitigation, title="Risk Mitigation", border_style="magenta"))

    if recommendation.alternatives:
        alt_table = Table(show_header=True, header_style="bold blue")
        alt_table.add_column("Alternative")
        alt_table.add_column("Impact")
        alt_table.add_column("Confidence", justify="right")
        alt_table.add_column("Score", justify="right")

        for alt in recommendation.alternatives:
            impact_style = _IMPACT_STYLES.get(alt.impact_level, "white")
            alt_table.add_row(
                alt.summary,
                Text(alt.impact_level.replace("_", " ").title(), style=impact_style),
                f"{alt.confidence * 100:.0f}%",
                f"{alt.score:.1f}",
            )

        out_console.print(Panel(alt_table, title="Alternatives", border_style="blue"))


def display_scenario_header(
    scenario_name: str,
    config: Mapping[str, object],
    *,
    console_override: Console | None = None,
) -> None:
    """Render a scenario headline with key configuration values."""

    out_console = _get_console(console_override)
    title = Text(f"Scenario: {scenario_name}", style="bold white on dark_green")
    out_console.rule(title)

    overview = Table.grid(padding=(0, 2))
    overview.add_row("Max Iterations", str(config.get("max_iterations", "-")))
    overview.add_row("Batch Size", str(config.get("batch_size_per_iteration", "-")))
    overview.add_row("Early Stop Threshold", str(config.get("early_stopping_threshold", "-")))
    overview.add_row("Search Order", str(config.get("search_order", "-")))
    overview.add_row("Time Window", str(config.get("time_window_type", "-")))
    overview.add_row("Risk Tolerance", str(config.get("risk_tolerance", "-")))
    overview.add_row("Approval Preference", str(config.get("approval_preference", "-")))

    out_console.print(Panel(overview, border_style="dark_green", title="Configuration"))


def display_progress_bar(
    description: str,
    total: int,
    *,
    console_override: Console | None = None,
) -> tuple[Progress, TaskID]:
    """Create a reusable progress bar for async operations."""

    out_console = _get_console(console_override)
    progress = Progress(
        SpinnerColumn(style="cyan"),
        TextColumn("{task.description}", style="bold"),
        BarColumn(bar_width=None),
        TextColumn("{task.completed}/{task.total}"),
        TimeElapsedColumn(),
        console=out_console,
    )
    task_id = progress.add_task(description, total=total)
    return progress, task_id


def display_error(message: str, error_type: str = "Error") -> None:
    """Display error message with rich formatting."""

    console.print(f"[red]{error_type}:[/red] {message}")


def display_success(message: str) -> None:
    """Display success message with rich formatting."""

    console.print(f"[green]✓[/green] {message}")
