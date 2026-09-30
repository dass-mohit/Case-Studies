-- Supply Chain & Inventory Management
-- Week 3 Case Study 2
-- Database: supply_chain_dwh

USE supply_chain_dwh;

-- ============================================================
-- DATA WAREHOUSE VALIDATION
-- ============================================================

SELECT 'DimDate' AS Table_Name, COUNT(*) AS Record_Count FROM DimDate
UNION ALL
SELECT 'DimProduct', COUNT(*) FROM DimProduct
UNION ALL
SELECT 'DimStore', COUNT(*) FROM DimStore
UNION ALL
SELECT 'DimSupplier', COUNT(*) FROM DimSupplier
UNION ALL
SELECT 'FactSales', COUNT(*) FROM FactSales
UNION ALL
SELECT 'FactInventory', COUNT(*) FROM FactInventory
UNION ALL
SELECT 'FactPurchaseOrders', COUNT(*) FROM FactPurchaseOrders;

-- Expected: DimDate 5000, DimProduct 5, DimStore 4, DimSupplier 50,
-- FactSales 5000, FactInventory 200, FactPurchaseOrders 1000.

-- ============================================================
-- SALES VALIDATION
-- ============================================================

SELECT
    COUNT(*) AS Total_Sales,
    COUNT(DISTINCT Product_Key) AS Unique_Products,
    COUNT(DISTINCT Store_Key) AS Unique_Stores,
    COUNT(DISTINCT Sale_ID) AS Unique_Sale_IDs,
    ROUND(SUM(Quantity_Sold), 2) AS Total_Quantity_Sold,
    ROUND(SUM(Revenue), 2) AS Total_Revenue
FROM FactSales;

SELECT COUNT(*) AS Invalid_Product_References
FROM FactSales f
LEFT JOIN DimProduct p ON f.Product_Key = p.Product_Key
WHERE p.Product_Key IS NULL;

SELECT COUNT(*) AS Invalid_Store_References
FROM FactSales f
LEFT JOIN DimStore s ON f.Store_Key = s.Store_Key
WHERE s.Store_Key IS NULL;

-- ============================================================
-- FAST-MOVING / SLOW-MOVING PRODUCTS
-- ============================================================

SELECT
    p.Product_ID,
    SUM(f.Quantity_Sold) AS Total_Quantity_Sold,
    ROUND(SUM(f.Revenue), 2) AS Total_Revenue,
    COUNT(DISTINCT f.Sale_ID) AS Transactions
FROM FactSales f
JOIN DimProduct p
    ON f.Product_Key = p.Product_Key
GROUP BY p.Product_Key, p.Product_ID
ORDER BY Total_Quantity_Sold DESC;

-- Highest quantity = fast-moving product.
-- Lowest quantity = slow-moving product.

-- ============================================================
-- LATEST 3 COMPLETE MONTHS
-- ============================================================

SELECT
    d.Year,
    d.Month,
    d.Month_Name,
    SUM(f.Quantity_Sold) AS Total_Quantity_Sold,
    ROUND(SUM(f.Revenue), 2) AS Total_Revenue,
    COUNT(DISTINCT f.Sale_ID) AS Transactions
FROM FactSales f
JOIN DimDate d
    ON f.Date_Key = d.Date_Key
WHERE d.Full_Date >= '2037-06-01'
  AND d.Full_Date < '2037-09-01'
GROUP BY d.Year, d.Month, d.Month_Name
ORDER BY d.Year, d.Month;

-- ============================================================
-- LATEST INVENTORY SNAPSHOT
-- One latest record per Product + Store combination
-- ============================================================

WITH RankedInventory AS (
    SELECT
        f.Inventory_Key,
        f.Product_Key,
        f.Store_Key,
        f.Warehouse_ID,
        f.Date_Key,
        f.Stock_Level,
        f.Reorder_Level,
        ROW_NUMBER() OVER (
            PARTITION BY f.Product_Key, f.Store_Key
            ORDER BY f.Date_Key DESC, f.Inventory_Key DESC
        ) AS rn
    FROM FactInventory f
)
SELECT
    p.Product_ID,
    s.Store_ID,
    r.Warehouse_ID,
    d.Full_Date AS Latest_Inventory_Date,
    r.Stock_Level,
    r.Reorder_Level,
    r.Stock_Level - r.Reorder_Level AS Stock_Gap,
    CASE
        WHEN r.Stock_Level < r.Reorder_Level THEN 'Below Reorder'
        ELSE 'At/Above Reorder'
    END AS Inventory_Status
