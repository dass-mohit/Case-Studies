mysql> CREATE DATABASE IF NOT EXISTS supply_chain_dwh;
Query OK, 1 row affected (0.02 sec)

mysql>
mysql> USE supply_chain_dwh;
Database changed
mysql>
mysql> SELECT DATABASE();
+------------------+
| DATABASE()       |
+------------------+
| supply_chain_dwh |
+------------------+
1 row in set (0.00 sec)

mysql> USE supply_chain_dwh;
Database changed
mysql>
mysql> CREATE TABLE stg_sales (
    ->     Sale_ID VARCHAR(40),
    ->     Product_ID VARCHAR(20),
    ->     Store_ID VARCHAR(20),
    ->     Sale_Date DATETIME,
    ->     Quantity_Sold INT,
    ->     Revenue DECIMAL(12,2),
    ->     Year INT,
    ->     Month INT,
    ->     Month_Name VARCHAR(20),
    ->     Quarter VARCHAR(10)
    -> );
Query OK, 0 rows affected (0.02 sec)

mysql>
mysql> CREATE TABLE stg_inventory (
    ->     Product_ID VARCHAR(20),
    ->     Store_ID VARCHAR(20),
    ->     Warehouse_ID VARCHAR(20),
    ->     Stock_Level INT,
    ->     Reorder_Level INT,
    ->     Last_Updated DATE
    -> );
Query OK, 0 rows affected (0.01 sec)

mysql>
mysql> CREATE TABLE stg_suppliers (
    ->     Supplier_ID VARCHAR(20),
    ->     Supplier_Name VARCHAR(100),
    ->     Product_ID VARCHAR(20),
    ->     `Lead_Time (days)` INT,
    ->     Order_Frequency VARCHAR(20)
    -> );
Query OK, 0 rows affected (0.01 sec)

mysql>
mysql> CREATE TABLE stg_purchase_orders (
    ->     Order_ID VARCHAR(40),
    ->     Product_ID VARCHAR(20),
    ->     Supplier_ID VARCHAR(20),
    ->     Order_Date DATE,
    ->     Quantity INT,
    ->     Arrival_Date DATE,
    ->     Actual_Lead_Time INT
    -> );
Query OK, 0 rows affected (0.01 sec)

mysql>
mysql> SHOW TABLES;
+----------------------------+
| Tables_in_supply_chain_dwh |
+----------------------------+
| stg_inventory              |
| stg_purchase_orders        |
| stg_sales                  |
| stg_suppliers              |
+----------------------------+
4 rows in set (0.00 sec)

mysql> TRUNCATE TABLE supply_chain_dwh.stg_sales;
Query OK, 0 rows affected (0.02 sec)

mysql> SELECT COUNT(*) AS Sales_Rows
    -> FROM supply_chain_dwh.stg_sales;
+------------+
| Sales_Rows |
+------------+
|       5000 |
+------------+
1 row in set (0.01 sec)

mysql> SELECT COUNT(*) AS Inventory_Rows
    -> FROM supply_chain_dwh.stg_inventory;
+----------------+
| Inventory_Rows |
+----------------+
|            200 |
+----------------+
1 row in set (0.00 sec)

mysql> SELECT COUNT(*) AS Supplier_Rows
    -> FROM supply_chain_dwh.stg_suppliers;
+---------------+
| Supplier_Rows |
+---------------+
|            50 |
+---------------+
1 row in set (0.00 sec)

mysql> SELECT COUNT(*) AS Purchase_Order_Rows
    -> FROM supply_chain_dwh.stg_purchase_orders;
+---------------------+
| Purchase_Order_Rows |
+---------------------+
|                1000 |
+---------------------+
1 row in set (0.00 sec)

mysql> SELECT
    ->     (SELECT COUNT(*) FROM stg_sales) AS Sales_Rows,
    ->     (SELECT COUNT(*) FROM stg_inventory) AS Inventory_Rows,
    ->     (SELECT COUNT(*) FROM stg_suppliers) AS Supplier_Rows,
    ->     (SELECT COUNT(*) FROM stg_purchase_orders) AS Purchase_Order_Rows;
+------------+----------------+---------------+---------------------+
| Sales_Rows | Inventory_Rows | Supplier_Rows | Purchase_Order_Rows |
+------------+----------------+---------------+---------------------+
|       5000 |            200 |            50 |                1000 |
+------------+----------------+---------------+---------------------+
1 row in set (0.01 sec)

