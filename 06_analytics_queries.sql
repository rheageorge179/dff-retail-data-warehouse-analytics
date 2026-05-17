/*
Script 06: Analytics queries mapped to business questions
*/

USE DFF_Retail_DW;
GO

-- BQ1: Profit margin by department, season, and promotion type
SELECT
    p.department,
    d.season,
    promo.promotion_type,
    SUM(fs.net_sales_amount) AS total_net_sales,
    SUM(fs.gross_margin_amount) AS total_gross_margin,
    SUM(fs.gross_margin_amount) / NULLIF(SUM(fs.net_sales_amount), 0) AS overall_margin_pct
FROM dw.fact_sales fs
JOIN dw.dim_product p
    ON p.product_key = fs.product_key
JOIN dw.dim_date d
    ON d.date_key = fs.date_key
LEFT JOIN dw.dim_promotion promo
    ON promo.promotion_key = fs.promotion_key
GROUP BY p.department, d.season, promo.promotion_type
ORDER BY overall_margin_pct DESC;
GO

-- BQ2: Price elasticity style analysis by category and price tier
SELECT
    p.department,
    tier.tier_name,
    ROUND(fs.unit_price, 2) AS rounded_unit_price,
    SUM(fs.units_sold) AS total_units_sold,
    SUM(fs.net_sales_amount) AS total_sales
FROM dw.fact_sales fs
JOIN dw.dim_product p
    ON p.product_key = fs.product_key
LEFT JOIN dw.dim_price_tier tier
    ON tier.price_tier_key = fs.price_tier_key
GROUP BY p.department, tier.tier_name, ROUND(fs.unit_price, 2)
ORDER BY p.department, tier.tier_name, rounded_unit_price;
GO

-- BQ3: Store traffic vs weekly sales
SELECT
    st.store_id,
    st.zone,
    dt.week_id,
    fp.customer_count,
    fp.net_sales,
    fp.conversion_rate,
    fp.avg_order_value,
    fp.performance_flag
FROM dw.fact_store_perf fp
JOIN dw.dim_store st
    ON st.store_key = fp.store_key
JOIN dw.dim_date dt
    ON dt.date_key = fp.date_key
ORDER BY fp.net_sales DESC;
GO

-- BQ4: Manufacturer coupon vs store promotion impact
SELECT
    p.department,
    promo.promotion_type,
    AVG(fpi.units_lift_pct) AS avg_units_lift_pct,
    AVG(fpi.margin_change_pt) AS avg_margin_change_pt,
    SUM(fpi.net_sales) AS promo_net_sales
FROM dw.fact_promotion_impact fpi
JOIN dw.dim_product p
    ON p.product_key = fpi.product_key
JOIN dw.dim_promotion promo
    ON promo.promotion_key = fpi.promotion_key
GROUP BY p.department, promo.promotion_type
ORDER BY promo_net_sales DESC;
GO

-- BQ8: Demographic impact on sales and coupon behavior
SELECT
    demo.income_band,
    demo.household_size_band,
    SUM(fd.net_sales) AS total_sales,
    SUM(fd.coupon_sales) AS total_coupon_sales,
    AVG(fd.avg_sales_per_customer) AS avg_sales_per_customer,
    AVG(fd.coupon_redemption_rate) AS avg_coupon_redemption_rate
FROM dw.fact_demographics fd
JOIN dw.dim_store_demo demo
    ON demo.store_demo_key = fd.store_demo_key
GROUP BY demo.income_band, demo.household_size_band
ORDER BY total_sales DESC;
GO

-- Data validation: fact row counts
SELECT 'fact_sales' AS table_name, COUNT(*) AS row_count FROM dw.fact_sales
UNION ALL
SELECT 'fact_store_perf', COUNT(*) FROM dw.fact_store_perf
UNION ALL
SELECT 'fact_promotion_impact', COUNT(*) FROM dw.fact_promotion_impact
UNION ALL
SELECT 'fact_demographics', COUNT(*) FROM dw.fact_demographics;
GO
