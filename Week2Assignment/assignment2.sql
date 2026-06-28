CREATE DATABASE Celebal;
SHOW DATABASES;
USE Celebal;

-- I Created a table 'customers' containing user info.
CREATE TABLE customers (
    customer_id INT PRIMARY KEY,
    first_name VARCHAR(50) NOT NULL,
    last_name VARCHAR(50) NOT NULL,
    email VARCHAR(100) UNIQUE NOT NULL,
    city VARCHAR(50) NOT NULL,
    state VARCHAR(50) NOT NULL,
    join_date DATE NOT NULL,
    is_premium BOOLEAN DEFAULT FALSE
);

CREATE INDEX idx_customers_city ON customers(city);
CREATE INDEX idx_customers_state ON customers(state);

SELECT * FROM customers;
-- PRODUCTS TABLE
CREATE TABLE products (
    product_id INT PRIMARY KEY,
    product_name VARCHAR(100) NOT NULL,
    category VARCHAR(50) NOT NULL,
    brand VARCHAR(50) NOT NULL,
    unit_price DECIMAL(10,2) NOT NULL CHECK (unit_price > 0),
    stock_qty INT NOT NULL DEFAULT 0 CHECK (stock_qty >= 0)
);

CREATE INDEX idx_products_category ON products(category);

-- ORDERS TABLE

CREATE TABLE orders (
    order_id INT PRIMARY KEY,
    customer_id INT NOT NULL,
    order_date DATE NOT NULL,
    status VARCHAR(20) NOT NULL DEFAULT 'Pending'
        CHECK (status IN ('Pending','Shipped','Delivered','Cancelled')),
    total_amount DECIMAL(12,2) NOT NULL CHECK (total_amount >= 0),

    FOREIGN KEY (customer_id)
        REFERENCES customers(customer_id)
);

CREATE INDEX idx_orders_date ON orders(order_date);
CREATE INDEX idx_orders_status ON orders(status);

-- ORDER_ITEMS TABLE
CREATE TABLE order_items (
    item_id INT PRIMARY KEY,
    order_id INT NOT NULL,
    product_id INT NOT NULL,
    quantity INT NOT NULL CHECK (quantity > 0),
    unit_price DECIMAL(10,2) NOT NULL CHECK (unit_price > 0),
    discount_pct DECIMAL(5,2) DEFAULT 0
        CHECK (discount_pct BETWEEN 0 AND 100),

    FOREIGN KEY (order_id)
        REFERENCES orders(order_id),

    FOREIGN KEY (product_id)
        REFERENCES products(product_id)
);

-- Now let's add the info. in the customers table
INSERT INTO customers
(customer_id, first_name, last_name, email, city, state, join_date, is_premium)
VALUES
(101, 'Aarav', 'Sharma', 'aarav.s@email.com', 'Mumbai', 'Maharashtra', '2024-01-15', TRUE),
(102, 'Priya', 'Patel', 'priya.p@email.com', 'Ahmedabad', 'Gujarat', '2024-02-20', FALSE),
(103, 'Rohan', 'Gupta', 'rohan.g@email.com', 'Delhi', 'Delhi', '2024-03-10', TRUE),
(104, 'Sneha', 'Reddy', 'sneha.r@email.com', 'Hyderabad', 'Telangana', '2024-04-05', FALSE),
(105, 'Vikram', 'Singh', 'vikram.s@email.com', 'Jaipur', 'Rajasthan', '2024-05-12', TRUE),
(106, 'Ananya', 'Iyer', 'ananya.i@email.com', 'Chennai', 'Tamil Nadu', '2024-06-18', FALSE),
(107, 'Karan', 'Mehta', 'karan.m@email.com', 'Pune', 'Maharashtra', '2024-07-22', TRUE),
(108, 'Divya', 'Nair', 'divya.n@email.com', 'Kochi', 'Kerala', '2024-08-30', FALSE);

SELECT * FROM customers;

INSERT INTO products
(product_id, product_name, category, brand, unit_price, stock_qty)
VALUES
(201, 'Wireless Earbuds', 'Electronics', 'BoAt', 1499.00, 250),
(202, 'Cotton T-Shirt', 'Clothing', 'Levi''s', 799.00, 500),
(203, 'Smart Watch', 'Electronics', 'Noise', 2999.00, 150),
(204, 'Running Shoes', 'Clothing', 'Nike', 4599.00, 120),
(205, 'Bluetooth Speaker', 'Electronics', 'JBL', 3499.00, 200),
(206, 'Bedsheet Set', 'Home', 'Spaces', 1299.00, 300),
(207, 'Laptop Stand', 'Electronics', 'AmazonBasics', 899.00, 180),
(208, 'Cushion Covers (Set)', 'Home', 'HomeCenter', 599.00, 400);

