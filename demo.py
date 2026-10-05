from pathlib import Path
import sqlite3


ROOT = Path(__file__).parent


def build_database() -> sqlite3.Connection:
    connection = sqlite3.connect(":memory:")
    connection.execute("PRAGMA foreign_keys = ON")
    connection.executescript((ROOT / "sql" / "schema.sql").read_text(encoding="utf-8"))
    connection.executescript((ROOT / "sql" / "seed.sql").read_text(encoding="utf-8"))
    return connection


def record_sale(db: sqlite3.Connection) -> int:
    with db:
        sale_id = db.execute("INSERT INTO sales (customer_id, discount_rate, tax_rate) VALUES (?, ?, ?) RETURNING sale_id", (1, 0.10, 0.19)).fetchone()[0]
        db.executemany("INSERT INTO sale_items (sale_id, product_id, quantity, unit_price) VALUES (?, ?, ?, ?)", [(sale_id, 1, 2, 18.50), (sale_id, 2, 1, 9.90)])
        total = db.execute("SELECT total FROM sale_totals WHERE sale_id = ?", (sale_id,)).fetchone()[0]
        db.execute("INSERT INTO payments (sale_id, payment_method, amount) VALUES (?, 'cash', ?)", (sale_id, 60))
        return sale_id


if __name__ == "__main__":
    db = build_database()
    sale_id = record_sale(db)
    receipt = db.execute("SELECT subtotal, discount, tax, total FROM sale_totals WHERE sale_id = ?", (sale_id,)).fetchone()
    print(f"Sale #{sale_id}: subtotal=${receipt[0]:.2f}, discount=${receipt[1]:.2f}, tax=${receipt[2]:.2f}, total=${receipt[3]:.2f}")
    print("Daily summary:", db.execute("SELECT sale_count, revenue FROM daily_sales_summary").fetchone())
    print("Remaining coffee stock:", db.execute("SELECT stock_quantity FROM products WHERE sku = 'CAF-001'").fetchone()[0])