mysql> CREATE TABLE DimDate (
    ->     Date_Key INT PRIMARY KEY,
    ->     Full_Date DATE NOT NULL,
    ->     Year INT NOT NULL,
    ->     Month INT NOT NULL,
    ->     Month_Name VARCHAR(20) NOT NULL,
    ->     Quarter VARCHAR(10) NOT NULL
    -> );
Query OK, 0 rows affected (0.02 sec)

mysql>
mysql> CREATE TABLE DimProduct (
    ->     Product_Key INT AUTO_INCREMENT PRIMARY KEY,
    ->     Product_ID VARCHAR(20) NOT NULL UNIQUE
    -> );
Query OK, 0 rows affected (0.03 sec)

mysql>
mysql> CREATE TABLE DimStore (
    ->     Store_Key INT AUTO_INCREMENT PRIMARY KEY,
    ->     Store_ID VARCHAR(20) NOT NULL UNIQUE
    -> );
Query OK, 0 rows affected (0.03 sec)

mysql>
mysql> CREATE TABLE DimSupplier (
    ->     Supplier_Key INT AUTO_INCREMENT PRIMARY KEY,
    ->     Supplier_ID VARCHAR(20) NOT NULL UNIQUE,
    ->     Supplier_Name VARCHAR(100),
    ->     Lead_Time_Days INT,
    ->     Order_Frequency VARCHAR(20)
    -> );
Query OK, 0 rows affected (0.03 sec)

mysql>
mysql> SHOW TABLES;
+----------------------------+
| Tables_in_supply_chain_dwh |
+----------------------------+
| dimdate                    |
| dimproduct                 |
| dimstore                   |
| dimsupplier                |
| stg_inventory              |
| stg_purchase_orders        |
| stg_sales                  |
| stg_suppliers              |
+----------------------------+
8 rows in set (0.00 sec)

mysql> INSERT INTO DimProduct (Product_ID)
    -> SELECT DISTINCT Product_ID
    -> FROM stg_sales
    -> ORDER BY Product_ID;
Query OK, 5 rows affected (0.01 sec)
Records: 5  Duplicates: 0  Warnings: 0

mysql> SELECT *
    -> FROM DimProduct
    -> ORDER BY Product_Key;
+-------------+------------+
| Product_Key | Product_ID |
+-------------+------------+
|           1 | P001       |
|           2 | P002       |
|           3 | P003       |
|           4 | P004       |
|           5 | P005       |
+-------------+------------+
5 rows in set (0.00 sec)

mysql> INSERT INTO DimStore (Store_ID)
    -> SELECT DISTINCT Store_ID
    -> FROM stg_sales
    -> ORDER BY Store_ID;
Query OK, 4 rows affected (0.01 sec)
Records: 4  Duplicates: 0  Warnings: 0

mysql> SELECT *
    -> FROM DimStore
    -> ORDER BY Store_Key;
+-----------+----------+
| Store_Key | Store_ID |
+-----------+----------+
|         1 | S101     |
|         2 | S102     |
|         3 | S103     |
|         4 | S104     |
+-----------+----------+
4 rows in set (0.00 sec)

mysql> INSERT INTO DimSupplier (
    ->     Supplier_ID,
    ->     Supplier_Name,
    ->     Lead_Time_Days,
    ->     Order_Frequency
    -> )
    -> SELECT DISTINCT
    ->     Supplier_ID,
    ->     Supplier_Name,
    ->     `Lead_Time (days)`,
    ->     Order_Frequency
    -> FROM stg_suppliers
    -> ORDER BY Supplier_ID;
Query OK, 50 rows affected (0.01 sec)
Records: 50  Duplicates: 0  Warnings: 0

mysql> SELECT COUNT(*) AS Supplier_Count
    -> FROM DimSupplier;
+----------------+
| Supplier_Count |
+----------------+
|             50 |
+----------------+
1 row in set (0.00 sec)

