/*
------------------------------------------------------------------------------------
-- Script Name   : Create_Silver_Layer_Tables.sql
-- Description   : This script is used to create the required tables in the 'silver' 
--                 layer of the DataWarehouse. It includes CRM and ERP-related 
--                 customer, product, sales, and location tables.
-- 
--                The script:
--                  - Checks and drops existing tables if they exist
--                  - Recreates all tables with appropriate data types
--                  - Adds a data warehouse tracking column 'dwh_create_date' 
--                    with default current timestamp
--
-- Tables Created:
--   1. silver.Crm_cust_info       - CRM Customer Information
--   2. silver.Crm_prd_info        - CRM Product Information
--   3. silver.Crm_sales_details   - CRM Sales Transaction Details
--   4. silver.Erp_loc_a101        - ERP Customer Location Details
--   5. silver.Erp_cust_az12       - ERP Customer Demographic Details
--   6. silver.Erp_px_cat_g1v2     - ERP Product Category & Maintenance Info
--
-- Author        : [Pravin Kawthale]
------------------------------------------------------------------------------------
*/
USE DataWarehouse;

-- Drop and Create: silver.Crm_cust_info
IF OBJECT_ID('silver.Crm_cust_info', 'U') IS NOT NULL
    DROP TABLE silver.Crm_cust_info;

CREATE TABLE silver.Crm_cust_info (
    cst_id INT,
    cst_key VARCHAR(50),
    cst_firstname VARCHAR(50),
    cst_lastname VARCHAR(50),
    cst_marital_status NVARCHAR(50),
    cst_gndr NVARCHAR(50),
    cst_create_date DATE,
    dwh_create_date DATETIME2 DEFAULT GETDATE()
);

-- Drop and Create: silver.Crm_prd_info
IF OBJECT_ID('silver.Crm_prd_info', 'U') IS NOT NULL
    DROP TABLE silver.Crm_prd_info;

CREATE TABLE silver.Crm_prd_info (
    prd_id INT,
    cat_id NVARCHAR(50),
    prd_key NVARCHAR(50),
    prd_nm NVARCHAR(50),
    prd_cost INT,
    prd_line NVARCHAR(50),
    prd_start_dt DATE,
    prd_end_dt DATE,
    dwh_create_date DATETIME2 DEFAULT GETDATE()
);

-- Drop and Create: silver.Crm_sales_details
IF OBJECT_ID('silver.Crm_sales_details', 'U') IS NOT NULL
    DROP TABLE silver.Crm_sales_details;

CREATE TABLE silver.Crm_sales_details (
    sls_ord_num NVARCHAR(50),
    sls_prd_key NVARCHAR(50),
    sls_cust_id INT,
    sls_order_dt DATE,
    sls_ship_dt DATE,
    sls_due_dt DATE,
    sls_sales INT,
    sls_quantity INT,
    sls_price INT,
    dwh_create_date DATETIME2 DEFAULT GETDATE()
);

-- Drop and Create: silver.Erp_loc_a101
IF OBJECT_ID('silver.Erp_loc_a101', 'U') IS NOT NULL
    DROP TABLE silver.Erp_loc_a101;

CREATE TABLE silver.Erp_loc_a101 (
    cid NVARCHAR(50),
    cntry NVARCHAR(50),
    dwh_create_date DATETIME2 DEFAULT GETDATE()
);

-- Drop and Create: silver.Erp_cust_az12
IF OBJECT_ID('silver.Erp_cust_az12', 'U') IS NOT NULL
    DROP TABLE silver.Erp_cust_az12;

CREATE TABLE silver.Erp_cust_az12 (
    cid NVARCHAR(50),
    bdate DATE,
    gen NVARCHAR(50),
    dwh_create_date DATETIME2 DEFAULT GETDATE()
);

-- Drop and Create: silver.Erp_px_cat_g1v2
IF OBJECT_ID('silver.Erp_px_cat_g1v2', 'U') IS NOT NULL
    DROP TABLE silver.Erp_px_cat_g1v2;

CREATE TABLE silver.Erp_px_cat_g1v2 (
    id NVARCHAR(50),
    cat NVARCHAR(50),
    subcat NVARCHAR(50),
    maintenance NVARCHAR(50),
    dwh_create_date DATETIME2 DEFAULT GETDATE()
);

