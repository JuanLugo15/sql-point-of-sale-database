PRAGMA foreign_keys = ON;

DROP VIEW IF EXISTS daily_sales_summary;
DROP VIEW IF EXISTS sale_totals;
DROP TRIGGER IF EXISTS sale_item_after_insert;
DROP TABLE IF EXISTS payments;
DROP TABLE IF EXISTS sale_items;
DROP TABLE IF EXISTS sales;
DROP TABLE IF EXISTS products;
DROP TABLE IF EXISTS customers;

CREATE TABLE customers (
    customer_id INTEGER PRIMARY KEY,
    full_name TEXT NOT NULL,
    email TEXT UNIQUE,
    created_at TEXT NOT NULL DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE products (
    product_id INTEGER PRIMARY KEY,
    sku TEXT NOT NULL UNIQUE,
    name TEXT NOT NULL,
    unit_price NUMERIC NOT NULL CHECK (unit_price >= 0),
    stock_quantity INTEGER NOT NULL CHECK (stock_quantity >= 0),
    active INTEGER NOT NULL DEFAULT 1 CHECK (active IN (0, 1))
);

CREATE TABLE sales (
    sale_id INTEGER PRIMARY KEY,
    customer_id INTEGER,
    status TEXT NOT NULL DEFAULT 'completed' CHECK (status IN ('draft', 'completed', 'cancelled')),
    discount_rate NUMERIC NOT NULL DEFAULT 0 CHECK (discount_rate BETWEEN 0 AND 1),
    tax_rate NUMERIC NOT NULL DEFAULT 0.19 CHECK (tax_rate >= 0),
    created_at TEXT NOT NULL DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (customer_id) REFERENCES customers(customer_id)
);

CREATE TABLE sale_items (
    sale_item_id INTEGER PRIMARY KEY,
    sale_id INTEGER NOT NULL,
    product_id INTEGER NOT NULL,
    quantity INTEGER NOT NULL CHECK (quantity > 0),
    unit_price NUMERIC NOT NULL CHECK (unit_price >= 0),
    FOREIGN KEY (sale_id) REFERENCES sales(sale_id) ON DELETE CASCADE,
    FOREIGN KEY (product_id) REFERENCES products(product_id)
);

CREATE TABLE payments (
    payment_id INTEGER PRIMARY KEY,
    sale_id INTEGER NOT NULL,
    payment_method TEXT NOT NULL CHECK (payment_method IN ('cash', 'card', 'transfer')),
    amount NUMERIC NOT NULL CHECK (amount > 0),
    paid_at TEXT NOT NULL DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (sale_id) REFERENCES sales(sale_id) ON DELETE CASCADE
);

CREATE INDEX idx_sales_created_at ON sales(created_at);
CREATE INDEX idx_sale_items_sale ON sale_items(sale_id);
CREATE INDEX idx_payments_method ON payments(payment_method);

CREATE TRIGGER sale_item_after_insert
AFTER INSERT ON sale_items
BEGIN
    UPDATE products
       SET stock_quantity = stock_quantity - NEW.quantity
     WHERE product_id = NEW.product_id;
END;

CREATE VIEW sale_totals AS
SELECT
    s.sale_id,
    ROUND(SUM(i.quantity * i.unit_price), 2) AS subtotal,
    ROUND(SUM(i.quantity * i.unit_price) * s.discount_rate, 2) AS discount,
    ROUND((SUM(i.quantity * i.unit_price) - SUM(i.quantity * i.unit_price) * s.discount_rate) * s.tax_rate, 2) AS tax,
    ROUND((SUM(i.quantity * i.unit_price) - SUM(i.quantity * i.unit_price) * s.discount_rate) * (1 + s.tax_rate), 2) AS total
FROM sales s
JOIN sale_items i ON i.sale_id = s.sale_id
GROUP BY s.sale_id;

CREATE VIEW daily_sales_summary AS
SELECT
    substr(s.created_at, 1, 10) AS sale_date,
    COUNT(DISTINCT s.sale_id) AS sale_count,
    ROUND(SUM(t.total), 2) AS revenue
FROM sales s
JOIN sale_totals t ON t.sale_id = s.sale_id
WHERE s.status = 'completed'
GROUP BY substr(s.created_at, 1, 10);
