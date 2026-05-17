# DFF Retail Data Warehouse & BI Analytics

## Project Overview

This project builds a retail analytics data warehouse for **Dominick's Finer Foods (DFF)** using historical store-level sales, customer traffic, promotion, product, and demographic data.

The goal is to convert normalized operational retail files into a dimensional warehouse that supports decision-making around:

- Category profitability
- Price elasticity
- Store traffic vs. sales conversion
- Promotion and coupon effectiveness
- Demographic impact on sales and coupon behavior

This repository is structured as a recruiter/interview-ready version of the original academic data warehousing project. It focuses on the technical implementation: SQL schema design, ETL logic, analytics queries, and BI reporting structure.

---

## Business Questions Answered

1. **Profitability:** Which product categories generate the highest profit margins across stores, and how do margins vary by season or promotion?
2. **Price Elasticity:** How does price elasticity vary across product categories and pricing tiers?
3. **Store Performance:** What is the relationship between store foot traffic and weekly sales?
4. **Promotion Impact:** How do manufacturer coupons and store promotions compare in sales lift and margin impact?
5. **Demographics:** Do income level and household size influence weekly sales and coupon usage?

---

## Data Sources

The DFF dataset is organized into four source families:

| Source | Grain | Purpose |
|---|---:|---|
| Movement files | Store × Week × UPC | Weekly units sold, price, profit, promotion flag |
| UPC master files | Product / UPC | Product description, size, category metadata |
| Customer count files | Store × Day | Daily traffic, department sales, coupon activity |
| Demographics file | Store | Income, education, household size, competition, market attributes |

> Raw data is not included in this repository because the original dataset is large. Place downloaded files in `data/raw/` before running the ETL scripts.

---

## Architecture

```text
Raw CSV Files
    |
    v
Staging Tables
    |
    v
Dimensional Data Warehouse
    |
    +-- Dim_Date
    +-- Dim_Store
    +-- Dim_Product
    +-- Dim_Promotion
    +-- Dim_Price_Tier
    +-- Dim_Store_Demo
    |
    v
Fact Tables / Data Marts
    |
    +-- Fact_Sales
    +-- Fact_Store_Perf
    +-- Fact_Promotion_Impact
    +-- Fact_Demographics
    |
    v
BI / Analytics Layer
    |
    +-- Profitability reports
    +-- Elasticity analysis
    +-- Traffic vs. sales dashboards
    +-- Promotion impact dashboards
    +-- Demographic segmentation reports
```

---

## Repository Structure

```text
.
├── sql/
│   ├── 00_create_database_schemas.sql
│   ├── 01_create_staging_tables.sql
│   ├── 02_create_dimension_tables.sql
│   ├── 03_create_fact_tables.sql
│   ├── 04_etl_load_dimensions.sql
│   ├── 05_etl_load_facts.sql
│   └── 06_analytics_queries.sql
├── python/
│   ├── data_quality_checks.py
│   └── sample_visuals.py
├── docs/
│   ├── architecture.md
│   ├── project_summary_for_submission.md
│   └── video_walkthrough_script.md
├── data/
│   ├── raw/
│   └── processed/
├── assets/
├── requirements.txt
└── .gitignore
```

---

## Tools Used

- SQL Server / T-SQL for data warehouse modeling and ETL logic
- Amazon Redshift-compatible SQL for demographic segmentation queries
- Power BI / Tableau-ready reporting queries
- Python for data quality validation and sample visualizations
- Kimball dimensional modeling methodology

---

## Key Technical Highlights

- Designed a Kimball-style dimensional model with conformed dimensions.
- Built independent but connected data marts for sales, store performance, promotion impact, and demographic analysis.
- Declared fact table grains before implementing measures to avoid mixed-grain reporting issues.
- Created derived KPIs including gross margin amount, margin percentage, conversion rate, average basket size, coupon redemption rate, unit lift percentage, and average sales per customer.
- Used staging-to-warehouse ETL logic to clean invalid records, standardize product/category fields, create demographic bands, and load fact tables.
- Wrote analytics queries that directly map to business questions.

---

## How to Use This Repository

### 1. Clone the repository

```bash
git clone https://github.com/<your-username>/dff-retail-data-warehouse-analytics.git
cd dff-retail-data-warehouse-analytics
```

### 2. Add raw data

Place the source CSV files into:

```text
data/raw/
```

Expected source families:

```text
CCOUNT.csv
DEMO.csv
UPC*.csv
DONE-W*.csv
```

### 3. Run SQL scripts in order

```text
00_create_database_schemas.sql
01_create_staging_tables.sql
02_create_dimension_tables.sql
03_create_fact_tables.sql
04_etl_load_dimensions.sql
05_etl_load_facts.sql
06_analytics_queries.sql
```

### 4. Run optional Python checks

```bash
pip install -r requirements.txt
python python/data_quality_checks.py
python python/sample_visuals.py
```

---

## Example Insights

- Promotional periods increased revenue for several categories, but margin impact varied by product group.
- Store traffic showed a strong relationship with weekly sales, suggesting that many low-performing stores were traffic-constrained rather than purely conversion-constrained.
- Medium-income store areas generated stronger sales than expected, making them valuable targets for promotion and assortment planning.
- Promotion lift should be evaluated together with margin change, not revenue alone.

---



