-- Basic SQL
SELECT
	*
FROM
	accounts a;

-- Limit
SELECT
	*
FROM
	web_events we
LIMIT 10;

SELECT
	we.occurred_at,
	we.account_id,
	we.channel
FROM
	web_events we
LIMIT 15;


-- ORDER BY
-- Write a query to return the 10 earliest orders in the orders table. Include the id,
SELECT
	o.id,
	o.occurred_at,
	o.total_amt_usd
FROM
	orders o
ORDER BY
	o.occurred_at
LIMIT 10;


-- Write a query to return the top 5 orders in terms of largest total_amt_usd.
-- Include the id, account_id, and total_amt_usd.
SELECT
	o.id,
	o.account_id,
	o.total_amt_usd
FROM
	orders o
ORDER BY
	o.total_amt_usd DESC 
LIMIT 5;


-- Write a query to return the lowest 20 orders in terms of smallest total_amt_usd.
-- Include the id, account_id, and total_amt_usd.
SELECT
	o.id,
	o.account_id,
	o.total_amt_usd
FROM
	orders o
ORDER BY
	o.total_amt_usd 
LIMIT 20;


--Write a query that displays the order ID, account ID, and total dollar amount
--for all the orders, sorted first by the account ID (in ascending order),
--and then by the total dollar amount (in descending order).

SELECT
	o.id,
	o.account_id,
	o.total_amt_usd
FROM
	orders o
ORDER BY
	o.account_id, o.total_amt_usd DESC;

--Now write a query that again displays order ID, account ID, and total dollar
--amount for each order, but this time sorted first by total dollar amount
--(in descending order), and then by account ID (in ascending order).

SELECT
	o.id,
	o.account_id,
	o.total_amt_usd
FROM
	orders o
ORDER BY
	o.total_amt_usd DESC, o.account_id;


---------------------------------------------------------------------------
-- WHERE
---------------------------------------------------------------------------

--Pulls the first 5 rows and all columns from the orders table that have a 
--dollar amount of gloss_amt_usd greater than or equal to 1000.
SELECT * FROM orders WHERE gloss_amt_usd >= 1000 ORDER BY gloss_amt_usd LIMIT 5;


--Pulls the first 10 rows and all columns from the orders table that have a 
--total_amt_usd less than 500.
SELECT * FROM orders WHERE total_amt_usd < 500 ORDER BY total_amt_usd LIMIT 10;

--Filter the accounts table to include the company name, website, and the 
--primary point of contact (primary_poc) just for the Exxon Mobil company
--in the accounts table.

SELECT a.name, a.website, a.primary_poc  FROM accounts a WHERE a.name = 'Exxon Mobil';

---------------------------------------------------------------------------
-- Arithmetic Operations
---------------------------------------------------------------------------


--Create a column that divides the standard_amt_usd by the standard_qty to find the
--unit price for standard paper for each order. Limit the results to the first 10 orders,
--and include the id and account_id fields.
SELECT 
	id,
	account_id,
	standard_amt_usd/standard_qty AS unit_price_std
FROM
	orders o
LIMIT 10;


--Write a query that finds the percentage of revenue that comes from poster paper for 
--each order. You will need to use only the columns that end with _usd.
--(Try to do this without using the total column.) Display the id and account_id fields also.
--NOTE - you will receive an error with the correct solution to this question.
--This occurs because at least one of the values in the data creates a division by zero
--in your formula. You will learn later in the course how to fully handle this issue.
--For now, you can just limit your calculations to the first 10 orders, as we did in question
--#1, and you'll avoid that set of data that causes the problem.

SELECT 
	id,
	account_id,
	poster_amt_usd*100/(standard_amt_usd + gloss_amt_usd + poster_amt_usd) AS post_per
FROM
	orders o
WHERE poster_amt_usd != 0;

---------------------------------------------------------------------------
-- LIKE
---------------------------------------------------------------------------

--All the companies whose names start with 'C'.
SELECT * FROM accounts a WHERE a.name LIKE 'C%' OR a.name LIKE 'c%';

--All companies whose names contain the string 'one' somewhere in the name.
SELECT * FROM accounts a WHERE a.name LIKE '%one%';

--All companies whose names end with 's'.
SELECT * FROM accounts a WHERE a.name LIKE '%s' OR a.name LIKE '%S';

