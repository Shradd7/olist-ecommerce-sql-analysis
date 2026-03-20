
USE olist_db;
CREATE OR REPLACE VIEW executive_summary AS
SELECT 'Total Orders'        AS metric, COUNT(*)                          AS value FROM orders
UNION ALL
SELECT 'Delivered Orders'    , COUNT(*)                                   FROM orders WHERE order_status = 'delivered'
UNION ALL
SELECT 'Cancelled Orders'    , COUNT(*)                                   FROM orders WHERE order_status = 'cancelled'
UNION ALL
SELECT 'Unique Customers'    , COUNT(DISTINCT customer_unique_id)         FROM customers
UNION ALL
SELECT 'Total Sellers'       , COUNT(*)                                   FROM sellers
UNION ALL
SELECT 'Avg Review Score x10', ROUND(AVG(review_score) * 10, 0)          FROM reviews;


USE olist_db;

-- RFM segment counts
SELECT segment, COUNT(*) AS customers
FROM (
  WITH rfm_base AS (
    SELECT
      c.customer_unique_id,
      DATEDIFF('2018-10-01', MAX(o.order_purchase_timestamp)) AS recency,
      COUNT(DISTINCT o.order_id)                              AS frequency,
      ROUND(SUM(p.payment_value), 2)                         AS monetary
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
  SELECT *,
    CASE
      WHEN r_score >= 4 AND f_score >= 4 THEN 'Champion'
      WHEN r_score >= 3 AND f_score >= 3 THEN 'Loyal'
      WHEN r_score >= 3 AND f_score <= 2 THEN 'Promising'
      WHEN r_score <= 2 AND f_score >= 3 THEN 'At Risk'
      WHEN r_score <= 2 AND f_score <= 2 THEN 'Lost'
      ELSE 'Needs Attention'
    END AS segment
  FROM rfm_scored
) AS rfm
GROUP BY segment
ORDER BY customers DESC;