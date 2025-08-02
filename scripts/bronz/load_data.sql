/*
====================================================================
Script: Load Bronz Layer Data
Author: [pravin kawthale]
Date: [02-08-2025]
Description:
This script defines and executes the stored procedure `bronz.load_bronz`
which performs bulk data loading into the Data Warehouse's bronz (staging) layer.

Key Features:
- Drops and recreates procedure `bronz.load_bronz` if it exists.
- Truncates existing data in staging tables to avoid duplicates.
- Loads fresh data using `BULK INSERT` from CRM and ERP CSV files.
- Logs timing for each individual table load and overall batch.
- Uses TRY...CATCH for error handling with detailed error messages.

Note:
- `tablock` is used in bulk insert for performance improvement.
- Assumes all CSVs are correctly formatted and located locally on disk.
- Requires the file paths and SQL Server to have appropriate access.
====================================================================
*/

EXEC bronz.load_bronz;

CREATE OR ALTER PROCEDURE bronz.load_bronz AS
BEGIN
	DECLARE 
		@start_time DATETIME, 
		@end_time DATETIME, 
		@batch_start_time DATETIME, 
		@batch_end_time DATETIME;

	BEGIN TRY
		SET @batch_start_time = GETDATE();
		PRINT '===============================================================';
		PRINT 'Loading Bronz Layer';
		PRINT '===============================================================';

		-- ================= CRM Tables ===================
		PRINT '---------------------------------------------------------------';
		PRINT 'Loading CRM Tables';
		PRINT '---------------------------------------------------------------';

		-- Crm_cust_info
		SET @start_time = GETDATE();
		PRINT '>> Truncating table: Crm_cust_info';
		TRUNCATE TABLE bronz.Crm_cust_info;
		PRINT '>> Inserting data...';
		BULK INSERT bronz.Crm_cust_info
		FROM 'D:\Sql Projects\sql-data-warehouse-project\sql-data-warehouse-project\datasets\source_crm\cust_info.csv'
		WITH (
			FIRSTROW = 2,
			FIELDTERMINATOR = ',',
			TABLOCK
		);
		SET @end_time = GETDATE();
		PRINT 'Load duration: ' + CAST(DATEDIFF(SECOND, @start_time, @end_time) AS NVARCHAR) + ' seconds';

		-- Crm_prd_info
		SET @start_time = GETDATE();
		PRINT '>> Truncating table: Crm_prd_info';
		TRUNCATE TABLE bronz.Crm_prd_info;
		PRINT '>> Inserting data...';
		BULK INSERT bronz.Crm_prd_info
		FROM 'D:\Sql Projects\sql-data-warehouse-project\sql-data-warehouse-project\datasets\source_crm\prd_info.csv'
		WITH (
			FIRSTROW = 2,
			FIELDTERMINATOR = ',',
			TABLOCK
		);
		SET @end_time = GETDATE();
		PRINT 'Load duration: ' + CAST(DATEDIFF(SECOND, @start_time, @end_time) AS NVARCHAR) + ' seconds';

		-- Crm_sales_details
		SET @start_time = GETDATE();
		PRINT '>> Truncating table: Crm_sales_details';
		TRUNCATE TABLE bronz.Crm_sales_details;
		PRINT '>> Inserting data...';
		BULK INSERT bronz.Crm_sales_details
		FROM 'D:\Sql Projects\sql-data-warehouse-project\sql-data-warehouse-project\datasets\source_crm\sales_details.csv'
		WITH (
			FIRSTROW = 2,
			FIELDTERMINATOR = ',',
			TABLOCK
		);
		SET @end_time = GETDATE();
		PRINT 'Load duration: ' + CAST(DATEDIFF(SECOND, @start_time, @end_time) AS NVARCHAR) + ' seconds';

		-- ================= ERP Tables ===================
		PRINT '---------------------------------------------------------------';
		PRINT 'Loading ERP Tables';
		PRINT '---------------------------------------------------------------';

		-- Erp_cust_az12
		SET @start_time = GETDATE();
		PRINT '>> Truncating table: Erp_cust_az12';
		TRUNCATE TABLE bronz.Erp_cust_az12;
		PRINT '>> Inserting data...';
		BULK INSERT bronz.Erp_cust_az12
		FROM 'D:\Sql Projects\sql-data-warehouse-project\sql-data-warehouse-project\datasets\source_erp\CUST_AZ12.csv'
		WITH (
			FIRSTROW = 2,
			FIELDTERMINATOR = ',',
			TABLOCK
		);
		SET @end_time = GETDATE();
		PRINT 'Load duration: ' + CAST(DATEDIFF(SECOND, @start_time, @end_time) AS NVARCHAR) + ' seconds';

		-- Erp_loc_a101
		SET @start_time = GETDATE();
		PRINT '>> Truncating table: Erp_loc_a101';
		TRUNCATE TABLE bronz.Erp_loc_a101;
		PRINT '>> Inserting data...';
		BULK INSERT bronz.Erp_loc_a101
		FROM 'D:\Sql Projects\sql-data-warehouse-project\sql-data-warehouse-project\datasets\source_erp\LOC_A101.csv'
		WITH (
			FIRSTROW = 2,
			FIELDTERMINATOR = ',',
			TABLOCK
		);
		SET @end_time = GETDATE();
		PRINT 'Load duration: ' + CAST(DATEDIFF(SECOND, @start_time, @end_time) AS NVARCHAR) + ' seconds';

		-- Erp_px_cat_g1v2
		SET @start_time = GETDATE();
		PRINT '>> Truncating table: Erp_px_cat_g1v2';
		TRUNCATE TABLE bronz.Erp_px_cat_g1v2;
		PRINT '>> Inserting data...';
		BULK INSERT bronz.Erp_px_cat_g1v2
		FROM 'D:\Sql Projects\sql-data-warehouse-project\sql-data-warehouse-project\datasets\source_erp\PX_CAT_G1V2.csv'
		WITH (
			FIRSTROW = 2,
			FIELDTERMINATOR = ',',
			TABLOCK
		);
		SET @end_time = GETDATE();
		PRINT 'Load duration: ' + CAST(DATEDIFF(SECOND, @start_time, @end_time) AS NVARCHAR) + ' seconds';

		-- ================= Finish ===================
		SET @batch_end_time = GETDATE();
		PRINT 'Bronz load completed in: ' + CAST(DATEDIFF(SECOND, @batch_start_time, @batch_end_time) AS NVARCHAR) + ' seconds';

	END TRY
	BEGIN CATCH
		PRINT '===============================================================';
		PRINT 'Error occurred during loading Bronz Layer';
		PRINT 'Error message: ' + ERROR_MESSAGE();
		PRINT 'Error number: ' + CAST(ERROR_NUMBER() AS NVARCHAR);
		PRINT '===============================================================';
	END CATCH
END;
