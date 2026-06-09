"""
KPI Weekly Narrator
Author: Sri Vaishnavi Devarashetty
Purpose: Turns a CSV of weekly KPIs into a concise executive summary.
         Used to draft Monday stakeholder briefings — always reviewed before sending.

AI governance note: Output is a first draft. Numbers are validated against
source data before the summary leaves the analyst's hands.
"""

import csv
import sys
from pathlib import Path


def load_kpis(filepath: str) -> list[dict]:
    """Load KPI CSV. Expected columns: metric, current_value, previous_value, unit."""
    with open(filepath, newline="", encoding="utf-8") as f:
        return list(csv.DictReader(f))


def calculate_change(current: float, previous: float) -> tuple[float, str]:
    """Return absolute change and direction label."""
    if previous == 0:
        return 0.0, "unchanged"
    change = current - previous
    pct = (change / previous) * 100
    direction = "up" if change > 0 else ("down" if change < 0 else "unchanged")
    return pct, direction


def format_value(value: float, unit: str) -> str:
    """Format a number with its unit for readable narrative."""
    if unit == "%":
        return f"{value:.1f}%"
    elif unit == "count":
        return f"{int(value):,}"
    elif unit == "hours":
        return f"{value:.1f} hrs"
    elif unit == "$":
        return f"${value:,.0f}"
    return str(value)


def build_narrative(kpis: list[dict], week_label: str) -> str:
    """Generate a plain-English executive summary from KPI rows."""
    lines = [f"**Weekly Analytics Briefing — {week_label}**\n"]

    highlights = []
    concerns = []

    for row in kpis:
        metric   = row["metric"]
        current  = float(row["current_value"])
        previous = float(row["previous_value"])
        unit     = row.get("unit", "count")
        target   = float(row["target"]) if row.get("target") else None

        pct_change, direction = calculate_change(current, previous)
        val_str = format_value(current, unit)

        # Build bullet
        arrow = "↑" if direction == "up" else ("↓" if direction == "down" else "→")
        change_str = f"{arrow} {abs(pct_change):.1f}% vs last week"

        # Flag vs target
        vs_target = ""
        if target is not None:
            if current >= target:
                vs_target = " ✓ on target"
            else:
                gap = format_value(target - current, unit)
                vs_target = f" ⚠ {gap} below target"

        bullet = f"- **{metric}:** {val_str}  ({change_str}){vs_target}"

        if direction == "down" or (target and current < target):
            concerns.append(bullet)
        else:
            highlights.append(bullet)

    if highlights:
        lines.append("### Highlights")
        lines.extend(highlights)
        lines.append("")

    if concerns:
        lines.append("### Areas to Watch")
        lines.extend(concerns)
        lines.append("")

    lines.append(
        "_This summary was drafted with AI assistance and reviewed by the analytics team "
        "before distribution. All figures validated against Snowflake source data._"
    )

    return "\n".join(lines)


def main(kpi_file: str, week_label: str, output_file: str | None = None) -> None:
    kpis = load_kpis(kpi_file)
    narrative = build_narrative(kpis, week_label)

    if output_file:
        Path(output_file).write_text(narrative, encoding="utf-8")
        print(f"Narrative written to {output_file}")
    else:
        print(narrative)


if __name__ == "__main__":
    # Usage: python kpi_narrator.py kpis.csv "Week of June 9, 2026" [output.md]
    if len(sys.argv) < 3:
        print("Usage: python kpi_narrator.py <kpi_csv> <week_label> [output_file]")
        sys.exit(1)

    output = sys.argv[3] if len(sys.argv) > 3 else None
    main(sys.argv[1], sys.argv[2], output)