mysql> INSERT INTO DimDate (
    ->     Date_Key,
    ->     Full_Date,
    ->     Year,
    ->     Month,
    ->     Month_Name,
    ->     Quarter
    -> )
    -> SELECT
    ->     DATE_FORMAT(d, '%Y%m%d') + 0 AS Date_Key,
    ->     d AS Full_Date,
    ->     YEAR(d) AS Year,
    ->     MONTH(d) AS Month,
    ->     MONTHNAME(d) AS Month_Name,
    ->     CONCAT('Q', QUARTER(d)) AS Quarter
    -> FROM (
    ->     SELECT
    ->         ADDDATE(
    ->             '2024-01-01',
    ->             INTERVAL seq DAY
    ->         ) AS d
    ->     FROM (
    ->         SELECT
    ->             a.N + b.N * 10 + c.N * 100 + d.N * 1000 + e.N * 10000 AS seq
    ->         FROM
    ->             (SELECT 0 N UNION ALL SELECT 1 UNION ALL SELECT 2 UNION ALL SELECT 3 UNION ALL SELECT 4
    ->              UNION ALL SELECT 5 UNION ALL SELECT 6 UNION ALL SELECT 7 UNION ALL SELECT 8 UNION ALL SELECT 9) a,
    ->             (SELECT 0 N UNION ALL SELECT 1 UNION ALL SELECT 2 UNION ALL SELECT 3 UNION ALL SELECT 4
    ->              UNION ALL SELECT 5 UNION ALL SELECT 6 UNION ALL SELECT 7 UNION ALL SELECT 8 UNION ALL SELECT 9) b,
    ->             (SELECT 0 N UNION ALL SELECT 1 UNION ALL SELECT 2 UNION ALL SELECT 3 UNION ALL SELECT 4
    ->              UNION ALL SELECT 5 UNION ALL SELECT 6 UNION ALL SELECT 7 UNION ALL SELECT 8 UNION ALL SELECT 9) c,
    ->             (SELECT 0 N UNION ALL SELECT 1 UNION ALL SELECT 2 UNION ALL SELECT 3 UNION ALL SELECT 4
    ->              UNION ALL SELECT 5 UNION ALL SELECT 6 UNION ALL SELECT 7 UNION ALL SELECT 8 UNION ALL SELECT 9) d,
    ->             (SELECT 0 N UNION ALL SELECT 1 UNION ALL SELECT 2 UNION ALL SELECT 3 UNION ALL SELECT 4
    ->              UNION ALL SELECT 5 UNION ALL SELECT 6 UNION ALL SELECT 7 UNION ALL SELECT 8 UNION ALL SELECT 9) e
    ->     ) numbers
    -> ) dates
    -> WHERE d <= '2037-09-08';
Query OK, 5000 rows affected (0.25 sec)
Records: 5000  Duplicates: 0  Warnings: 0

mysql> SELECT
    ->     COUNT(*) AS Date_Rows,
    ->     MIN(Full_Date) AS First_Date,
    ->     MAX(Full_Date) AS Last_Date
    -> FROM DimDate;
+-----------+------------+------------+
| Date_Rows | First_Date | Last_Date  |
+-----------+------------+------------+
|      5000 | 2024-01-01 | 2037-09-08 |
+-----------+------------+------------+
1 row in set (0.00 sec)

mysql> CREATE TABLE FactSales (
    ->     Sale_Key BIGINT AUTO_INCREMENT PRIMARY KEY,
    ->     Sale_ID VARCHAR(40) NOT NULL,
    ->     Date_Key INT NOT NULL,
    ->     Product_Key INT NOT NULL,
    ->     Store_Key INT NOT NULL,
    ->     Quantity_Sold INT NOT NULL,
    ->     Revenue DECIMAL(12,2) NOT NULL,
    ->
    ->     FOREIGN KEY (Date_Key)
    ->         REFERENCES DimDate(Date_Key),
    ->
    ->     FOREIGN KEY (Product_Key)
    ->         REFERENCES DimProduct(Product_Key),
    ->
    ->     FOREIGN KEY (Store_Key)
    ->         REFERENCES DimStore(Store_Key),
    ->
    ->     UNIQUE (Sale_ID)
    -> );
Query OK, 0 rows affected (0.05 sec)

mysql> DESCRIBE FactSales;
+---------------+---------------+------+-----+---------+----------------+
| Field         | Type          | Null | Key | Default | Extra          |
+---------------+---------------+------+-----+---------+----------------+
| Sale_Key      | bigint        | NO   | PRI | NULL    | auto_increment |
| Sale_ID       | varchar(40)   | NO   | UNI | NULL    |                |
| Date_Key      | int           | NO   | MUL | NULL    |                |
| Product_Key   | int           | NO   | MUL | NULL    |                |
| Store_Key     | int           | NO   | MUL | NULL    |                |
| Quantity_Sold | int           | NO   |     | NULL    |                |
| Revenue       | decimal(12,2) | NO   |     | NULL    |                |
+---------------+---------------+------+-----+---------+----------------+
7 rows in set (0.00 sec)

mysql> CREATE TABLE FactInventory (
    ->     Inventory_Key BIGINT AUTO_INCREMENT PRIMARY KEY,
    ->     Product_Key INT NOT NULL,
    ->     Store_Key INT NOT NULL,
    ->     Warehouse_ID VARCHAR(20),
    ->     Date_Key INT NOT NULL,
    ->     Stock_Level INT NOT NULL,
    ->     Reorder_Level INT NOT NULL,
    ->
    ->     FOREIGN KEY (Product_Key)
    ->         REFERENCES DimProduct(Product_Key),
    ->
    ->     FOREIGN KEY (Store_Key)
    ->         REFERENCES DimStore(Store_Key),
    ->
    ->     FOREIGN KEY (Date_Key)
    ->         REFERENCES DimDate(Date_Key)
    -> );
