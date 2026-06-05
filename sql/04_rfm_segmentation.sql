-- ============================================================
-- SCRIPT: 04_rfm_segmentation.sql
-- PURPOSE: Segment customers by value using RFM analysis
-- KEY QUESTIONS:
--   - Who are our most valuable customers?
--   - What proportion of customers are at risk of churning?
--   - How is customer value distributed across segments?
-- NOTE: Reference date set to 2018-10-18 (day after last order)
--       to calculate recency accurately against dataset end date
-- ============================================================

-- -----------------------------------------------
-- QUERY 1: Calculate Raw RFM Scores per Customer
-- -----------------------------------------------
-- NOTE: Reference date = 2018-10-18. Chosen as one day after the last recorded order in the dataset (MAX(order_purchase_timestamp) = 2018-10-17)
-- This ensures recency_days = 0 for the most recent customer rather than a negative number
WITH rfm_base AS (
    SELECT
        customer_unique_id,
        MAX(DATE(order_purchase_timestamp))         AS last_order_date,
        COUNT(DISTINCT order_id)                    AS frequency,
        ROUND(SUM(price + freight_value), 2)        AS monetary,
        JULIANDAY('2018-10-18') - 
        JULIANDAY(MAX(DATE(order_purchase_timestamp))) AS recency_days
    FROM master_orders
    GROUP BY customer_unique_id
),

-- -----------------------------------------------
-- QUERY 2: Score each customer 1-5 on R, F, M
-- -----------------------------------------------
rfm_scores AS (
    SELECT
        customer_unique_id,
        last_order_date,
        recency_days,
        frequency,
        monetary,
        NTILE(5) OVER (ORDER BY recency_days DESC)  AS r_score,
        NTILE(5) OVER (ORDER BY frequency ASC)      AS f_score,
        NTILE(5) OVER (ORDER BY monetary ASC)       AS m_score
    FROM rfm_base
),

-- -----------------------------------------------
-- QUERY 3: Assign Segment Labels
-- -----------------------------------------------
rfm_segments AS (
    SELECT
        customer_unique_id,
        last_order_date,
        recency_days,
        frequency,
        monetary,
        r_score,
        f_score,
        m_score,
        ROUND((r_score + f_score + m_score) * 1.0 / 3, 2) AS rfm_avg,
        CASE
            WHEN r_score >= 4 AND f_score >= 4 AND m_score >= 4
                THEN 'Champions'
            WHEN r_score >= 3 AND f_score >= 3 AND m_score >= 3
                THEN 'Loyal Customers'
            WHEN r_score >= 4 AND f_score <= 2
                THEN 'New Customers'
            WHEN r_score <= 2 AND f_score >= 3 AND m_score >= 3
                THEN 'At Risk'
            WHEN r_score <= 2 AND f_score <= 2 AND m_score <= 2
                THEN 'Lost'
            ELSE
                THEN 'Potential Loyalists'
        END AS segment
    FROM rfm_scores
)

SELECT * FROM rfm_segments
ORDER BY rfm_avg DESC;