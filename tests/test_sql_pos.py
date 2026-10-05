import unittest

from demo import build_database, record_sale


class PointOfSaleSqlTests(unittest.TestCase):
    def test_sale_transaction_calculates_totals_and_stock(self):
        db = build_database()
        sale_id = record_sale(db)
        totals = db.execute("SELECT subtotal, discount, tax, total FROM sale_totals WHERE sale_id = ?", (sale_id,)).fetchone()
        self.assertEqual(tuple(round(value, 2) for value in totals), (46.90, 4.69, 8.02, 50.23))
        stock = db.execute("SELECT stock_quantity FROM products WHERE sku = 'CAF-001'").fetchone()[0]
        self.assertEqual(stock, 22)

    def test_foreign_keys_and_payment_method_constraint(self):
        db = build_database()
        with self.assertRaises(Exception):
            db.execute("INSERT INTO sale_items (sale_id, product_id, quantity, unit_price) VALUES (999, 1, 1, 10)")
        with self.assertRaises(Exception):
            db.execute("INSERT INTO payments (sale_id, payment_method, amount) VALUES (1, 'crypto', 10)")


if __name__ == "__main__":
    unittest.main()