Query OK, 0 rows affected (0.04 sec)

mysql> DESCRIBE FactInventory;
+---------------+-------------+------+-----+---------+----------------+
| Field         | Type        | Null | Key | Default | Extra          |
+---------------+-------------+------+-----+---------+----------------+
| Inventory_Key | bigint      | NO   | PRI | NULL    | auto_increment |
| Product_Key   | int         | NO   | MUL | NULL    |                |
| Store_Key     | int         | NO   | MUL | NULL    |                |
| Warehouse_ID  | varchar(20) | YES  |     | NULL    |                |
| Date_Key      | int         | NO   | MUL | NULL    |                |
| Stock_Level   | int         | NO   |     | NULL    |                |
| Reorder_Level | int         | NO   |     | NULL    |                |
+---------------+-------------+------+-----+---------+----------------+
7 rows in set (0.00 sec)

mysql> CREATE TABLE FactPurchaseOrders (
    ->     Purchase_Order_Key BIGINT AUTO_INCREMENT PRIMARY KEY,
    ->     Order_ID VARCHAR(40) NOT NULL,
    ->     Product_Key INT NOT NULL,
    ->     Supplier_Key INT NOT NULL,
    ->     Order_Date_Key INT NOT NULL,
    ->     Arrival_Date_Key INT NOT NULL,
    ->     Quantity INT NOT NULL,
    ->     Actual_Lead_Time INT NOT NULL,
    ->
    ->     FOREIGN KEY (Product_Key)
    ->         REFERENCES DimProduct(Product_Key),
    ->
    ->     FOREIGN KEY (Supplier_Key)
    ->         REFERENCES DimSupplier(Supplier_Key),
    ->
    ->     FOREIGN KEY (Order_Date_Key)
    ->         REFERENCES DimDate(Date_Key),
    ->
    ->     FOREIGN KEY (Arrival_Date_Key)
    ->         REFERENCES DimDate(Date_Key),
    ->
    ->     UNIQUE (Order_ID)
    -> );
Query OK, 0 rows affected (0.04 sec)

mysql> DESCRIBE FactPurchaseOrders;
+--------------------+-------------+------+-----+---------+----------------+
| Field              | Type        | Null | Key | Default | Extra          |
+--------------------+-------------+------+-----+---------+----------------+
| Purchase_Order_Key | bigint      | NO   | PRI | NULL    | auto_increment |
| Order_ID           | varchar(40) | NO   | UNI | NULL    |                |
| Product_Key        | int         | NO   | MUL | NULL    |                |
| Supplier_Key       | int         | NO   | MUL | NULL    |                |
| Order_Date_Key     | int         | NO   | MUL | NULL    |                |
| Arrival_Date_Key   | int         | NO   | MUL | NULL    |                |
| Quantity           | int         | NO   |     | NULL    |                |
| Actual_Lead_Time   | int         | NO   |     | NULL    |                |
+--------------------+-------------+------+-----+---------+----------------+
8 rows in set (0.00 sec)

mysql> INSERT INTO FactSales (
    ->     Sale_ID,
    ->     Date_Key,
    ->     Product_Key,
    ->     Store_Key,
    ->     Quantity_Sold,
    ->     Revenue
    -> )
    -> SELECT
    ->     s.Sale_ID,
    ->     DATE_FORMAT(s.Sale_Date, '%Y%m%d') + 0 AS Date_Key,
    ->     p.Product_Key,
    ->     st.Store_Key,
    ->     s.Quantity_Sold,
    ->     s.Revenue
    -> FROM stg_sales s
    -> JOIN DimProduct p
    ->     ON s.Product_ID = p.Product_ID
    -> JOIN DimStore st
    ->     ON s.Store_ID = st.Store_ID
    -> JOIN DimDate d
    ->     ON DATE(s.Sale_Date) = d.Full_Date;
Query OK, 5000 rows affected (0.16 sec)
Records: 5000  Duplicates: 0  Warnings: 0

mysql> SELECT COUNT(*) AS FactSales_Rows
    -> FROM FactSales;
+----------------+
| FactSales_Rows |
+----------------+
|           5000 |
+----------------+
1 row in set (0.00 sec)

