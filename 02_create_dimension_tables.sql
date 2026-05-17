/*
Script 02: Create dimension tables
*/

USE DFF_Retail_DW;
GO

DROP TABLE IF EXISTS dw.dim_date;
CREATE TABLE dw.dim_date (
    date_key        INT IDENTITY(1,1) PRIMARY KEY,
    week_id         INT NOT NULL,
    week_start_date DATE NULL,
    week_end_date   DATE NULL,
    month_num       INT NULL,
    quarter_num     INT NULL,
    year_num        INT NULL,
    season          VARCHAR(20) NULL,
    holiday_flag    BIT DEFAULT 0
);
GO

DROP TABLE IF EXISTS dw.dim_store;
CREATE TABLE dw.dim_store (
    store_key      INT IDENTITY(1,1) PRIMARY KEY,
    store_id       INT NOT NULL,
    city           VARCHAR(100) NULL,
    zone           VARCHAR(50) NULL,
    region         VARCHAR(50) NULL,
    price_tier     VARCHAR(20) NULL,
    effective_date DATE DEFAULT CAST(GETDATE() AS DATE),
    expiry_date    DATE NULL,
    current_flag   BIT DEFAULT 1
);
GO

DROP TABLE IF EXISTS dw.dim_product;
CREATE TABLE dw.dim_product (
    product_key    INT IDENTITY(1,1) PRIMARY KEY,
    upc            BIGINT NOT NULL,
    com_code       INT NULL,
    brand          VARCHAR(100) NULL,
    product_desc   VARCHAR(255) NULL,
    size_raw       VARCHAR(100) NULL,
    case_qty       INT NULL,
    category       VARCHAR(100) NULL,
    department     VARCHAR(100) NULL,
    effective_date DATE DEFAULT CAST(GETDATE() AS DATE),
    expiry_date    DATE NULL,
    current_flag   BIT DEFAULT 1
);
GO

DROP TABLE IF EXISTS dw.dim_promotion;
CREATE TABLE dw.dim_promotion (
    promotion_key  INT IDENTITY(1,1) PRIMARY KEY,
    promotion_code VARCHAR(20) NOT NULL,
    promotion_type VARCHAR(50) NOT NULL,
    coupon_flag    BIT DEFAULT 0,
    promo_desc     VARCHAR(255) NULL
);
GO

DROP TABLE IF EXISTS dw.dim_price_tier;
CREATE TABLE dw.dim_price_tier (
    price_tier_key   INT IDENTITY(1,1) PRIMARY KEY,
    tier_name        VARCHAR(20) NOT NULL,
    tier_rule_version VARCHAR(20) DEFAULT 'v1'
);
GO

DROP TABLE IF EXISTS dw.dim_store_demo;
CREATE TABLE dw.dim_store_demo (
    store_demo_key          INT IDENTITY(1,1) PRIMARY KEY,
    store_id                INT NOT NULL,
    income                  DECIMAL(18,4) NULL,
    hsizeavg                DECIMAL(18,4) NULL,
    educ                    DECIMAL(18,4) NULL,
    density                 DECIMAL(18,4) NULL,
    income_band             VARCHAR(20) NULL,
    household_size_band     VARCHAR(20) NULL,
    education_band          VARCHAR(20) NULL,
    population_density_band VARCHAR(20) NULL,
    effective_date          DATE DEFAULT CAST(GETDATE() AS DATE),
    expiry_date             DATE NULL,
    current_flag            BIT DEFAULT 1
);
GO
