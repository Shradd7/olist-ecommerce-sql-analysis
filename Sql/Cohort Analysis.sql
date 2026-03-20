USE olist_db;

CREATE TABLE IF NOT EXISTS customer_orders AS
SELECT
  c.customer_unique_id,
  DATE_FORMAT(o.order_purchase_timestamp, '%Y-%m') AS order_month
FROM orders o
JOIN customers c ON o.customer_id = c.customer_id
WHERE o.order_status = 'delivered';


WITH cohorts AS (
  SELECT
    customer_unique_id,
    MIN(order_month) AS cohort_month
  FROM customer_orders
  GROUP BY customer_unique_id
)
SELECT
  c.cohort_month,
  a.order_month,
  COUNT(DISTINCT a.customer_unique_id) AS retained_customers
FROM cohorts c
JOIN customer_orders a ON c.customer_unique_id = a.customer_unique_id
GROUP BY c.cohort_month, a.order_month
ORDER BY c.cohort_month, a.order_month;