mysql> INSERT INTO FactInventory (
    ->     Product_Key,
    ->     Store_Key,
    ->     Warehouse_ID,
    ->     Date_Key,
    ->     Stock_Level,
    ->     Reorder_Level
    -> )
    -> SELECT
    ->     p.Product_Key,
    ->     st.Store_Key,
    ->     i.Warehouse_ID,
    ->     d.Date_Key,
    ->     i.Stock_Level,
    ->     i.Reorder_Level
    -> FROM stg_inventory i
    -> JOIN DimProduct p
    ->     ON i.Product_ID = p.Product_ID
    -> JOIN DimStore st
    ->     ON i.Store_ID = st.Store_ID
    -> JOIN DimDate d
    ->     ON i.Last_Updated = d.Full_Date;
Query OK, 200 rows affected (0.01 sec)
Records: 200  Duplicates: 0  Warnings: 0

mysql> SELECT COUNT(*) AS FactInventory_Rows
    -> FROM FactInventory;
+--------------------+
| FactInventory_Rows |
+--------------------+
|                200 |
+--------------------+
1 row in set (0.00 sec)

mysql> INSERT INTO FactPurchaseOrders (
    ->     Order_ID,
    ->     Product_Key,
    ->     Supplier_Key,
    ->     Order_Date_Key,
    ->     Arrival_Date_Key,
    ->     Quantity,
    ->     Actual_Lead_Time
    -> )
    -> SELECT
    ->     po.Order_ID,
    ->     p.Product_Key,
    ->     s.Supplier_Key,
    ->     od.Date_Key,
    ->     ad.Date_Key,
    ->     po.Quantity,
    ->     po.Actual_Lead_Time
    -> FROM stg_purchase_orders po
    -> JOIN DimProduct p
    ->     ON po.Product_ID = p.Product_ID
    -> JOIN DimSupplier s
    ->     ON po.Supplier_ID = s.Supplier_ID
    -> JOIN DimDate od
    ->     ON po.Order_Date = od.Full_Date
    -> JOIN DimDate ad
    ->     ON po.Arrival_Date = ad.Full_Date;
Query OK, 1000 rows affected (0.05 sec)
Records: 1000  Duplicates: 0  Warnings: 0

mysql> SELECT COUNT(*) AS FactPurchaseOrder_Rows
    -> FROM FactPurchaseOrders;
+------------------------+
| FactPurchaseOrder_Rows |
+------------------------+
|                   1000 |
+------------------------+
1 row in set (0.00 sec)

mysql> SELECT
    ->     (SELECT COUNT(*) FROM DimDate) AS DimDate_Rows,
    ->     (SELECT COUNT(*) FROM DimProduct) AS DimProduct_Rows,
    ->     (SELECT COUNT(*) FROM DimStore) AS DimStore_Rows,
    ->     (SELECT COUNT(*) FROM DimSupplier) AS DimSupplier_Rows,
    ->     (SELECT COUNT(*) FROM FactSales) AS FactSales_Rows,
    ->     (SELECT COUNT(*) FROM FactInventory) AS FactInventory_Rows,
    ->     (SELECT COUNT(*) FROM FactPurchaseOrders) AS FactPurchaseOrder_Rows;
+--------------+-----------------+---------------+------------------+----------------+--------------------+------------------------+
| DimDate_Rows | DimProduct_Rows | DimStore_Rows | DimSupplier_Rows | FactSales_Rows | FactInventory_Rows | FactPurchaseOrder_Rows |
+--------------+-----------------+---------------+------------------+----------------+--------------------+------------------------+
|         5000 |               5 |             4 |               50 |           5000 |                200 |                   1000 |
+--------------+-----------------+---------------+------------------+----------------+--------------------+------------------------+
1 row in set (0.00 sec)

mysql> SELECT
    ->     p.Product_ID,
    ->     SUM(f.Quantity_Sold) AS Total_Quantity_Sold,
    ->     SUM(f.Revenue) AS Total_Revenue,
    ->     COUNT(DISTINCT f.Sale_ID) AS Transaction_Count
    -> FROM FactSales f
    -> JOIN DimProduct p
    ->     ON f.Product_Key = p.Product_Key
    -> GROUP BY p.Product_ID
    -> ORDER BY Total_Quantity_Sold DESC;
+------------+---------------------+---------------+-------------------+
| Product_ID | Total_Quantity_Sold | Total_Revenue | Transaction_Count |
+------------+---------------------+---------------+-------------------+
| P002       |              269100 |   26084882.00 |              1018 |
| P001       |              260296 |   25355109.00 |              1044 |
| P004       |              258635 |   24835649.00 |               985 |
| P005       |              254794 |   24896449.00 |               973 |
| P003       |              249297 |   24697925.00 |               980 |
+------------+---------------------+---------------+-------------------+
5 rows in set (0.01 sec)

