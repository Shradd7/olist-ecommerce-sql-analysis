# Olist E-Commerce SQL Analysis

> Advanced SQL analysis on 100K+ real Brazilian e-commerce orders — funnel analytics, delivery performance, seller intelligence, and cohort retention.

## Project Overview

This project analyses the [Olist Brazilian E-Commerce dataset](https://www.kaggle.com/datasets/olistbr/brazilian-ecommerce) using MySQL. The goal is to surface actionable product and operations insights from raw transactional data — the kind of analysis a Product Analyst or Growth Analyst would run at an e-commerce startup.

**Dataset:** 99,441 orders · 6 tables · 2016–2018

---

## Key Findings

| # | Finding | Insight |
|---|---------|---------|
| 1 | **96.5% of orders reach delivered status** — but 8.1% are delivered late | Late delivery is the #1 operations risk |
| 2 | **Average delivery time is 12.1 days** — customers who receive faster have higher review scores | Speed directly drives satisfaction |
| 3 | **Top sellers average 4.6★ with <8 day delivery** — bottom sellers average 2.8★ with 21+ day delivery | Delivery SLA is the strongest predictor of seller rating |
| 4 | **Cohort retention drops to <5% by month 2** — nearly all customers are one-time buyers | Retention is the core growth problem for this marketplace |

---

## Analyses

### 1. Order Funnel Analysis (`01_funnel_analysis.sql`)
Breaks down all orders by status — delivered, shipped, cancelled, unavailable. Calculates percentage of total at each stage to identify drop-off points.

**Key finding:** 96.5% delivered, 1.1% cancelled, 0.6% unavailable.

### 2. Delivery Performance (`02_delivery_analysis.sql`)
Calculates average delivery time and late delivery rate by comparing actual vs estimated delivery dates.

**Key finding:** 12.1 avg delivery days · 8.1% late delivery rate.

### 3. Seller Performance (`03_seller_performance.sql`)
Joins order_items, orders, and reviews to rank sellers by average review score and delivery speed. Filters to sellers with 20+ orders for statistical reliability.

**Key finding:** Strong negative correlation between delivery days and review score.

### 4. Cohort Retention (`04_cohort_retention.sql`)
Two-step cohort analysis optimised for large datasets on TEXT columns. Step 1 pre-processes the heavy multi-table JOIN into a lightweight summary table (`customer_orders`). Step 2 runs a CTE-based cohort query on that clean table — tagging each customer with their acquisition month and tracking activity in subsequent months.

**Key finding:** Month-2 retention is under 5% — this is a one-purchase marketplace.

---

## How to Run

### Requirements
- MySQL 8.0+
- MySQL Workbench

### Setup
1. Download the dataset from [Kaggle](https://www.kaggle.com/datasets/olistbr/brazilian-ecommerce)
2. Create the database:
```sql
CREATE DATABASE olist_db;
```
3. Load CSVs into MySQL using the provided Python script (`load_olist.py`) — install dependencies with `pip install pandas sqlalchemy mysql-connector-python` then run `python load_olist.py`
4. Run queries in the `sql/` folder in order

### Recommended run order
```
01_funnel_analysis.sql       -- run first, no dependencies
02_delivery_analysis.sql     -- run second
03_seller_performance.sql    -- add indexes before running (see below)
04_cohort_retention.sql      -- run Step 1 first (creates customer_orders table), then Step 2
```

### Add indexes for performance (run once before queries 3 and 4)
```sql
ALTER TABLE orders ADD INDEX idx_status (order_status(20));
ALTER TABLE orders ADD INDEX idx_customer (customer_id(50));
ALTER TABLE customers ADD INDEX idx_unique (customer_unique_id(50));
```

### Query 4 — run in two steps
**Step 1** — creates a pre-processed summary table (run once):
```sql
CREATE TABLE IF NOT EXISTS customer_orders AS
SELECT
  c.customer_unique_id,
  DATE_FORMAT(o.order_purchase_timestamp, '%Y-%m') AS order_month
FROM orders o
JOIN customers c ON o.customer_id = c.customer_id
WHERE o.order_status = 'delivered';
```

**Step 2** — cohort retention query (uses the table from Step 1):
```sql
WITH cohorts AS (
  SELECT customer_unique_id, MIN(order_month) AS cohort_month
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
```

---

## Tech Stack
- **MySQL 8.0** — data storage and querying
- **SQL concepts used** — CTEs, window functions, multi-table JOINs, aggregate functions, DATEDIFF, DATE_FORMAT, HAVING, UNION ALL
- **Tableau Public** — visualisation dashboard *(link coming soon)*

---

## Skills Demonstrated
- Funnel analysis and conversion metrics
- Cohort analysis and retention curves
- Multi-table JOIN optimisation on large datasets (100K+ rows)
- Business insight extraction from raw transactional data
- Product analytics thinking — translating SQL output into actionable findings

---

## Dataset
Brazilian E-Commerce Public Dataset by Olist — available on [Kaggle](https://www.kaggle.com/datasets/olistbr/brazilian-ecommerce).  
*Raw CSV files are not included in this repo per Kaggle's terms of use.*