SELECT * FROM products
WHERE category = 'Electronics';

INSERT INTO orders
(order_id, customer_id, order_date, status, total_amount)
VALUES
(1001, 101, '2024-08-01', 'Delivered', 4498.00),
(1002, 102, '2024-08-03', 'Delivered', 799.00),
(1003, 103, '2024-08-05', 'Shipped', 7498.00),
(1004, 101, '2024-08-10', 'Delivered', 3499.00),
(1005, 104, '2024-08-12', 'Cancelled', 2999.00),
(1006, 105, '2024-08-15', 'Delivered', 5898.00),
(1007, 106, '2024-08-18', 'Pending', 1299.00),
(1008, 103, '2024-08-20', 'Delivered', 899.00),
(1009, 107, '2024-08-25', 'Shipped', 6098.00),
(1010, 108, '2024-08-28', 'Delivered', 1598.00);

INSERT INTO order_items
(item_id, order_id, product_id, quantity, unit_price, discount_pct)
VALUES
(5001, 1001, 201, 2, 1499.00, 0),
(5002, 1001, 207, 1, 899.00, 10),
(5003, 1002, 202, 1, 799.00, 0),
(5004, 1003, 203, 1, 2999.00, 0),
(5005, 1003, 204, 1, 4599.00, 5),
(5006, 1004, 205, 1, 3499.00, 0),
(5007, 1005, 203, 1, 2999.00, 0),
(5008, 1006, 201, 1, 1499.00, 10),
(5009, 1006, 204, 1, 4599.00, 5),
(5010, 1007, 206, 1, 1299.00, 0),
(5011, 1008, 207, 1, 899.00, 0),
(5012, 1009, 205, 1, 3499.00, 0),
(5013, 1009, 208, 2, 599.00, 15),
(5014, 1010, 206, 1, 1299.00, 0),
(5015, 1010, 208, 1, 599.00, 0);

SELECT * FROM order_items;

/*
Now that we have created all the tables lets answer the question asked.
*/

-- Section A — SQL Basics (SELECT, Constraints, Primary Keys) 
-- These questions test your understanding of basic data retrieval, table structure, and database constraints. 

-- Q1. Write a query to display all columns and rows from the customer's table. 
SELECT * FROM customers;
-- Q2. Retrieve only the first_name, last_name, and city of all customers. 
SELECT first_name, last_name, city FROM customers;
-- Q3. List all unique categories available in the products table. 
SELECT DISTINCT category FROM products;
-- Q4. Identify the Primary Key of each table in the schema. Explain why a Primary Key must be unique and NOT NULL. 
-- Answer - For customers it's customer_id,
-- 			for products it's product_id,
-- 			for orders it's order_id,
-- 			for order_items it's item_id
-- 			Primary key must be unique and not null cause then it becomes easy to travese the data and also helps with duplicacy.
-- Q5. What constraints are applied to the email column in the customers table? What would happen if you tried to insert a duplicate email? 
-- Answer - The email column in the customers table has two constraints UNIQUE and NOT NULL.
-- 			The UNIQUE constraint ensures that no two customers can have the same email address,
-- 			preventing duplicate records and ambiguity in the database.
-- 			The NOT NULL constraint ensures that every customer must have an email address.
-- 			If a duplicate email is inserted, MySQL will reject the operation and return a duplicate entry error.
-- Let's test it-
INSERT INTO customers
(customer_id, first_name, last_name, email, city, state, join_date, is_premium)
VALUES
(109, 'Divya', 'Nair', 'divya.n@email.com', 'Kochi', 'Kerala', '2024-08-30', FALSE);
-- When i ran this command this error message came up - 
-- Error Code: 1062. Duplicate entry 'divya.n@email.com' for key 'customers.email'

-- Q6. Try inserting a product with unit_price = -50. What happens and which constraint prevents it? Write both the INSERT statement and explain the error. 
-- Answer- 	Let's try adding the negative price and see ourselves.
INSERT INTO order_items
(item_id, order_id, product_id, quantity, unit_price, discount_pct)
VALUES
(123, 1001, 204, 1, -50, 12);

-- As we can see we get the error "Error Code: 3819. Check constraint 'order_items_chk_2' is violated", we clearly mentioned that the price
-- should be greater than 0(unit_price DECIMAL(10,2) NOT NULL CHECK (unit_price > 0)). And here we are violating it.