mysql> SELECT
    ->     d.Year,
    ->     d.Month,
    ->     d.Month_Name,
    ->     SUM(f.Quantity_Sold) AS Total_Quantity_Sold,
    ->     SUM(f.Revenue) AS Total_Revenue,
    ->     COUNT(DISTINCT f.Sale_ID) AS Transaction_Count
    -> FROM FactSales f
    -> JOIN DimDate d
    ->     ON f.Date_Key = d.Date_Key
    -> WHERE d.Full_Date >= '2037-06-01'
    ->   AND d.Full_Date < '2037-09-01'
    -> GROUP BY
    ->     d.Year,
    ->     d.Month,
    ->     d.Month_Name
    -> ORDER BY
    ->     d.Year,
    ->     d.Month;
+------+-------+------------+---------------------+---------------+-------------------+
| Year | Month | Month_Name | Total_Quantity_Sold | Total_Revenue | Transaction_Count |
+------+-------+------------+---------------------+---------------+-------------------+
| 2037 |     6 | June       |                7585 |     664893.00 |                30 |
| 2037 |     7 | July       |                6738 |     696360.00 |                31 |
| 2037 |     8 | August     |                8385 |     850017.00 |                31 |
+------+-------+------------+---------------------+---------------+-------------------+
3 rows in set (0.01 sec)

mysql> WITH LatestInventory AS (
    ->     SELECT
    ->         fi.*,
    ->         ROW_NUMBER() OVER (
    ->             PARTITION BY
    ->                 fi.Product_Key,
    ->                 fi.Store_Key
    ->             ORDER BY fi.Date_Key DESC
    ->         ) AS rn
    ->     FROM FactInventory fi
    -> )
    ->
    -> SELECT
    ->     p.Product_ID,
    ->     s.Store_ID,
    ->     li.Warehouse_ID,
    ->     d.Full_Date AS Last_Updated,
    ->     li.Stock_Level,
    ->     li.Reorder_Level,
    ->     li.Stock_Level - li.Reorder_Level AS Stock_Gap
    -> FROM LatestInventory li
    -> JOIN DimProduct p
    ->     ON li.Product_Key = p.Product_Key
    -> JOIN DimStore s
    ->     ON li.Store_Key = s.Store_Key
    -> JOIN DimDate d
    ->     ON li.Date_Key = d.Date_Key
    -> WHERE li.rn = 1
    ->   AND li.Stock_Level < li.Reorder_Level
    -> ORDER BY Stock_Gap ASC;
+------------+----------+--------------+--------------+-------------+---------------+-----------+
| Product_ID | Store_ID | Warehouse_ID | Last_Updated | Stock_Level | Reorder_Level | Stock_Gap |
+------------+----------+--------------+--------------+-------------+---------------+-----------+
| P001       | S104     | W003         | 2024-08-18   |         140 |           184 |       -44 |
| P004       | S101     | W003         | 2024-07-30   |         100 |           136 |       -36 |
| P005       | S103     | W001         | 2024-08-17   |         164 |           180 |       -16 |
+------------+----------+--------------+--------------+-------------+---------------+-----------+
3 rows in set (0.00 sec)

mysql> SELECT
    ->     s.Supplier_ID,
    ->     s.Supplier_Name,
    ->     s.Lead_Time_Days AS Reported_Lead_Time,
    ->     s.Order_Frequency,
    ->     COUNT(po.Purchase_Order_Key) AS Total_Orders,
    ->     SUM(po.Quantity) AS Total_Quantity_Ordered,
    ->     ROUND(
    ->         AVG(po.Actual_Lead_Time),
    ->         2
    ->     ) AS Avg_Actual_Lead_Time
    -> FROM DimSupplier s
    -> JOIN FactPurchaseOrders po
    ->     ON s.Supplier_Key = po.Supplier_Key
    -> GROUP BY
    ->     s.Supplier_ID,
    ->     s.Supplier_Name,
    ->     s.Lead_Time_Days,
    ->     s.Order_Frequency
    -> ORDER BY
    ->     s.Lead_Time_Days ASC,
    ->     Avg_Actual_Lead_Time ASC;
