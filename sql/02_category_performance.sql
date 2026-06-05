-- ============================================================
-- SCRIPT: 02_category_performance.sql
-- PURPOSE: Identify top performing product categories
-- KEY QUESTIONS:
--   - Which categories generate the most revenue?
--   - Which categories have the highest order volume?
--   - What is the average order value per category?
--   - Which categories have the best review scores?
-- ============================================================

-- -----------------------------------------------
-- QUERY 1: Revenue and Volume by Category
-- -----------------------------------------------
SELECT
    product_category_name_english,
    COUNT(DISTINCT order_id)              AS total_orders,
    ROUND(SUM(price), 2)                  AS total_revenue,
    ROUND(AVG(price), 2)                  AS avg_item_price,
    ROUND(SUM(freight_value), 2)          AS total_freight,
    ROUND(AVG(review_score), 2)           AS avg_review_score
FROM master_orders
GROUP BY product_category_name_english
ORDER BY total_revenue DESC
LIMIT 15;

-- -----------------------------------------------
-- QUERY 2: Category Revenue Share (% of total)
-- -----------------------------------------------
WITH category_revenue AS (
    SELECT
        product_category_name_english,
        ROUND(SUM(price), 2) AS total_revenue
    FROM master_orders
    GROUP BY product_category_name_english
),
total AS (
    SELECT ROUND(SUM(price), 2) AS grand_total FROM master_orders
)
SELECT
    c.product_category_name_english,
    c.total_revenue,
    ROUND(c.total_revenue / t.grand_total * 100, 2) AS revenue_share_pct
FROM category_revenue c, total t
ORDER BY c.total_revenue DESC
LIMIT 15;

-- -----------------------------------------------
-- QUERY 3: Hidden Gems — High rated, mid-volume categories
-- Threshold logic:
--   Lower bound (100): minimum orders for review score to be statistically reliable
--   Upper bound (1,481): 75th percentile of category order volume
--   Categories above this are already dominant, not hidden
--   Review score threshold (4.11): median avg score across all categories
-- -----------------------------------------------
SELECT
    product_category_name_english,
    COUNT(DISTINCT order_id)     AS total_orders,
    ROUND(SUM(price), 2)         AS total_revenue,
    ROUND(AVG(review_score), 2)  AS avg_review_score
FROM master_orders
GROUP BY product_category_name_english
HAVING total_orders BETWEEN 100 AND 1481
   AND avg_review_score >= 4.11
ORDER BY avg_review_score DESC;
