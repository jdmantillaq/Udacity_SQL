-------------------------------------------------------------------------------
--  Window Functions
-------------------------------------------------------------------------------
-- The provided SQL query demonstrates the use of a window function to
-- calculate a running total of the standard_qty column from the orders table.
SELECT o.standard_qty,
        sum(o.standard_qty) OVER (ORDER BY o.occurred_at) running_total -- window function
FROM orders o;

-- For each row in the output, the month column shows the month of the order,
-- the standard_qty column shows the quantity of the order, and the running_total
-- column shows the cumulative sum of standard_qty for the current month up to
-- and including the current row, ordered by the occurred_at column. 
SELECT
	date_trunc('month', o.occurred_at) AS month,
	o.standard_qty,
	sum(o.standard_qty) OVER (PARTITION BY date_trunc('month', o.occurred_at) 
						      ORDER BY o.occurred_at) running_total
	-- window function
FROM
	orders o;

--Create a running total of standard_amt_usd (in the orders table) over ORDER
--time with no date truncation. Your final table should have two columns:
--one with the amount being added for each new row, and a second with the
--running total.
SELECT
	o.occurred_at,
	o.standard_amt_usd,
	sum(o.standard_amt_usd) OVER (
	ORDER BY o.occurred_at) AS running_total
FROM
	orders o;

--Create a running total of standard_amt_usd (in the orders table) over order time,
--but this time, date truncate occurred_at by year and partition by that same
--year-truncated occurred_at variable. Your final table should have three columns:
--One with the amount being added for each row, one for the truncated date, and a
--final column with the running total within each year.
SELECT
	date_part('year', o.occurred_at),
	o.standard_amt_usd,
	sum(o.standard_amt_usd) OVER (PARTITION BY date_trunc('year', o.occurred_at) ORDER BY o.occurred_at) AS running_total
FROM
	orders o;


-------------------------------------------------------------------------------
--  ROW_NUMBER & RANK
-------------------------------------------------------------------------------

--Select the id, account_id, and total variable from the orders table, THEN
--create a column called total_rank that ranks this total amount of paper
--ordered (from highest to lowest) for each account using a partition.
--Your final table should have these four columns.

SELECT
	o.id,
	o.account_id,
	o.total,
	RANK() OVER (PARTITION BY o.id
	ORDER BY o.total DESC) AS total_rank
FROM
	orders o;


-------------------------------------------------------------------------------
--  AGGREGATES IN WINDOW FUNCTION
-------------------------------------------------------------------------------

-- Example
SELECT
	o.id,
	o.account_id,
	o.standard_qty,
	date_trunc('month', o.occurred_at),
	dense_rank() OVER (PARTITION BY account_id ORDER BY date_trunc('month', o.occurred_at)) AS DENSE_RANK,
	sum(o.standard_qty) OVER (PARTITION BY account_id ORDER BY date_trunc('month', o.occurred_at)) AS sum_std_qty,
	count(o.standard_qty) OVER (PARTITION BY account_id ORDER BY date_trunc('month', o.occurred_at)) AS count_std_qty,
	avg(o.standard_qty) OVER (PARTITION BY account_id ORDER BY date_trunc('month', o.occurred_at)) AS avg_std_qty,
	min(o.standard_qty) OVER (PARTITION BY account_id ORDER BY date_trunc('month', o.occurred_at)) AS min_std_qty,
	max(o.standard_qty) OVER (PARTITION BY account_id ORDER BY date_trunc('month', o.occurred_at)) AS max_std_qty
FROM
	orders o;

SELECT id,
       account_id,
       standard_qty,
       DATE_TRUNC('month', occurred_at) AS month,
       DENSE_RANK() OVER (PARTITION BY account_id) AS dense_rank,
       SUM(standard_qty) OVER (PARTITION BY account_id) AS sum_std_qty,
       COUNT(standard_qty) OVER (PARTITION BY account_id) AS count_std_qty,
       AVG(standard_qty) OVER (PARTITION BY account_id ) AS avg_std_qty,
       MIN(standard_qty) OVER (PARTITION BY account_id ) AS min_std_qty,
       MAX(standard_qty) OVER (PARTITION BY account_id ) AS max_std_qty
FROM orders

-------------------------------------------------------------------------------
--  Aliases for Multiple Window Functions
-------------------------------------------------------------------------------

SELECT id,
       account_id,
       standard_qty,
       DATE_TRUNC('month', occurred_at) AS month,
       DENSE_RANK() OVER w AS dense_rank,
       SUM(standard_qty) OVER w AS sum_std_qty,
       COUNT(standard_qty) OVER w AS count_std_qty,
       AVG(standard_qty) OVER w AS avg_std_qty,
       MIN(standard_qty) OVER w AS min_std_qty,
       MAX(standard_qty) OVER w AS max_std_qty
FROM orders
WINDOW w AS (PARTITION BY account_id ORDER BY date_trunc('month', occurred_at));


SELECT id,
       account_id,
       DATE_TRUNC('year',occurred_at) AS year,
       DENSE_RANK() OVER w AS dense_rank,
       total_amt_usd,
       SUM(total_amt_usd) OVER w AS sum_total_amt_usd,
       COUNT(total_amt_usd) OVER w AS count_total_amt_usd,
       AVG(total_amt_usd) OVER w AS avg_total_amt_usd,
       MIN(total_amt_usd) OVER w AS min_total_amt_usd,
       MAX(total_amt_usd) OVER w AS max_total_amt_usd
