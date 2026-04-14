CREATE DATABASE online_store_db;

CREATE SCHEMA store; 
SET search_path TO store;

-- table 1 - customer
CREATE TABLE customer (
    customer_id BIGSERIAL PRIMARY KEY,
    first_name VARCHAR(50) NOT NULL,
    last_name VARCHAR(50) NOT NULL,
    full_name VARCHAR(101) GENERATED ALWAYS AS (first_name || ' ' || last_name) STORED,
    gender CHAR(1) NOT NULL,
    email VARCHAR(100) NOT NULL UNIQUE,
    birth_date DATE NOT NULL,
    created_date DATE NOT NULL DEFAULT CURRENT_DATE,

    CONSTRAINT chk_customers_gender
        CHECK (gender IN ('M', 'F', 'O')),

    CONSTRAINT chk_customers_birth_date
        CHECK (birth_date > DATE '2000-01-01')
);

-- table 2 - category
CREATE TABLE category (
    category_id BIGSERIAL PRIMARY KEY,
    category_name VARCHAR(100) NOT NULL UNIQUE,
    description TEXT,

    CONSTRAINT chk_category_name_not_blank
        CHECK (char_length(trim(category_name)) > 0)
);

-- table 3 - product
CREATE TABLE product (
    product_id BIGSERIAL PRIMARY KEY,
    category_id BIGINT NOT NULL,
    product_name VARCHAR(100) NOT NULL,
    unit_price NUMERIC(10,2) NOT NULL DEFAULT 0,
    stock_qty INTEGER NOT NULL DEFAULT 0,
    weight_kg NUMERIC(8,2) NOT NULL DEFAULT 0,
    created_date DATE NOT NULL DEFAULT CURRENT_DATE,

    CONSTRAINT fk_products_category
        FOREIGN KEY (category_id)
        REFERENCES category(category_id),

    CONSTRAINT chk_product_price_non_negative
        CHECK (unit_price >= 0),

    CONSTRAINT chk_product_stock_non_negative
        CHECK (stock_qty >= 0),

    CONSTRAINT chk_product_weight_non_negative
        CHECK (weight_kg >= 0)
);

-- table 4 - orders
CREATE TABLE orders (
    order_id BIGSERIAL PRIMARY KEY,
    customer_id BIGINT NOT NULL,
    order_date DATE NOT NULL DEFAULT CURRENT_DATE,
    order_status VARCHAR(20) NOT NULL DEFAULT 'new',

    CONSTRAINT fk_orders_customer
        FOREIGN KEY (customer_id)
        REFERENCES customer(customer_id),

    CONSTRAINT chk_order_date
        CHECK (order_date > DATE '2000-01-01'),

    CONSTRAINT chk_order_status
        CHECK (order_status IN ('new', 'paid', 'shipped', 'completed', 'cancelled'))
);

-- table 5 - order_item
CREATE TABLE order_item (
    order_id BIGINT NOT NULL,
    product_id BIGINT NOT NULL,
    quantity INTEGER NOT NULL DEFAULT 1,
    unit_price NUMERIC(10,2) NOT NULL,
    line_total NUMERIC(12,2) GENERATED ALWAYS AS (quantity * unit_price) STORED,

    CONSTRAINT fk_order_items_order
        FOREIGN KEY (order_id)
        REFERENCES orders(order_id)
        ON DELETE CASCADE,

    CONSTRAINT fk_order_items_product
        FOREIGN KEY (product_id)
        REFERENCES product(product_id),

    CONSTRAINT pk_order_product
        PRIMARY KEY (order_id, product_id),

    CONSTRAINT chk_order_item_quantity
        CHECK (quantity > 0),

    CONSTRAINT chk_order_item_price
        CHECK (unit_price >= 0)
);

