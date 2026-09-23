USE employee_attrition_db;

-- Table validation
SELECT 'DimEmployee' AS Table_Name, COUNT(*) AS Record_Count
FROM DimEmployee
UNION ALL
SELECT 'FactEmployeePerformance', COUNT(*)
FROM FactEmployeePerformance
UNION ALL
SELECT 'DimAttrition', COUNT(*)
FROM DimAttrition;


-- Workforce overview
SELECT
    COUNT(*) AS Total_Employees,
    ROUND(AVG(Age), 2) AS Average_Age,
    ROUND(AVG(Job_Tenure), 2) AS Average_Tenure,
    ROUND(AVG(Distance_From_Home), 2) AS Average_Distance_From_Home
FROM DimEmployee;


-- Department performance
SELECT
    e.Department,
    COUNT(e.Employee_ID) AS Employee_Count,
    ROUND(AVG(f.Performance_Rating), 2) AS Average_Performance_Rating,
    ROUND(AVG(f.Overall_Satisfaction), 2) AS Average_Satisfaction,
    ROUND(AVG(f.Training_Hours), 2) AS Average_Training_Hours
FROM DimEmployee e
JOIN FactEmployeePerformance f
    ON e.Employee_ID = f.Employee_ID
GROUP BY e.Department
ORDER BY Average_Performance_Rating DESC;


-- Performance rating distribution
SELECT
    Performance_Rating,
    COUNT(*) AS Employee_Count,
    ROUND(
        COUNT(*) * 100.0 /
        (SELECT COUNT(*) FROM FactEmployeePerformance),
        2
    ) AS Percentage
FROM FactEmployeePerformance
GROUP BY Performance_Rating
ORDER BY Performance_Rating;


-- Performance category distribution
SELECT
    Performance_Category,
    COUNT(*) AS Employee_Count,
    ROUND(
        COUNT(*) * 100.0 /
        (SELECT COUNT(*) FROM FactEmployeePerformance),
        2
    ) AS Percentage
FROM FactEmployeePerformance
GROUP BY Performance_Category
ORDER BY Employee_Count DESC;


-- Overall satisfaction summary
SELECT
    ROUND(AVG(Overall_Satisfaction), 2) AS Average_Overall_Satisfaction,
    MIN(Overall_Satisfaction) AS Minimum_Satisfaction,
    MAX(Overall_Satisfaction) AS Maximum_Satisfaction
FROM FactEmployeePerformance;


-- Work-life balance and job satisfaction
SELECT
    Work_Life_Balance,
    COUNT(*) AS Employee_Count,
    ROUND(AVG(Job_Satisfaction), 2) AS Average_Job_Satisfaction
FROM FactEmployeePerformance
GROUP BY Work_Life_Balance
ORDER BY Work_Life_Balance;


-- Observed attrition and retention
SELECT
    COUNT(*) AS Total_Attrition_Records,
    SUM(CASE WHEN Attrition = 'True' THEN 1 ELSE 0 END) AS Attrition_Count,
    SUM(CASE WHEN Attrition = 'False' THEN 1 ELSE 0 END) AS Retained_Count,
    ROUND(
        SUM(CASE WHEN Attrition = 'True' THEN 1 ELSE 0 END) * 100.0 /
        COUNT(*),
        2
    ) AS Observed_Attrition_Rate,
    ROUND(
        SUM(CASE WHEN Attrition = 'False' THEN 1 ELSE 0 END) * 100.0 /
        COUNT(*),
        2
    ) AS Observed_Retention_Rate
FROM DimAttrition;


-- Observed attrition by department
SELECT
    e.Department,
    COUNT(a.Employee_ID) AS Attrition_Records,
    SUM(CASE WHEN a.Attrition = 'True' THEN 1 ELSE 0 END) AS Attrition_Count,
    ROUND(
        SUM(CASE WHEN a.Attrition = 'True' THEN 1 ELSE 0 END) * 100.0 /
        COUNT(a.Employee_ID),
        2
    ) AS Observed_Attrition_Rate
FROM DimEmployee e
JOIN DimAttrition a
    ON e.Employee_ID = a.Employee_ID
GROUP BY e.Department
ORDER BY Observed_Attrition_Rate DESC;


-- Observed attrition by tenure category
SELECT
    e.Tenure_Category,
    COUNT(a.Employee_ID) AS Attrition_Records,
    SUM(CASE WHEN a.Attrition = 'True' THEN 1 ELSE 0 END) AS Attrition_Count,
    ROUND(
        SUM(CASE WHEN a.Attrition = 'True' THEN 1 ELSE 0 END) * 100.0 /
        COUNT(a.Employee_ID),
        2
    ) AS Observed_Attrition_Rate