+-------------+-------------------------------+--------------------+-----------------+--------------+------------------------+----------------------+
| Supplier_ID | Supplier_Name                 | Reported_Lead_Time | Order_Frequency | Total_Orders | Total_Quantity_Ordered | Avg_Actual_Lead_Time |
+-------------+-------------------------------+--------------------+-----------------+--------------+------------------------+----------------------+
| SUP028      | Taylor Ltd                    |                  3 | Biweekly        |           23 |                   6299 |                 5.00 |
| SUP032      | Ferguson Group                |                  3 | Weekly          |           21 |                   4668 |                 5.00 |
| SUP039      | Ortega-Manning                |                  3 | Monthly         |           22 |                   6557 |                 5.00 |
| SUP041      | Brown Ltd                     |                  3 | Weekly          |           14 |                   4114 |                 5.00 |
| SUP003      | Acosta Inc                    |                  4 | Monthly         |           22 |                   5521 |                 5.00 |
| SUP024      | Thompson-Hebert               |                  4 | Biweekly        |           19 |                   5075 |                 5.00 |
| SUP009      | Baker LLC                     |                  4 | Weekly          |           15 |                   3780 |                 5.00 |
| SUP011      | Peterson, Thomas and Page     |                  4 | Biweekly        |           27 |                   7267 |                 5.00 |
| SUP015      | Watson Ltd                    |                  4 | Biweekly        |           16 |                   4556 |                 5.00 |
| SUP019      | Bowers and Sons               |                  4 | Weekly          |           20 |                   5098 |                 5.00 |
| SUP021      | Robertson LLC                 |                  4 | Biweekly        |           19 |                   5274 |                 5.00 |
| SUP022      | Alvarado, Ramirez and Taylor  |                  4 | Biweekly        |           17 |                   4523 |                 5.00 |
| SUP044      | Peters-Salas                  |                  4 | Monthly         |           20 |                   4587 |                 5.00 |
| SUP040      | Wilson-Stanley                |                  4 | Weekly          |           24 |                   6311 |                 5.00 |
| SUP047      | Nunez-May                     |                  4 | Biweekly        |           19 |                   4855 |                 5.00 |
| SUP048      | Williams Inc                  |                  4 | Biweekly        |           25 |                   6899 |                 5.00 |
| SUP030      | Baker, Dean and Jensen        |                  5 | Biweekly        |           16 |                   3319 |                 5.00 |
| SUP027      | Woods PLC                     |                  5 | Monthly         |           18 |                   4674 |                 5.00 |
| SUP025      | Rose Inc                      |                  5 | Monthly         |           21 |                   6333 |                 5.00 |
| SUP018      | Wilson Inc                    |                  5 | Weekly          |           19 |                   4496 |                 5.00 |
| SUP031      | Harmon, Davis and Harper      |                  5 | Monthly         |           20 |                   5328 |                 5.00 |
| SUP023      | Smith and Sons                |                  6 | Monthly         |           19 |                   6019 |                 5.00 |
| SUP005      | Johnson, Wise and Barr        |                  6 | Biweekly        |           27 |                   7981 |                 5.00 |
| SUP006      | Hood, Barrera and Woodard     |                  6 | Monthly         |           14 |                   4498 |                 5.00 |
| SUP020      | Porter, Daniels and Stewart   |                  6 | Monthly         |           18 |                   4279 |                 5.00 |
| SUP012      | Wright, White and Gonzalez    |                  6 | Monthly         |           20 |                   6159 |                 5.00 |
| SUP026      | Roberts-Williams              |                  6 | Weekly          |           20 |                   4965 |                 5.00 |
| SUP042      | Cross, Scott and Avery        |                  6 | Weekly          |           13 |                   3280 |                 5.00 |
| SUP013      | Norman, Welch and Foster      |                  7 | Biweekly        |           16 |                   4369 |                 5.00 |
| SUP014      | Brown LLC                     |                  7 | Biweekly        |           25 |                   7593 |                 5.00 |
| SUP017      | Ayers Ltd                     |                  7 | Monthly         |           19 |                   4690 |                 5.00 |
| SUP045      | Castro-Townsend               |                  7 | Weekly          |           21 |                   6628 |                 5.00 |
| SUP008      | Edwards-Barnes                |                  8 | Weekly          |           33 |                   9350 |                 5.00 |
| SUP037      | Kerr-Palmer                   |                  8 | Weekly          |           16 |                   4101 |                 5.00 |
| SUP016      | Johnson Group                 |                  8 | Biweekly        |           21 |                   6039 |                 5.00 |
| SUP038      | Johnson, Turner and Carpenter |                  8 | Biweekly        |           15 |                   3810 |                 5.00 |
| SUP004      | Evans, Brown and Turner       |                  8 | Weekly          |           25 |                   6927 |                 5.00 |
| SUP050      | Sosa, Cain and Cummings       |                  8 | Weekly          |           30 |                   8576 |                 5.00 |
| SUP007      | Meyers, Miller and Young      |                  9 | Weekly          |           19 |                   5620 |                 5.00 |
| SUP010      | Wright PLC                    |                  9 | Monthly         |           20 |                   6451 |                 5.00 |
| SUP033      | Murphy-Wise                   |                  9 | Weekly          |           18 |                   4586 |                 5.00 |
| SUP034      | James, Mullen and Cooper      |                  9 | Weekly          |           25 |                   7301 |                 5.00 |
| SUP043      | Fox Group                     |                  9 | Biweekly        |           18 |                   5966 |                 5.00 |
| SUP001      | Murray-Ramirez                |                  9 | Weekly          |           18 |                   5328 |                 5.00 |
| SUP035      | Smith PLC                     |                  9 | Monthly         |           21 |                   6165 |                 5.00 |
| SUP046      | Harris, Patterson and Harris  |                  9 | Biweekly        |           19 |                   5668 |                 5.00 |
| SUP036      | Powers, Olson and Sanchez     |                  9 | Weekly          |           10 |                   3078 |                 5.00 |
| SUP029      | Duncan, Davidson and Martin   |                  9 | Monthly         |           23 |                   6140 |                 5.00 |
| SUP049      | Obrien-Jones                  |                  9 | Biweekly        |           19 |                   5371 |                 5.00 |
| SUP002      | Thomas, Meyer and Campbell    |                  9 | Weekly          |           21 |                   6016 |                 5.00 |
+-------------+-------------------------------+--------------------+-----------------+--------------+------------------------+----------------------+
50 rows in set (0.01 sec)

