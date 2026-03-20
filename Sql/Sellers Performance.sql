
SELECT
  oi.seller_id,
  COUNT(DISTINCT oi.order_id)                                                          AS total_orders,
  ROUND(AVG(r.review_score), 2)                                                        AS avg_review_score,
  ROUND(AVG(DATEDIFF(o.order_delivered_customer_date, o.order_purchase_timestamp)), 1) AS avg_delivery_days
FROM order_items oi
JOIN orders o  ON oi.order_id = o.order_id
JOIN reviews r ON o.order_id  = r.order_id
WHERE o.order_status = 'delivered'
  AND o.order_delivered_customer_date IS NOT NULL
GROUP BY oi.seller_id
HAVING COUNT(DISTINCT oi.order_id) > 20
ORDER BY avg_review_score DESC
LIMIT 30;