-- Invoice totals
SELECT * FROM sale_totals WHERE sale_id = 1;

-- Revenue by day
SELECT sale_date, sale_count, revenue
FROM daily_sales_summary
ORDER BY sale_date DESC;

-- Revenue by payment method
SELECT payment_method, ROUND(SUM(amount), 2) AS collected
FROM payments
GROUP BY payment_method
ORDER BY collected DESC;

-- Top-selling products
SELECT p.sku, p.name, SUM(i.quantity) AS units_sold, ROUND(SUM(i.quantity * i.unit_price), 2) AS gross_sales
FROM sale_items i
JOIN products p ON p.product_id = i.product_id
JOIN sales s ON s.sale_id = i.sale_id
WHERE s.status = 'completed'
GROUP BY p.product_id
ORDER BY units_sold DESC, gross_sales DESC;
