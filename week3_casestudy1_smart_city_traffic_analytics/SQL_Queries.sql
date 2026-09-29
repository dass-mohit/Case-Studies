

mysql> CREATE DATABASE smart_city_dwh;
Query OK, 1 row affected (0.01 sec)

mysql> USE smart_city_dwh;
Database changed
mysql> CREATE TABLE staging_traffic_sensor (
    ->     Sensor_ID VARCHAR(20),
    ->     Location VARCHAR(100),
    ->     Date_Time DATETIME,
    ->     Vehicle_Count INT,
    ->     Average_Speed DECIMAL(10,2),
    ->     Congestion_Level VARCHAR(30),
    ->     Date DATE,
    ->     Hour INT,
    ->     Day INT,
    ->     Month INT,
    ->     Day_of_Week VARCHAR(20),
    ->     Congestion_Index DECIMAL(10,4)
    -> );
Query OK, 0 rows affected (0.02 sec)

mysql> CREATE TABLE staging_traffic_accident (
    ->     Accident_ID VARCHAR(20),
    ->     Date_Time DATETIME,
    ->     Location VARCHAR(100),
    ->     Weather_Condition VARCHAR(50),
    ->     Road_Condition VARCHAR(50),
    ->     Vehicle_Type VARCHAR(50),
    ->     Accident_Severity VARCHAR(30),
    ->     Number_of_Vehicles INT,
    ->     Casualties INT,
    ->     Traffic_Density VARCHAR(30),
    ->     Date DATE,
    ->     Hour INT,
    ->     Day INT,
    ->     Month INT,
    ->     Day_of_Week VARCHAR(20)
    -> );
Query OK, 0 rows affected (0.02 sec)

mysql> SHOW TABLES;
+--------------------------+
| Tables_in_smart_city_dwh |
+--------------------------+
| staging_traffic_accident |
| staging_traffic_sensor   |
+--------------------------+
2 rows in set (0.01 sec)

mysql> DESCRIBE staging_traffic_sensor;
+------------------+---------------+------+-----+---------+-------+
| Field            | Type          | Null | Key | Default | Extra |
+------------------+---------------+------+-----+---------+-------+
| Sensor_ID        | varchar(20)   | YES  |     | NULL    |       |
| Location         | varchar(100)  | YES  |     | NULL    |       |
| Date_Time        | datetime      | YES  |     | NULL    |       |
| Vehicle_Count    | int           | YES  |     | NULL    |       |
| Average_Speed    | decimal(10,2) | YES  |     | NULL    |       |
| Congestion_Level | varchar(30)   | YES  |     | NULL    |       |
| Date             | date          | YES  |     | NULL    |       |
| Hour             | int           | YES  |     | NULL    |       |
| Day              | int           | YES  |     | NULL    |       |
| Month            | int           | YES  |     | NULL    |       |
| Day_of_Week      | varchar(20)   | YES  |     | NULL    |       |
| Congestion_Index | decimal(10,4) | YES  |     | NULL    |       |
+------------------+---------------+------+-----+---------+-------+
12 rows in set (0.01 sec)

mysql> DESCRIBE staging_traffic_accident;
+--------------------+--------------+------+-----+---------+-------+
| Field              | Type         | Null | Key | Default | Extra |
+--------------------+--------------+------+-----+---------+-------+
| Accident_ID        | varchar(20)  | YES  |     | NULL    |       |
| Date_Time          | datetime     | YES  |     | NULL    |       |
| Location           | varchar(100) | YES  |     | NULL    |       |
| Weather_Condition  | varchar(50)  | YES  |     | NULL    |       |
| Road_Condition     | varchar(50)  | YES  |     | NULL    |       |
| Vehicle_Type       | varchar(50)  | YES  |     | NULL    |       |
| Accident_Severity  | varchar(30)  | YES  |     | NULL    |       |
| Number_of_Vehicles | int          | YES  |     | NULL    |       |
| Casualties         | int          | YES  |     | NULL    |       |
| Traffic_Density    | varchar(30)  | YES  |     | NULL    |       |
| Date               | date         | YES  |     | NULL    |       |
| Hour               | int          | YES  |     | NULL    |       |
| Day                | int          | YES  |     | NULL    |       |
| Month              | int          | YES  |     | NULL    |       |
| Day_of_Week        | varchar(20)  | YES  |     | NULL    |       |
+--------------------+--------------+------+-----+---------+-------+
15 rows in set (0.00 sec)

