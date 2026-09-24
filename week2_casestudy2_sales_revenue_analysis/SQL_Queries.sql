USE sales_dwh;

-- Staging table validation
SELECT 'stg_sales' AS Table_Name, COUNT(*) AS Row_Count FROM stg_sales
UNION ALL
SELECT 'stg_customers', COUNT(*) FROM stg_customers
UNION ALL
SELECT 'stg_customer_clv', COUNT(*) FROM stg_customer_clv
UNION ALL
SELECT 'stg_monthly_forecast', COUNT(*) FROM stg_monthly_forecast;

-- Overall sales KPIs
SELECT
    COUNT(*) AS Total_Transactions,
    COUNT(DISTINCT Customer_ID) AS Unique_Customers,
    COUNT(DISTINCT Product_Name) AS Unique_Products,
    SUM(Total_Amount) AS Total_Revenue,
    SUM(Quantity) AS Total_Quantity,
    ROUND(AVG(Total_Amount), 2) AS Average_Transaction_Value
FROM stg_sales;

-- Monthly revenue
SELECT
    Year_Month,
    COUNT(*) AS Transactions,
    SUM(Quantity) AS Quantity_Sold,
    ROUND(SUM(Total_Amount), 2) AS Revenue
FROM stg_sales
GROUP BY Year_Month
ORDER BY Year_Month;

-- Category performance
SELECT
    Product_Category,
    COUNT(*) AS Transactions,
    SUM(Quantity) AS Quantity_Sold,
    ROUND(SUM(Total_Amount), 2) AS Revenue
FROM stg_sales
GROUP BY Product_Category
ORDER BY Revenue DESC;

-- Product performance
SELECT
    Product_Name,
    COUNT(*) AS Transactions,
    SUM(Quantity) AS Quantity_Sold,
    ROUND(SUM(Total_Amount), 2) AS Revenue
FROM stg_sales
GROUP BY Product_Name
ORDER BY Revenue DESC;

-- Payment method analysis
SELECT
    Payment_Method,
    COUNT(*) AS Transactions,
    SUM(Quantity) AS Quantity_Sold,
    ROUND(SUM(Total_Amount), 2) AS Revenue
FROM stg_sales
GROUP BY Payment_Method
ORDER BY Revenue DESC;

-- Customer revenue summary
SELECT
    MIN(Total_Spent) AS Min_Revenue,
    ROUND(AVG(Total_Spent), 2) AS Avg_Revenue,
    MAX(Total_Spent) AS Max_Revenue
FROM stg_customers;

-- Customer segmentation
SELECT
    Customer_Segment,
    COUNT(*) AS Customers,
    ROUND(SUM(Total_Spent), 2) AS Total_Revenue,
    ROUND(AVG(Total_Spent), 2) AS Average_Revenue
FROM stg_customers
GROUP BY Customer_Segment
ORDER BY CASE Customer_Segment
    WHEN 'High Value' THEN 1
    WHEN 'Medium Value' THEN 2
    WHEN 'Low Value' THEN 3
END;

-- Top 10 customers
SELECT
    c.Customer_ID,
    c.Name,
    c.Total_Spent,
    c.Customer_Segment
FROM stg_customers c
ORDER BY c.Total_Spent DESC
LIMIT 10;

-- CLV summary by segment
SELECT
    Customer_Segment,
    COUNT(*) AS Customers,
    ROUND(SUM(CLV), 2) AS Total_CLV,
    ROUND(AVG(CLV), 2) AS Average_CLV
FROM stg_customer_clv
GROUP BY Customer_Segment
ORDER BY Total_CLV DESC;

-- Actual vs forecast revenue
SELECT
    Year_Month,
    Actual_Revenue,
    Predicted_Revenue
FROM stg_monthly_forecast
ORDER BY Year_Month;

-- Referential integrity checks
SELECT COUNT(*) AS Invalid_Customer_References
FROM stg_sales s
LEFT JOIN stg_customers c ON s.Customer_ID = c.Customer_ID
WHERE c.Customer_ID IS NULL;

SELECT COUNT(*) AS Invalid_Product_References
FROM stg_sales s
LEFT JOIN (
    SELECT DISTINCT Product_Name FROM stg_sales
) p ON s.Product_Name = p.Product_Name
WHERE p.Product_Name IS NULL;
