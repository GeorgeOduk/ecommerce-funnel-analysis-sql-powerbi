/*
03_analysis_queries.sql
*/

USE ecommerce_funnel_portfolio;
GO

SELECT *
FROM mart.vw_funnel_stage_counts
ORDER BY stage_order;
GO

WITH overall AS (
	SELECT
		COUNT(*) AS home_users,
		SUM(reached_search) AS search_users,
		SUM(reached_payment) AS payment_users,
		SUM(reached_confirmation) AS confirmation_users
	FROM mart.vw_user_funnel_flags
)
SELECT
	home_users,
	search_users,
	payment_users,
	confirmation_users,
	CAST(search_users * 1.0 / NULLIF(home_users, 0) AS DECIMAL (10, 4)) AS home_to_search_rate,
	CAST(payment_users * 1.0 / NULLIF(search_users, 0) AS DECIMAL (10, 4)) AS search_to_payment_rate,
	CAST(confirmation_users * 1.0 / NULLIF(payment_users, 0) AS DECIMAL (10, 4)) AS payment_to_confirmation_rate,
	CAST(confirmation_users * 1.0 / NULLIF(home_users, 0) AS DECIMAL (10, 4)) AS overall_conversion_rate
FROM overall;
GO

SELECT *
FROM mart.vw_funnel_by_device
ORDER BY overall_conversion_rate DESC;
GO

SELECT *
FROM mart.vw_funnel_by_sex
ORDER BY overall_conversion_rate DESC;
GO

SELECT *
FROM mart.vw_funnel_monthly_by_device
ORDER BY visit_month_start, device;
GO

WITH period_flags AS (
	SELECT
		CASE
			WHEN visit_date < '2015-03-01' THEN 'Before 2015-03-01'
			ELSE 'On/After 2015-03-01'
			END AS period_group,
			device,
			reached_search,
			reached_payment,
			reached_confirmation
		FROM mart.vw_user_funnel_flags
)
SELECT
	period_group,
	device,
	COUNT(*) AS home_users,
	SUM(reached_search) AS search_users,
	SUM(reached_payment) AS payment_users,
	SUM(reached_confirmation) AS confirmation_users,
	CAST(SUM(reached_search) * 1.0 / NULLIF(COUNT(*), 0) AS DECIMAL (10, 4)) AS home_to_search_rate,
	CAST(SUM(reached_payment) * 1.0 / NULLIF(SUM(reached_search), 0) AS DECIMAL (10, 4)) AS search_to_payment_rate,
	CAST(SUM(reached_confirmation) * 1.0 / NULLIF(SUM(reached_payment), 0) AS DECIMAL (10, 4)) AS payment_to_confirmation_rate,
	CAST(SUM(reached_confirmation) * 1.0 / NULLIF(COUNT(*), 0) AS DECIMAL (10, 4)) AS overall_conversion__rate
FROM period_flags
GROUP BY period_group, device
ORDER BY period_group, device;
GO

SELECT
	COUNT(*) AS home_users,
	SUM(CASE WHEN reached_search = 0 THEN 1 ELSE 0 END) AS dropped_after_home,
	SUM(CASE WHEN reached_search = 1 AND reached_payment = 0 THEN 1 ELSE 0 END) AS dropped_after_search,
	SUM(CASE WHEN reached_payment = 1 AND reached_confirmation = 0 THEN 1 ELSE 0 END) AS dropped_after_payment,
	SUM(reached_confirmation) AS purchased_users
FROM mart.vw_user_funnel_flags;
GO
