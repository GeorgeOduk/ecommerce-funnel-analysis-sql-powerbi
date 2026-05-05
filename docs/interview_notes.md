# Interview Notes

## 30-Second Project Explanation

I built an end-to-end e-commerce funnel analysis project using SQL Server and Power BI. I imported raw CSV data into SQL Server, cleaned and modeled the data into a user-level funnel view, calculated stage conversion rates, analysed performance by device, sex, and month, and built a Power BI dashboard to communicate the key insights and recommendations.

---

## Main Business Finding

The biggest issue is that only 0.50% of users complete the full funnel. The largest absolute drop-offs happen before checkout, while the weakest stage efficiency is Payment - Purchase. The strongest diagnostic insight is a sharp deterioration from March 2015 onward.

---

## Why I Built a User-Level Funnel View

I created one row per user with binary stage flags because it made the analysis reusable, simple to segment, and easy to connect to Power BI.

---

## SQL Techniques Used

- joins
- CTEs
- CASE statements
- aggregate calculations
- conversion rates with NULLIF
- date grouping
- SQL views
- staging and mart schemas

---

## Power BI Techniques Used

- KPI cards
- funnel chart
- bar charts
- line charts
- matrix visuals
- slicers
- conditional formatting
- custom colour theme
- dashboard storytelling

---

## Recommendations I Would Give the Business

I would recommend investigating March 2015 changes first, especially mobile discovery and desktop checkout progression. Then I would prioritise Search - Payment friction and Payment - Purchase checkout barriers.