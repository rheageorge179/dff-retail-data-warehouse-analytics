/*
Script 05: Load fact tables
*/

USE DFF_Retail_DW;
GO

INSERT INTO dw.fact_sales (
    date_key,
    store_key,
    product_key,
    promotion_key,
    price_tier_key,
    units_sold,
    unit_price,
    net_sales_amount,
    gross_margin_pct,
    gross_margin_amount,
    discount_amount,
    ok_flag
)
SELECT
    dt.date_key,
    st.store_key,
    pr.product_key,
    promo.promotion_key,
    tier.price_tier_key,
    mv.move_units AS units_sold,
    CASE WHEN NULLIF(mv.qty, 0) IS NULL THEN mv.price ELSE mv.price / NULLIF(mv.qty, 0) END AS unit_price,
    mv.move_units * (CASE WHEN NULLIF(mv.qty, 0) IS NULL THEN mv.price ELSE mv.price / NULLIF(mv.qty, 0) END) AS net_sales_amount,
    mv.profit AS gross_margin_pct,
    (mv.move_units * (CASE WHEN NULLIF(mv.qty, 0) IS NULL THEN mv.price ELSE mv.price / NULLIF(mv.qty, 0) END)) * COALESCE(mv.profit, 0) AS gross_margin_amount,
    CASE WHEN mv.sale_code IS NULL THEN 0 ELSE ABS(COALESCE(mv.price,0) * 0.05) END AS discount_amount,
    mv.ok_flag
FROM stg.stg_movement mv
JOIN dw.dim_date dt
    ON dt.week_id = mv.week_id
JOIN dw.dim_store st
    ON st.store_id = mv.store_id
   AND st.current_flag = 1
JOIN dw.dim_product pr
    ON pr.upc = mv.upc
   AND pr.current_flag = 1
LEFT JOIN dw.dim_promotion promo
    ON promo.promotion_code = COALESCE(NULLIF(mv.sale_code, ''), 'NONE')
LEFT JOIN dw.dim_price_tier tier
    ON tier.tier_name = COALESCE(st.price_tier, 'Unknown')
WHERE COALESCE(mv.ok_flag, 1) = 1;
GO

DROP TABLE IF EXISTS #ccount_store_week;
SELECT
    c.store_id,
    c.week_id,
    SUM(COALESCE(c.custcount, 0)) AS customer_count,
    SUM(COALESCE(c.man_coupons, 0) + COALESCE(c.promo_sales, 0)) AS coupon_sales
INTO #ccount_store_week
FROM stg.stg_customer_count c
GROUP BY c.store_id, c.week_id;

DROP TABLE IF EXISTS #sales_store_week;
SELECT
    st.store_id,
    dt.week_id,
    SUM(fs.net_sales_amount) AS net_sales,
    SUM(fs.units_sold) AS total_units,
    COUNT_BIG(*) AS transactions
INTO #sales_store_week
FROM dw.fact_sales fs
JOIN dw.dim_store st ON st.store_key = fs.store_key
JOIN dw.dim_date dt ON dt.date_key = fs.date_key
GROUP BY st.store_id, dt.week_id;

INSERT INTO dw.fact_store_perf (
    date_key,
    store_key,
    customer_count,
    transactions,
    net_sales,
    avg_basket_size,
    avg_order_value,
    conversion_rate,
    coupon_redemption_rate,
    performance_flag
)
SELECT
    dt.date_key,
    st.store_key,
    c.customer_count,
    CAST(s.transactions AS INT),
    s.net_sales,
    s.total_units / NULLIF(CAST(s.transactions AS DECIMAL(18,4)), 0) AS avg_basket_size,
    s.net_sales / NULLIF(CAST(s.transactions AS DECIMAL(18,4)), 0) AS avg_order_value,
    CAST(s.transactions AS DECIMAL(18,4)) / NULLIF(c.customer_count, 0) AS conversion_rate,
    c.coupon_sales / NULLIF(s.net_sales, 0) AS coupon_redemption_rate,
    CASE
        WHEN s.net_sales IS NULL THEN 'Unknown'
        WHEN s.net_sales < 10000 THEN 'Low'
        WHEN s.net_sales < 25000 THEN 'Medium'
        ELSE 'High'
    END AS performance_flag
FROM #ccount_store_week c
JOIN #sales_store_week s
    ON s.store_id = c.store_id
   AND s.week_id = c.week_id
JOIN dw.dim_store st
    ON st.store_id = c.store_id
   AND st.current_flag = 1
JOIN dw.dim_date dt
    ON dt.week_id = c.week_id;
GO

WITH non_promo_baseline AS (
    SELECT
        store_key,
        product_key,
        AVG(CAST(units_sold AS DECIMAL(18,4))) AS baseline_units,
        AVG(gross_margin_pct) AS baseline_margin_pct
    FROM dw.fact_sales fs
    JOIN dw.dim_promotion p ON p.promotion_key = fs.promotion_key
    WHERE p.promotion_type = 'Regular'
    GROUP BY store_key, product_key
)
INSERT INTO dw.fact_promotion_impact (
    date_key,
    store_key,
    product_key,
    promotion_key,
    units_sold,
    net_sales,
    gross_margin_pct,
    baseline_units,
    units_lift_pct,
    margin_change_pt
)
SELECT
    fs.date_key,
    fs.store_key,
    fs.product_key,
    fs.promotion_key,
    fs.units_sold,
    fs.net_sales_amount,
    fs.gross_margin_pct,
    b.baseline_units,
    (fs.units_sold - b.baseline_units) / NULLIF(b.baseline_units, 0) AS units_lift_pct,
    fs.gross_margin_pct - b.baseline_margin_pct AS margin_change_pt
FROM dw.fact_sales fs
JOIN dw.dim_promotion p
    ON p.promotion_key = fs.promotion_key
LEFT JOIN non_promo_baseline b
    ON b.store_key = fs.store_key
   AND b.product_key = fs.product_key
WHERE p.promotion_type <> 'Regular';
GO

INSERT INTO dw.fact_demographics (
    date_key,
    store_key,
    store_demo_key,
    customer_count,
    net_sales,
    coupon_sales,
    avg_sales_per_customer,
    avg_coupon_spend,
    coupon_redemption_rate
)
SELECT
    dt.date_key,
    st.store_key,
    demo.store_demo_key,
    c.customer_count,
    s.net_sales,
    c.coupon_sales,
    s.net_sales / NULLIF(c.customer_count, 0) AS avg_sales_per_customer,
    c.coupon_sales / NULLIF(c.customer_count, 0) AS avg_coupon_spend,
    c.coupon_sales / NULLIF(s.net_sales, 0) AS coupon_redemption_rate
FROM #ccount_store_week c
JOIN #sales_store_week s
    ON s.store_id = c.store_id
   AND s.week_id = c.week_id
JOIN dw.dim_date dt
    ON dt.week_id = c.week_id
JOIN dw.dim_store st
    ON st.store_id = c.store_id
   AND st.current_flag = 1
JOIN dw.dim_store_demo demo
    ON demo.store_id = c.store_id
   AND demo.current_flag = 1;
GO

DROP TABLE IF EXISTS #ccount_store_week;
DROP TABLE IF EXISTS #sales_store_week;
GO