---------------------------------------------------------------------------
-- IN
---------------------------------------------------------------------------

--Use the accounts table to find the account name, primary_poc, and 
--sales_rep_id for Walmart, Target, and Nordstrom.
SELECT
	a.name,
	a.primary_poc,
	a.sales_rep_id
FROM
	accounts a
WHERE
	a.name IN ('Walmart', 'Target', 'Nordstrom');


--Use the web_events table to find all information regarding individuals who were contacted via the channel of organic or adwords.
SELECT
	*
FROM
	web_events we
WHERE
	we.channel IN ('organic', 'adwords');


---------------------------------------------------------------------------
-- NOT
---------------------------------------------------------------------------

--Use the accounts table to find the account name, primary poc, and sales rep id for 
--all stores except Walmart, Target, and Nordstrom.

SELECT
	a.name,
	a.primary_poc,
	a.sales_rep_id
FROM
	accounts a
WHERE
	a.name NOT IN ('Walmart', 'Target', 'Nordstrom');


--Use the web_events table to find all information regarding individuals who were contacted
--via any method except using organic or adwords methods.
SELECT
	*
FROM
	web_events we
WHERE
	we.channel NOT IN ('organic', 'adwords');

--All the companies whose names do not start with 'C'.
SELECT * FROM accounts a WHERE a.name NOT LIKE 'C%';

--All companies whose names do not contain the string 'one' somewhere in the name.
SELECT * FROM accounts a WHERE a.name NOT LIKE '%one%';


--All companies whose names do not end with 's'.
SELECT * FROM accounts a WHERE a.name NOT LIKE '%s';

---------------------------------------------------------------------------
-- AND and BETWEEN
---------------------------------------------------------------------------

--Write a query that returns all the orders where the standard_qty is over 1000,
--the poster_qty is 0, and the gloss_qty is 0.
SELECT
	*
FROM
	orders o
WHERE
	o.standard_qty > 1000
	AND poster_qty = 0
	AND gloss_qty = 0;

--Using the accounts table, find all the companies whose names do not start with 'C' and end with 's'.
SELECT
	*
FROM
	accounts a
WHERE
	a.name NOT LIKE 'C%'
	AND a.name NOT LIKE '%s';

--When you use the BETWEEN operator in SQL, do the results include the values of your
--endpoints, or not? Figure out the answer to this important question by writing a query
--that displays the order date and gloss_qty data for all orders where gloss_qty is BETWEEN
--24 and 29. Then look at your output to see if the BETWEEN operator included the begin and end values or not.
SELECT
	o.occurred_at,
	o.gloss_qty
FROM
	orders o
WHERE
	gloss_qty BETWEEN 24 AND 29;


--Use the web_events table to find all information regarding individuals who were contacted
--via the organic or adwords channels, and started their account at any point in 2016, sorted from newest to oldest.

SELECT
	*
FROM
	web_events we
WHERE
	we.channel IN ('organic', 'adwords')
	AND we.occurred_at BETWEEN '2016-01-01' AND '2017-01-01'
ORDER BY
	we.occurred_at;


---------------------------------------------------------------------------
-- OR
---------------------------------------------------------------------------

--Find list of orders ids where either gloss_qty or poster_qty is greater than 4000.
--Only include the id field in the resulting table.
SELECT
	o.id,
	gloss_qty,
	poster_qty
FROM
	orders o
WHERE gloss_qty > 4000 OR poster_qty > 4000;


--Write a query that returns a list of orders where the standard_qty is zero
--and either the gloss_qty or poster_qty is over 1000.
SELECT
	o.id,
	standard_qty,
	gloss_qty,
	poster_qty
FROM
	orders o
WHERE standard_qty = 0 AND (gloss_qty > 1000 OR poster_qty > 1000);

--Find all the company names that start with a 'C' or 'W', and the primary contact
--contains 'ana' or 'Ana', but it doesn't contain 'eana'.
SELECT
	a.name
FROM
	accounts a
WHERE
	(a.name LIKE 'C%'
		OR a.name LIKE 'W%')
	AND ((a.primary_poc LIKE '%ana%'
		OR a.primary_poc LIKE '%Ana%')
	AND a.primary_poc NOT LIKE '%eana%');




