mysql> SELECT
    ->     (SELECT COUNT(*) FROM staging_traffic_sensor) AS Sensor_Records,
    ->     (SELECT COUNT(*) FROM staging_traffic_accident) AS Accident_Records;
+----------------+------------------+
| Sensor_Records | Accident_Records |
+----------------+------------------+
|            300 |             5000 |
+----------------+------------------+
1 row in set (0.01 sec)

mysql> CREATE TABLE dim_date (
    ->     Date_Key INT AUTO_INCREMENT PRIMARY KEY,
    ->     Full_Date DATE NOT NULL,
    ->     Day INT,
    ->     Month INT,
    ->     Year INT,
    ->     Day_of_Week VARCHAR(20)
    -> );
Query OK, 0 rows affected (0.02 sec)

mysql> CREATE TABLE dim_location (
    ->     Location_Key INT AUTO_INCREMENT PRIMARY KEY,
    ->     Location_Name VARCHAR(100) NOT NULL UNIQUE
    -> );
Query OK, 0 rows affected (0.03 sec)

mysql> INSERT INTO dim_location (Location_Name)
    -> SELECT DISTINCT Location
    -> FROM (
    ->     SELECT Location FROM staging_traffic_sensor
    ->     UNION
    ->     SELECT Location FROM staging_traffic_accident
    -> ) AS locations;
Query OK, 5 rows affected (0.01 sec)
Records: 5  Duplicates: 0  Warnings: 0

mysql> SELECT * FROM dim_location;
+--------------+------------------+
| Location_Key | Location_Name    |
+--------------+------------------+
|            1 | Downtown         |
|            2 | Highway          |
|            4 | Industrial Area  |
|            3 | Residential Zone |
|            5 | Suburbs          |
+--------------+------------------+
5 rows in set (0.00 sec)

mysql> CREATE TABLE fact_traffic_sensor (
    ->     Traffic_Key INT AUTO_INCREMENT PRIMARY KEY,
    ->     Sensor_ID VARCHAR(20) NOT NULL,
    ->     Date_Key INT NOT NULL,
    ->     Location_Key INT NOT NULL,
    ->     Date_Time DATETIME NOT NULL,
    ->     Vehicle_Count INT,
    ->     Average_Speed DECIMAL(10,2),
    ->     Congestion_Level VARCHAR(30),
    ->     Congestion_Index DECIMAL(10,4),
    ->
    ->     FOREIGN KEY (Date_Key) REFERENCES dim_date(Date_Key),
    ->     FOREIGN KEY (Location_Key) REFERENCES dim_location(Location_Key)
    -> );
Query OK, 0 rows affected (0.04 sec)

mysql> CREATE TABLE fact_accident (
    ->     Accident_Key INT AUTO_INCREMENT PRIMARY KEY,
    ->     Accident_ID VARCHAR(20) NOT NULL,
    ->     Date_Key INT NOT NULL,
    ->     Location_Key INT NOT NULL,
    ->     Date_Time DATETIME NOT NULL,
    ->     Weather_Condition VARCHAR(50),
    ->     Road_Condition VARCHAR(50),
    ->     Vehicle_Type VARCHAR(50),
    ->     Accident_Severity VARCHAR(30),
    ->     Number_of_Vehicles INT,
    ->     Casualties INT,
    ->     Traffic_Density VARCHAR(30),
    ->
    ->     FOREIGN KEY (Date_Key) REFERENCES dim_date(Date_Key),
    ->     FOREIGN KEY (Location_Key) REFERENCES dim_location(Location_Key)
    -> );
Query OK, 0 rows affected (0.04 sec)

mysql> INSERT INTO dim_date (Full_Date, Day, Month, Year, Day_of_Week)
    -> SELECT DISTINCT
    ->     DATE(Date_Time) AS Full_Date,
    ->     DAY(Date_Time) AS Day,
    ->     MONTH(Date_Time) AS Month,
    ->     YEAR(Date_Time) AS Year,
    ->     DAYNAME(Date_Time) AS Day_of_Week
    -> FROM (
    ->     SELECT Date_Time FROM staging_traffic_sensor
    ->     UNION
    ->     SELECT Date_Time FROM staging_traffic_accident
    -> ) AS all_dates;
