-- ============================================================
-- SCRIPT: 03_delivery_analysis.sql
-- PURPOSE: Analyze delivery performance and its impact on 
--          customer satisfaction
-- KEY QUESTIONS:
--   - Does late delivery hurt review scores?
--   - Which states have the worst delivery performance?
--   - How does delivery time affect satisfaction?
--   - Is freight cost correlated with delivery speed?
-- ============================================================

-- -----------------------------------------------
-- QUERY 1: Late vs On-Time — Review Score Impact
-- -----------------------------------------------
SELECT
    CASE WHEN is_late = 1 THEN 'Late' ELSE 'On Time' END AS delivery_status,
    COUNT(DISTINCT order_id)            AS total_orders,
    ROUND(AVG(review_score), 2)         AS avg_review_score,
    ROUND(AVG(actual_delivery_days), 1) AS avg_delivery_days
FROM master_orders
GROUP BY is_late;


-- -----------------------------------------------
-- QUERY 2: Review Score by Delivery Day Buckets
-- (how satisfaction degrades as delivery takes longer)
-- -----------------------------------------------
SELECT
    CASE
        WHEN actual_delivery_days <= 7  THEN '1. 0-7 days'
        WHEN actual_delivery_days <= 14 THEN '2. 8-14 days'
        WHEN actual_delivery_days <= 21 THEN '3. 15-21 days'
        WHEN actual_delivery_days <= 30 THEN '4. 22-30 days'
        ELSE                                 '5. 30+ days'
    END AS delivery_bucket,
    COUNT(DISTINCT order_id)            AS total_orders,
    ROUND(AVG(review_score), 2)         AS avg_review_score,
    ROUND(AVG(actual_delivery_days), 1) AS avg_delivery_days
FROM master_orders
GROUP BY delivery_bucket
ORDER BY delivery_bucket;


-- -----------------------------------------------
-- QUERY 3: Delivery Performance by Customer State
-- -----------------------------------------------
SELECT
    customer_state,
    COUNT(DISTINCT order_id)                        AS total_orders,
    ROUND(AVG(actual_delivery_days), 1)             AS avg_delivery_days,
    ROUND(AVG(freight_value), 2)                    AS avg_freight_cost,
    ROUND(AVG(review_score), 2)                     AS avg_review_score,
    COUNT(DISTINCT CASE WHEN is_late = 1 
          THEN order_id END)                        AS late_orders,
    ROUND(COUNT(DISTINCT CASE WHEN is_late = 1 
          THEN order_id END) * 100.0 / 
          COUNT(DISTINCT order_id), 1)              AS late_pct
FROM master_orders
GROUP BY customer_state
ORDER BY avg_delivery_days DESC;

