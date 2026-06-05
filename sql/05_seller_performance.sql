-- ============================================================
-- SCRIPT: 05_seller_performance.sql
-- PURPOSE: Evaluate seller quality and performance
-- KEY QUESTIONS:
--   - Who are the top performing sellers by revenue?
--   - Which sellers have the best customer satisfaction?
--   - Which sellers have delivery or quality problems?
--   - How is seller performance distributed across states?
-- ============================================================

-- -----------------------------------------------
-- QUERY 1: Overall Seller Performance Scorecard
-- -----------------------------------------------
SELECT
    seller_id,
    seller_city,
    seller_state,
    COUNT(DISTINCT order_id)                        AS total_orders,
    ROUND(SUM(price), 2)                            AS total_revenue,
    ROUND(AVG(price), 2)                            AS avg_item_price,
    ROUND(AVG(review_score), 2)                     AS avg_review_score,
    COUNT(DISTINCT CASE WHEN is_late = 1
          THEN order_id END)                        AS late_orders,
    ROUND(COUNT(DISTINCT CASE WHEN is_late = 1
          THEN order_id END) * 100.0 /
          COUNT(DISTINCT order_id), 1)              AS late_pct,
    ROUND(AVG(actual_delivery_days), 1)             AS avg_delivery_days
FROM master_orders
GROUP BY seller_id, seller_city, seller_state
HAVING total_orders >= 30
ORDER BY total_revenue DESC;


-- -----------------------------------------------
-- QUERY 2: Seller Segments
-- Top performers vs At Risk vs Problem sellers
-- Thresholds based on dataset medians
-- -----------------------------------------------
WITH seller_stats AS (
    SELECT
        seller_id,
        seller_state,
        COUNT(DISTINCT order_id)                    AS total_orders,
        ROUND(SUM(price), 2)                        AS total_revenue,
        ROUND(AVG(review_score), 2)                 AS avg_review_score,
        ROUND(COUNT(DISTINCT CASE WHEN is_late = 1
              THEN order_id END) * 100.0 /
              COUNT(DISTINCT order_id), 1)          AS late_pct
    FROM master_orders
    GROUP BY seller_id, seller_state
    HAVING total_orders >= 30
)
SELECT
    seller_id,
    seller_state,
    total_orders,
    total_revenue,
    avg_review_score,
    late_pct,
    CASE
        WHEN avg_review_score >= 4.0 AND late_pct <= 8.1  THEN 'Top Performer'
        WHEN avg_review_score >= 4.0 AND late_pct > 8.1   THEN 'Good Quality Late Delivery'
        WHEN avg_review_score < 4.0  AND late_pct <= 8.1  THEN 'Low Satisfaction On Time'
        WHEN avg_review_score < 4.0  AND late_pct > 8.1   THEN 'At Risk'
    END AS seller_segment
FROM seller_stats
ORDER BY total_revenue DESC;


-- -----------------------------------------------
-- QUERY 3: Seller Performance by State
-- Which states produce the best sellers?
-- -----------------------------------------------
SELECT
    seller_state,
    COUNT(DISTINCT seller_id)                       AS total_sellers,
    ROUND(SUM(price), 2)                            AS total_revenue,
    ROUND(AVG(review_score), 2)                     AS avg_review_score,
    ROUND(COUNT(DISTINCT CASE WHEN is_late = 1
          THEN order_id END) * 100.0 /
          COUNT(DISTINCT order_id), 1)              AS late_pct,
    ROUND(AVG(actual_delivery_days), 1)             AS avg_delivery_days
FROM master_orders
GROUP BY seller_state
ORDER BY total_revenue DESC;