/*
Section B — Filtering & Optimization (WHERE, Indexes) 
These questions test your ability to filter data effectively and understand how indexes improve query performance.
 */

-- Q7. Retrieve all orders with status = 'Delivered'.
SELECT * FROM orders
WHERE status = 'Delivered';
-- Q8. Find all products in the 'Electronics' category with a unit_price greater than ₹2000. 
SELECT * FROM products
WHERE category = 'Electronics' 
AND unit_price > 2000;
-- Q9. List all customers who joined in the year 2024 and belong to the state 'Maharashtra'. 
SELECT * FROM customers
WHERE state = 'Maharashtra' AND join_date >= '2024-01-01';
-- Q10. Find all orders placed between '2024-08-10' and '2024-08-25' (inclusive) that are NOT cancelled. 
SELECT *
FROM orders
WHERE order_date BETWEEN '2024-08-10' AND '2024-08-25'
AND status != 'cancelled';
-- Q11. Explain what the index idx_orders_date does. How would it improve the performance of a query that filters orders by order_date? Write a sample query that would benefit from this index. 
-- Answer - The idx_orders_date index creates a separate index on the order_date column.
-- 			It works like the index in a book, allowing the database to quickly locate
-- 			rows with a specific order_date instead of searching the entire table.
-- 			This improves query performance because the database uses the index to find
-- 			the matching rows directly rather than performing a full table scan.
-- Q12. If you run: SELECT * FROM customers WHERE YEAR(join_date) = 2024; — would the index on join_date be used? Explain why or why not, and rewrite the query to be index-friendly (SARGable). 
-- Answer - When i run the YEAR(join_date) = 2024 the database calculates for every row, which ain't good. so the better query would be 
SELECT *
FROM customers
WHERE join_date >= '2024-01-01'
AND join_date < '2025-01-01';
-- What this query does is it allows the database to use the index and execute the query faster.


-- Section - C
-- Q13. Count the total number of orders in the orders table. 
-- Answer - 
SELECT COUNT(*) AS ordersTotal
FROM orders;
-- Q14. Find the total revenue (SUM of total_amount) from all 'Delivered' orders. 
SELECT SUM(total_amount) AS totalAmount
FROM orders
WHERE status = 'Delivered';
-- Q15. Calculate the average unit_price of products in each category. 
SELECT category, ROUND(AVG(unit_price), 2) as avgPrice
FROM products
GROUP BY category;

-- Q16. For each order status, find the count of orders and the total revenue. Sort the result by total revenue in descending order. 
SELECT status, COUNT(*) as ORDERCOUNT, SUM(total_amount) as Revenue
FROM orders
GROUP BY status
ORDER BY Revenue DESC;
-- Q17. Find the most expensive (MAX) and cheapest (MIN) product in each category. 
SELECT category, MAX(unit_price) AS MaxPrice, MIN(unit_price) AS MinPrice
FROM products
GROUP BY category;
-- Q18. List all product categories where the average unit_price is greater than ₹2000. (Hint: Use HAVING clause) 
SELECT category
FROM products
GROUP BY category
HAVING AVG(unit_price) > 2000;


/*
Section D — Joins & Relationships 
These questions test your ability to combine data from multiple tables using different types of JOINs. 
*/

-- Q19. Write an INNER JOIN query to display each order along with the customer's first_name and last_name. Show: order_id, order_date, first_name, last_name, total_amount. 
SELECT 
o.order_id,
o.order_date,
c.first_name, 
c.last_name,
o.total_amount
FROM orders as o
INNER JOIN customers as c
ON c.customer_id = o.customer_id;
-- Q20. Using a LEFT JOIN, list ALL customers and their orders (if any). Customers with no orders should still appear with NULL values for order columns. 
SELECT 
c.first_name,
c.last_name,
o.order_id,
o.order_date,
o.total_amount
FROM  customers as c
LEFT JOIN orders as o
ON c.customer_id = o.customer_id;

-- Q21. Write a query using JOINs across three tables (orders → order_items → products) to show: order_id, product_name, quantity, unit_price, and discount_pct for each order item. 
SELECT 
o.order_id,
p.product_name, 
oi.quantity, 
p.unit_price, 
oi.discount_pct
FROM orders as o
INNER JOIN order_items as oi
ON o.order_id = oi.order_id
INNER JOIN products as p
ON oi.product_id = p.product_id;
-- Q22. Explain the difference between LEFT JOIN and RIGHT JOIN with an example from this schema. When would you use a FULL OUTER JOIN? 
-- Answer - So how left join works is it shows all the elements in left table as well as the common column in right table.
-- 			The query is-
 			SELECT *
            FROM orders
            LEFT JOIN customers
            ON orders.customer_id = customers.customer_id;
