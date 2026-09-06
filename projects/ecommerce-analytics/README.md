# E-Commerce Revenue & Customer Analytics

> **Flagship Portfolio Project** · SQL · Python · Power BI · DAX · Data Modeling

## Overview

This project builds an end-to-end analytics solution for a fictional online retailer. The objective is not simply to visualize sales: it is to create a reliable analytical model that explains **where revenue comes from, how customers behave, which products drive performance, and where the business has opportunities to improve retention and profitability**.

---

## Business Problem

The retailer has transactional data across orders, customers, products, order items, returns, and acquisition channels. Management currently sees total sales but cannot easily answer deeper questions about growth or customer behavior.

The analysis is designed to answer:

1. How are revenue, orders, and average order value changing over time?
2. Which product categories contribute the most revenue?
3. Which customer segments are most valuable?
4. How much revenue comes from repeat customers?
5. Which products have high sales but unusually high return rates?
6. Which acquisition channels generate valuable customers?
7. Where are the strongest and weakest geographic markets?
8. Which customers should be prioritized for retention activity?

---

## Planned Data Model

```text
                 DimCustomer
                      |
                      |
DimDate ------ FactOrders ------ DimChannel
                      |
                      |
                FactOrderItems
                  /         \
                 /           \
          DimProduct       FactReturns
```

### Core Tables

**customers**
- customer_id
- signup_date
- country
- city
- acquisition_channel

**orders**
- order_id
- customer_id
- order_date
- order_status
- shipping_amount
- discount_amount

**order_items**
- order_id
- product_id
- quantity
- unit_price
- unit_cost

**products**
- product_id
- product_name
- category
- subcategory

**returns**
- return_id
- order_id
- product_id
- return_date
- return_reason

---

## KPI Definitions

| KPI | Definition |
|---|---|
| Revenue | Gross item revenue less applicable discounts |
| Orders | Distinct completed orders |
| Customers | Distinct purchasing customers |
| Average Order Value | Revenue / Orders |
| Gross Profit | Revenue - Product Cost |
| Gross Margin % | Gross Profit / Revenue |
| Repeat Customer Rate | Customers with >1 order / Purchasing customers |
| Return Rate | Returned units / Sold units |

---

## SQL Analysis

### Customer Value Segmentation

```sql
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
    SUM(total_revenue) AS segment_revenue,
    AVG(total_revenue) AS avg_customer_revenue
FROM customer_value
GROUP BY
    CASE
        WHEN total_orders = 1 THEN 'One-time'
        WHEN total_orders BETWEEN 2 AND 4 THEN 'Repeat'
        ELSE 'High-frequency'
    END
ORDER BY segment_revenue DESC;
```

### Monthly Revenue Growth

```sql
WITH monthly_revenue AS (
    SELECT
        DATEFROMPARTS(YEAR(order_date), MONTH(order_date), 1) AS month_start,
        SUM(net_revenue) AS revenue
    FROM analytics_orders
    GROUP BY DATEFROMPARTS(YEAR(order_date), MONTH(order_date), 1)
)
SELECT
    month_start,
    revenue,
    LAG(revenue) OVER (ORDER BY month_start) AS previous_month_revenue,
    (revenue - LAG(revenue) OVER (ORDER BY month_start)) /
        NULLIF(LAG(revenue) OVER (ORDER BY month_start), 0) AS mom_growth
FROM monthly_revenue
ORDER BY month_start;
```

---

## Python Workflow

```python
import pandas as pd

orders = pd.read_csv('data/orders.csv', parse_dates=['order_date'])
customers = pd.read_csv('data/customers.csv', parse_dates=['signup_date'])
items = pd.read_csv('data/order_items.csv')
products = pd.read_csv('data/products.csv')

# Validate uniqueness
assert orders['order_id'].is_unique
assert customers['customer_id'].is_unique
assert products['product_id'].is_unique

analysis = (
    items
    .merge(orders, on='order_id', validate='many_to_one')
    .merge(products, on='product_id', validate='many_to_one')
)

analysis['gross_revenue'] = analysis['quantity'] * analysis['unit_price']
analysis['product_cost'] = analysis['quantity'] * analysis['unit_cost']
analysis['gross_profit'] = analysis['gross_revenue'] - analysis['product_cost']
```

---

## Power BI Measures

```DAX
Revenue =
SUMX(
    FactOrderItems,
    FactOrderItems[Quantity] * FactOrderItems[UnitPrice]
)

Orders =
DISTINCTCOUNT(FactOrders[OrderID])

Average Order Value =
DIVIDE([Revenue], [Orders])

Gross Profit =
[Revenue] - [Product Cost]

Gross Margin % =
DIVIDE([Gross Profit], [Revenue])
```

---

## Data Quality Checks

The project will explicitly validate:

- Duplicate primary keys
- Missing customer/product references
- Invalid quantities
- Negative prices or costs
- Orders without items
- Returns without valid orders
- Dates outside the expected reporting range
- Unexpected order statuses

---

## Project Deliverables

- [x] Business case and analytical design
- [x] Data model specification
- [x] KPI definitions
- [x] SQL analysis examples
- [x] Python transformation workflow
- [x] Power BI measure design
- [ ] Final project dataset
- [ ] Complete SQL analysis file
- [ ] Complete Python notebook
- [ ] Dashboard screenshots
- [ ] Final findings and recommendations

---

## Why This Project Matters

A strong analytics project should show more than software knowledge. This case study demonstrates how SQL, Python, data modeling, BI, and business reasoning work together to turn transactional data into decisions.
