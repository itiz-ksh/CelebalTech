CREATE DATABASE SUPERSTORE;
USE SUPERSTORE;

CREATE TABLE superstore_raw (
    row_id INT,
    order_id VARCHAR(20),
    order_date DATE,
    ship_date DATE,
    ship_mode VARCHAR(50),
    customer_id VARCHAR(20),
    customer_name VARCHAR(100),
    segment VARCHAR(50),
    country VARCHAR(50),
    city VARCHAR(50),
    state VARCHAR(50),
    postal_code VARCHAR(20),
    region VARCHAR(50),
    product_id VARCHAR(30),
    category VARCHAR(50),
    sub_category VARCHAR(50),
    product_name VARCHAR(255),
    sales DECIMAL(10,2),
    quantity INT,
    discount DECIMAL(5,2),
    profit DECIMAL(10,2)
);

SHOW VARIABLES LIKE 'local_infile';

LOAD DATA LOCAL INFILE '/Users/negikshitiz/Documents/CelebalTech/Dataset/Sample - Superstore.csv'
INTO TABLE superstore_raw
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS
(@row_id,@order_id,@order_date,@ship_date,@ship_mode,@customer_id,@customer_name,
 @segment,@country,@city,@state,@postal_code,@region,@product_id,@category,
 @sub_category,@product_name,@sales,@quantity,@discount,@profit)
SET
row_id = @row_id,
order_id = @order_id,
order_date = STR_TO_DATE(@order_date,'%c/%e/%Y'),
ship_date = STR_TO_DATE(@ship_date,'%c/%e/%Y'),
ship_mode = @ship_mode,
customer_id = @customer_id,
customer_name = @customer_name,
segment = @segment,
country = @country,
city = @city,
state = @state,
postal_code = @postal_code,
region = @region,
product_id = @product_id,
category = @category,
sub_category = @sub_category,
product_name = @product_name,
sales = @sales,
quantity = @quantity,
discount = @discount,
profit = @profit;

SELECT * FROM superstore_raw LIMIT 5;
DESCRIBE superstore_raw;

CREATE TABLE customers (
    customer_id VARCHAR(20) PRIMARY KEY,
    customer_name VARCHAR(100),
    segment VARCHAR(50),
    country VARCHAR(100),
    city VARCHAR(100),
    state VARCHAR(100),
    postal_code VARCHAR(20),
    region VARCHAR(50)
);

SELECT customer_id, COUNT(*)
FROM superstore_raw
GROUP BY customer_id
HAVING COUNT(*) > 1;

SELECT *
FROM superstore_raw
WHERE customer_id = 'TB-21520';

INSERT INTO customers
SELECT
    customer_id,
    MAX(customer_name),
    MAX(segment),
    MAX(country),
    MAX(city),
    MAX(state),
    MAX(postal_code),
    MAX(region)
FROM superstore_raw
GROUP BY customer_id;


CREATE TABLE products (
    product_id VARCHAR(50) PRIMARY KEY,
    category VARCHAR(100),
    sub_category VARCHAR(100),
    product_name VARCHAR(255)
);

INSERT INTO products (
    product_id,
    category,
    sub_category,
    product_name
)
SELECT
    product_id,
    MAX(category),
    MAX(sub_category),
    MAX(product_name)
FROM superstore_raw
GROUP BY product_id;

SELECT COUNT(*) FROM products;

CREATE TABLE orders (
    row_id INT PRIMARY KEY,
    order_id VARCHAR(20),
    order_date DATE,
    ship_date DATE,
    ship_mode VARCHAR(50),
    customer_id VARCHAR(20),
    product_id VARCHAR(50),
    sales DECIMAL(10,2),
    quantity INT,
    discount DECIMAL(5,2),
    profit DECIMAL(10,2),

    FOREIGN KEY (customer_id) REFERENCES customers(customer_id),
    FOREIGN KEY (product_id) REFERENCES products(product_id)
);

INSERT INTO orders (
    row_id,
    order_id,
    order_date,
    ship_date,
    ship_mode,
    customer_id,
    product_id,
    sales,
    quantity,
    discount,
    profit
)
SELECT DISTINCT
    row_id,
    order_id,
    order_date,
    ship_date,
    ship_mode,
    customer_id,
    product_id,
    sales,
    quantity,
    discount,
    profit
FROM superstore_raw;


SELECT * FROM customers;
SELECT * FROM orders;
SELECT * FROM products;


-- Find all orders where sales are greater than the average sales. (Subquery)
SELECT *
FROM orders
WHERE sales > (SELECT AVG(sales) FROM orders);

-- Find the highest sales order for each customer. (Subquery)
SELECT * 
FROM orders o 
WHERE sales = (SELECT MAX(sales) FROM orders
WHERE customer_id = o.customer_id);

