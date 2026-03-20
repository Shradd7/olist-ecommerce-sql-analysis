USE olist_db;

SELECT
order_status,
  COUNT(*) AS order_count,
  ROUND(COUNT(*) * 100.0 / (SELECT COUNT(*) FROM orders), 2) AS pct_of_total
FROM orders
GROUP BY order_status
ORDER BY order_count DESC;
