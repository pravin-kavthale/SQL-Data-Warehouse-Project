/***************************************************************************************************
Project: Data Warehouse - Gold Layer Views Creation
Author: [Pravin Kawthale]
Date: [4-08-25]
Database: DataWarehouse

Description:
This script defines and creates materialized views in the **Gold Layer** of the Data Warehouse.
The Gold Layer represents the curated, analytics-ready data used for reporting, dashboards, and 
business intelligence applications. The script builds the following views:

1. gold.dim_customers
   - Combines customer information from CRM and ERP systems.
   - Generates a surrogate key (customer_key).
   - Handles missing gender data by falling back to alternate source.
   - Filters out test or irrelevant customer records.

2. gold.dim_products
   - Merges product data with category metadata.
   - Filters out historical or inactive products.
   - Adds category, subcategory, and maintenance details.

3. gold.fact_sales
   - Integrates sales transactions with customer and product dimensions.
   - Provides enriched sales data with foreign keys from dimensional tables.
   - Enables analysis by sales amount, quantity, pricing, and order timelines.

Each view is dropped if it already exists to ensure a clean rebuild. The views follow star schema 
design principles to support OLAP and reporting use cases.

***************************************************************************************************/

use DataWarehouse;

if object_id('gold.dim_customers','V')is not null 
	drop view gold.dim_customers
create view gold.dim_customers as
select 
	row_number() over(order by ci.cst_id) as customer_key,
	ci.cst_id as customer_id,
	ci.cst_key as customer_number,
	ci.cst_firstname as first_name,
	ci.cst_lastname as last_name,
	la.cntry as country,
	ci.cst_marital_status as marital_status,
	case when ci.cst_gndr!='n/a' then ci.cst_gndr	
			else COALESCE(ca.gen,'n/a')
	end as gender,
	ca.bdate as birthdate,
	ci.cst_create_date as create_date
from silver.Crm_cust_info ci
left join silver.Erp_cust_az12 ca
on	ca.cid=ci.cst_key
left join silver.Erp_loc_a101 la
on la.cid=ci.cst_key
where ci.cst_key != 'PO25'


if object_id('gold.dim_products','V')is not null 
	drop view gold.dim_products
create view gold.dim_products as
select 
	row_number() over (order by pin.prd_start_dt,pin.prd_id) as product_key,
	pin.prd_id as product_id,
	pin.prd_key as product_number,
	pin.prd_nm as product_name,
	pin.cat_id as category_id,
	ct.cat as category,
	ct.subcat as subcategory,
	ct.maintenance as maintenance,
	pin.prd_cost as cost,
	pin.prd_line as product_line,
	pin.prd_start_dt as start_date              
from silver.Crm_prd_info pin
left join silver.Erp_px_cat_g1v2 ct
on ct.id=pin.cat_id
where pin.prd_end_dt is null -- filter out all historical data


if object_id('gold.fact_sales','V')is not null 
	drop view gold.fact_sales
create view gold.fact_sales as
select 
	sd.sls_ord_num as order_numbers,
	pr.product_key,
	cst.customer_key,
	sd.sls_sales as sales,
	sd.sls_quantity as quantity,
	sd.sls_price as price,
	sd.sls_order_dt as order_date,
	sd.sls_ship_dt as ship_date,
	sd.sls_due_dt as due_date
from silver.Crm_sales_details sd
left join gold.dim_products pr
on pr.product_number=sd.sls_prd_key
left join gold.dmi_customers cst
on cst.customer_id=sd.sls_cust_id;
