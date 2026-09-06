# E-Commerce Revenue & Customer Analytics

> **Flagship Portfolio Project** · SQL · Python · Power BI · DAX · Data Modeling

An end-to-end analytics project focused on turning transactional e-commerce data into clear business insights across **revenue, customers, products, profitability, repeat purchasing, and returns**.

### Project Files

[📊 View Power BI Dashboard](./Dashboard%20Pictures.pdf) · [🗄️ View SQL Analysis](./sql/analysis.sql) · [🐍 View Python Analysis](./python/analysis.py)

---

## Project Overview

The objective is to build a complete analytical solution for an online retailer rather than simply visualize sales totals. The project combines SQL, Python, dimensional modeling, DAX, and Power BI to analyze performance and support business decisions.

### Business Questions

1. How are revenue, orders, and average order value changing over time?
2. Which product categories contribute the most revenue?
3. Which customer segments are most valuable?
4. How much revenue comes from repeat customers?
5. Which products combine strong sales with weak margins or high return rates?
6. Which acquisition channels generate valuable customers?
7. Where are the strongest and weakest markets?
8. Which customers should be prioritized for retention?

---

## Power BI Dashboard

The dashboard presents the analytical results through four business views:

| View | Focus |
|---|---|
| **Executive Overview** | Revenue, gross profit, orders, customers, AOV, monthly trends, category and market performance |
| **Customer Analytics** | New vs repeat customers, customer segments, acquisition channels, purchase behavior and cohorts |
| **Product Analytics** | Product/category revenue, gross margin, units sold, top products and low-margin products |
| **Retention & Returns** | Repeat purchase rate, return reasons, abnormal product return rates and retention opportunities |

### [Open the full dashboard →](./Dashboard%20Pictures.pdf)

---

## KPI Framework

| KPI | Definition |
|---|---|
| **Revenue** | Gross item revenue less applicable discounts |
| **Orders** | Distinct completed orders |
| **Customers** | Distinct purchasing customers |
| **Average Order Value** | Revenue / Orders |
| **Gross Profit** | Revenue - Product Cost |
| **Gross Margin %** | Gross Profit / Revenue |
| **Repeat Customer Rate** | Customers with more than one order / Purchasing customers |
| **Return Rate** | Returned units / Sold units |

---

## Data Model

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

| Table | Purpose |
|---|---|
| `customers` | Customer profile, signup date, location and acquisition channel |
| `orders` | Order header, customer, date, status, shipping and discounts |
| `order_items` | Product-level quantity, price and cost |
| `products` | Product, category and subcategory attributes |
| `returns` | Returned products, dates and return reasons |

---

## SQL Analysis

The SQL layer covers monthly performance, customer segmentation, product ranking, repeat purchasing, revenue concentration, and data-quality validation.

Key techniques used:

- CTEs
- Window functions
- `LAG()` for month-over-month comparison
- `DENSE_RANK()` for product ranking
- `NTILE()` for customer revenue concentration
- Conditional segmentation
- Data-quality checks

### Example — Customer Value Segmentation

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
```

**[View complete SQL analysis →](./sql/analysis.sql)**

---

## Python Analysis

Python is used to load, validate, combine, and transform the source tables into an analysis-ready dataset.

The workflow includes:

- CSV ingestion with pandas
- Primary-key validation
- Referential-integrity checks
- Invalid quantity/price/cost checks
- Many-to-one merge validation
- Revenue, cost and gross-profit calculations
- Monthly KPI aggregation
- Month-over-month growth
- Customer purchase-frequency segmentation

### Example

```python
analysis = (
    items
    .merge(orders, on="order_id", how="left", validate="many_to_one")
    .merge(products, on="product_id", how="left", validate="many_to_one")
    .merge(customers, on="customer_id", how="left", validate="many_to_one")
)

analysis["gross_revenue"] = analysis["quantity"] * analysis["unit_price"]
analysis["product_cost"] = analysis["quantity"] * analysis["unit_cost"]
analysis["gross_profit"] = analysis["gross_revenue"] - analysis["product_cost"]
```

**[View complete Python workflow →](./python/analysis.py)**

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

## Data Quality

Before analysis, the workflow checks for:

- Duplicate primary keys
- Missing customer or product references
- Invalid quantities
- Negative prices or costs
- Orders without valid relationships
- Returns without valid orders
- Unexpected order statuses

---

## Repository Structure

```text
ecommerce-analytics/
│
├── README.md
├── Dashboard Pictures.pdf
│
├── sql/
│   └── analysis.sql
│
└── python/
    └── analysis.py
```

---

## Skills Demonstrated

**SQL** · **Python** · **pandas** · **Power BI** · **DAX** · **Data Modeling** · **Data Cleaning** · **Data Quality** · **Customer Segmentation** · **Business Intelligence**

---

## Project Status

- [x] Business case and analytical design
- [x] Data model specification
- [x] KPI framework
- [x] SQL analysis
- [x] Python analysis workflow
- [x] Power BI measure design
- [x] Dashboard design
- [x] Dashboard PDF
- [ ] Final project dataset
- [ ] Final findings and recommendations

---

## What This Project Demonstrates

This project demonstrates the complete analytical workflow: **understanding a business problem, structuring data, validating data quality, analyzing with SQL and Python, modeling KPIs, and communicating results through Power BI.**
