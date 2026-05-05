/*
02_clean_and_model.sql
*/

USE ecommerce_funnel_portfolio;
GO

DROP TABLE IF EXISTS stg.users;
SELECT
	CAST(user_id AS INT) AS user_id,
	CAST([date] AS DATE) AS visit_date,
	LTRIM(RTRIM(device)) AS device,
	LTRIM(RTRIM(sex)) AS sex
INTO stg.users
FROM dbo.raw_user_table;
GO

ALTER TABLE stg.users
ALTER COLUMN user_id INT NOT NULL;
GO

ALTER TABLE stg.users
ADD CONSTRAINT PK_stg_users PRIMARY KEY CLUSTERED (user_id);
GO

DROP TABLE IF EXISTS stg.home_page;
SELECT DISTINCT 
	CAST(user_id AS INT) AS user_id,
	LTRIM(RTRIM(page)) AS page_name
INTO stg.home_page
FROM dbo.raw_home_page_table
GO

ALTER TABLE stg.home_page
ALTER COLUMN user_id INT NOT NULL;
GO

ALTER TABLE stg.home_page
ADD CONSTRAINT PK_stg_home_page PRIMARY KEY CLUSTERED (user_id);
GO

DROP TABLE IF EXISTS stg.search_page;
SELECT DISTINCT
	CAST(user_id AS INT) AS user_id,
	LTRIM(RTRIM(page)) AS page_name
INTO stg.search_page
FROM dbo.raw_search_page_table;
GO

ALTER TABLE stg.search_page
ALTER COLUMN user_id INT NOT NULL;
GO

ALTER TABLE stg.search_page
ADD CONSTRAINT PK_stg_search_page PRIMARY KEY CLUSTERED (user_id);
GO

DROP TABLE IF EXISTS stg.payment_page;
SELECT DISTINCT
	CAST(user_id AS INT) AS user_id,
	LTRIM(RTRIM(page)) AS page_name
INTO stg.payment_page
FROM dbo.raw_payment_page_table;
GO

ALTER TABLE stg.payment_page
ALTER COLUMN user_id INT NOT NULL;
GO

ALTER TABLE stg.payment_page
ADD CONSTRAINT PK_stg_payment_page PRIMARY KEY CLUSTERED (user_id);
GO

DROP TABLE IF EXISTS stg.payment_confirmation_page;
SELECT DISTINCT
	CAST(user_id AS INT) AS user_id,
	LTRIM(RTRIM(page)) AS page_name
INTO stg.payment_confirmation_page
FROM dbo.raw_payment_confirmation_table;
GO

ALTER TABLE stg.payment_confirmation_page
ALTER COLUMN user_id INT NOT NULL;
GO

ALTER TABLE stg.payment_confirmation_page
ADD CONSTRAINT PK_stg_payment_confrirmation_page PRIMARY KEY CLUSTERED (user_id);
GO

CREATE OR ALTER VIEW mart.vw_user_funnel_flags
AS
SELECT
	u.user_id,
	u.visit_date,
	YEAR(u.visit_date) AS visit_year,
	MONTH(u.visit_date) AS visit_month_num,
	DATENAME(MONTH, u.visit_date) AS visit_month_name,
	DATEFROMPARTS(YEAR(u.visit_date), MONTH(u.visit_date), 1) as visit_month_start,
	u.device,
	u.sex,
	CAST(1 AS INT) AS reached_home,
	CASE WHEN s.user_id IS NOT NULL THEN 1 ELSE 0 END AS reached_search,
	CASE WHEN p.user_id IS NOT NULL THEN 1 ELSE 0 END AS reached_payment,
	CASE WHEN c.user_id IS NOT NULL THEN 1 ELSE 0 END AS reached_confirmation
FROM stg.users u
LEFT JOIN stg.search_page s
	ON u.user_id = s.user_id
LEFT JOIN stg.payment_page p
	ON u.user_id = p.user_id
LEFT JOIN stg.payment_confirmation_page c
	ON u.user_id = c.user_id;
GO

CREATE OR ALTER VIEW mart.vw_funnel_stage_counts
AS
SELECT 1 AS stage_order, '01 Home Page' AS stage_name, COUNT(*) AS users_at_stage
FROM mart.vw_user_funnel_flags

UNION ALL

SELECT 2 AS stage_order, '02 Search Page', SUM(reached_search)
FROM mart.vw_user_funnel_flags

UNION ALL

SELECT 3 AS stage_order, '03 Payment Stage', SUM(reached_payment)
FROM mart.vw_user_funnel_flags

UNION ALL

SELECT 4 AS stage_order, '04 Purchase Confirmation', SUM(reached_confirmation)
FROM mart.vw_user_funnel_flags;
GO

