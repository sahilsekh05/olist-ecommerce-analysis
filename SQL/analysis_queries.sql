CREATE DATABASE olist_db;
USE olist_db;

CREATE TABLE orders (
    order_id VARCHAR(50) PRIMARY KEY,
    customer_id VARCHAR(50),
    order_status VARCHAR(20),
    order_purchase_timestamp VARCHAR(25),
    order_delivered_customer_date VARCHAR(25)
);

SELECT COUNT(*) FROM orders;

SELECT 
    order_purchase_timestamp,
    order_delivered_customer_date
FROM orders
LIMIT 5;

SELECT 
    COUNT(*) AS total_orders,
    COUNT(order_delivered_customer_date) AS delivered_orders
FROM orders;

SELECT DISTINCT order_status
FROM orders;



CREATE TABLE order_items (
    order_id VARCHAR(50),
    product_id VARCHAR(50),
    price DECIMAL(10,2),
    freight_value DECIMAL(10,2)
);

SELECT COUNT(*) FROM order_items;

CREATE TABLE customers (
    customer_id VARCHAR(50) PRIMARY KEY,
    customer_unique_id VARCHAR(50),
    customer_state VARCHAR(5)
);

SELECT COUNT(*) FROM customers;
SELECT * 
FROM customers
LIMIT 10;

DROP TABLE customers;


CREATE TABLE products (
    product_id VARCHAR(50) PRIMARY KEY,
    product_category_name VARCHAR(50)
);

SELECT COUNT(*) FROM products;

CREATE TABLE payments (
    order_id VARCHAR(50),
    payment_type VARCHAR(20),
    payment_value DECIMAL(10,2)
);

SELECT COUNT(*) FROM payments;

SHOW TABLES;

#Total Orders
SELECT COUNT(*) AS total_orders
FROM orders;

#Total Revenue
SELECT SUM(price) AS total_revenue
FROM order_items;

#Average Order Value
SELECT 
    SUM(oi.price) / COUNT(DISTINCT o.order_id) AS avg_order_value
FROM orders o
JOIN order_items oi
ON o.order_id = oi.order_id;

#For KPI summary
SELECT 
    COUNT(DISTINCT o.order_id) AS total_orders,
    ROUND(SUM(oi.price), 2) AS total_revenue,
    ROUND(SUM(oi.price) / COUNT(DISTINCT o.order_id), 2) AS avg_order_value
FROM orders o
JOIN order_items oi
ON o.order_id = oi.order_id;


#Monthly Sales Trend
SELECT 
    DATE_FORMAT(o.order_purchase_timestamp, '%Y-%m') AS month,
    SUM(oi.price) AS monthly_revenue
FROM orders o
JOIN order_items oi
ON o.order_id = oi.order_id
GROUP BY month
ORDER BY month;

#Monthly Order count
SELECT 
    DATE_FORMAT(order_purchase_timestamp, '%Y-%m') AS month,
    COUNT(DISTINCT order_id) AS total_orders
FROM orders
GROUP BY month
ORDER BY month;

#Top Product Categories by Revenue
SELECT 
    p.product_category_name,
    SUM(oi.price) AS revenue
FROM order_items oi
JOIN products p
ON oi.product_id = p.product_id
GROUP BY p.product_category_name
ORDER BY revenue DESC
LIMIT 10;

#TOP PRODUCT CATEGORIES BY SALES VOLUME
SELECT 
    p.product_category_name AS category,
    COUNT(oi.product_id) AS items_sold
FROM order_items oi
JOIN products p ON oi.product_id = p.product_id
GROUP BY category
ORDER BY items_sold DESC
LIMIT 10;

#TOP CUSTOMERS BY REVENUE
SELECT 
    c.customer_id,
    ROUND(SUM(oi.price), 2) AS revenue
FROM customers c
JOIN orders o ON c.customer_id = o.customer_id
JOIN order_items oi ON o.order_id = oi.order_id
GROUP BY c.customer_id
ORDER BY revenue DESC
LIMIT 20;

