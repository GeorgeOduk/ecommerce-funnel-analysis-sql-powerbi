/*
01_project_setup.sql
Creating database and schemas for the portfolio project in SQL Server
*/

IF DB_ID('ecommerce_funnel_portfolio') IS NULL
BEGIN
	CREATE DATABASE ecommerce_funnel_portfolio;
END
GO

USE ecommerce_funnel_portfolio;
GO

IF NOT EXISTS (SELECT 1 FROM sys.schemas WHERE name = 'stg')
	EXEC('CREATE SCHEMA stg');
GO

IF NOT EXISTS (SELECT 1 FROM sys.schemas WHERE name = 'mart')
	EXEC('CREATE SCHEMA mart');
GO

/*
Checking that the raw tables are imported properly
*/

USE ecommerce_funnel_portfolio;
GO

SELECT 'raw_user_table' AS table_name, COUNT(*) AS row_count FROM dbo.raw_user_table
UNION ALL
SELECT 'raw_home_page_table', COUNT(*) FROM dbo.raw_home_page_table
UNION ALL
SELECT 'raw_search_page_table', COUNT(*) FROM dbo.raw_search_page_table
UNION ALL
SELECT 'raw_payment_page_table', COUNT(*) FROM dbo.raw_payment_page_table
UNION ALL
SELECT 'raw_payment_confirmation_table', COUNT(*) FROM dbo.raw_payment_confirmation_table;

SELECT TOP 10 * FROM dbo.raw_user_table;
SELECT TOP 10 * FROM dbo.raw_home_page_table;
SELECT TOP 10 * FROM dbo.raw_search_page_table;
SELECT TOP 10 * FROM dbo.raw_payment_page_table;
SELECT TOP 10 * FROM dbo.raw_payment_confirmation_table;

