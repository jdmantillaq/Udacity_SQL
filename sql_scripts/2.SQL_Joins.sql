---------------------------------------------------------------------------
-- JOIN
---------------------------------------------------------------------------

SELECT *
FROM orders
JOIN accounts
ON orders.account_id = accounts.id;

--Try pulling all the data from the accounts table, and all the data from the orders table.
SELECT
	*
FROM
	accounts a
JOIN orders o ON
	a.id = o.account_id ;


--Try pulling standard_qty, gloss_qty, and poster_qty from the orders table, and the website
--and the primary_poc from the accounts table.
SELECT
	standard_qty,
	gloss_qty,
	poster_qty,
	a.website,
	a.primary_poc
FROM
	orders o
JOIN accounts a ON
	o.account_id = a.id;

---------------------------------------------------------------------------
-- JOIN Questions Part I
---------------------------------------------------------------------------

--Provide a table for all web_events associated with account name of Walmart.
--There should be three columns. Be sure to include the primary_poc, time OF
--the event, and the channel for each event. Additionally, you might choose
--to add a fourth column to assure only Walmart events were chosen.

SELECT
	a.primary_poc,
	we.occurred_at,
	we.channel,
	a.name
FROM
	web_events we
JOIN accounts a ON
	we.account_id = a.id
WHERE
	a.name = 'Walmart';


--Provide a table that provides the region for each sales_rep along WITH
--their associated accounts. Your final table should include three columns:
--the region name, the sales rep name, and the account name.
--Sort the accounts alphabetically (A-Z) according to account name.

SELECT
	r.name, sr.name, a.name
FROM
	sales_reps sr
JOIN region r ON
	sr.region_id = r.id
JOIN accounts a ON
	sr.id = a.sales_rep_id
ORDER BY a.name;



--Provide the name for each region for every order, as well as the account
--name and the unit price they paid (total_amt_usd/total) for the order.
--Your final table should have 3 columns: region name, account name,
--and unit price. A few accounts have 0 for total, so I divided
--by (total + 0.01) to assure not dividing by zero.

SELECT
	r.name reg_name, a.name acc_name, (o.total_amt_usd/(o.total+0.01)) unit_price
FROM
	orders o
JOIN accounts a ON
	o.account_id = a.id
JOIN sales_reps sr ON
	sr.id = a.sales_rep_id
JOIN region r ON
	r.id = sr.region_id;
--------------------------------------------------------------------------


--Provide a table that provides the region for each sales_rep along WITH
--their associated accounts. This time only for the Midwest region.
--Your final table should include three columns: the region name,
--the sales rep name, and the account name. Sort the accounts
--alphabetically (A-Z) according to account name.

SELECT
	r.name reg, sr.name sales_rep, a.name account
FROM
	sales_reps sr
JOIN region r ON
	sr.region_id = r.id
JOIN accounts a ON
sr.id = a.sales_rep_id
ORDER BY account;


--Provide a table that provides the region for each sales_rep along
--with their associated accounts. This time only for accounts where 
--the sales rep has a first name starting with S and in the Midwest 
--region. Your final table should include three columns: the region 
--name, the sales rep name, and the account name. Sort the accounts 
--alphabetically (A-Z) according to account name.

SELECT
	r.name reg,
	sr.name sales_rep,
	a.name account
FROM
	sales_reps sr
JOIN accounts a ON
	sr.id = a.sales_rep_id
	AND sr.name LIKE 'S%'
JOIN region r ON
	sr.region_id = r.id
	AND r.name = 'Midwest'
ORDER BY
	account;



--Provide a table that provides the region for each sales_rep along 
--with their associated accounts. This time only for accounts where 
--the sales rep has a last name starting with K and in the Midwest 
--region. Your final table should include three columns: the region 
--name, the sales rep name, and the account name. Sort the accounts 
--alphabetically (A-Z) according to account name.

SELECT
	r.name reg, sr.name sales_rep, a.name account
FROM
	sales_reps sr
JOIN region r ON
	sr.region_id = r.id
	AND (sr.name LIKE '% K%' AND r.name = 'Midwest')
JOIN accounts a ON
sr.id = a.sales_rep_id
ORDER BY account;


--Provide the name for each region for every order, as well as 
--the account name and the unit price they paid (total_amt_usd/total) 
--for the order. However, you should only provide the results 
--if the standard order quantity exceeds 100. Your final table 
--should have 3 columns: region name, account name, and unit price. 
--In order to avoid a division by zero error, adding .01 to the 
--denominator here is helpful total_amt_usd/(total+0.01).
SELECT
	r.name region,
	a.name account,
	(o.total_amt_usd /(o.total + 0.001)) unit_price,
	o.standard_qty
FROM
	orders o
JOIN accounts a ON
	o.account_id = a.id
	AND o.standard_qty > 100
JOIN sales_reps sr ON
	a.sales_rep_id = sr.id
JOIN region r ON
	sr.region_id = r.id;



--Provide the name for each region for every order, as well as 
--the account name and the unit price they paid (total_amt_usd/total) 
--for the order. However, you should only provide the results 
--if the standard order quantity exceeds 100 and the poster order 
--quantity exceeds 50. Your final table should have 3 columns: 
--region name, account name, and unit price. Sort for the smallest 
--unit price first. In order to avoid a division by zero error, 
--adding .01 to the denominator here is helpful (total_amt_usd/(total+0.01).

SELECT
	r.name region,
	a.name account,
	(o.total_amt_usd /(o.total + 0.001)) unit_price,
	o.standard_qty,
	o.poster_qty
FROM
	orders o
JOIN accounts a ON
	o.account_id = a.id
	AND (o.standard_qty > 100 AND o.poster_qty > 50)
JOIN sales_reps sr ON
	a.sales_rep_id = sr.id
JOIN region r ON
	sr.region_id = r.id
ORDER BY unit_price;


--What are the different channels used by account id 1001?
--Your final table should have only 2 columns: account name AND
--the different channels. You can try SELECT DISTINCT to narrow 
--down the results to only the unique values.
SELECT DISTINCT
	a.id,
	a.name,
	we.channel
FROM
	accounts a
JOIN web_events we ON
	a.id = we.account_id
	AND a.id = 1001;



--Find all the orders that occurred in 2015. Your final TABLE
--should have 4 columns: occurred_at, account name, order total,
--and order total_amt_usd.

SELECT
	o.occurred_at, a.name, o.total, o.total_amt_usd
FROM
	orders o
JOIN accounts a ON
	o.account_id = a.id
	AND o.occurred_at BETWEEN '2015-01-01' AND '2016-01-01'
ORDER BY o.occurred_at;




