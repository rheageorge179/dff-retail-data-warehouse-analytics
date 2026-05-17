"""
Sample visualizations for exported DFF analytics query results.

Expected input:
- data/processed/bq1_profit_margin.csv
- data/processed/bq3_traffic_sales.csv
- data/processed/bq8_demographics.csv

These files can be exported from the SQL queries in sql/06_analytics_queries.sql.
"""

from pathlib import Path
import pandas as pd
import matplotlib.pyplot as plt

PROCESSED_DIR = Path("data/processed")
ASSET_DIR = Path("assets")
ASSET_DIR.mkdir(exist_ok=True)


def plot_bq1_profit_margin() -> None:
    path = PROCESSED_DIR / "bq1_profit_margin.csv"
    if not path.exists():
        print(f"Skipping BQ1 chart. Missing file: {path}")
        return

    df = pd.read_csv(path)
    grouped = (
        df.groupby("department", as_index=False)["overall_margin_pct"]
        .mean()
        .sort_values("overall_margin_pct", ascending=False)
    )

    plt.figure(figsize=(10, 6))
    plt.bar(grouped["department"], grouped["overall_margin_pct"])
    plt.title("Average Profit Margin by Department")
    plt.xlabel("Department")
    plt.ylabel("Average Margin %")
    plt.xticks(rotation=45, ha="right")
    plt.tight_layout()
    plt.savefig(ASSET_DIR / "bq1_profit_margin_by_department.png")
    plt.close()


def plot_bq3_traffic_sales() -> None:
    path = PROCESSED_DIR / "bq3_traffic_sales.csv"
    if not path.exists():
        print(f"Skipping BQ3 chart. Missing file: {path}")
        return

    df = pd.read_csv(path)

    plt.figure(figsize=(8, 6))
    plt.scatter(df["customer_count"], df["net_sales"])
    plt.title("Store Foot Traffic vs Weekly Sales")
    plt.xlabel("Customer Count")
    plt.ylabel("Net Sales")
    plt.tight_layout()
    plt.savefig(ASSET_DIR / "bq3_traffic_vs_sales.png")
    plt.close()


def plot_bq8_demographics() -> None:
    path = PROCESSED_DIR / "bq8_demographics.csv"
    if not path.exists():
        print(f"Skipping BQ8 chart. Missing file: {path}")
        return

    df = pd.read_csv(path)
    grouped = (
        df.groupby("income_band", as_index=False)["total_sales"]
        .sum()
        .sort_values("total_sales", ascending=False)
    )

    plt.figure(figsize=(8, 6))
    plt.bar(grouped["income_band"], grouped["total_sales"])
    plt.title("Total Sales by Income Band")
    plt.xlabel("Income Band")
    plt.ylabel("Total Sales")
    plt.tight_layout()
    plt.savefig(ASSET_DIR / "bq8_sales_by_income_band.png")
    plt.close()


def main() -> None:
    plot_bq1_profit_margin()
    plot_bq3_traffic_sales()
    plot_bq8_demographics()
    print("Charts generated in assets/ where input files were available.")


if __name__ == "__main__":
    main()