mysql> SELECT
    ->     s.Lead_Time_Days AS Reported_Lead_Time,
    ->     COUNT(DISTINCT s.Supplier_ID) AS Supplier_Count,
    ->     COUNT(po.Purchase_Order_Key) AS Total_Orders,
    ->     ROUND(
    ->         AVG(po.Actual_Lead_Time),
    ->         2
    ->     ) AS Avg_Actual_Lead_Time
    -> FROM DimSupplier s
    -> JOIN FactPurchaseOrders po
    ->     ON s.Supplier_Key = po.Supplier_Key
    -> GROUP BY s.Lead_Time_Days
    -> ORDER BY s.Lead_Time_Days;
+--------------------+----------------+--------------+----------------------+
| Reported_Lead_Time | Supplier_Count | Total_Orders | Avg_Actual_Lead_Time |
+--------------------+----------------+--------------+----------------------+
|                  3 |              4 |           80 |                 5.00 |
|                  4 |             12 |          243 |                 5.00 |
|                  5 |              5 |           94 |                 5.00 |
|                  6 |              7 |          131 |                 5.00 |
|                  7 |              4 |           81 |                 5.00 |
|                  8 |              6 |          140 |                 5.00 |
|                  9 |             12 |          231 |                 5.00 |
+--------------------+----------------+--------------+----------------------+
7 rows in set (0.00 sec)

mysql> WITH LatestInventory AS (
    ->     SELECT
    ->         fi.*,
    ->         ROW_NUMBER() OVER (
    ->             PARTITION BY
    ->                 fi.Product_Key,
    ->                 fi.Store_Key
    ->             ORDER BY fi.Date_Key DESC
    ->         ) AS rn
    ->     FROM FactInventory fi
    -> )
    ->
    -> SELECT
    ->     COUNT(*) AS Product_Store_Combinations,
    ->     SUM(
    ->         CASE
    ->             WHEN Stock_Level < Reorder_Level
    ->             THEN 1
    ->             ELSE 0
    ->         END
    ->     ) AS Below_Reorder,
    ->     SUM(
    ->         CASE
    ->             WHEN Stock_Level >= Reorder_Level
    ->             THEN 1
    ->             ELSE 0
    ->         END
    ->     ) AS At_Or_Above_Reorder,
    ->     ROUND(
    ->         AVG(Stock_Level),
    ->         2
    ->     ) AS Avg_Stock_Level,
    ->     ROUND(
    ->         AVG(Reorder_Level),
    ->         2
    ->     ) AS Avg_Reorder_Level
    -> FROM LatestInventory
    -> WHERE rn = 1;
+----------------------------+---------------+---------------------+-----------------+-------------------+
| Product_Store_Combinations | Below_Reorder | At_Or_Above_Reorder | Avg_Stock_Level | Avg_Reorder_Level |
+----------------------------+---------------+---------------------+-----------------+-------------------+
|                         20 |             3 |                  17 |          273.95 |            134.50 |
+----------------------------+---------------+---------------------+-----------------+-------------------+
1 row in set (0.00 sec)
