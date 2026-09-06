"""E-Commerce Revenue & Customer Analytics - Python workflow."""

from pathlib import Path
import pandas as pd

DATA = Path(__file__).resolve().parents[1] / "data"


def load_data():
    customers = pd.read_csv(DATA / "customers.csv", parse_dates=["signup_date"])
    orders = pd.read_csv(DATA / "orders.csv", parse_dates=["order_date"])
    items = pd.read_csv(DATA / "order_items.csv")
    products = pd.read_csv(DATA / "products.csv")
    returns = pd.read_csv(DATA / "returns.csv", parse_dates=["return_date"])
    return customers, orders, items, products, returns


def validate(customers, orders, items, products, returns):
    """Fail early when core relational assumptions are broken."""
    assert customers["customer_id"].is_unique, "Duplicate customer IDs"
    assert orders["order_id"].is_unique, "Duplicate order IDs"
    assert products["product_id"].is_unique, "Duplicate product IDs"
    assert (items["quantity"] > 0).all(), "Invalid quantity found"
    assert (items["unit_price"] >= 0).all(), "Negative unit price found"
    assert (items["unit_cost"] >= 0).all(), "Negative unit cost found"
    assert items["order_id"].isin(orders["order_id"]).all(), "Orphan order item"
    assert items["product_id"].isin(products["product_id"]).all(), "Orphan product"
    assert returns["order_id"].isin(orders["order_id"]).all(), "Invalid return order"


def build_analysis_table(customers, orders, items, products):
    df = (
        items
        .merge(orders, on="order_id", how="left", validate="many_to_one")
        .merge(products, on="product_id", how="left", validate="many_to_one")
        .merge(customers, on="customer_id", how="left", validate="many_to_one")
    )
    df["gross_revenue"] = df["quantity"] * df["unit_price"]
    df["product_cost"] = df["quantity"] * df["unit_cost"]
    df["gross_profit"] = df["gross_revenue"] - df["product_cost"]
    df["gross_margin_pct"] = df["gross_profit"] / df["gross_revenue"].replace(0, pd.NA)
    return df


def monthly_kpis(df):
    monthly = (
        df.assign(month=df["order_date"].dt.to_period("M").dt.to_timestamp())
        .groupby("month", as_index=False)
        .agg(
            revenue=("gross_revenue", "sum"),
            gross_profit=("gross_profit", "sum"),
            orders=("order_id", "nunique"),
            customers=("customer_id", "nunique"),
        )
    )
    monthly["average_order_value"] = monthly["revenue"] / monthly["orders"]
    monthly["mom_growth"] = monthly["revenue"].pct_change()
    return monthly


def customer_segments(df):
    customer = (
        df.groupby("customer_id", as_index=False)
        .agg(orders=("order_id", "nunique"), revenue=("gross_revenue", "sum"))
    )
    customer["segment"] = pd.cut(
        customer["orders"],
        bins=[0, 1, 4, float("inf")],
        labels=["One-time", "Repeat", "High-frequency"],
    )
    return customer


def main():
    customers, orders, items, products, returns = load_data()
    validate(customers, orders, items, products, returns)
    analysis = build_analysis_table(customers, orders, items, products)

    print("MONTHLY KPIs")
    print(monthly_kpis(analysis).tail(12).to_string(index=False))

    print("\nCUSTOMER SEGMENTS")
    print(
        customer_segments(analysis)
        .groupby("segment", observed=True)
        .agg(customers=("customer_id", "count"), revenue=("revenue", "sum"))
        .to_string()
    )


if __name__ == "__main__":
    main()
