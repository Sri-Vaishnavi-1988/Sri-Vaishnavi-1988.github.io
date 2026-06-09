"""
Data Cleaning Pipeline — L&D Enrollment Data
Author: Sri Vaishnavi Devarashetty
Context: Preprocessing pattern used before loading to Snowflake for Tableau dashboards
"""

import pandas as pd
import numpy as np


def load_raw_data(filepath: str) -> pd.DataFrame:
    """Load raw CSV export from the L&D platform."""
    df = pd.read_csv(filepath, parse_dates=["enrollment_date", "completion_date"])
    print(f"Loaded {len(df):,} rows from {filepath}")
    return df


def standardise_columns(df: pd.DataFrame) -> pd.DataFrame:
    """Lowercase and snake_case all column names."""
    df.columns = (
        df.columns
        .str.strip()
        .str.lower()
        .str.replace(r"[\s\-]+", "_", regex=True)
    )
    return df


def clean_status_field(df: pd.DataFrame) -> pd.DataFrame:
    """Normalise free-text status values to controlled vocabulary."""
    status_map = {
        "complete":     "completed",
        "done":         "completed",
        "finished":     "completed",
        "in progress":  "in_progress",
        "started":      "in_progress",
        "not started":  "not_started",
        "enrolled":     "not_started",
    }
    df["status"] = (
        df["status"]
        .str.strip()
        .str.lower()
        .map(status_map)
        .fillna("unknown")
    )
    return df


def handle_missing_scores(df: pd.DataFrame) -> pd.DataFrame:
    """
    Scores are only meaningful for completed courses.
    Fill missing scores for in-progress / not-started with NaN (not 0).
    Zero would skew averages; NaN is correctly excluded by aggregations.
    """
    df.loc[df["status"] != "completed", "score"] = np.nan
    return df


def derive_completion_days(df: pd.DataFrame) -> pd.DataFrame:
    """Add days_to_complete — useful KPI for course difficulty benchmarking."""
    df["days_to_complete"] = (
        df["completion_date"] - df["enrollment_date"]
    ).dt.days
    # Negative values indicate data entry errors — flag them
    df["data_quality_flag"] = df["days_to_complete"].apply(
        lambda x: "negative_duration" if pd.notna(x) and x < 0 else None
    )
    return df


def remove_duplicates(df: pd.DataFrame) -> pd.DataFrame:
    """
    Remove duplicate enrollment records.
    Keep the row with the latest completion_date if duplicated.
    """
    before = len(df)
    df = (
        df
        .sort_values("completion_date", na_position="last")
        .drop_duplicates(subset=["learner_id", "course_id"], keep="last")
    )
    after = len(df)
    print(f"Removed {before - after:,} duplicate rows")
    return df


def flag_data_quality_issues(df: pd.DataFrame) -> pd.DataFrame:
    """Summary report of data quality issues — used in governance reviews."""
    issues = {
        "missing_learner_id":    df["learner_id"].isna().sum(),
        "missing_course_id":     df["course_id"].isna().sum(),
        "unknown_status":        (df["status"] == "unknown").sum(),
        "negative_duration":     (df["data_quality_flag"] == "negative_duration").sum(),
        "completed_no_score":    (
            (df["status"] == "completed") & df["score"].isna()
        ).sum(),
    }
    print("\n── Data Quality Report ─────────────────────")
    for issue, count in issues.items():
        flag = "⚠" if count > 0 else "✓"
        print(f"  {flag}  {issue}: {count:,}")
    print("────────────────────────────────────────────\n")
    return df


def run_pipeline(input_path: str, output_path: str) -> pd.DataFrame:
    """End-to-end pipeline: load → clean → validate → export."""
    df = load_raw_data(input_path)
    df = standardise_columns(df)
    df = clean_status_field(df)
    df = handle_missing_scores(df)
    df = derive_completion_days(df)
    df = remove_duplicates(df)
    df = flag_data_quality_issues(df)

    df.to_csv(output_path, index=False)
    print(f"Clean data written to {output_path} — {len(df):,} rows")
    return df


if __name__ == "__main__":
    run_pipeline(
        input_path="data/raw_ld_enrollments.csv",
        output_path="data/clean_ld_enrollments.csv"
    )