-- table 6 - payment
CREATE TABLE payment (
    payment_id BIGSERIAL PRIMARY KEY,
    order_id BIGINT NOT NULL,
    payment_date DATE NOT NULL,
    amount NUMERIC(10,2) NOT NULL,
    payment_method VARCHAR(20) NOT NULL,
    payment_status VARCHAR(20) NOT NULL DEFAULT 'pending',

    CONSTRAINT fk_payments_order
        FOREIGN KEY (order_id)
        REFERENCES orders(order_id)
        ON DELETE CASCADE,

    CONSTRAINT chk_payment_date
        CHECK (payment_date > DATE '2000-01-01'),

    CONSTRAINT chk_payment_amount
        CHECK (amount >= 0),

    CONSTRAINT chk_payment_method
        CHECK (payment_method IN ('card', 'cash', 'transfer')),

    CONSTRAINT chk_payment_status
        CHECK (payment_status IN ('pending', 'paid', 'failed'))
);

-- add sample data
INSERT INTO customer (first_name, last_name, gender, email, birth_date)
VALUES ('Nurdaulet', 'Tulegen', 'M', 'nurdaulettolen26@gmail.com', '2006-08-16'),
	('Tokayev', 'Kasymzhomart', 'M', 'tokayev@example.com', '2000-08-21'),
	('Putin', 'Vladimir', 'M', 'putin@example.com', '2002-11-03'),
	('Donald', 'Tramp', 'M', 'tramp@example.com', '2001-12-09');

INSERT INTO category (category_name, description)
VALUES ('Electronics', 'Devices and gadgets'),
	('Books', 'Educational and other books'),
	('Accessories', 'Useful accessories');

INSERT INTO product (category_id, product_name, unit_price, stock_qty, weight_kg)
VALUES (1, 'Wireless Mouse', 4500.00, 100, 0.20),
	(1, 'Keyboard', 8500.00, 50, 0.70),
	(2, 'Database Basics Book', 7000.00, 40, 0.50),
	(3, 'Laptop Bag', 12000.00, 25, 0.90),
	(3, 'USB Cable', 2000.00, 200, 0.10);

INSERT INTO orders (customer_id, order_date, order_status)
VALUES (1, '2024-11-10', 'paid'),
	(2, '2024-11-11', 'new'),
	(3, '2024-11-12', 'shipped'),
	(4, '2024-11-13', 'completed');

INSERT INTO order_item (order_id, product_id, quantity, unit_price)
VALUES (1, 1, 2, 4500.00),
	(1, 5, 1, 2000.00),
	(2, 3, 1, 7000.00),
	(3, 2, 1, 8500.00),
	(4, 4, 1, 12000.00);

INSERT INTO payment (order_id, payment_date, amount, payment_method, payment_status)
VALUES (1, '2024-11-10', 11000.00, 'card', 'paid'),
	(2, '2024-11-11', 7000.00, 'transfer', 'pending'),
	(3, '2024-11-12', 8500.00, 'cash', 'paid'),
	(4, '2024-11-13', 12000.00, 'card', 'paid');

ALTER TABLE customer ADD COLUMN record_ts DATE DEFAULT CURRENT_DATE;
ALTER TABLE category ADD COLUMN record_ts DATE DEFAULT CURRENT_DATE;
ALTER TABLE product ADD COLUMN record_ts DATE DEFAULT CURRENT_DATE;
ALTER TABLE orders ADD COLUMN record_ts DATE DEFAULT CURRENT_DATE;
ALTER TABLE order_item ADD COLUMN record_ts DATE DEFAULT CURRENT_DATE;
ALTER TABLE payment ADD COLUMN record_ts DATE DEFAULT CURRENT_DATE;

SELECT customer_id, full_name, record_ts
FROM customer;

SELECT category_id, category_name, record_ts
FROM category;

SELECT product_id, product_name, record_ts
FROM product;

SELECT order_id, order_status, record_ts
FROM orders;

SELECT line_total, record_ts
FROM order_item;

SELECT payment_id, amount, record_ts
FROM payment;



