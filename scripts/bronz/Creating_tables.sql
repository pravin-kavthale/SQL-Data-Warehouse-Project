/*
=======================================
Script: Bronze Layer Table Definitions
Author: [Pravin Kawthale]
Date: [2-08-2025]
Description:
This SQL script creates raw (bronze layer) staging tables for a data warehouse 
project. These tables are intended to hold unprocessed data ingested from CRM 
and ERP systems for further transformation in the silver and gold layers.

The script performs the following:
- Drops tables if they already exist to ensure a fresh schema.
- Creates staging tables for:
    - CRM customer information
    - CRM product information
    - CRM sales transactions
    - ERP customer demographics
    - ERP location information
    - ERP product category details

Note:
- These tables are intended for raw, untransformed data.
- Primary and foreign keys are not defined in this layer intentionally.
=======================================
*/

USE DataWarehouse;

-- Drop and create CRM customer info table
IF OBJECT_ID('bronz.Crm_cust_info', 'U') IS NOT NULL
    DROP TABLE bronz.Crm_cust_info;

CREATE TABLE bronz.Crm_cust_info (
    cst_id INT, 
    cst_key VARCHAR(50),
    cst_firstname VARCHAR(50),
    cst_lastname VARCHAR(50),
    cast_marital_status NVARCHAR(50),
    cst_gndr NVARCHAR(50),
    cst_create_date DATE
);

-- Drop and create CRM product info table
IF OBJECT_ID('bronz.Crm_prd_info', 'U') IS NOT NULL
    DROP TABLE bronz.Crm_prd_info;

CREATE TABLE bronz.Crm_prd_info (
    prd_id INT,
    prd_key NVARCHAR(50),
    prd_nm NVARCHAR(50),
    prd_cost INT,
    prd_line NVARCHAR(50),
    prd_start_dt DATE,
    prd_end_dt DATE
);

-- Drop and create CRM sales details table
IF OBJECT_ID('bronz.Crm_sales_details', 'U') IS NOT NULL
    DROP TABLE bronz.Crm_sales_details;

CREATE TABLE bronz.Crm_sales_details (
    sls_ord_num NVARCHAR(50),
    sls_prd_key NVARCHAR(50),
    sls_cust_id INT,
    sls_order_dt INT,
    sls_shit_dt INT,
    sls_due_dt INT,
    sls_sales INT,
    sls_quantity INT,
    sls_price INT
);

-- Drop and create ERP location table (fixing trailing comma)
IF OBJECT_ID('bronz.Erp_loc_a101', 'U') IS NOT NULL
    DROP TABLE bronz.Erp_loc_a101;

CREATE TABLE bronz.Erp_loc_a101 (
    cid NVARCHAR(50),
    cntry NVARCHAR(50)
);

-- Drop and create ERP customer demographic table
IF OBJECT_ID('bronz.Erp_cust_az12', 'U') IS NOT NULL
    DROP TABLE bronz.Erp_cust_az12;

CREATE TABLE bronz.Erp_cust_az12 (
    cid NVARCHAR(50),
    bdate DATE,
    gen NVARCHAR(50)
);

-- Drop and create ERP product category table (fixing trailing comma)
IF OBJECT_ID('bronz.Erp_px_cat_g1v2', 'U') IS NOT NULL
    DROP TABLE bronz.Erp_px_cat_g1v2;

CREATE TABLE bronz.Erp_px_cat_g1v2 (
    id NVARCHAR(50),
    cat NVARCHAR(50),
    subcat NVARCHAR(50),
    maintenance NVARCHAR(50)
);
