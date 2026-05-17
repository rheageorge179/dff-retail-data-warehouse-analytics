"""
Data quality checks for the DFF Retail Data Warehouse project.

This script is intentionally lightweight so it can run against CSV extracts
or processed files before loading into SQL Server.
"""

from pathlib import Path
import pandas as pd

RAW_DIR = Path("data/raw")
PROCESSED_DIR = Path("data/processed")


def profile_file(path: Path) -> dict:
    """Return basic quality metrics for a CSV file."""
    df = pd.read_csv(path, nrows=100000)
    return {
        "file": path.name,
        "rows_sampled": len(df),
        "columns": len(df.columns),
        "duplicate_rows": int(df.duplicated().sum()),
        "missing_cells": int(df.isna().sum().sum()),
        "missing_pct": round(float(df.isna().mean().mean() * 100), 2),
    }


def main() -> None:
    csv_files = sorted(RAW_DIR.glob("*.csv"))

    if not csv_files:
        print("No raw CSV files found in data/raw/. Add DFF source files first.")
        return

    results = [profile_file(path) for path in csv_files]
    report = pd.DataFrame(results)

    PROCESSED_DIR.mkdir(parents=True, exist_ok=True)
    output_path = PROCESSED_DIR / "data_quality_profile.csv"
    report.to_csv(output_path, index=False)

    print(report.to_string(index=False))
    print(f"\nSaved quality profile to: {output_path}")


if __name__ == "__main__":
    main()
