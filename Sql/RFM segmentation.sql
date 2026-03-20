-- ============================================================
-- Query 5: RFM Customer Segmentation
-- Segments all customers into Champions, Loyal, Promising,
-- At Risk, and Lost using Recency, Frequency, Monetary scoring
-- Uses NTILE() window function for scoring
-- ============================================================
USE olist_db;

WITH rfm_base AS (
  SELECT
    c.customer_unique_id,
    DATEDIFF('2018-10-01', MAX(o.order_purchase_timestamp)) AS recency,
    COUNT(DISTINCT o.order_id)                              AS frequency,
    ROUND(SUM(p.payment_value), 2)                          AS monetary
  FROM orders o
  JOIN customers c ON o.customer_id = c.customer_id
  JOIN payments p  ON o.order_id    = p.order_id
  WHERE o.order_status = 'delivered'
  GROUP BY c.customer_unique_id
),
rfm_scored AS (
  SELECT *,
    NTILE(5) OVER (ORDER BY recency  ASC)  AS r_score,
    NTILE(5) OVER (ORDER BY frequency DESC) AS f_score,
    NTILE(5) OVER (ORDER BY monetary  DESC) AS m_score
  FROM rfm_base
)
SELECT
  customer_unique_id,
  recency,
  frequency,
  monetary,
  r_score,
  f_score,
  m_score,
  CASE
    WHEN r_score >= 4 AND f_score >= 4 THEN 'Champion'
    WHEN r_score >= 3 AND f_score >= 3 THEN 'Loyal'
    WHEN r_score >= 3 AND f_score <= 2 THEN 'Promising'
    WHEN r_score <= 2 AND f_score >= 3 THEN 'At Risk'
    WHEN r_score <= 2 AND f_score <= 2 THEN 'Lost'
    ELSE 'Needs Attention'
  END AS segment
FROM rfm_scored
ORDER BY r_score DESC, f_score DESC;