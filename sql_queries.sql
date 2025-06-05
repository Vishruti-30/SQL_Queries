-- ============================
-- CREATE DATABASE
-- ============================
CREATE DATABASE IF NOT EXISTS sales_analysis;
USE sales_analysis;

-- ============================
-- CREATE TABLES
-- ============================

-- Customers table
CREATE TABLE Customers (
    CustomerID INT PRIMARY KEY,
    Name VARCHAR(100),
    Region VARCHAR(50)
);

-- Products table
CREATE TABLE Products (
    ProductID INT PRIMARY KEY,
    ProductName VARCHAR(100),
    UnitPrice DECIMAL(10,2)
);

-- Orders table
CREATE TABLE Orders (
    OrderID INT PRIMARY KEY,
    CustomerID INT,
    ProductID INT,
    Quantity INT,
    OrderDate DATE,
    FOREIGN KEY (CustomerID) REFERENCES Customers(CustomerID),
    FOREIGN KEY (ProductID) REFERENCES Products(ProductID)
);

-- ============================
-- INSERT SAMPLE DATA
-- ============================

-- Customers
INSERT INTO Customers (CustomerID, Name, Region) VALUES
(1, 'Alice', 'East'),
(2, 'Bob', 'West'),
(3, 'Charlie', 'East'),
(4, 'David', 'South'),
(5, 'Ella', 'West'),
(6, 'Frank', 'North'),
(7, 'Grace', 'South'),
(8, 'Hannah', 'East'),
(9, 'Ivan', 'North'),
(10, 'Jack', 'West'),
(11, 'Kara', 'East'),
(12, 'Liam', 'South'),
(13, 'Mia', 'North'),
(14, 'Noah', 'West'),
(15, 'Olivia', 'East'),
(16, 'Peter', 'North'),
(17, 'Quinn', 'West'),
(18, 'Rita', 'South'),
(19, 'Sam', 'North'),
(20, 'Tina', 'East');

-- Products
INSERT INTO Products (ProductID, ProductName, UnitPrice) VALUES
(101, 'Laptop', 1200.00),
(102, 'Mouse', 25.00),
(103, 'Keyboard', 45.00),
(104, 'Monitor', 300.00),
(105, 'Webcam', 80.00),
(106, 'Headphones', 100.00),
(107, 'Desk Chair', 150.00),
(108, 'Printer', 200.00),
(109, 'USB Hub', 35.00),
(110, 'External HDD', 95.00);

-- Orders
INSERT INTO Orders (OrderID, CustomerID, ProductID, Quantity, OrderDate) VALUES
(1, 1, 101, 1, '2023-06-01'),
(2, 1, 102, 2, '2023-06-02'),
(3, 2, 104, 1, '2023-06-05'),
(4, 3, 103, 3, '2023-06-10'),
(5, 4, 102, 1, '2023-06-11'),
(6, 3, 101, 2, '2023-06-12'),
(7, 5, 105, 1, '2023-06-15'),
(8, 6, 106, 2, '2023-06-17'),
(9, 7, 108, 1, '2023-06-18'),
(10, 8, 101, 1, '2023-06-20'),
(11, 9, 109, 2, '2023-06-21'),
(12, 10, 110, 1, '2023-06-23'),
(13, 11, 107, 1, '2023-06-24'),
(14, 12, 104, 1, '2023-06-25'),
(15, 13, 105, 1, '2023-06-26'),
(16, 14, 102, 4, '2023-06-27'),
(17, 15, 106, 2, '2023-06-28'),
(18, 16, 103, 2, '2023-06-29'),
(19, 17, 108, 1, '2023-07-01'),
(20, 18, 101, 1, '2023-07-02');

-- ============================
-- ANALYTICAL SQL QUERIES
-- ============================

-- 1. View all orders with customer and product details
SELECT 
    o.OrderID,
    c.Name AS Customer,
    c.Region,
    p.ProductName,
    o.Quantity,
    p.UnitPrice,
    (o.Quantity * p.UnitPrice) AS TotalAmount,
    o.OrderDate
FROM Orders o
JOIN Customers c ON o.CustomerID = c.CustomerID
JOIN Products p ON o.ProductID = p.ProductID;

-- 2. Total sales by region
SELECT 
    c.Region,
    SUM(o.Quantity * p.UnitPrice) AS TotalSales
FROM Orders o
JOIN Customers c ON o.CustomerID = c.CustomerID
JOIN Products p ON o.ProductID = p.ProductID
GROUP BY c.Region
ORDER BY TotalSales DESC;

-- 3. Top 3 customers by total spend
SELECT 
    c.Name AS Customer,
    SUM(o.Quantity * p.UnitPrice) AS TotalSpent
FROM Orders o
JOIN Customers c ON o.CustomerID = c.CustomerID
JOIN Products p ON o.ProductID = p.ProductID
GROUP BY c.Name
ORDER BY TotalSpent DESC
LIMIT 3;

-- 4. Total orders per customer
SELECT 
    c.Name,
    COUNT(o.OrderID) AS OrderCount
FROM Orders o
JOIN Customers c ON o.CustomerID = c.CustomerID
GROUP BY c.Name
ORDER BY OrderCount DESC;

-- 5. Total quantity sold per product
SELECT 
    p.ProductName,
    SUM(o.Quantity) AS TotalUnitsSold
FROM Orders o
JOIN Products p ON o.ProductID = p.ProductID
GROUP BY p.ProductName
ORDER BY TotalUnitsSold DESC;

-- 6. Customers who ordered more than one product type
SELECT 
    c.Name,
    COUNT(DISTINCT o.ProductID) AS DistinctProducts
FROM Orders o
JOIN Customers c ON o.CustomerID = c.CustomerID
GROUP BY c.Name
HAVING COUNT(DISTINCT o.ProductID) > 1;

-- 7. Average order value per customer
SELECT 
    c.Name,
    ROUND(AVG(o.Quantity * p.UnitPrice), 2) AS AvgOrderValue
FROM Orders o
JOIN Customers c ON o.CustomerID = c.CustomerID
JOIN Products p ON o.ProductID = p.ProductID
GROUP BY c.Name;

-- 8. Most recent order per customer
SELECT 
    c.Name,
    MAX(o.OrderDate) AS LastOrderDate
FROM Orders o
JOIN Customers c ON o.CustomerID = c.CustomerID
GROUP BY c.Name;

-- 9. Monthly sales trend
SELECT 
    DATE_FORMAT(o.OrderDate, '%Y-%m') AS Month,
    SUM(o.Quantity * p.UnitPrice) AS MonthlySales
FROM Orders o
JOIN Products p ON o.ProductID = p.ProductID
GROUP BY Month
ORDER BY Month;

-- 10. Orders with value above average
WITH AvgOrder AS (
    SELECT AVG(o.Quantity * p.UnitPrice) AS avg_order_value
    FROM Orders o
    JOIN Products p ON o.ProductID = p.ProductID
)
SELECT 
    o.OrderID,
    c.Name,
    p.ProductName,
    o.Quantity,
    p.UnitPrice,
    (o.Quantity * p.UnitPrice) AS OrderValue
FROM Orders o
JOIN Customers c ON o.CustomerID = c.CustomerID
JOIN Products p ON o.ProductID = p.ProductID,
     AvgOrder a
WHERE (o.Quantity * p.UnitPrice) > a.avg_order_value
ORDER BY OrderValue DESC;