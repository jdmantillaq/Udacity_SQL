-------------------------------------------------------------------------------
--  FULL OUTER JOIN
-------------------------------------------------------------------------------

--each account who has a sales rep and each sales rep that has an account
--(all of the columns in these returned rows will be full)
SELECT
	*
FROM
	accounts a
FULL OUTER JOIN sales_reps sr ON
	a.sales_rep_id = sr.id;

--but also each account that does not have a sales rep and each sales rep
--that does not have an account (some of the columns in these returned ROWS
--will be empty)

SELECT
	*
FROM
	accounts a
FULL OUTER JOIN sales_reps sr ON
	a.sales_rep_id = sr.id
WHERE
	a.sales_rep_id IS NULL
	OR sr.id IS NULL;

-------------------------------------------------------------------------------
--  JOINs with Comparison Operators
-------------------------------------------------------------------------------

-- Course Example:
SELECT
	o.id,
	o.occurred_at AS order_date,
	we.*
FROM
	orders o
LEFT JOIN web_events we
ON
	we.account_id = o.account_id
	AND we.occurred_at < o.occurred_at
WHERE date_trunc('month', o.occurred_at) = 
	(SELECT date_trunc('month', min(o.occurred_at)) FROM orders o)
ORDER BY o.account_id, o.occurred_at;


--Write a query that left joins the accounts TABLE
--and the sales_reps tables on each sale rep's ID number and joins it using the
--< comparison operator on accounts.primary_poc and sales_reps.name
SELECT
	a.name,
	a.primary_poc,
	sr.name
FROM
	accounts a
LEFT JOIN sales_reps sr ON
	a.sales_rep_id = sr.id
	AND a.primary_poc < sr.name;

-------------------------------------------------------------------------------
--  Self JOINs
-------------------------------------------------------------------------------

--Course Example: Which account made mutiple orders with 30 days.
--The join condition specifies that the account_id values in o1 and o2
--must be the same, and additionally, the occurred_at value in o2 must be
--greater than the occurred_at value in o1 but within 28 days of it.
--This is achieved USING the condition o2.occurred_at > o1.occurred_at
--AND o2.occurred_at <= o1.occurred_at + INTERVAL '28_days'.
SELECT
	o1.id o1_id,
	o1.account_id o1_account_id,
	o1.occurred_at o1_occurred_at,
	o2.id o2_id,
	o2.account_id o2_account_id,
	o2.occurred_at o2_occured_at
FROM
	orders o1
LEFT JOIN orders o2
ON
	o1.account_id = o2.account_id
	AND o2.occurred_at > o1.occurred_at
	AND o2.occurred_at <= o1.occurred_at + INTERVAL '28_days'
ORDER BY
	o1.account_id,
	o1.occurred_at

--Modify the query from the previous video, which is pre-populated in the
--SQL Explorer below, to perform the same interval analysis except for the
--web_events table.
--Also: change the interval to 1 day to find those web events that
--occurred after, but not more than 1 day after, another web event

SELECT
	we1.id we1_id,
	we1.account_id we1_acc,
	we1.occurred_at we1_occ,
	we1.id we2_id,
	we2.account_id we2_acc,
	we2.occurred_at we2_occ
FROM
web_events we1
LEFT JOIN web_events we2
ON we1.account_id = we2.account_id
AND we2.occurred_at > we1.occurred_at
AND we2.occurred_at <= we1.occurred_at + INTERVAL '1_days'
ORDER BY we1.account_id, we2.occurred_at;


-------------------------------------------------------------------------------
--  UNION (Stag table on top of another)
-------------------------------------------------------------------------------

--Write a query that uses UNION ALL on two instances (and selecting all columns)
--of the accounts table. Then inspect the results and answer the subsequent quiz.
WITH t1 AS (
SELECT * FROM accounts a1
UNION ALL 
SELECT * FROM accounts a2)
SELECT * FROM t1
;


--Add a WHERE clause to each of the tables that you unioned in the query above,
--filtering the first table where name equals Walmart and filtering the
--second table where name equals Disney.

WITH t1 AS (
SELECT * FROM accounts a1
where a1.name = 'Walmart'
UNION ALL 
SELECT * FROM accounts a2
where a2.name = 'Disney')
SELECT * FROM t1
;

