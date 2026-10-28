 /* ASSIGNMENT 1 */
--Please write responses between the QUERY # and END QUERY blocks
/* SECTION 2 */


--SELECT
/* 1. Write a query that returns everything in the customer table. */
--QUERY 1
SELECT * FROM customer; 
-- bcs we want everything from the table, we use the *. select says what u wanna do (which is see/select), from customer is telling u where to get it from


--END QUERY


/* 2. Write a query that displays all of the columns and 10 rows from the customer table, 
sorted by customer_last_name, then customer_first_ name. */
--QUERY 2

SELECT * -- select every column
FROM customer -- from this table
ORDER BY customer_last_name, customer_first_name -- but we wanna order it by last name then first name 
LIMIT 10; --and we only wanna see 10 rows 


--END QUERY


--WHERE
/* 1. Write a query that returns all customer purchases of product IDs 4 and 9. 
Limit to 25 rows of output. */
--QUERY 3

SELECT * -- select every column
FROM customer_purchases -- from customer_purchase table
WHERE product_id = 4 OR product_id = 9 -- only wanna see purchases of product 4 and 9
LIMIT 25; -- only want to see 25 rows	


--END QUERY



/*2. Write a query that returns all customer purchases and a new calculated column 'price' (quantity * cost_per_quantity), 
filtered by customer IDs between 8 and 10 (inclusive) using either:
	1.  two conditions using AND
	2.  one condition using BETWEEN
Limit to 25 rows of output.
*/
--QUERY 4

SELECT *, quantity*cost_per_quantity AS price -- new price column
FROM customer_purchases -- from customer_purchases table
WHERE customer_id >= 8 AND customer_id <= 10 -- use and statment to make sure we get the customers between 8 and 10. 
LIMIT 25; -- only wanna see 25 output

--END QUERY


--CASE
/* 1. Products can be sold by the individual unit or by bulk measures like lbs. or oz. 
Using the product table, write a query that outputs the product_id and product_name
columns and add a column called prod_qty_type_condensed that displays the word “unit” 
if the product_qty_type is “unit,” and otherwise displays the word “bulk.” */
--QUERY 5

SELECT product_id, product_name, -- select these two columns, which are the ones we are interested in
	CASE 
		WHEN product_qty_type = 'unit' THEN 'unit' -- basically an if/else statement. when the product_qty_type (already exists) is a unit, we want to show it as 'unit'. if it is not, show it as 'bulk'
		ELSE 'bulk'
	END AS prod_qty_type_condensed -- new column name
FROM product; -- get the data from the product table 

--END QUERY


/* 2. We want to flag all of the different types of pepper products that are sold at the market. 
add a column to the previous query called pepper_flag that outputs a 1 if the product_name 
contains the word “pepper” (regardless of capitalization), and otherwise outputs 0. */
--QUERY 6


SELECT product_id, product_name, --question is asking us to add a column to the previous query, so we select the same two columns as before
	CASE -- previous case
		WHEN product_qty_type = 'unit' THEN 'unit' -- basically an if/else statement. when the product_qty_type (already exists) is a unit, we want to show it as 'unit'. if it is not, show it as 'bulk'
		ELSE 'bulk'
	END AS prod_qty_type_condensed, -- new column name
CASE -- new case: pepper 
	WHEN lower(product_name) LIKE '%pepper%' THEN 1 -- if the product name contains pepper, we want to flag it as 1
		ELSE 0 -- if it does not contain pepper, we want to flag it as 0
	END AS pepper_flag -- new column namew
FROM product; -- getting the data from the previous query, which called on the product table. 


--END QUERY


--JOIN
/* 1. Write a query that INNER JOINs the vendor table to the vendor_booth_assignments table on the 
vendor_id field they both have in common, and sorts the result by market_date, then vendor_name.
Limit to 24 rows of output. */
--QUERY 7

SELECT * 
FROM vendor -- from this table 
INNER JOIN vendor_booth_assignments ON vendor.vendor_id = vendor_booth_assignments.vendor_id -- we want to join the two tables based on the volumn they have in common (vendor_id)
ORDER BY vendor_booth_assignments.market_date, vendor.vendor_name -- and sort the results 
LIMIT 24;

