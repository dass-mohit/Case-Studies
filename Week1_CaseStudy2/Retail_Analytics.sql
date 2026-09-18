-- Retail Sales & Customer Insights Dashboard
-- Week 1 Case Study 2
-- Database: Retail_Analytics

CREATE DATABASE IF NOT EXISTS Retail_Analytics;
USE Retail_Analytics;

CREATE TABLE IF NOT EXISTS DimCustomer (
    CustomerID VARCHAR(10) PRIMARY KEY,
    FirstName VARCHAR(50) NOT NULL,
    LastName VARCHAR(50) NOT NULL,
    Gender VARCHAR(10) NOT NULL,
    Region VARCHAR(50) NOT NULL,
    SSN VARCHAR(20) NOT NULL UNIQUE
);

CREATE TABLE IF NOT EXISTS DimProduct (
    ProductID INT PRIMARY KEY,
    ProductName VARCHAR(100) NOT NULL,
    Category VARCHAR(50) NOT NULL
);

CREATE TABLE IF NOT EXISTS FactSales (
    SaleID VARCHAR(40) PRIMARY KEY,
    CustomerID VARCHAR(10) NOT NULL,
    ProductID INT NOT NULL,
    SalesAmount DECIMAL(10,2) NOT NULL,
    Quantity INT NOT NULL,
    Timestamp DATETIME NOT NULL,
    CONSTRAINT fk_sales_customer
        FOREIGN KEY (CustomerID) REFERENCES DimCustomer(CustomerID),
    CONSTRAINT fk_sales_product
        FOREIGN KEY (ProductID) REFERENCES DimProduct(ProductID)
);

-- Actual SaleID values are 36-character UUID-like strings.
-- If FactSales was initially created with VARCHAR(20), use:
-- ALTER TABLE FactSales MODIFY COLUMN SaleID VARCHAR(40) NOT NULL;

-- Validation
SELECT COUNT(*) AS Total_Sales,
       COUNT(DISTINCT CustomerID) AS Unique_Customers,
       COUNT(DISTINCT ProductID) AS Unique_Products
FROM FactSales;

SELECT COUNT(*) AS Invalid_Customer_References
FROM FactSales f
LEFT JOIN DimCustomer c ON f.CustomerID = c.CustomerID
WHERE c.CustomerID IS NULL;

SELECT COUNT(*) AS Invalid_Product_References
FROM FactSales f
LEFT JOIN DimProduct p ON f.ProductID = p.ProductID
WHERE p.ProductID IS NULL;

SELECT MIN(Timestamp) AS First_Sale,
       MAX(Timestamp) AS Last_Sale
FROM FactSales;

-- Best-selling products
SELECT p.ProductName,
       SUM(f.Quantity) AS Total_Quantity_Sold,
       ROUND(SUM(f.SalesAmount), 2) AS Total_Revenue
FROM FactSales f
JOIN DimProduct p ON f.ProductID = p.ProductID
GROUP BY p.ProductID, p.ProductName
ORDER BY Total_Quantity_Sold DESC;

-- Regional sales performance
SELECT c.Region,
       COUNT(*) AS Total_Transactions,
       SUM(f.Quantity) AS Total_Quantity_Sold,
       ROUND(SUM(f.SalesAmount), 2) AS Total_Revenue
FROM FactSales f
JOIN DimCustomer c ON f.CustomerID = c.CustomerID
GROUP BY c.Region
ORDER BY Total_Revenue DESC;

-- Customer revenue and transaction analysis
SELECT c.CustomerID,
       c.FirstName,
       c.LastName,
       c.Gender,
       c.Region,
       COUNT(*) AS Total_Transactions,
       SUM(f.Quantity) AS Total_Quantity_Sold,
       ROUND(SUM(f.SalesAmount), 2) AS Total_Revenue,
       ROUND(AVG(f.SalesAmount), 2) AS Average_Transaction_Value
FROM FactSales f
JOIN DimCustomer c ON f.CustomerID = c.CustomerID
GROUP BY c.CustomerID, c.FirstName, c.LastName, c.Gender, c.Region
ORDER BY Total_Revenue DESC;

-- Customer revenue statistics
SELECT MIN(Total_Revenue) AS Min_Revenue,
       ROUND(AVG(Total_Revenue), 2) AS Avg_Revenue,
       MAX(Total_Revenue) AS Max_Revenue
FROM (
    SELECT CustomerID, SUM(SalesAmount) AS Total_Revenue
    FROM FactSales
    GROUP BY CustomerID
) customer_revenue;

-- Revenue-based customer segmentation using NTILE(3)
WITH CustomerRevenue AS (
    SELECT CustomerID,
           SUM(SalesAmount) AS Total_Revenue
    FROM FactSales
    GROUP BY CustomerID
),
SegmentedCustomers AS (
    SELECT CustomerID,
           Total_Revenue,
           NTILE(3) OVER (ORDER BY Total_Revenue DESC) AS Segment_Rank
    FROM CustomerRevenue
)
SELECT CASE
           WHEN Segment_Rank = 1 THEN 'High Value'
           WHEN Segment_Rank = 2 THEN 'Medium Value'
           WHEN Segment_Rank = 3 THEN 'Low Value'
       END AS Customer_Segment,
       COUNT(*) AS Customer_Count,
       ROUND(SUM(Total_Revenue), 2) AS Segment_Revenue,
       ROUND(AVG(Total_Revenue), 2) AS Average_Revenue
FROM SegmentedCustomers
GROUP BY Segment_Rank
ORDER BY Segment_Rank;

-- Monthly sales trend
SELECT DATE_FORMAT(Timestamp, '%Y-%m') AS Sales_Month,
       COUNT(*) AS Total_Transactions,
       SUM(Quantity) AS Total_Quantity_Sold,
       ROUND(SUM(SalesAmount), 2) AS Total_Revenue
FROM FactSales
GROUP BY DATE_FORMAT(Timestamp, '%Y-%m')
ORDER BY Sales_Month;
