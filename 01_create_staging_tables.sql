/*
Script 01: Create staging tables

These tables mirror the major DFF source families:
- Movement files: Store x Week x UPC
- UPC files: Product metadata
- Customer count: Store x Day
- Demographics: Store-level profile
*/

USE DFF_Retail_DW;
GO

DROP TABLE IF EXISTS stg.stg_movement;
CREATE TABLE stg.stg_movement (
    store_id        INT             NOT NULL,
    week_id         INT             NOT NULL,
    upc             BIGINT          NOT NULL,
    move_units      INT             NULL,
    qty             DECIMAL(18,4)   NULL,
    price           DECIMAL(18,4)   NULL,
    profit          DECIMAL(18,4)   NULL,
    sale_code       VARCHAR(10)     NULL,
    ok_flag         TINYINT         NULL,
    source_category VARCHAR(50)     NULL,
    src_filename    VARCHAR(255)    NULL,
    load_ts         DATETIME2       DEFAULT SYSUTCDATETIME()
);
GO

DROP TABLE IF EXISTS stg.stg_upc;
CREATE TABLE stg.stg_upc (
    upc             BIGINT          NOT NULL,
    com_code        INT             NULL,
    product_desc    VARCHAR(255)    NULL,
    size_raw        VARCHAR(100)    NULL,
    case_qty        INT             NULL,
    source_category VARCHAR(50)     NULL,
    src_filename    VARCHAR(255)    NULL,
    load_ts         DATETIME2       DEFAULT SYSUTCDATETIME()
);
GO

DROP TABLE IF EXISTS stg.stg_customer_count;
CREATE TABLE stg.stg_customer_count (
    store_id        INT             NOT NULL,
    calendar_date   DATE            NOT NULL,
    week_id         INT             NULL,
    custcount       INT             NULL,
    mvpclub         INT             NULL,
    grocery_sales   DECIMAL(18,2)   NULL,
    meat_sales      DECIMAL(18,2)   NULL,
    produce_sales   DECIMAL(18,2)   NULL,
    frozen_sales    DECIMAL(18,2)   NULL,
    bakery_sales    DECIMAL(18,2)   NULL,
    pharmacy_sales  DECIMAL(18,2)   NULL,
    man_coupons     DECIMAL(18,2)   NULL,
    promo_sales     DECIMAL(18,2)   NULL,
    src_filename    VARCHAR(255)    NULL,
    load_ts         DATETIME2       DEFAULT SYSUTCDATETIME()
);
GO

DROP TABLE IF EXISTS stg.stg_demographics;
CREATE TABLE stg.stg_demographics (
    store_id        INT             NOT NULL,
    city            VARCHAR(100)    NULL,
    zip_code        VARCHAR(20)     NULL,
    zone            VARCHAR(50)     NULL,
    income          DECIMAL(18,4)   NULL,
    hsizeavg        DECIMAL(18,4)   NULL,
    educ            DECIMAL(18,4)   NULL,
    density         DECIMAL(18,4)   NULL,
    cubdist         DECIMAL(18,4)   NULL,
    omnidist        DECIMAL(18,4)   NULL,
    src_filename    VARCHAR(255)    NULL,
    load_ts         DATETIME2       DEFAULT SYSUTCDATETIME()
);
GO

/*
Example bulk load pattern.
Adjust file paths for your local or server environment.

BULK INSERT stg.stg_movement
FROM 'C:\dff\data\DONE-WCHE.csv'
WITH (
    FIRSTROW = 2,
    FIELDTERMINATOR = ',',
    ROWTERMINATOR = '0x0a',
    TABLOCK
);
*/