--END QUERY



/* SECTION 3 */

-- AGGREGATE
/* 1. Write a query that determines how many times each vendor has rented a booth 
at the farmer’s market by counting the vendor booth assignments per vendor_id. */
--QUERY 8
SELECT vendor_id, -- the column we want to grou[ by]
       COUNT(*) AS booth_rentals -- count the number of booth rentals
FROM vendor_booth_assignments
GROUP BY vendor_id; -- group by the vendors so we count the number of rentals per vendor


--END QUERY


/* 2. The Farmer’s Market Customer Appreciation Committee wants to give a bumper 
sticker to everyone who has ever spent more than $2000 at the market. Write a query that generates a list 
of customers for them to give stickers to, sorted by last name, then first name. 

HINT: This query requires you to join two tables, use an aggregate function, and use the HAVING keyword. */
--QUERY 9

SELECT customer.customer_id, customer.customer_first_name, customer.customer_last_name,-- selecting coluumns we want from each table
    SUM(customer_purchases.quantity * customer_purchases.cost_per_quantity) AS total_spent -- the aggregate function; creating a new column calculating the total amount spent 
FROM customer -- table 1
INNER JOIN customer_purchases -- joiing this table to customer table 
    ON customer.customer_id = customer_purchases.customer_id -- column they have in common
GROUP BY customer.customer_id, customer.customer_first_name, customer.customer_last_name -- grouping
HAVING SUM(customer_purchases.quantity * customer_purchases.cost_per_quantity) > 2000 -- filters it so we only incldude the customers over 2000k
ORDER BY customer.customer_last_name, customer.customer_first_name;


--END QUERY


--Temp Table
/* 1. Insert the original vendor table into a temp.new_vendor and then add a 10th vendor: 
Thomass Superfood Store, a Fresh Focused store, owned by Thomas Rosenthal

HINT: This is two total queries -- first create the table from the original, then insert the new 10th vendor. 
When inserting the new vendor, you need to appropriately align the columns to be inserted 
(there are five columns to be inserted, I've given you the details, but not the syntax) 

-> To insert the new row use VALUES, specifying the value you want for each column:
VALUES(col1,col2,col3,col4,col5) 
*/
--QUERY 10
--1 create the temporary table (basically making a copy of the original vendor table)
CREATE TEMP TABLE new_vendor AS 
SELECT *
FROM vendor;

--2 insert the new vendor 
INSERT INTO new_vendor (vendor_id, vendor_name, vendor_type, vendor_owner_first_name, vendor_owner_last_name) -- these are the columns that we are inserting into new vendor
VALUES (10,'Thomass Superfood Store','Fresh Focused','Thomas','Rosenthal'); -- this is the data we want to insert 


--END QUERY


-- Date
/*1. Get the customer_id, month, and year (in separate columns) of every purchase in the customer_purchases table.

HINT: you might need to search for strfrtime modifers sqlite on the web to know what the modifers for month 
and year are! 
Limit to 25 rows of output. */
--QUERY 11

SELECT customer_id, STRFTIME('%m', market_date) AS month, STRFTIME('%Y', market_date) AS year -- selecting the customer_id, month, and year from the market_date column. using strftime to get the month and year in separate columns
FROM customer_purchases -- table
LIMIT 25; -- number of rows we wanna see 


--END QUERY


/* 2. Using the previous query as a base, determine how much money each customer spent in April 2022. 
Remember that money spent is quantity*cost_per_quantity. 

HINTS: you will need to AGGREGATE, GROUP BY, and filter...
but remember, STRFTIME returns a STRING for your WHERE statement...
AND be sure you remove the LIMIT from the previous query before aggregating!! */
--QUERY 12

SELECT customer_id, 
	SUM(quantity * cost_per_quantity) AS total_spent
FROM customer_purchases
WHERE STRFTIME('%m', market_date) = '04'
    AND STRFTIME('%Y', market_date) = '2022'
GROUP BY customer_id;


--END QUERY