Query OK, 209 rows affected (0.02 sec)
Records: 209  Duplicates: 0  Warnings: 0

mysql> SELECT
    ->     COUNT(*) AS Total_Dates,
    ->     MIN(Full_Date) AS First_Date,
    ->     MAX(Full_Date) AS Last_Date
    -> FROM dim_date;
+-------------+------------+------------+
| Total_Dates | First_Date | Last_Date  |
+-------------+------------+------------+
|         209 | 2024-01-01 | 2024-07-27 |
+-------------+------------+------------+
1 row in set (0.00 sec)

mysql> INSERT INTO fact_traffic_sensor (
    ->     Sensor_ID,
    ->     Date_Key,
    ->     Location_Key,
    ->     Date_Time,
    ->     Vehicle_Count,
    ->     Average_Speed,
    ->     Congestion_Level,
    ->     Congestion_Index
    -> )
    -> SELECT
    ->     s.Sensor_ID,
    ->     d.Date_Key,
    ->     l.Location_Key,
    ->     s.Date_Time,
    ->     s.Vehicle_Count,
    ->     s.Average_Speed,
    ->     s.Congestion_Level,
    ->     s.Congestion_Index
    -> FROM staging_traffic_sensor s
    -> JOIN dim_date d
    ->     ON d.Full_Date = s.Date
    -> JOIN dim_location l
    ->     ON l.Location_Name = s.Location;
Query OK, 300 rows affected (0.04 sec)
Records: 300  Duplicates: 0  Warnings: 0

mysql> INSERT INTO fact_accident (
    ->     Accident_ID,
    ->     Date_Key,
    ->     Location_Key,
    ->     Date_Time,
    ->     Weather_Condition,
    ->     Road_Condition,
    ->     Vehicle_Type,
    ->     Accident_Severity,
    ->     Number_of_Vehicles,
    ->     Casualties,
    ->     Traffic_Density
    -> )
    -> SELECT
    ->     a.Accident_ID,
    ->     d.Date_Key,
    ->     l.Location_Key,
    ->     a.Date_Time,
    ->     a.Weather_Condition,
    ->     a.Road_Condition,
    ->     a.Vehicle_Type,
    ->     a.Accident_Severity,
    ->     a.Number_of_Vehicles,
    ->     a.Casualties,
    ->     a.Traffic_Density
    -> FROM staging_traffic_accident a
    -> JOIN dim_date d
    ->     ON d.Full_Date = a.Date
    -> JOIN dim_location l
    ->     ON l.Location_Name = a.Location;
Query OK, 5000 rows affected (0.12 sec)
Records: 5000  Duplicates: 0  Warnings: 0

mysql> SELECT
    ->     (SELECT COUNT(*) FROM dim_date) AS Date_Dimension,
    ->     (SELECT COUNT(*) FROM dim_location) AS Location_Dimension,
    ->     (SELECT COUNT(*) FROM fact_traffic_sensor) AS Traffic_Facts,
    ->     (SELECT COUNT(*) FROM fact_accident) AS Accident_Facts;
+----------------+--------------------+---------------+----------------+
| Date_Dimension | Location_Dimension | Traffic_Facts | Accident_Facts |
+----------------+--------------------+---------------+----------------+
|            209 |                  5 |           300 |           5000 |
+----------------+--------------------+---------------+----------------+
1 row in set (0.01 sec)

mysql> SELECT
    ->     COUNT(*) AS Invalid_Traffic_References
    -> FROM fact_traffic_sensor f
    -> LEFT JOIN dim_date d
    ->     ON f.Date_Key = d.Date_Key
    -> LEFT JOIN dim_location l
    ->     ON f.Location_Key = l.Location_Key
    -> WHERE d.Date_Key IS NULL
    ->    OR l.Location_Key IS NULL;
+----------------------------+
| Invalid_Traffic_References |
+----------------------------+
|                          0 |
+----------------------------+
1 row in set (0.00 sec)

mysql> SELECT
    ->     COUNT(*) AS Invalid_Accident_References
    -> FROM fact_accident f
    -> LEFT JOIN dim_date d
    ->     ON f.Date_Key = d.Date_Key
    -> LEFT JOIN dim_location l
    ->     ON f.Location_Key = l.Location_Key
    -> WHERE d.Date_Key IS NULL
    ->    OR l.Location_Key IS NULL;