FROM orders
WINDOW w AS (PARTITION BY account_id ORDER BY DATE_TRUNC('year',occurred_at));

-------------------------------------------------------------------------------
--Comparing a Row to Previous Row
-------------------------------------------------------------------------------

WITH t1 AS (
SELECT
	o.account_id,
	sum(o.standard_qty) AS std_sum
FROM
	orders o
GROUP BY
	1)
SELECT
	t1.account_id,
	t1.std_sum,
	lag(t1.std_sum) OVER w AS LAG,
	lead(t1.std_sum) OVER w AS LEAD,
	t1.std_sum - lag(t1.std_sum) OVER w AS lag_diff,
	lead(t1.std_sum) OVER w - t1.std_sum AS lead_diff
FROM
	t1
WINDOW w AS (ORDER BY t1.std_sum)
;

--Imagine you're an analyst at Parch & Posey and you want to determine how the
--current order's total revenue ("total" meaning from sales of all types of paper)
--compares to the next order's total revenue.
WITH t1 AS (
SELECT
	o.occurred_at ,
	sum(o.total_amt_usd) AS total_amt_usd
FROM
	orders o
GROUP BY
	1)
SELECT t1.occurred_at,
		t1.total_amt_usd,
		lead(t1.total_amt_usd) OVER w - t1.total_amt_usd AS lead_diff
FROM t1
WINDOW w AS (ORDER BY t1.occurred_at);


-------------------------------------------------------------------------------
-- Percentiles NTILE()
-------------------------------------------------------------------------------

SELECT
	o.id,
	o.account_id,
    o.standard_qty,
    ntile(4) OVER w AS quartile,
    ntile(5) OVER w AS quintile,
    ntile(100) OVER w AS percentile
FROM
	orders o
WINDOW w AS (ORDER BY o.standard_qty)
ORDER BY o.standard_qty desc;

--Use the NTILE functionality to divide the accounts into 4 levels in terms OF
--the amount of standard_qty for their orders. Your resulting table should have
--the account_id, the occurred_at time for each order, the total amount OF
--standard_qty paper purchased, and one of four levels in a standard_quartile column.

SELECT o.account_id,
		o.occurred_at,
		o.standard_qty,
NTILE(4) OVER (PARTITION BY account_id ORDER BY standard_qty) AS standard_quartile
FROM orders o
ORDER BY account_id;

--Use the NTILE functionality to divide the accounts into two levels in terms
--of the amount of gloss_qty for their orders. Your resulting table should have
--the account_id, the occurred_at time for each order, the total amount of gloss_qty
--paper purchased, and one of two levels in a gloss_half column.
SELECT o.account_id,
		o.occurred_at,
		o.gloss_qty,
NTILE(2) OVER (PARTITION BY account_id ORDER BY gloss_qty) AS gloss_half
FROM orders o
ORDER BY account_id;

--Use the NTILE functionality to divide the orders for each account into 100 levels
--in terms of the amount of total_amt_usd for their orders. Your resulting TABLE
--should have the account_id, the occurred_at time for each order, the total amount
--of total_amt_usd paper purchased, and one of 100 levels in a total_percentile column.

SELECT
	o.account_id,
	o.occurred_at,
	o.total_amt_usd ,
	NTILE(100) OVER (PARTITION BY account_id ORDER BY o.total_amt_usd) AS percentile
FROM
	orders o
ORDER BY
	account_id;

-------------------------------------------------------------------------------
-- Ejercicios
-------------------------------------------------------------------------------

--Use COUNT() as a window function to count how many events each account_id has.
SELECT o.account_id,
	o.occurred_at,
	count(*) OVER (PARTITION BY o.account_id ORDER BY o.occurred_at) FROM orders o;

--Use RANK() to assign a ranking to events within each account_id, ordered by
--occurred_at.
SELECT o.account_id,
	o.occurred_at,
	RANK() OVER (PARTITION BY o.account_id ORDER BY o.occurred_at) FROM orders o;


--Use LAG() to get the timestamp of the previous event for each account_id.
SELECT o.account_id,
	o.occurred_at,
	lag(o.occurred_at) OVER (PARTITION BY o.account_id ORDER BY o.occurred_at) FROM orders o;

--Use LEAD() to get the timestamp of the next event for each account_id.
SELECT o.account_id,
	o.occurred_at,
	lead(o.occurred_at) OVER (PARTITION BY o.account_id ORDER BY o.occurred_at) FROM orders o;

--Use lead() and occurred_at to calculate the time difference between each
--event for an account.
SELECT o.account_id,
	o.occurred_at,
	lead(o.occurred_at) OVER (PARTITION BY o.account_id ORDER BY o.occurred_at) AS LEAD,
	lead(o.occurred_at) OVER (PARTITION BY o.account_id ORDER BY o.occurred_at)- o.occurred_at AS lead_diff
FROM orders o;

--Use AVG() as a window function to calculate the average id in a window of
--3 previous events.
SELECT
	account_id,
		occurred_at,
		total_amt_usd,
	AVG(total_amt_usd) OVER w AS moving_avg_total
FROM
	orders
WINDOW w AS (PARTITION BY account_id
ORDER BY
	occurred_at ROWS BETWEEN 3 PRECEDING AND CURRENT ROW);

SELECT
	account_id,
		occurred_at,
		total_amt_usd,
	AVG(total_amt_usd) OVER w AS moving_avg_total
FROM
	orders
WINDOW w AS (PARTITION BY account_id
ORDER BY
	occurred_at ROWS BETWEEN 1 PRECEDING AND 1 FOLLOWING);