-- Calculate total sales for each customer. (CTE)
WITH CTETotalSales AS (
SELECT
customer_id,
SUM(sales) AS TotalSalesSum
FROM orders
GROUP BY customer_id
)

SELECT c.customer_id, 
c.customer_name,
cts.TotalSalesSum
FROM customers c
LEFT JOIN CTETotalSales cts
ON cts.customer_id = c.customer_id;

-- Find customers whose total sales are above average. (CTE + Subquery)
WITH CustomerSales AS (
SELECT
customer_id,
SUM(sales) AS SalesTotal
FROM orders
GROUP BY customer_id
)

SELECT c.customer_id,
c.customer_name,
cs.SalesTotal
FROM CustomerSales cs
JOIN customers c
ON cs.customer_id = c.customer_id
WHERE cs.SalesTotal > (
SELECT AVG(SalesTotal)
FROM CustomerSales
);
-- Rank all customers based on total sales. (Window Function)
WITH CustomerSales AS (
SELECT
customer_id,
SUM(sales) AS SalesTotal
FROM orders
GROUP BY customer_id
)
SELECT
customer_id,
SalesTotal,
RANK() OVER (ORDER BY SalesTotal DESC) AS RankOnSales
FROM CustomerSales;
-- Assign row numbers to each order within a customer. (Window Function + PARTITION BY)
SELECT
customer_id,
order_id,
order_date,
sales,
ROW_NUMBER() OVER (
PARTITION BY customer_id
ORDER BY order_date
) AS order_number
FROM orders;

-- Display top 3 customers based on total sales. (Window Function)  
WITH CustomerSales AS (
SELECT
customer_id,
SUM(sales) AS SalesTotal
FROM orders
GROUP BY customer_id
),
RankedCustomers AS (
SELECT
customer_id,
SalesTotal,
RANK() OVER (ORDER BY SalesTotal DESC) AS RankOnSales
FROM CustomerSales
)
SELECT
customer_id,
SalesTotal,
RankOnSales
FROM RankedCustomers
WHERE RankOnSales <= 3;

-- Write one final query that shows: Customer Name, Total Sales, Rank(Use JOIN + CTE + Window Function together)
WITH CustomerSales AS (
SELECT
c.customer_id,
c.customer_name,
SUM(o.sales) AS SalesTotal
FROM customers c
JOIN orders o
ON c.customer_id = o.customer_id
GROUP BY
c.customer_id,
c.customer_name
)
SELECT
customer_name,
SalesTotal,
RANK() OVER (ORDER BY SalesTotal DESC) AS RankOnSales
FROM CustomerSales
ORDER BY RankOnSales;


-- Mini Project: Customer Sales Insights 
-- Answer the following using SQL: 
-- Who are the top 5 customers?  
WITH CustomerSales AS (
SELECT
c.customer_id,
c.customer_name,
SUM(o.sales) AS SalesTotal
FROM customers c
JOIN orders o
ON c.customer_id = o.customer_id
GROUP BY c.customer_id, c.customer_name
)
SELECT
customer_name,
SalesTotal
FROM CustomerSales
ORDER BY SalesTotal DESC
LIMIT 5;

-- Who are the bottom 5 customers?  
WITH CustomerSales AS (
SELECT
c.customer_id,
c.customer_name,
SUM(o.sales) AS SalesTotal
FROM customers c
JOIN orders o
ON c.customer_id = o.customer_id
GROUP BY c.customer_id, c.customer_name
)
SELECT
customer_name,
SalesTotal
FROM CustomerSales
ORDER BY SalesTotal ASC
LIMIT 5;

-- Which customers made only one order?  
SELECT
c.customer_name,
COUNT(o.order_id) AS OrderTotal
FROM customers c
JOIN orders o
ON c.customer_id = o.customer_id
GROUP BY
c.customer_id,
c.customer_name
HAVING COUNT(o.order_id) = 1;
-- Which customers have above-average sales?  
WITH CustomerSales AS (
SELECT
c.customer_id,
c.customer_name,
SUM(o.sales) AS SalesTotal
FROM customers c
JOIN orders o
ON c.customer_id = o.customer_id
GROUP BY
c.customer_id,
c.customer_name
)
SELECT
customer_name,
SalesTotal
FROM CustomerSales
WHERE SalesTotal > (
SELECT AVG(SalesTotal)
FROM CustomerSales
);

-- What is the highest order value per customer? 
SELECT
c.customer_name,
MAX(o.sales) AS MaxAmountSpend
FROM customers c
JOIN orders o
ON c.customer_id = o.customer_id
GROUP BY
c.customer_id,
c.customer_name
ORDER BY MaxAmountSpend DESC;
