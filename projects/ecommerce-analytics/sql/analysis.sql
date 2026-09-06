/*
  E-Commerce Revenue & Customer Analytics
  Portfolio SQL Case Study
*/

-- 01. Monthly revenue and order volume
SELECT
    DATEFROMPARTS(YEAR(order_date), MONTH(order_date), 1) AS month_start,
    COUNT(DISTINCT order_id) AS orders,
    COUNT(DISTINCT customer_id) AS customers,
    SUM(net_revenue) AS revenue,
    SUM(net_revenue) / NULLIF(COUNT(DISTINCT order_id), 0) AS average_order_value
FROM analytics_orders
GROUP BY DATEFROMPARTS(YEAR(order_date), MONTH(order_date), 1)
ORDER BY month_start;

-- 02. Month-over-month revenue growth
WITH monthly AS (
    SELECT
        DATEFROMPARTS(YEAR(order_date), MONTH(order_date), 1) AS month_start,
        SUM(net_revenue) AS revenue
    FROM analytics_orders
    GROUP BY DATEFROMPARTS(YEAR(order_date), MONTH(order_date), 1)
), comparison AS (
    SELECT
        month_start,
        revenue,
        LAG(revenue) OVER (ORDER BY month_start) AS previous_month_revenue
    FROM monthly
)
SELECT
    month_start,
    revenue,
    previous_month_revenue,
    (revenue - previous_month_revenue) / NULLIF(previous_month_revenue, 0) AS mom_growth
FROM comparison
ORDER BY month_start;

-- 03. Customer purchase-frequency segmentation
WITH customer_value AS (
    SELECT
        customer_id,
        COUNT(DISTINCT order_id) AS total_orders,
        SUM(net_revenue) AS total_revenue
    FROM analytics_orders
    GROUP BY customer_id
)
SELECT
    CASE
        WHEN total_orders = 1 THEN 'One-time'
        WHEN total_orders BETWEEN 2 AND 4 THEN 'Repeat'
        ELSE 'High-frequency'
    END AS customer_segment,
    COUNT(*) AS customers,
    SUM(total_revenue) AS revenue,
    AVG(total_revenue) AS avg_customer_revenue
FROM customer_value
GROUP BY
    CASE
        WHEN total_orders = 1 THEN 'One-time'
        WHEN total_orders BETWEEN 2 AND 4 THEN 'Repeat'
        ELSE 'High-frequency'
    END
ORDER BY revenue DESC;

-- 04. Rank products within category
WITH product_sales AS (
    SELECT
        category,
        product_id,
        product_name,
        SUM(quantity) AS units_sold,
        SUM(quantity * unit_price) AS revenue
    FROM analytics_order_items
    GROUP BY category, product_id, product_name
)
SELECT
    *,
    DENSE_RANK() OVER (PARTITION BY category ORDER BY revenue DESC) AS revenue_rank
FROM product_sales
ORDER BY category, revenue_rank;

-- 05. Top 3 products per category
WITH product_sales AS (
    SELECT
        category,
        product_id,
        product_name,
        SUM(quantity * unit_price) AS revenue
    FROM analytics_order_items
    GROUP BY category, product_id, product_name
), ranked AS (
    SELECT
        *,
        DENSE_RANK() OVER (PARTITION BY category ORDER BY revenue DESC) AS revenue_rank
    FROM product_sales
)
SELECT *
FROM ranked
WHERE revenue_rank <= 3
ORDER BY category, revenue_rank;

-- 06. Repeat customer rate
WITH customer_orders AS (
    SELECT customer_id, COUNT(DISTINCT order_id) AS order_count
    FROM analytics_orders
    GROUP BY customer_id
)
SELECT
    COUNT(*) AS purchasing_customers,
    SUM(CASE WHEN order_count > 1 THEN 1 ELSE 0 END) AS repeat_customers,
    1.0 * SUM(CASE WHEN order_count > 1 THEN 1 ELSE 0 END) / NULLIF(COUNT(*), 0) AS repeat_customer_rate
FROM customer_orders;

-- 07. Revenue concentration by customer
WITH customer_revenue AS (
    SELECT customer_id, SUM(net_revenue) AS revenue
    FROM analytics_orders
    GROUP BY customer_id
), ranked AS (
    SELECT
        customer_id,
        revenue,
        NTILE(10) OVER (ORDER BY revenue DESC) AS revenue_decile
    FROM customer_revenue
)
SELECT
    revenue_decile,
    COUNT(*) AS customers,
    SUM(revenue) AS revenue
FROM ranked
GROUP BY revenue_decile
ORDER BY revenue_decile;

-- 08. Data-quality check: orders without valid customers
SELECT o.order_id, o.customer_id
FROM orders o
LEFT JOIN customers c ON c.customer_id = o.customer_id
WHERE c.customer_id IS NULL;

-- 09. Data-quality check: invalid order-item values
SELECT *
FROM order_items
WHERE quantity <= 0
   OR unit_price < 0
   OR unit_cost < 0;
