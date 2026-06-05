-- ============================================================
-- SCRIPT: 01_revenue_trends.sql
-- PURPOSE: Analyze revenue trends over time
-- KEY QUESTIONS:
--   - How is monthly revenue trending across 2016-2018?
--   - Which year had the highest growth?
--   - What is the month-over-month change?
-- ============================================================

-- -----------------------------------------------
-- QUERY 1: Monthly Revenue Trend
-- -----------------------------------------------

SELECT order_year_month, order_year, order_month,
       COUNT(DISTINCT order_id) AS total_orders,
       ROUND(SUM(price), 2) AS product_revenue,
       ROUND(SUM(freight_value), 2) AS freight_revenue,
       ROUND(SUM(price+freight_value), 2) AS total_revenue
FROM master_orders
GROUP BY order_year_month, order_year, order_month
ORDER BY order_year_month;

-- -----------------------------------------------
-- QUERY 2: Yearly Revenue Summary
-- -----------------------------------------------

