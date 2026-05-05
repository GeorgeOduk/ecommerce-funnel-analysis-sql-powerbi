# Technical Walkthrough

## 1. Data Import

The raw CSV files were imported into SQL Server using SQL Server Management Studio.

Raw tables:

- dbo.raw_user_table
- dbo.raw_home_page_table
- dbo.raw_search_page_table
- dbo.raw_payment_page_table
- dbo.raw_payment_confirmation_table

---

## 2. Data Cleaning

The raw data was cleaned into staging tables under the stg schema.

Cleaning included:

- casting user IDs to integer
- casting dates to date format
- trimming text fields
- removing duplicate stage records
- applying primary keys

---

## 3. Funnel Model

A user-level funnel view was created:

mart.vw_user_funnel_flags

This view contains one row per user with binary flags showing whether the user reached each funnel stage.

---

## 4. Analysis Views

Reporting views were created under the mart schema:

- mart.vw_funnel_stage_counts
- mart.vw_funnel_by_device
- mart.vw_funnel_by_sex
- mart.vw_funnel_monthly
- mart.vw_funnel_monthly_by_device

---

## 5. Power BI Dashboard

Power BI was connected to the SQL Server reporting views.

The dashboard includes:

- KPI cards
- funnel chart
- drop-off diagnostics
- device and segment analysis
- monthly trend analysis
- before/after March 2015 comparison
- business recommendation text boxes