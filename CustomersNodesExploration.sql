-- CASE STUDY CAN BE FOUND: https://8weeksqlchallenge.com/case-study-4/
-- A. CUSTOMER NODES EXPLORATION

-- 1. How many unique nodes are there on the Data Bank system?

SELECT 
COUNT (DISTINCT NODE_ID) AS UNIQUE_NODES_COUNT
FROM CUSTOMER_NODES;

-- 2. What is the number of nodes per region?

SELECT 
REGION_NAME,
COUNT(DISTINCT NODE_ID) AS NODES_PER_REGION
FROM CUSTOMER_NODES AS C
JOIN REGIONS AS R ON R.REGION_ID = C.REGION_ID
GROUP BY REGION_NAME
ORDER BY REGION_NAME ASC;

-- 3. How many customers are allocated to each region?

SELECT 
REGION_NAME,
COUNT (DISTINCT CUSTOMER_ID) AS CUSTOMER_COUNT
FROM CUSTOMER_NODES AS C
JOIN REGIONS AS R ON R.REGION_ID = C.REGION_ID
GROUP BY REGION_NAME
ORDER BY CUSTOMER_COUNT DESC;


-- 4. How many days on average are customers reallocated to a different node?


WITH CTE AS (
SELECT
CUSTOMER_ID,
NODE_ID,
SUM(DATEDIFF('days', START_DATE, END_DATE)) AS DAYS_NODE
FROM CUSTOMER_NODES
WHERE END_DATE != '9999-12-31'
GROUP BY CUSTOMER_ID, NODE_ID
ORDER BY CUSTOMER_ID ASC
)

SELECT 
ROUND(AVG(DAYS_NODE), 0) AS AVG_DAYS_IN_NODE
FROM CTE;

-- 5. What is the median, 80th and 95th percentile for this same reallocation days metric for each region?

WITH CTE AS (
SELECT
CUSTOMER_ID,
REGION_ID,
NODE_ID,
SUM(DATEDIFF('days', START_DATE, END_DATE)) AS DAYS_IN_NODE
FROM CUSTOMER_NODES
WHERE END_DATE != '9999-12-31'
GROUP BY CUSTOMER_ID, REGION_ID, NODE_ID
ORDER BY CUSTOMER_ID ASC
)

SELECT 
REGION_NAME,
ROUND(AVG(DAYS_IN_NODE), 0) AS AVG_DAYS_IN_NODE,
ROUND(MEDIAN (DAYS_IN_NODE), 0) AS MEDIAN_DAYS_IN_NODE,
PERCENTILE_CONT(0.8) WITHIN GROUP (ORDER BY DAYS_IN_NODE) AS PC_80_DAYS_IN_NODE,
PERCENTILE_CONT(0.95) WITHIN GROUP (ORDER BY DAYS_IN_NODE) AS PC_95_DAYS_IN_NODE
FROM CTE
JOIN REGIONS AS R ON R.REGION_ID = CTE.REGION_ID
GROUP BY REGION_NAME;
