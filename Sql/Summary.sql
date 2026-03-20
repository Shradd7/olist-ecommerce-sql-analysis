
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