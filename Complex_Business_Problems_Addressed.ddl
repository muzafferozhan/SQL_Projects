'This project is made up of a workplace scenario where I will use SQL querying on company
data for various purposes to meet management\'s needs to make informed and data-driven decisions.'

'1) Descriptive Statistics for Monthly revenue by product using Subquery'
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

-----------------------------------------------------------------
| PRODUCTNAME | MIN_REV | MAX_REV | AVG_REV | STD_DEV_REV        |
------------------------------------------------------------------
| Basic       | 500     | 28000   | 13188   | 8123.763642197237  |
| Expert      | 3000    | 46000   | 18000   | 13796.134724383252 |
------------------------------------------------------------------

'Alternatively I can use a CTE to calculate the descriptive statistics for monthly revenue by 
product'

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

-----------------------------------------------------------------
| PRODUCTNAME | MIN_REV | MAX_REV | AVG_REV | STD_DEV_REV        |
------------------------------------------------------------------
| Basic       | 500     | 28000   | 13188   | 8123.763642197237  |
| Expert      | 3000    | 46000   | 18000   | 13796.134724383252 |
------------------------------------------------------------------

'2) We now need the number of clicks on a link in an email per user as an understanding of
how well an email marketing campaign is doing'

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

-------------------------------
| NUM_USERS | NUM_LINK_CLICKS |
-------------------------------
| 3         | 1               |
| 2         | 2               |
| 1         | 3               |
-------------------------------
' A subquery as follows also returns the same output.'

SELECT
    NUM_LINK_CLICKS,
    COUNT(userid) AS NUM_USERS
FROM (
    SELECT
        userid,
        COUNT(*) AS num_link_clicks
    FROM
        frontendeventlog el
    WHERE
        eventid = 5
    GROUP BY
        userid
) email_link_clicks
GROUP BY
    NUM_LINK_CLICKS;

-------------------------------
| NUM_LINK_CLICKS | NUM_USERS |
-------------------------------
| 1               | 3         |
| 2               | 2         |
| 3               | 1         |
-------------------------------