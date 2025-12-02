CREATE DATABASE ecommerce;
USE ecommerce;

CREATE TABLE Customers (
    customer_id INT AUTO_INCREMENT PRIMARY KEY,
    first_name VARCHAR(50),
    last_name VARCHAR(50),
    email VARCHAR(100),
    phone VARCHAR(15),
    city VARCHAR(50),
    state VARCHAR(50),
    pincode VARCHAR(10),
    created_at DATE
);

-- s.venkateshwaran@krishnamurthy-associates.co.in 

CREATE TABLE Categories (
    category_id INT AUTO_INCREMENT PRIMARY KEY,
    category_name VARCHAR(80)
);

CREATE TABLE Products (
    product_id INT AUTO_INCREMENT PRIMARY KEY,
    product_name VARCHAR(150),
    category_id INT,
    unit_price DECIMAL(10 , 2 ),
    FOREIGN KEY (category_id)
        REFERENCES Categories (category_id)
);

CREATE TABLE Orders (
    order_id INT AUTO_INCREMENT PRIMARY KEY,
    customer_id INT,
    order_date DATE,
    payment_method VARCHAR(50),
    order_status VARCHAR(30),
    order_total DECIMAL(12 , 2 ),
    FOREIGN KEY (customer_id)
        REFERENCES Customers (customer_id)
);

CREATE TABLE Order_Items (
    order_item_id INT AUTO_INCREMENT PRIMARY KEY,
    order_id INT,
    product_id INT,
    quantity INT,
    unit_price DECIMAL(10 , 2 ),
    total_price DECIMAL(12 , 2 ),
    FOREIGN KEY (order_item_id)
        REFERENCES Orders (order_id),
    FOREIGN KEY (product_id)
        REFERENCES products (product_id)
);

CREATE TABLE Shipping (
    shipping_id INT AUTO_INCREMENT PRIMARY KEY,
    order_id INT,
    shipping_city VARCHAR(80),
    shipping_state VARCHAR(80),
    shipping_pincode VARCHAR(10),
    shipping_status VARCHAR(30),
    FOREIGN KEY (order_id)
        REFERENCES Orders (order_id)
);

CREATE TABLE Payments (
    payment_id INT AUTO_INCREMENT PRIMARY KEY,
    order_id INT,
    payment_method VARCHAR(20),
    payment_amount DECIMAL(12 , 2 ),
    payment_status VARCHAR(30),
    payment_date DATE,
    FOREIGN KEY (order_id)
        REFERENCES Orders (order_id)
);

-- 1. Top 5 products by revenue --
SELECT p.product_name, SUM(oi.total_price) AS revenue
FROM Order_Items oi
JOIN Products p ON oi.product_id=p.product_id
GROUP BY p.product_name
ORDER BY revenue DESC
LIMIT 5;

-- 2. Revenue by category --
SELECT c.category_name, SUM(oi.total_price) AS revenue
FROM Order_Items oi
JOIN Products p ON oi.product_id = p.product_id
JOIN Categories c ON p.category_id = c.category_id
GROUP BY c.category_name
ORDER BY revenue DESC;

-- 3. Monthly sales trend (payments that succeeded) --
SELECT 
    DATE_FORMAT(p.payment_date, '%Y-%m') AS month,
    SUM(p.payment_amount) AS total_revenue
FROM Payments p
WHERE p.payment_status = 'Success'
GROUP BY month
ORDER BY month 
LIMIT 10;

-- 4. Top states by orders (count) --
SELECT c.state, COUNT(o.order_id) AS num_orders
FROM Orders o
JOIN Customers c ON o.customer_id = c.customer_id
GROUP BY c.state
ORDER BY num_orders DESC
LIMIT 10;

-- 5. Customers who spent above average (VIP) --
SELECT c.customer_id, c.first_name, c.last_name, SUM(p.payment_amount) AS total_spent
FROM Customers c
JOIN Orders o ON c.customer_id=o.customer_id
JOIN Payments p ON o.order_id=p.order_id
WHERE p.payment_status='Success'
GROUP BY c.customer_id, c.first_name, c.last_name
HAVING total_spent>(SELECT AVG(payment_amount) FROM Payments WHERE payment_status='Success')
ORDER BY total_spent DESC
LIMIT 10;

-- 6. Check: maximum UPI payment (should be <=UPI_CAP) --
SELECT MAX(payment_amount) AS max_upi_payment
FROM Payments
WHERE payment_method='UPI'; 

-- 7. Fast-moving items (by units sold) -- 
SELECT p.product_name, SUM(oi.quantity) AS units_sold
FROM Order_Items oi
JOIN Products p ON oi.product_id=p.product_id
GROUP BY p.product_id, p.product_name
ORDER BY units_sold DESC
LIMIT 10;