-- 			Right join is same are left join just the primary table becomes the one on the right and the secondary one is left one.
			SELECT *
            FROM orders
            RIGHT JOIN customers
            ON orders.customer_id = customers.customer_id;
            
-- Q23. Identify all Foreign Key relationships in the schema. Explain what would happen if you tried to insert an order with customer_id = 999 (which doesn't exist in customers).
-- customers ──(1:N)──▶ orders 
-- orders ──(1:N)──▶ order_items 
-- products ──(1:N)──▶ order_items 
-- customers.customer_id ◀──FK── orders.customer_id 
-- orders.order_id ◀──FK── order_items.order_id 
-- products.product_id ◀──FK── order_items.product_id
-- Answer - If customer_id = 999 does not exist in the customers table, and we insert it the database would not let the insertion occur because it violates the fk constraint.


/* 
Section E — Advanced Concepts (CASE, ACID, Transactions) 
These questions test your understanding of conditional logic, database reliability principles, and transaction management. 
*/

/* 
Q24. Write a query using CASE to classify products into price tiers: 
  • 'Budget'    → unit_price < 1000 
  • 'Mid-Range' → unit_price BETWEEN 1000 AND 3000 
  • 'Premium'   → unit_price > 3000 
Display: product_name, unit_price, price_tier. 
*/

SELECT 
product_name, 
unit_price, 
case 
when unit_price < 1000 then 'Budget'
when unit_price BETWEEN 1000 AND 3000 then 'Mid-Range'
when unit_price > 3000 then 'Premium'
end as price_tier
FROM products;

-- Q25. Using a CASE statement inside an aggregate function, count how many orders are 'Delivered' vs 'Not Delivered' (all other statuses). Display the result in a single row. 
SELECT 
SUM(case
when status = 'Delivered' then True 
else false end) as DELIVERED,
SUM(case
when status != 'Delivered' then True 
else false end) as NOTDELIVERED
FROM orders;
/* Q26. Explain each letter of ACID: 
  • A – Atomicity 
  • C – Consistency 
  • I – Isolation 
  • D – Durability 
Give a real-world example (e.g., bank transfer) showing why each property is important. 
*/
-- Answer - Atomicity if the thing happens it should be executed completely, and if not then do the process again from start this reduces the ambiguity.
-- 			example - if you book a seat in theater and if the payment fails, the seats should not remain reserved. You start the reservation from the initial step, and the seats become available again.
-- 			Consistency - the process should'nt disturb the database
-- 			example - a theater has 100 seats you book 2 out of it, it now has 98 left so it should show you the updated seats, so the database remains consistent because the number of available seats matches the actual booked seats.
-- 			Isolation - Multiple process can be performed simultaneously without affecting each other.
-- 			example - Without isolation: both users could successfully book the same seat. With isolation: The first transaction locks or reserves Seat 1.The second transaction waits or fails because the seat is no longer available. so in short it safeguards the race condition.
/* Q27. Write a SQL transaction that does the following atomically: 
  1. Insert a new order (order_id=1011, customer_id=102, today's date, 'Pending', 1598.00) 
  2. Insert two order items for that order 
  3. Update the stock_qty of the purchased products 
  4. If any step fails, ROLLBACK the entire transaction. Otherwise, COMMIT. 
Write the complete BEGIN...COMMIT/ROLLBACK block. */
START TRANSACTION;

-- Step 1: Insert a new order
INSERT INTO orders
(order_id, customer_id, order_date, status, total_amount)
VALUES
(1011, 102, CURDATE(), 'Pending', 1598.00);

-- Step 2: Insert the first order item
INSERT INTO order_items
(item_id, order_id, product_id, quantity, unit_price, discount_pct)
VALUES
(21, 1011, 1, 1, 999.00, 0);

-- Step 3: Insert the second order item
INSERT INTO order_items
(item_id, order_id, product_id, quantity, unit_price, discount_pct)
VALUES
(22, 1011, 2, 2, 299.50, 0);

-- Step 4: Update the stock of the purchased products :)
UPDATE products
SET stock_qty = stock_qty - 1
WHERE product_id = 1;

UPDATE products
SET stock_qty = stock_qty - 2
WHERE product_id = 2;

COMMIT;
-- If any statement fails during commit,
-- we execute:
ROLLBACK;