+-----------------------------+
| Invalid_Accident_References |
+-----------------------------+
|                           0 |
+-----------------------------+
1 row in set (0.01 sec)

mysql> SELECT
    ->     HOUR(Date_Time) AS Peak_Hour,
    ->     ROUND(AVG(Vehicle_Count), 2) AS Average_Vehicle_Count
    -> FROM fact_traffic_sensor
    -> GROUP BY HOUR(Date_Time)
    -> ORDER BY Average_Vehicle_Count DESC;
+-----------+-----------------------+
| Peak_Hour | Average_Vehicle_Count |
+-----------+-----------------------+
|        18 |                357.92 |
|        15 |                356.17 |
|        12 |                324.00 |
|        10 |                316.15 |
|         2 |                312.54 |
|         4 |                305.69 |
|         1 |                286.23 |
|        16 |                284.42 |
|        17 |                282.83 |
|         7 |                281.62 |
|        22 |                281.58 |
|        20 |                280.50 |
|         5 |                280.08 |
|         6 |                277.15 |
|         3 |                269.38 |
|        11 |                267.08 |
|         8 |                256.92 |
|        23 |                256.75 |
|         9 |                255.23 |
|        19 |                247.17 |
|         0 |                243.00 |
|        13 |                238.08 |
|        21 |                224.50 |
|        14 |                204.33 |
+-----------+-----------------------+
24 rows in set (0.00 sec)

mysql> SELECT
    ->     l.Location_Name,
    ->     COUNT(f.Traffic_Key) AS Traffic_Records,
    ->     ROUND(AVG(f.Vehicle_Count), 2) AS Average_Vehicle_Count,
    ->     ROUND(AVG(f.Average_Speed), 2) AS Average_Speed,
    ->     ROUND(AVG(f.Congestion_Index), 2) AS Average_Congestion_Index
    -> FROM fact_traffic_sensor f
    -> JOIN dim_location l
    ->     ON f.Location_Key = l.Location_Key
    -> GROUP BY l.Location_Name
    -> ORDER BY Average_Vehicle_Count DESC;
+------------------+-----------------+-----------------------+---------------+--------------------------+
| Location_Name    | Traffic_Records | Average_Vehicle_Count | Average_Speed | Average_Congestion_Index |
+------------------+-----------------+-----------------------+---------------+--------------------------+
| Residential Zone |              59 |                329.42 |         45.54 |                     9.00 |
| Downtown         |              55 |                290.56 |         49.36 |                     7.00 |
| Industrial Area  |              51 |                283.78 |         50.18 |                     6.75 |
| Highway          |              80 |                257.79 |         49.71 |                     5.99 |
| Suburbs          |              55 |                238.36 |         50.76 |                     5.34 |
+------------------+-----------------+-----------------------+---------------+--------------------------+
5 rows in set (0.00 sec)

mysql> SELECT
    ->     l.Location_Name,
    ->     COUNT(f.Accident_Key) AS Accident_Count,
    ->     ROUND(AVG(f.Casualties), 2) AS Average_Casualties
    -> FROM fact_accident f
    -> JOIN dim_location l
    ->     ON f.Location_Key = l.Location_Key
    -> GROUP BY l.Location_Name
    -> ORDER BY Accident_Count DESC;
+------------------+----------------+--------------------+
| Location_Name    | Accident_Count | Average_Casualties |
+------------------+----------------+--------------------+
| Highway          |           1018 |               4.58 |
| Suburbs          |           1017 |               4.41 |
| Residential Zone |            998 |               4.46 |
| Industrial Area  |            993 |               4.50 |
| Downtown         |            974 |               4.52 |
+------------------+----------------+--------------------+
5 rows in set (0.01 sec)

mysql> SELECT
    ->     Accident_Severity,
    ->     COUNT(*) AS Accident_Count,
    ->     ROUND(AVG(Casualties), 2) AS Average_Casualties,
    ->     ROUND(AVG(Number_of_Vehicles), 2) AS Average_Vehicles_Involved
    -> FROM fact_accident
    -> GROUP BY Accident_Severity
    -> ORDER BY Accident_Count DESC;
