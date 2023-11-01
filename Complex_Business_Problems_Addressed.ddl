-- 1) Descriptive statistics using Sub-query
SELECT 
    ProductName,
    MIN(sum) as MIN_REV,
    MAX(sum) as MAX_REV,
    AVG(sum) as AVG_REV,
    STDDEV(sum) as STD_DEV_REV
FROM (
    SELECT
        p.PRODUCTID as Product_ID,
        p.PRODUCTNAME as ProductName,
        date_trunc('month', s.OrderDate) as date,
        SUM(s.REVENUE) as sum
    FROM
        subscriptions s
    JOIN
        products p
    ON
        s.ProductID = p.ProductID
    WHERE
        EXTRACT(YEAR FROM s.OrderDate) = 2022
    GROUP BY
        p.PRODUCTID, date_trunc('month', s.OrderDate)
) AS Subquery
GROUP BY ProductName;

-- 2) Descriptive statistics using CTE 

WITH Sum_Table AS (
    SELECT
        p.PRODUCTNAME as ProductName,
        date_trunc('month', s.OrderDate) as date,
        SUM(s.REVENUE) as sum
    FROM
        subscriptions s
    JOIN
        products p
    ON
        s.ProductID = p.ProductID
    WHERE
        EXTRACT(YEAR FROM s.OrderDate) = 2022
    GROUP BY
        p.ProductName, date_trunc('month', s.OrderDate)
)

SELECT 
    ProductName,
    MIN(sum) as MIN_REV,
    MAX(sum) as MAX_REV,
    AVG(sum) as AVG_REV,
    STDDEV(sum) as STD_DEV_REV
FROM Sum_Table
GROUP BY PRODUCTNAME;

--      3) Number of clicks on a link in an email per user 

WITH email_link_clicks as (
SELECT
userid,
count(*) as num_link_clicks
FROM
frontendeventlog el
WHERE 
eventid=5
GROUP BY
userid 
)

SELECT 
count(userid) as NUM_USERS,
NUM_LINK_CLICKS
FROM
email_link_clicks
GROUP BY
NUM_LINK_CLICKS
