# SQL Point of Sale Database

Transactional point-of-sale database project built with SQLite. It models customers, products, sales, line items, payments, stock movements, and reporting views.

## What it demonstrates

- Relational model for a checkout workflow.
- Primary keys, foreign keys, unique constraints, checks, and indexes.
- Transaction-safe sale creation with stock movement tracking.
- Views for invoice totals and daily sales summaries.
- Queries for revenue, payment methods, and top products.
- Python demo and automated integrity tests using only the standard library.

## Run the demo

Run python demo.py and python -m unittest discover -s tests -v.

The demo creates an in-memory database, records a sale, commits the transaction, and prints the resulting invoice and daily summary.

## Files

- sql/schema.sql: tables, indexes, triggers, and reporting views.
- sql/seed.sql: product and customer sample data.
- sql/queries.sql: revenue and operational reports.
- demo.py: end-to-end transaction example.
- tests/: automated SQL integrity checks.
