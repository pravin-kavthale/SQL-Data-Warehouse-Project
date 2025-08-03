/*
===============================================================================
 Script Name   : load_silver.sql
 Procedure     : silver.load_silver
 Description   : This procedure performs the ETL operations for loading data 
                 from the Bronze layer to the Silver layer in the Data Warehouse.
                 It includes the following transformations:
                   - Truncates existing silver tables before reloading
                   - Cleanses and standardizes fields like gender, country, and dates
                   - Ensures deduplication using ROW_NUMBER()
                   - Calculates derived fields like end dates
                   - Handles nulls and invalid values
                 All load steps are timed and errors are handled with TRY/CATCH.

 Author        : [Your Name]
 Last Updated  : [Date]
===============================================================================
*/

USE DataWarehouse;

EXEC silver.load_silver;

CREATE OR ALTER PROCEDURE silver.load_silver
AS
BEGIN
    DECLARE @start_time DATETIME, @end_time DATETIME, 
            @silver_start_time DATETIME, @silver_end_time DATETIME;

    BEGIN TRY
        SET @silver_start_time = GETDATE();

        PRINT '-------------------------------------------------------------------';
        PRINT 'CRM Tables';
        PRINT '-------------------------------------------------------------------';

        --------------------------
        -- Load Crm_cust_info
        --------------------------
        SET @start_time = GETDATE();
        PRINT '>> truncating table: silver.Crm_cust_info';
        TRUNCATE TABLE silver.Crm_cust_info;

        PRINT '>> inserting into table: silver.Crm_cust_info';
        INSERT INTO silver.Crm_cust_info (
            cst_id, cst_key, cst_firstname, cst_lastname,
            cst_marital_status, cst_gndr, cst_create_date
        )
        SELECT 
            cst_id,
            cst_key,
            TRIM(cst_firstname),
            TRIM(cst_lastname),
            CASE 
                WHEN UPPER(TRIM(cst_marital_status)) = 'S' THEN 'Single'
                WHEN UPPER(TRIM(cst_marital_status)) = 'M' THEN 'Married'
                ELSE 'n/a'
            END,
            CASE 
                WHEN UPPER(TRIM(cst_gndr)) = 'F' THEN 'Female'
                WHEN UPPER(TRIM(cst_gndr)) = 'M' THEN 'Male'
                ELSE 'n/a'
            END,
            cst_create_date
        FROM (
            SELECT *, 
                   ROW_NUMBER() OVER(PARTITION BY cst_id ORDER BY cst_create_date DESC) AS flag_last
            FROM bronz.Crm_cust_info
        ) t
        WHERE flag_last = 1;

        SET @end_time = GETDATE();
        PRINT '>> loading time:' + CAST(DATEDIFF(SECOND, @start_time, @end_time) AS VARCHAR) + ' second';

        --------------------------
        -- Load Crm_prd_info
        --------------------------
        SET @start_time = GETDATE();
        PRINT '>> truncating table: silver.Crm_prd_info';
        TRUNCATE TABLE silver.Crm_prd_info;

        PRINT '>> inserting into table: silver.Crm_prd_info';
        INSERT INTO silver.Crm_prd_info (
            prd_id, cat_id, prd_key, prd_nm, prd_cost,
            prd_line, prd_start_dt, prd_end_dt
        )
        SELECT 
            prd_id,
            REPLACE(SUBSTRING(prd_key, 1, 5), '-', '_') AS cat_id,
            SUBSTRING(prd_key, 7, LEN(prd_key)) AS prd_key,
            prd_nm,
            ISNULL(prd_cost, 0),
            CASE UPPER(TRIM(prd_line))
                WHEN 'M' THEN 'Mountain'
                WHEN 'R' THEN 'Road'
                WHEN 'S' THEN 'Other Sales'
                WHEN 'T' THEN 'Touring'
                ELSE 'n/a'
            END,
            CAST(prd_start_dt AS DATE),
            CAST(DATEADD(DAY, -1, LEAD(prd_start_dt) OVER (PARTITION BY prd_key ORDER BY prd_start_dt)) AS DATE)
        FROM bronz.Crm_prd_info;

        SET @end_time = GETDATE();
        PRINT '>> loading time:' + CAST(DATEDIFF(SECOND, @start_time, @end_time) AS VARCHAR) + ' second';

        --------------------------
        -- Load Crm_sales_details
        --------------------------
        SET @start_time = GETDATE();
        PRINT '>> truncating table: silver.Crm_sales_details';
        TRUNCATE TABLE silver.Crm_sales_details;

        PRINT '>> inserting into table: silver.Crm_sales_details';
        INSERT INTO silver.Crm_sales_details (
            sls_ord_num, sls_prd_key, sls_cust_id,
            sls_order_dt, sls_ship_dt, sls_due_dt,
            sls_sales, sls_quantity, sls_price
        )
        SELECT 
            sls_ord_num,
            sls_prd_key,
            sls_cust_id,
            CASE 
                WHEN sls_order_dt = 0 OR LEN(sls_order_dt) != 8 THEN NULL
                ELSE CAST(CAST(sls_order_dt AS VARCHAR) AS DATE)
            END,
            CASE 
                WHEN sls_ship_dt = 0 OR LEN(sls_ship_dt) != 8 THEN NULL
                ELSE CAST(CAST(sls_ship_dt AS VARCHAR) AS DATE)
            END,
            CASE 
                WHEN sls_due_dt = 0 OR LEN(sls_due_dt) != 8 THEN NULL
                ELSE CAST(CAST(sls_due_dt AS VARCHAR) AS DATE)
            END,
            CASE 
                WHEN sls_sales IS NULL OR sls_sales <= 0 OR sls_sales != sls_quantity * ABS(sls_price)
                    THEN sls_quantity * ABS(sls_price)
                ELSE sls_sales
            END,
            sls_quantity,
            CASE 
                WHEN sls_price IS NULL OR sls_price <= 0 
                    THEN sls_sales / NULLIF(sls_quantity, 0)
                ELSE sls_price
            END
        FROM bronz.Crm_sales_details;

        SET @end_time = GETDATE();
        PRINT '>> loading time:' + CAST(DATEDIFF(SECOND, @start_time, @end_time) AS VARCHAR) + ' second';

        PRINT '-------------------------------------------------------------------';
        PRINT 'ERP Tables';
        PRINT '-------------------------------------------------------------------';

        --------------------------
        -- Load Erp_cust_az12
        --------------------------
        SET @start_time = GETDATE();
        PRINT '>> truncating table: silver.Erp_cust_az12';
        TRUNCATE TABLE silver.Erp_cust_az12;

        PRINT '>> inserting into table: silver.Erp_cust_az12';
        INSERT INTO silver.Erp_cust_az12 (cid, bdate, gen)
        SELECT 
            CASE 
                WHEN cid LIKE 'NAS%' THEN SUBSTRING(cid, 4, LEN(cid))
                ELSE cid
            END,
            CASE 
                WHEN bdate > GETDATE() THEN NULL
                ELSE bdate
            END,
            CASE 
                WHEN UPPER(TRIM(gen)) IN ('M', 'MALE') THEN 'Male'
                WHEN UPPER(TRIM(gen)) IN ('F', 'FEMALE') THEN 'Female'
                ELSE 'n/a'
            END
        FROM bronz.Erp_cust_az12;

        SET @end_time = GETDATE();
        PRINT '>> loading time:' + CAST(DATEDIFF(SECOND, @start_time, @end_time) AS VARCHAR) + ' second';

        --------------------------
        -- Load Erp_loc_a101
        --------------------------
        SET @start_time = GETDATE();
        PRINT '>> truncating table: silver.Erp_loc_a101';
        TRUNCATE TABLE silver.Erp_loc_a101;

        PRINT '>> inserting into table: silver.Erp_loc_a101';
        INSERT INTO silver.Erp_loc_a101 (cid, cntry)
        SELECT 
            REPLACE(cid, '-', ''),
            CASE 
                WHEN UPPER(TRIM(cntry)) IN ('USA', 'US', 'UNITED STATE') THEN 'United State'
                WHEN UPPER(TRIM(cntry)) IN ('DE', 'GERMANY') THEN 'Germany'
                WHEN UPPER(TRIM(cntry)) = 'AUSTRALIA' THEN 'Australia'
                WHEN UPPER(TRIM(cntry)) = 'CANADA' THEN 'Canada'
                WHEN UPPER(TRIM(cntry)) = 'UNITED KINGDOM' THEN 'United Kingdom'
                WHEN UPPER(TRIM(cntry)) = 'FRANCE' THEN 'France'
                ELSE 'n/a'
            END
        FROM bronz.Erp_loc_a101;

        SET @end_time = GETDATE();
        PRINT '>> loading time:' + CAST(DATEDIFF(SECOND, @start_time, @end_time) AS VARCHAR) + ' second';

        --------------------------
        -- Load Erp_px_cat_g1v2
        --------------------------
        SET @start_time = GETDATE();
        PRINT '>> truncating table: silver.Erp_px_cat_g1v2';
        TRUNCATE TABLE silver.Erp_px_cat_g1v2;

        PRINT '>> inserting into table: silver.Erp_px_cat_g1v2';
        INSERT INTO silver.Erp_px_cat_g1v2 (id, cat, subcat, maintenance)
        SELECT id, cat, subcat, maintenance
        FROM bronz.Erp_px_cat_g1v2;

        SET @end_time = GETDATE();
        PRINT '>> loading time:' + CAST(DATEDIFF(SECOND, @start_time, @end_time) AS VARCHAR) + ' second';

        SET @silver_end_time = GETDATE();

        PRINT '-------------------------------------------------------------------';
        PRINT '>> Silver level loading time:' + CAST(DATEDIFF(SECOND, @silver_start_time, @silver_end_time) AS VARCHAR) + ' second';
        PRINT '-------------------------------------------------------------------';

    END TRY
    BEGIN CATCH
        PRINT '======================================================================';
        PRINT 'Error occurred during loading data at silver level';
        PRINT 'Error Message: ' + ERROR_MESSAGE();
        PRINT 'Error Number: ' + CAST(ERROR_NUMBER() AS VARCHAR);
        PRINT 'Error State: ' + CAST(ERROR_STATE() AS VARCHAR);
        PRINT '======================================================================';
    END CATCH
END;
