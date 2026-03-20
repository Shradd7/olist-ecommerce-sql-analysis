USE olist_db;

WITH category_revenue AS (
  SELECT
    pt.product_category_name_english  AS category,
    ROUND(SUM(p.payment_value), 2)    AS total_revenue,
    COUNT(DISTINCT o.order_id)        AS total_orders
  FROM payments p
  JOIN order_items oi ON p.order_id    = oi.order_id
  JOIN orders o       ON oi.order_id   = o.order_id
  JOIN products pr    ON oi.product_id = pr.product_id
  JOIN product_category_translation pt
                      ON pr.product_category_name = pt.product_category_name
  WHERE o.order_status = 'delivered'
  GROUP BY pt.product_category_name_english
),
running AS (
  SELECT *,
    ROUND(SUM(total_revenue) OVER (
      ORDER BY total_revenue DESC
      ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
    ), 2) AS running_total,
    ROUND(total_revenue * 100.0 /
      SUM(total_revenue) OVER (), 2) AS pct_of_total
  FROM category_revenue
)
SELECT
  category,
  total_revenue,
  total_orders,
  pct_of_total,
  ROUND(running_total * 100.0 /
    SUM(total_revenue) OVER (), 2) AS cumulative_pct
FROM running
ORDER BY total_revenue DESC
LIMIT 20;