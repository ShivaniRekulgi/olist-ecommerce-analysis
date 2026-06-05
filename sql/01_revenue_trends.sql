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

SELECT
    order_year,
    COUNT(DISTINCT order_id)             AS total_orders,
    COUNT(DISTINCT customer_unique_id)   AS unique_customers,
    ROUND(SUM(price + freight_value), 2) AS total_revenue,
    ROUND(AVG(price + freight_value), 2) AS avg_order_value
FROM master_orders
GROUP BY order_year
ORDER BY order_year;

-- -----------------------------------------------
-- QUERY 3: Month-over-Month Revenue Change
-- -----------------------------------------------

WITH monthly_revenue AS (
    SELECT
        order_year_month,
        ROUND(SUM(price + freight_value), 2) AS total_revenue
    FROM master_orders
    GROUP BY order_year_month
)
SELECT
    order_year_month,
    total_revenue,
    LAG(total_revenue) OVER (ORDER BY order_year_month) AS prev_month_revenue,
    ROUND(
        (total_revenue - LAG(total_revenue) OVER (ORDER BY order_year_month)) 
        / LAG(total_revenue) OVER (ORDER BY order_year_month) * 100
    , 1) AS mom_growth_pct
FROM monthly_revenue
ORDER BY order_year_month;