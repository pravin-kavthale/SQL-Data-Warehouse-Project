-- ===================================================
-- 🏗️  Data Warehouse Initialization Script
-- 📁  Creating Database and Multi-Layered Schemas
-- 🔰  Layers: Bronze (Raw) → Silver (Cleaned) → Gold (Curated)
-- ===================================================

-- 🔸 Use the master database to start with system-level access
USE master;

-- 🔸 Create a new database for the data warehouse
CREATE DATABASE DataWarehouse;

-- 🔸 Switch context to the newly created data warehouse
USE DataWarehouse;

-- ===================================================
-- 📂 Creating Layered Schemas
-- These represent the classic Data Lakehouse or Medallion architecture
-- ===================================================

-- 🟫 Bronze Layer: Raw, unprocessed data as ingested
CREATE SCHEMA bronz;
GO

-- 🪙 Silver Layer: Cleaned and structured data
CREATE SCHEMA silver;
GO

-- 🥇 Gold Layer: Final curated and aggregated data for reporting/analytics
CREATE SCHEMA gold;
GO