+-------------------+----------------+--------------------+---------------------------+
| Accident_Severity | Accident_Count | Average_Casualties | Average_Vehicles_Involved |
+-------------------+----------------+--------------------+---------------------------+
| Minor             |           1262 |               4.52 |                      2.47 |
| Fatal             |           1253 |               4.46 |                      2.54 |
| Moderate          |           1248 |               4.59 |                      2.50 |
| Severe            |           1237 |               4.40 |                      2.57 |
+-------------------+----------------+--------------------+---------------------------+
4 rows in set (0.01 sec)

mysql> SELECT
    ->     Weather_Condition,
    ->     COUNT(*) AS Accident_Count,
    ->     ROUND(AVG(Casualties), 2) AS Average_Casualties
    -> FROM fact_accident
    -> GROUP BY Weather_Condition
    -> ORDER BY Accident_Count DESC;
+-------------------+----------------+--------------------+
| Weather_Condition | Accident_Count | Average_Casualties |
+-------------------+----------------+--------------------+
| Rain              |           1054 |               4.51 |
| Clear             |           1019 |               4.43 |
| Snow              |           1001 |               4.49 |
| Fog               |            969 |               4.52 |
| Storm             |            957 |               4.51 |
+-------------------+----------------+--------------------+
5 rows in set (0.01 sec)

mysql> SELECT
    ->     Road_Condition,
    ->     COUNT(*) AS Accident_Count,
    ->     ROUND(AVG(Casualties), 2) AS Average_Casualties
    -> FROM fact_accident
    -> GROUP BY Road_Condition
    -> ORDER BY Accident_Count DESC;
+--------------------+----------------+--------------------+
| Road_Condition     | Accident_Count | Average_Casualties |
+--------------------+----------------+--------------------+
| Icy                |           1288 |               4.57 |
| Dry                |           1257 |               4.50 |
| Wet                |           1233 |               4.46 |
| Under Construction |           1222 |               4.44 |
+--------------------+----------------+--------------------+
4 rows in set (0.01 sec)

mysql> SELECT
    ->     Vehicle_Type,
    ->     COUNT(*) AS Accident_Count,
    ->     ROUND(AVG(Casualties), 2) AS Average_Casualties
    -> FROM fact_accident
    -> GROUP BY Vehicle_Type
    -> ORDER BY Accident_Count DESC;
+--------------+----------------+--------------------+
| Vehicle_Type | Accident_Count | Average_Casualties |
+--------------+----------------+--------------------+
| Truck        |           1052 |               4.46 |
| Car          |           1032 |               4.48 |
| Bicycle      |            988 |               4.52 |
| Motorcycle   |            972 |               4.59 |
| Bus          |            956 |               4.42 |
+--------------+----------------+--------------------+
5 rows in set (0.00 sec)

mysql> SELECT
    ->     Traffic_Density,
    ->     Accident_Severity,
    ->     COUNT(*) AS Accident_Count
    -> FROM fact_accident
    -> GROUP BY Traffic_Density, Accident_Severity
    -> ORDER BY Traffic_Density, Accident_Count DESC;
+-----------------+-------------------+----------------+
| Traffic_Density | Accident_Severity | Accident_Count |
+-----------------+-------------------+----------------+
| High            | Minor             |            451 |
| High            | Severe            |            421 |
| High            | Moderate          |            411 |
| High            | Fatal             |            404 |
| Low             | Moderate          |            418 |
| Low             | Minor             |            405 |
| Low             | Fatal             |            401 |
| Low             | Severe            |            379 |
| Moderate        | Fatal             |            448 |
| Moderate        | Severe            |            437 |
| Moderate        | Moderate          |            419 |
| Moderate        | Minor             |            406 |
+-----------------+-------------------+----------------+
12 rows in set (0.00 sec)

mysql> SELECT
    ->     HOUR(Date_Time) AS Accident_Hour,
    ->     COUNT(*) AS Accident_Count
    -> FROM fact_accident
    -> GROUP BY HOUR(Date_Time)
    -> ORDER BY Accident_Count DESC;
+---------------+----------------+
| Accident_Hour | Accident_Count |
+---------------+----------------+
|             0 |            209 |
|             1 |            209 |
|             2 |            209 |
|             3 |            209 |
|             4 |            209 |
|             5 |            209 |
|             6 |            209 |
|             7 |            209 |
|             8 |            208 |
|             9 |            208 |
|            10 |            208 |
|            11 |            208 |
|            12 |            208 |
|            13 |            208 |
|            14 |            208 |
|            15 |            208 |
|            16 |            208 |
|            17 |            208 |
|            18 |            208 |
|            19 |            208 |
|            20 |            208 |
|            21 |            208 |
|            22 |            208 |
|            23 |            208 |
+---------------+----------------+
24 rows in set (0.00 sec)

