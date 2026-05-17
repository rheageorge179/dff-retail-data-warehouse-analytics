/*
Amazon Redshift Query Editor v2 compatible queries
Use this for demographic segmentation reporting.
*/

-- Total sales by income band
SELECT
    d.income_band,
    SUM(f.net_sales) AS total_sales,
    SUM(f.coupon_sales) AS total_coupon_sales,
    AVG(f.avg_sales_per_customer) AS avg_sales_per_customer
FROM fact_demographics f
JOIN dim_store_demo d
    ON d.store_demo_key = f.store_demo_key
GROUP BY d.income_band
ORDER BY total_sales DESC;

-- Coupon sales by household size band
SELECT
    d.household_size_band,
    SUM(f.coupon_sales) AS total_coupon_sales,
    AVG(f.coupon_redemption_rate) AS avg_coupon_redemption_rate
FROM fact_demographics f
JOIN dim_store_demo d
    ON d.store_demo_key = f.store_demo_key
GROUP BY d.household_size_band
ORDER BY total_coupon_sales DESC;

-- Average sales per customer by education band
SELECT
    d.education_band,
    AVG(f.avg_sales_per_customer) AS avg_sales_per_customer,
    SUM(f.net_sales) AS total_sales
FROM fact_demographics f
JOIN dim_store_demo d
    ON d.store_demo_key = f.store_demo_key
GROUP BY d.education_band
ORDER BY avg_sales_per_customer DESC;
