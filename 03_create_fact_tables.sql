/*
Script 03: Create fact tables / data marts
*/

USE DFF_Retail_DW;
GO

DROP TABLE IF EXISTS dw.fact_sales;
CREATE TABLE dw.fact_sales (
    sales_key            BIGINT IDENTITY(1,1) PRIMARY KEY,
    date_key             INT NOT NULL,
    store_key            INT NOT NULL,
    product_key          INT NOT NULL,
    promotion_key        INT NULL,
    price_tier_key       INT NULL,
    units_sold           INT NULL,
    unit_price           DECIMAL(18,4) NULL,
    net_sales_amount     DECIMAL(18,2) NULL,
    gross_margin_pct     DECIMAL(18,4) NULL,
    gross_margin_amount  DECIMAL(18,2) NULL,
    discount_amount      DECIMAL(18,2) NULL,
    ok_flag              TINYINT NULL,
    load_ts              DATETIME2 DEFAULT SYSUTCDATETIME()
);
GO

DROP TABLE IF EXISTS dw.fact_store_perf;
CREATE TABLE dw.fact_store_perf (
    store_perf_key          BIGINT IDENTITY(1,1) PRIMARY KEY,
    date_key                INT NOT NULL,
    store_key               INT NOT NULL,
    customer_count          INT NULL,
    transactions            INT NULL,
    net_sales               DECIMAL(18,2) NULL,
    avg_basket_size         DECIMAL(18,4) NULL,
    avg_order_value         DECIMAL(18,4) NULL,
    conversion_rate         DECIMAL(18,4) NULL,
    coupon_redemption_rate  DECIMAL(18,4) NULL,
    performance_flag        VARCHAR(20) NULL,
    load_ts                 DATETIME2 DEFAULT SYSUTCDATETIME()
);
GO

DROP TABLE IF EXISTS dw.fact_promotion_impact;
CREATE TABLE dw.fact_promotion_impact (
    promo_impact_key     BIGINT IDENTITY(1,1) PRIMARY KEY,
    date_key             INT NOT NULL,
    store_key            INT NOT NULL,
    product_key          INT NOT NULL,
    promotion_key        INT NOT NULL,
    units_sold           INT NULL,
    net_sales            DECIMAL(18,2) NULL,
    gross_margin_pct     DECIMAL(18,4) NULL,
    baseline_units       DECIMAL(18,4) NULL,
    units_lift_pct       DECIMAL(18,4) NULL,
    margin_change_pt     DECIMAL(18,4) NULL,
    load_ts              DATETIME2 DEFAULT SYSUTCDATETIME()
);
GO

DROP TABLE IF EXISTS dw.fact_demographics;
CREATE TABLE dw.fact_demographics (
    demographics_key          BIGINT IDENTITY(1,1) PRIMARY KEY,
    date_key                  INT NOT NULL,
    store_key                 INT NOT NULL,
    store_demo_key            INT NOT NULL,
    customer_count            INT NULL,
    net_sales                 DECIMAL(18,2) NULL,
    coupon_sales              DECIMAL(18,2) NULL,
    avg_sales_per_customer    DECIMAL(18,4) NULL,
    avg_coupon_spend          DECIMAL(18,4) NULL,
    coupon_redemption_rate    DECIMAL(18,4) NULL,
    load_ts                   DATETIME2 DEFAULT SYSUTCDATETIME()
);
GO