mysql> SELECT
    ->     MONTH(Date_Time) AS Accident_Month,
    ->     COUNT(*) AS Accident_Count
    -> FROM fact_accident
    -> GROUP BY MONTH(Date_Time)
    -> ORDER BY Accident_Month;
+----------------+----------------+
| Accident_Month | Accident_Count |
+----------------+----------------+
|              1 |            744 |
|              2 |            696 |
|              3 |            744 |
|              4 |            720 |
|              5 |            744 |
|              6 |            720 |
|              7 |            632 |
+----------------+----------------+
7 rows in set (0.00 sec)

mysql> SELECT
    ->     DAYNAME(Date_Time) AS Day_of_Week,
    ->     COUNT(*) AS Accident_Count
    -> FROM fact_accident
    -> GROUP BY DAYNAME(Date_Time)
    -> ORDER BY Accident_Count DESC;
+-------------+----------------+
| Day_of_Week | Accident_Count |
+-------------+----------------+
| Monday      |            720 |
| Tuesday     |            720 |
| Wednesday   |            720 |
| Thursday    |            720 |
| Friday      |            720 |
| Saturday    |            704 |
| Sunday      |            696 |
+-------------+----------------+
7 rows in set (0.00 sec)

mysql> SELECT
    ->     Congestion_Level,
    ->     COUNT(*) AS Traffic_Records,
    ->     ROUND(AVG(Vehicle_Count), 2) AS Average_Vehicle_Count,
    ->     ROUND(AVG(Average_Speed), 2) AS Average_Speed,
    ->     ROUND(AVG(Congestion_Index), 2) AS Average_Congestion_Index
    -> FROM fact_traffic_sensor
    -> GROUP BY Congestion_Level
    -> ORDER BY Traffic_Records DESC;
+------------------+-----------------+-----------------------+---------------+--------------------------+
| Congestion_Level | Traffic_Records | Average_Vehicle_Count | Average_Speed | Average_Congestion_Index |
+------------------+-----------------+-----------------------+---------------+--------------------------+
| Low              |             104 |                278.14 |         50.63 |                     6.40 |
| Moderate         |             100 |                305.08 |         49.80 |                     7.41 |
| High             |              96 |                251.96 |         46.72 |                     6.53 |
+------------------+-----------------+-----------------------+---------------+--------------------------+
3 rows in set (0.00 sec)

mysql> SELECT
    ->     l.Location_Name,
    ->     f.Congestion_Level,
    ->     COUNT(*) AS Traffic_Records,
    ->     ROUND(AVG(f.Congestion_Index), 2) AS Average_Congestion_Index
    -> FROM fact_traffic_sensor f
    -> JOIN dim_location l
    ->     ON f.Location_Key = l.Location_Key
    -> GROUP BY
    ->     l.Location_Name,
    ->     f.Congestion_Level
    -> ORDER BY
    ->     l.Location_Name,
    ->     Average_Congestion_Index DESC;
+------------------+------------------+-----------------+--------------------------+
| Location_Name    | Congestion_Level | Traffic_Records | Average_Congestion_Index |
+------------------+------------------+-----------------+--------------------------+
| Downtown         | Moderate         |              23 |                     7.42 |
| Downtown         | High             |              18 |                     6.94 |
| Downtown         | Low              |              14 |                     6.38 |
| Highway          | Moderate         |              26 |                     6.81 |
| Highway          | High             |              26 |                     6.40 |
| Highway          | Low              |              28 |                     4.85 |
| Industrial Area  | Moderate         |              15 |                     8.75 |
| Industrial Area  | Low              |              23 |                     6.22 |
| Industrial Area  | High             |              13 |                     5.37 |
| Residential Zone | High             |              14 |                     9.32 |
| Residential Zone | Low              |              25 |                     8.91 |
| Residential Zone | Moderate         |              20 |                     8.90 |
| Suburbs          | High             |              25 |                     5.40 |
| Suburbs          | Low              |              14 |                     5.35 |
| Suburbs          | Moderate         |              16 |                     5.25 |
+------------------+------------------+-----------------+--------------------------+
15 rows in set (0.00 sec)