--Perform the union in your first query (under the Appending Data via UNION header)
--in a common table expression and name it double_accounts. Then do a COUNT the
--number of times a name appears in the double_accounts table. If you do this
--correctly, your query results should have a count of 2 for each name.

WITH t1 AS (
SELECT * FROM accounts a1
UNION ALL 
SELECT * FROM accounts a2)
SELECT t1.name, count(*) FROM t1
GROUP BY 1
;

-------------------------------------------------------------------------------
--  Performance Tuning
-------------------------------------------------------------------------------

-- 1 Limit your aggregations with subqueries

--1. Aggregations
--2. FILTER
--3. Limit
SELECT o.account_id,
sum(o.total_amt_usd)
FROM orders o
WHERE o.occurred_at > '2016-01-01'
GROUP BY 1 
LIMIT 10;


-- Here teh results will run much more faster as the Limit is applied first
-- to the Suquery
SELECT o.account_id,
sum(o.total_amt_usd)
FROM (SELECT * FROM orders  LIMIT 100) AS o
WHERE o.occurred_at > '2016-01-01'
GROUP BY 1;



-- 2. Make the Joins less complicated: it is better to reduce table sizes
-- before joining them

SELECT a.name,
       COUNT(*) AS web_events
FROM accounts a 
JOIN web_events we 
ON we.account_id = a.id
GROUP BY 1
ORDER BY 2 DESC


SELECT a.name,
       sub.web_events
FROM (
    SELECT account_id,
           COUNT(*) AS web_events
    FROM web_events we 
    GROUP BY 1
) sub
JOIN accounts a
ON a.id = sub.account_id
ORDER BY 2 DESC



--3. Add EXPLAIN to get the query plan
--  The EXPLAIN statement is a powerful tool used to analyze and understand
--  how a database engine executes a query. It provides detailed information
--  about the steps the database takes to retrieve the requested data, which can
--  be invaluable for optimizing query performance.

EXPLAIN 
SELECT * FROM web_events we
WHERE we.occurred_at > '2016-01-01';


-- 4 Subqueries: advantages of aggregaring the tables in subqueries
-- and joining the preaggregated subqueries


-- The first query directly joins the accounts, orders, and web_events tables.
-- It uses the DATE_TRUNC function to truncate the occurred_at timestamps to
-- the day level, ensuring that the data is grouped by day.
-- The COUNT(DISTINCT ...) functions are used to count unique sales
-- representatives, orders, and web visits for each day. The results are
-- grouped by the truncated date and ordered in descending order.

SELECT DATE_TRUNC('day', o.occurred_at) AS date,
       COUNT(DISTINCT a.sales_rep_id) AS active_sales_reps,
       COUNT(DISTINCT o.id) AS orders,
       COUNT(DISTINCT we.id) AS web_visits
FROM accounts a
JOIN orders o
ON o.account_id = a.id
JOIN web_events we
ON DATE_TRUNC('day', we.occurred_at) = DATE_TRUNC('day', o.occurred_at)
GROUP BY 1
ORDER BY 1 DESC;

-- The second query breaks the aggregation into two subqueries before joining
-- them. The first subquery (orders) aggregates data from the accounts and orders
-- tables, counting active sales representatives and orders per day. The second
-- subquery (web_events) aggregates data from the web_events table, counting web
-- visits per day. These preaggregated subqueries are then joined using a
-- FULL JOIN on the truncated date, ensuring that all dates from both subqueries
-- are included in the final result. The COALESCE function is used to handle
-- dates that may appear in only one of the subqueries. The final result is
-- ordered by date in descending order.

SELECT
	COALESCE(orders.date,
	web_events.date) AS date,
	orders.active_sales_reps,
	orders.orders,
	web_events.web_visits
FROM
	(
	SELECT
		DATE_TRUNC('day',
		o.occurred_at) AS date,
		COUNT(a.sales_rep_id) AS active_sales_reps,
		COUNT(o.id) AS orders
	FROM
		accounts a
	JOIN orders o
    ON
		o.account_id = a.id
	GROUP BY
		1
) orders
FULL JOIN 
(
	SELECT
		DATE_TRUNC('day',
		we.occurred_at) AS date,
		COUNT(we.id) AS web_visits
	FROM
		web_events we
	GROUP BY
		1
) web_events
ON
	web_events.date = orders.date
ORDER BY
	1 DESC;