FROM DimEmployee e
JOIN DimAttrition a
    ON e.Employee_ID = a.Employee_ID
GROUP BY e.Tenure_Category
ORDER BY
    CASE e.Tenure_Category
        WHEN '0-5 Years' THEN 1
        WHEN '6-10 Years' THEN 2
        WHEN '11-15 Years' THEN 3
        WHEN '16-20 Years' THEN 4
    END;


-- Observed attrition by satisfaction band
SELECT
    CASE
        WHEN f.Overall_Satisfaction < 2 THEN '1-<2'
        WHEN f.Overall_Satisfaction < 3 THEN '2-<3'
        WHEN f.Overall_Satisfaction < 4 THEN '3-<4'
        ELSE '4-5'
    END AS Satisfaction_Category,
    COUNT(a.Employee_ID) AS Attrition_Records,
    SUM(CASE WHEN a.Attrition = 'True' THEN 1 ELSE 0 END) AS Attrition_Count,
    ROUND(
        SUM(CASE WHEN a.Attrition = 'True' THEN 1 ELSE 0 END) * 100.0 /
        COUNT(a.Employee_ID),
        2
    ) AS Observed_Attrition_Rate
FROM FactEmployeePerformance f
JOIN DimAttrition a
    ON f.Employee_ID = a.Employee_ID
GROUP BY Satisfaction_Category
ORDER BY Satisfaction_Category;


-- Observed attrition by performance category
SELECT
    f.Performance_Category,
    COUNT(a.Employee_ID) AS Attrition_Records,
    SUM(CASE WHEN a.Attrition = 'True' THEN 1 ELSE 0 END) AS Attrition_Count,
    ROUND(
        SUM(CASE WHEN a.Attrition = 'True' THEN 1 ELSE 0 END) * 100.0 /
        COUNT(a.Employee_ID),
        2
    ) AS Observed_Attrition_Rate
FROM FactEmployeePerformance f
JOIN DimAttrition a
    ON f.Employee_ID = a.Employee_ID
GROUP BY f.Performance_Category
ORDER BY Observed_Attrition_Rate DESC;


-- Exit interview score distribution
SELECT
    Exit_Interview_Score,
    COUNT(*) AS Employee_Count,
    ROUND(
        COUNT(*) * 100.0 /
        (SELECT COUNT(*)
         FROM DimAttrition
         WHERE Exit_Interview_Score IS NOT NULL),
        2
    ) AS Percentage
FROM DimAttrition
WHERE Exit_Interview_Score IS NOT NULL
GROUP BY Exit_Interview_Score
ORDER BY Exit_Interview_Score;


-- Training hours vs performance and satisfaction
SELECT
    CASE
        WHEN Training_Hours < 50 THEN '0-49 Hours'
        WHEN Training_Hours < 100 THEN '50-99 Hours'
        WHEN Training_Hours < 150 THEN '100-149 Hours'
        ELSE '150-200 Hours'
    END AS Training_Category,
    COUNT(*) AS Employee_Count,
    ROUND(AVG(Performance_Rating), 2) AS Average_Performance_Rating,
    ROUND(AVG(Overall_Satisfaction), 2) AS Average_Satisfaction
FROM FactEmployeePerformance
GROUP BY Training_Category
ORDER BY
    CASE Training_Category
        WHEN '0-49 Hours' THEN 1
        WHEN '50-99 Hours' THEN 2
        WHEN '100-149 Hours' THEN 3
        WHEN '150-200 Hours' THEN 4
    END;


-- Promotion recency vs performance and satisfaction
SELECT
    CASE
        WHEN Years_Since_Promotion <= 2 THEN '0-2 Years'
        WHEN Years_Since_Promotion <= 5 THEN '3-5 Years'
        WHEN Years_Since_Promotion <= 10 THEN '6-10 Years'
        ELSE '11-14 Years'
    END AS Promotion_Recency_Category,
    COUNT(*) AS Employee_Count,
    ROUND(AVG(Performance_Rating), 2) AS Average_Performance_Rating,
    ROUND(AVG(Overall_Satisfaction), 2) AS Average_Satisfaction
FROM FactEmployeePerformance
GROUP BY Promotion_Recency_Category
ORDER BY
    CASE Promotion_Recency_Category
        WHEN '0-2 Years' THEN 1
        WHEN '3-5 Years' THEN 2
        WHEN '6-10 Years' THEN 3
        WHEN '11-14 Years' THEN 4
    END;