FROM RankedInventory r
JOIN DimProduct p
    ON r.Product_Key = p.Product_Key
JOIN DimStore s
    ON r.Store_Key = s.Store_Key
JOIN DimDate d
    ON r.Date_Key = d.Date_Key
WHERE r.rn = 1
ORDER BY Inventory_Status, Stock_Gap;

-- Products currently below reorder:
WITH RankedInventory AS (
    SELECT
        f.*,
        ROW_NUMBER() OVER (
            PARTITION BY f.Product_Key, f.Store_Key
            ORDER BY f.Date_Key DESC, f.Inventory_Key DESC
        ) AS rn
    FROM FactInventory f
)
SELECT
    p.Product_ID,
    s.Store_ID,
    r.Warehouse_ID,
    r.Stock_Level,
    r.Reorder_Level,
    r.Reorder_Level - r.Stock_Level AS Restock_Gap
FROM RankedInventory r
JOIN DimProduct p ON r.Product_Key = p.Product_Key
JOIN DimStore s ON r.Store_Key = s.Store_Key
WHERE r.rn = 1
  AND r.Stock_Level < r.Reorder_Level
ORDER BY Restock_Gap DESC;

-- ============================================================
-- SUPPLIER LEAD-TIME ANALYSIS
-- ============================================================

SELECT
    s.Supplier_ID,
    s.Supplier_Name,
    s.Lead_Time AS Reported_Lead_Time_Days,
    s.Order_Frequency,
    COUNT(po.Purchase_Order_Key) AS Purchase_Orders,
    ROUND(AVG(po.Actual_Lead_Time), 2) AS Avg_Actual_Lead_Time_Days
FROM DimSupplier s
LEFT JOIN FactPurchaseOrders po
    ON s.Supplier_Key = po.Supplier_Key
GROUP BY
    s.Supplier_Key,
    s.Supplier_ID,
    s.Supplier_Name,
    s.Lead_Time,
    s.Order_Frequency
ORDER BY Reported_Lead_Time_Days DESC, s.Supplier_ID;

-- Compact lead-time summary
SELECT
    s.Lead_Time AS Reported_Lead_Time_Days,
    COUNT(DISTINCT s.Supplier_ID) AS Supplier_Count,
    COUNT(po.Purchase_Order_Key) AS Purchase_Order_Count,
    ROUND(AVG(po.Actual_Lead_Time), 2) AS Avg_Actual_Lead_Time_Days
FROM DimSupplier s
LEFT JOIN FactPurchaseOrders po
    ON s.Supplier_Key = po.Supplier_Key
GROUP BY s.Lead_Time
ORDER BY s.Lead_Time;

-- ============================================================
-- INVENTORY SUMMARY
-- Latest snapshot by Product + Store
-- ============================================================

WITH RankedInventory AS (
    SELECT
        f.*,
        ROW_NUMBER() OVER (
            PARTITION BY f.Product_Key, f.Store_Key
            ORDER BY f.Date_Key DESC, f.Inventory_Key DESC
        ) AS rn
    FROM FactInventory f
)
SELECT
    COUNT(*) AS Product_Store_Combinations,
    SUM(CASE WHEN Stock_Level < Reorder_Level THEN 1 ELSE 0 END)
        AS Below_Reorder_Count,
    SUM(CASE WHEN Stock_Level >= Reorder_Level THEN 1 ELSE 0 END)
        AS At_Or_Above_Reorder_Count,
    ROUND(AVG(Stock_Level), 2) AS Avg_Stock_Level,
    ROUND(AVG(Reorder_Level), 2) AS Avg_Reorder_Level
FROM RankedInventory
WHERE rn = 1;

-- ============================================================
-- PURCHASE ORDER SUMMARY
-- ============================================================

SELECT
    COUNT(*) AS Total_Purchase_Orders,
    SUM(Quantity) AS Total_Purchase_Quantity,
    ROUND(AVG(Actual_Lead_Time), 2) AS Avg_Actual_Lead_Time
FROM FactPurchaseOrders;

-- ============================================================
-- DATE RANGE
-- ============================================================

SELECT
    MIN(d.Full_Date) AS First_Sale_Date,
    MAX(d.Full_Date) AS Last_Sale_Date
FROM FactSales f
JOIN DimDate d
    ON f.Date_Key = d.Date_Key;