CREATE OR ALTER VIEW mart.vw_funnel_by_device
AS
SELECT
	device,
	COUNT(*) AS home_users,
	SUM(reached_search) AS search_users,
	SUM(reached_payment) AS payment_users,
	SUM(reached_confirmation) AS confirmation_users,
	CAST(SUM(reached_search) * 1.0 / NULLIF(COUNT(*), 0) AS DECIMAL(10, 4)) AS home_to_search_rate,
	CAST(SUM(reached_payment) * 1.0 / NULLIF(SUM(reached_search), 0) AS DECIMAL(10, 4)) AS search_to_payment_rate,
	CAST(SUM(reached_confirmation) * 1.0 / NULLIF(SUM(reached_payment), 0) AS DECIMAL(10, 4)) AS payment_to_confirmation_rate,
	CAST(SUM(reached_confirmation) * 1.0 / NULLIF(COUNT(*), 0) AS DECIMAL(10, 4)) AS overall_conversion_rate
FROM mart.vw_user_funnel_flags
GROUP BY device;
GO

CREATE OR ALTER VIEW mart.vw_funnel_by_sex
AS
SELECT
	sex,
	COUNT(*) AS home_users,
	SUM(reached_search) AS search_users,
	SUM(reached_payment) AS payment_users,
	SUM(reached_confirmation) AS confirmation_users,
	CAST(SUM(reached_search) * 1.0 / NULLIF(COUNT(*), 0) AS DECIMAL(10, 4)) AS home_to_search_rate,
	CAST(SUM(reached_payment) * 1.0 / NULLIF(SUM(reached_search), 0) AS DECIMAL(10, 4)) AS search_to_payment_rate,
	CAST(SUM(reached_confirmation) * 1.0 / NULLIF(SUM(reached_payment), 0) AS DECIMAL(10, 4)) AS payment_to_confirmation_rate,
	CAST(SUM(reached_confirmation) * 1.0 / NULLIF(COUNT(*), 0) AS DECIMAL(10, 4)) AS overall_conversion_rate
FROM mart.vw_user_funnel_flags
GROUP BY sex;
GO

CREATE OR ALTER VIEW mart.vw_funnel_monthly
AS
SELECT
	visit_month_start,
	COUNT(*) AS home_users,
	SUM(reached_search) AS search_users,
	SUM(reached_payment) AS payment_users,
	SUM(reached_confirmation) AS confirmation_users,
	CAST(SUM(reached_search) * 1.0 / NULLIF(COUNT(*), 0) AS DECIMAL(10, 4)) AS home_to_search_rate,
	CAST(SUM(reached_payment) * 1.0 / NULLIF(SUM(reached_search), 0) AS DECIMAL(10, 4)) AS search_to_payment_rate,
	CAST(SUM(reached_confirmation) * 1.0 / NULLIF(SUM(reached_payment), 0) AS DECIMAL(10, 4)) AS payment_to_confirmation_rate,
	CAST(SUM(reached_confirmation) * 1.0 / NULLIF(COUNT(*), 0) AS DECIMAL(10, 4)) AS overall_conversion_rate
FROM mart.vw_user_funnel_flags
GROUP BY visit_month_start;
GO

CREATE OR ALTER VIEW mart.vw_funnel_monthly_by_device
AS
SELECT
	visit_month_start,
	device,
	COUNT(*) AS home_users,
	SUM(reached_search) AS search_users,
	SUM(reached_payment) AS payment_users,
	SUM(reached_confirmation) AS confirmation_users,
	CAST(SUM(reached_search) * 1.0 / NULLIF(COUNT(*), 0) AS DECIMAL(10, 4)) AS home_to_search_rate,
	CAST(SUM(reached_payment) * 1.0 / NULLIF(SUM(reached_search), 0) AS DECIMAL(10, 4)) AS search_to_payment_rate,
	CAST(SUM(reached_confirmation) * 1.0 / NULLIF(SUM(reached_payment), 0) AS DECIMAL(10, 4)) AS payment_to_confirmation_rate,
	CAST(SUM(reached_confirmation) * 1.0 / NULLIF(COUNT(*), 0) AS DECIMAL(10, 4)) AS overall_conversion_rate
FROM mart.vw_user_funnel_flags
GROUP BY visit_month_start, device;
GO

-----------------------------------------------------------------------------------------------------------------------
/*
Checking if the cleaned model works
*/

SELECT TOP 20 * FROM stg.users;
SELECT TOP 20 * FROM stg.search_page;
SELECT TOP 20 * FROM mart.vw_user_funnel_flags;
SELECT * FROM mart.vw_funnel_stage_counts ORDER BY stage_order;
SELECT * FROM mart.vw_funnel_by_device;
SELECT * FROM mart.vw_funnel_monthly ORDER BY visit_month_start;


-----------------------------------------------------------------------------------------------------------------------

