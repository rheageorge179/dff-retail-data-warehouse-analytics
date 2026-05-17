/*
Script 04: Load dimensions
*/

USE DFF_Retail_DW;
GO

INSERT INTO dw.dim_promotion (promotion_code, promotion_type, coupon_flag, promo_desc)
SELECT 'NONE', 'Regular', 0, 'No promotion'
WHERE NOT EXISTS (SELECT 1 FROM dw.dim_promotion WHERE promotion_code = 'NONE');

INSERT INTO dw.dim_promotion (promotion_code, promotion_type, coupon_flag, promo_desc)
SELECT 'B', 'Bonus Buy', 0, 'Store bonus buy promotion'
WHERE NOT EXISTS (SELECT 1 FROM dw.dim_promotion WHERE promotion_code = 'B');

INSERT INTO dw.dim_promotion (promotion_code, promotion_type, coupon_flag, promo_desc)
SELECT 'C', 'Manufacturer Coupon', 1, 'Manufacturer coupon promotion'
WHERE NOT EXISTS (SELECT 1 FROM dw.dim_promotion WHERE promotion_code = 'C');

INSERT INTO dw.dim_promotion (promotion_code, promotion_type, coupon_flag, promo_desc)
SELECT 'S', 'Sale', 0, 'Store sale promotion'
WHERE NOT EXISTS (SELECT 1 FROM dw.dim_promotion WHERE promotion_code = 'S');
GO

INSERT INTO dw.dim_price_tier (tier_name, tier_rule_version)
SELECT tier_name, 'v1'
FROM (VALUES ('Low'), ('Medium'), ('High'), ('Unknown')) v(tier_name)
WHERE NOT EXISTS (
    SELECT 1 FROM dw.dim_price_tier d WHERE d.tier_name = v.tier_name
);
GO

INSERT INTO dw.dim_date (week_id, week_start_date, week_end_date, month_num, quarter_num, year_num, season)
SELECT DISTINCT
    src.week_id,
    MIN(src.calendar_date) AS week_start_date,
    MAX(src.calendar_date) AS week_end_date,
    MONTH(MIN(src.calendar_date)) AS month_num,
    DATEPART(QUARTER, MIN(src.calendar_date)) AS quarter_num,
    YEAR(MIN(src.calendar_date)) AS year_num,
    CASE 
        WHEN MONTH(MIN(src.calendar_date)) IN (12,1,2) THEN 'Winter'
        WHEN MONTH(MIN(src.calendar_date)) IN (3,4,5) THEN 'Spring'
        WHEN MONTH(MIN(src.calendar_date)) IN (6,7,8) THEN 'Summer'
        WHEN MONTH(MIN(src.calendar_date)) IN (9,10,11) THEN 'Fall'
        ELSE 'Unknown'
    END AS season
FROM stg.stg_customer_count src
WHERE src.week_id IS NOT NULL
GROUP BY src.week_id
HAVING NOT EXISTS (
    SELECT 1 FROM dw.dim_date d WHERE d.week_id = src.week_id
);
GO

INSERT INTO dw.dim_store (store_id, city, zone, region, price_tier)
SELECT DISTINCT
    d.store_id,
    d.city,
    d.zone,
    CASE WHEN d.zone IS NULL THEN 'Unknown' ELSE CONCAT('Zone ', d.zone) END AS region,
    CASE
        WHEN d.income IS NULL THEN 'Unknown'
        WHEN d.income < 33.33 THEN 'Low'
        WHEN d.income < 66.66 THEN 'Medium'
        ELSE 'High'
    END AS price_tier
FROM stg.stg_demographics d
WHERE NOT EXISTS (
    SELECT 1 FROM dw.dim_store s
    WHERE s.store_id = d.store_id
      AND s.current_flag = 1
);
GO

INSERT INTO dw.dim_product (
    upc, com_code, brand, product_desc, size_raw, case_qty, category, department
)
SELECT DISTINCT
    u.upc,
    u.com_code,
    LEFT(u.product_desc, NULLIF(CHARINDEX(' ', u.product_desc + ' '), 0) - 1) AS brand,
    u.product_desc,
    u.size_raw,
    u.case_qty,
    COALESCE(u.source_category, 'Unknown') AS category,
    CASE
        WHEN u.source_category IN ('WCHE') THEN 'Cheese'
        WHEN u.source_category IN ('WFRD') THEN 'Frozen Dinners'
        WHEN u.source_category IN ('WSDR') THEN 'Soft Drinks'
        WHEN u.source_category IN ('WTBR') THEN 'Beer'
        ELSE COALESCE(u.source_category, 'Unknown')
    END AS department
FROM stg.stg_upc u
WHERE NOT EXISTS (
    SELECT 1 FROM dw.dim_product p
    WHERE p.upc = u.upc
      AND p.current_flag = 1
);
GO

INSERT INTO dw.dim_store_demo (
    store_id, income, hsizeavg, educ, density,
    income_band, household_size_band, education_band, population_density_band
)
SELECT
    store_id,
    income,
    hsizeavg,
    educ,
    density,
    CASE
        WHEN income IS NULL THEN 'Unknown'
        WHEN income < 33.33 THEN 'Low'
        WHEN income < 66.66 THEN 'Medium'
        ELSE 'High'
    END AS income_band,
    CASE
        WHEN hsizeavg IS NULL THEN 'Unknown'
        WHEN hsizeavg < 2 THEN 'Small'
        WHEN hsizeavg < 3.5 THEN 'Medium'
        ELSE 'Large'
    END AS household_size_band,
    CASE
        WHEN educ IS NULL THEN 'Unknown'
        WHEN educ < 33.33 THEN 'Low'
        WHEN educ < 66.66 THEN 'Medium'
        ELSE 'High'
    END AS education_band,
    CASE
        WHEN density IS NULL THEN 'Unknown'
        WHEN density < 33.33 THEN 'Low Density'
        WHEN density < 66.66 THEN 'Medium Density'
        ELSE 'High Density'
    END AS population_density_band
FROM stg.stg_demographics d
WHERE NOT EXISTS (
    SELECT 1 FROM dw.dim_store_demo demo
    WHERE demo.store_id = d.store_id
      AND demo.current_flag = 1
);
GO