CREATE TABLE brazil_states (
    state_code VARCHAR(2) PRIMARY KEY,
    state_name VARCHAR(50)
);
INSERT INTO brazil_states (state_code, state_name) VALUES
('AC', 'Acre'),
('AL', 'Alagoas'),
('AP', 'Amapá'),
('AM', 'Amazonas'),
('BA', 'Bahia'),
('CE', 'Ceará'),
('DF', 'Distrito Federal'),
('ES', 'Espírito Santo'),
('GO', 'Goiás'),
('MA', 'Maranhão'),
('MT', 'Mato Grosso'),
('MS', 'Mato Grosso do Sul'),
('MG', 'Minas Gerais'),
('PA', 'Pará'),
('PB', 'Paraíba'),
('PR', 'Paraná'),
('PE', 'Pernambuco'),
('PI', 'Piauí'),
('RJ', 'Rio de Janeiro'),
('RN', 'Rio Grande do Norte'),
('RS', 'Rio Grande do Sul'),
('RO', 'Rondônia'),
('RR', 'Roraima'),
('SC', 'Santa Catarina'),
('SP', 'São Paulo'),
('SE', 'Sergipe'),
('TO', 'Tocantins');


#Revenue by State
SELECT 
    bs.state_name,
    ROUND(SUM(oi.price), 2) AS revenue
FROM customers c
JOIN brazil_states bs 
    ON c.customer_state = bs.state_code
JOIN orders o 
    ON c.customer_id = o.customer_id
JOIN order_items oi 
    ON o.order_id = oi.order_id
GROUP BY bs.state_name
ORDER BY revenue DESC;


#Average Delivery Time
SELECT 
    AVG(DATEDIFF(
        order_delivered_customer_date,
        order_purchase_timestamp
    )) AS avg_delivery_days
FROM orders
WHERE order_status = 'delivered';

#Revenue Concentration
SELECT 
    c.customer_id,
    SUM(oi.price) AS customer_revenue
FROM customers c
JOIN orders o ON c.customer_id = o.customer_id
JOIN order_items oi ON o.order_id = oi.order_id
GROUP BY c.customer_id
ORDER BY customer_revenue DESC
LIMIT 10;

#Repeat vs One-Time Customers
SELECT
    CASE
        WHEN order_count = 1 THEN 'One-time'
        ELSE 'Repeat'
    END AS customer_type,
    COUNT(*) AS customers
FROM (
    SELECT 
        c.customer_unique_id,
        COUNT(o.order_id) AS order_count
    FROM orders o
    JOIN customers c
        ON o.customer_id = c.customer_id
    GROUP BY c.customer_unique_id
) t
GROUP BY customer_type;


#Which Categories Drive Repeat Purchases?
SELECT 
    p.product_category_name,
    COUNT(DISTINCT o.customer_id) AS repeat_customers
FROM orders o
JOIN order_items oi ON o.order_id = oi.order_id
JOIN products p ON oi.product_id = p.product_id
GROUP BY p.product_category_name
ORDER BY repeat_customers DESC
LIMIT 10;

#Delivery Time Impact on Customer Satisfaction
SELECT 
    CASE 
        WHEN DATEDIFF(order_delivered_customer_date, order_purchase_timestamp) <= 5 THEN 'Fast'
        WHEN DATEDIFF(order_delivered_customer_date, order_purchase_timestamp) <= 10 THEN 'Medium'
        ELSE 'Slow'
    END AS delivery_speed,
    COUNT(*) AS orders
FROM orders
GROUP BY delivery_speed;

#High Revenue but Low Volume Categories (Hidden Gold)
SELECT 
    p.product_category_name,
    COUNT(oi.product_id) AS total_items,
    SUM(oi.price) AS revenue
FROM order_items oi
JOIN products p ON oi.product_id = p.product_id
GROUP BY p.product_category_name
ORDER BY revenue DESC;

#Payment Behavior Analysis (Advanced)
SELECT 
    payment_type,
    COUNT(*) AS transactions,
    SUM(payment_value) AS total_value
FROM payments
GROUP BY payment_type
ORDER BY total_value DESC;

#Monthly Growth Rate (CONSULTING LEVEL)
SELECT 
    month,
    revenue,
    ROUND(
        (revenue - LAG(revenue) OVER (ORDER BY month)) /
        LAG(revenue) OVER (ORDER BY month) * 100, 2
    ) AS growth_percentage
FROM (
    SELECT 
        DATE_FORMAT(order_purchase_timestamp, '%Y-%m') AS month,
        SUM(oi.price) AS revenue
    FROM orders o
    JOIN order_items oi ON o.order_id = oi.order_id
    GROUP BY month
) t;
