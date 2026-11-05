/* ASSIGNMENT 2 */
--Please write responses between the QUERY # and END QUERY blocks
/* SECTION 2 */

-- COALESCE
/* 1. Our favourite manager wants a detailed long list of products, but is afraid of tables! 
We tell them, no problem! We can produce a list with all of the appropriate details. 

Using the following syntax you create our super cool and not at all needy manager a list:

SELECT 
product_name || ', ' || product_size|| ' (' || product_qty_type || ')'
FROM product


But wait! The product table has some bad data (a few NULL values). 
Find the NULLs and then using COALESCE, replace the NULL with a blank for the first column with
nulls, and 'unit' for the second column with nulls. 

**HINT**: keep the syntax the same, but edited the correct components with the string. 
The `||` values concatenate the columns into strings. 
Edit the appropriate columns -- you're making two edits -- and the NULL rows will be fixed. 
All the other rows will remain the same. */
--QUERY 1

SELECT
    product_name || ', ' || -- selecting the product name and adding a comma after it
    COALESCE(product_size, '') || ' (' || -- if product_size is null, we wanna replace it with a blank. then add an opening bracket
    COALESCE(product_qty_type, 'unit') || ')' -- if product_qty_type is null, we want it to say unit instead. then close the bracket
FROM product; -- getting the data from the product table
--END QUERY


--Windowed Functions
/* 1. Write a query that selects from the customer_purchases table and numbers each customer’s  
visits to the farmer’s market (labeling each market date with a different number). 
Each customer’s first visit is labeled 1, second visit is labeled 2, etc. 

You can either display all rows in the customer_purchases table, with the counter changing on
each new market date for each customer, or select only the unique market dates per customer 
(without purchase details) and number those visits. 
HINT: One of these approaches uses ROW_NUMBER() and one uses DENSE_RANK(). 
Filter the visits to dates before April 29, 2022. */
--QUERY 2

SELECT
    customer_id, -- selecting the customer id
    market_date, -- selecting the date they went to the market
    DENSE_RANK() OVER ( -- using dense_rank to give each visit a number (customers may buy multiple products on the same day, so we want to count that as one visit)
        PARTITION BY customer_id -- basically grouping by customer so each customer starts at 1
        ORDER BY market_date -- ordering by date so their first visit is 1, second is 2, etc
    ) AS visit_number -- naming the new column visit_number
FROM customer_purchases -- getting the data from this table
WHERE market_date < '2022-04-29'; -- only wanna include visits before april 29 2022



--END QUERY


/* 2. Reverse the numbering of the query so each customer’s most recent visit is labeled 1, 
then write another query that uses this one as a subquery (or temp table) and filters the results to 
only the customer’s most recent visit.
HINT: Do not use the previous visit dates filter. */
--QUERY 3
--1--
SELECT
    customer_id, -- selecting customer id
    market_date, -- selecting the date
    DENSE_RANK() OVER ( -- numbering the visits again
        PARTITION BY customer_id -- doing this separately for each customer
        ORDER BY market_date DESC -- descending order, so the most recent visit is now 1
    ) AS visit_number -- naming our new column
FROM customer_purchases; -- getting the data from this table
--2-- (only the most recenbt visit)
WITH visits AS ( -- creating a temporary result that we can use in the next query
    SELECT
        customer_id, -- selecting the customer id
        market_date, -- selecting the date
        DENSE_RANK() OVER ( -- numbering each customer's visits
            PARTITION BY customer_id -- restarting the count for each customer
            ORDER BY market_date DESC -- putting their most recent visit first
        ) AS visit_number -- new column for the visit number
    FROM customer_purchases -- getting data from this table
)
SELECT DISTINCT -- selecting only unique rows, bcs one customer might buy multiple things on the same date
    customer_id,
    market_date,
    visit_number
FROM visits -- getting our results from the temporary table we made above
WHERE visit_number = 1; -- only wanna see the most recent visit for each customer


--END QUERY


/* 3. Using a COUNT() window function, include a value along with each row of the 
customer_purchases table that indicates how many different times that customer has purchased that product_id. 

You can make this a running count by including an ORDER BY within the PARTITION BY if desired.
Filter the visits to dates before April 29, 2022. */
--QUERY 4


SELECT
    *, -- selecting every column
    COUNT(*) OVER ( -- counting the number of times a product was purchased
        PARTITION BY customer_id, product_id -- basically grouping by both customer and product, so we get a separate count for each combination
    ) AS purchase_count -- naming the new column
FROM customer_purchases -- getting the data from this table
WHERE market_date < '2022-04-29'; -- only including purchases before april 29 2022


--END QUERY


-- String manipulations
/* 1. Some product names in the product table have descriptions like "Jar" or "Organic". 
These are separated from the product name with a hyphen. 
Create a column using SUBSTR (and a couple of other commands) that captures these, but is otherwise NULL. 
Remove any trailing or leading whitespaces. Don't just use a case statement for each product! 

| product_name               | description |
|----------------------------|-------------|
| Habanero Peppers - Organic | Organic     |

Hint: you might need to use INSTR(product_name,'-') to find the hyphens. INSTR will help split the column. */
--QUERY 5

SELECT
    product_name, -- selecting the product name
    CASE -- basically an if/else statement
        WHEN INSTR(product_name, '-') > 0 -- checking if there's a hyphen somewhere in the product name
        THEN TRIM( -- removing any extra spaces at the beginning or end
            SUBSTR(
                product_name, -- looking at the product name
                INSTR(product_name, '-') + 1 -- finding the hyphen and starting right after it
            )
        )
        ELSE NULL -- if there's no hyphen, we don't have a description, so return null
    END AS description -- creating a new column called description
FROM product; -- getting the data from the product table


--END QUERY


/* 2. Filter the query to show any product_size value that contain a number with REGEXP. */
--QUERY 6
SELECT * -- selecting every column
FROM product -- from the product table
WHERE product_size REGEXP '[0-9]'; -- only wanna see products where the size contains a number. [0-9] means any number from 0 to 9

--END QUERY


-- UNION
/* 1. Using a UNION, write a query that displays the market dates with the highest and lowest total sales.

HINT: There are a possibly a few ways to do this query, but if you're struggling, try the following: 
1) Create a CTE/Temp Table to find sales values grouped dates; 
2) Create another CTE/Temp table with a rank windowed function on the previous query to create 
"best day" and "worst day"; 
3) Query the second temp table twice, once for the best day, once for the worst day, 
with a UNION binding them. */
--QUERY 7


WITH daily_sales AS ( -- creating a temporary result to calculate total sales for each date
    SELECT
        market_date, -- selecting the market date
        SUM(quantity * cost_per_quantity) AS total_sales -- calculating total sales by multiplying quantity and price, then adding everything together
    FROM customer_purchases -- getting the data from this table
    GROUP BY market_date -- grouping by date so we get one total for each market day
),

ranked_sales AS ( -- creating another temporary result to rank the sales dates
    SELECT
        market_date, -- selecting the date
        total_sales, -- selecting the total sales we calculated above
        RANK() OVER (ORDER BY total_sales DESC) AS highest_rank, -- ranking from highest to lowest, so the best day is 1
        RANK() OVER (ORDER BY total_sales ASC) AS lowest_rank -- ranking from lowest to highest, so the worst day is 1
    FROM daily_sales -- using the results from our first temporary table
)

SELECT
    market_date, -- selecting the date
    total_sales, -- selecting the total sales
    'Highest' AS sales_type -- adding a column to show that this is the highest sales day
FROM ranked_sales -- getting the data from our ranked results
WHERE highest_rank = 1 -- only wanna see the highest ranked day

UNION -- combining the results of the two queries into one table

SELECT
    market_date, -- selecting the date
    total_sales, -- selecting total sales
    'Lowest' AS sales_type -- showing that this is the lowest sales day
FROM ranked_sales -- using the same ranked results
WHERE lowest_rank = 1; -- only wanna see the lowest ranked day

--END QUERY



/* SECTION 3 */

-- Cross Join
/*1. Suppose every vendor in the `vendor_inventory` table had 5 of each of their products to sell to **every** 
customer on record. How much money would each vendor make per product? 
Show this by vendor_name and product name, rather than using the IDs.

HINT: Be sure you select only relevant columns and rows. 
Remember, CROSS JOIN will explode your table rows, so CROSS JOIN should likely be a subquery. 
Think a bit about the row counts: how many distinct vendors, product names are there (x)?
How many customers are there (y). 
Before your final group by you should have the product of those two queries (x*y).  */
--QUERY 8

WITH daily_sales AS ( -- creating a temporary result to calculate total sales for each date
    SELECT
        market_date, -- selecting the market date
        SUM(quantity * cost_per_quantity) AS total_sales -- calculating total sales by multiplying quantity and price, then adding everything together
    FROM customer_purchases -- getting the data from this table
    GROUP BY market_date -- grouping by date so we get one total for each market day
),

ranked_sales AS ( -- creating another temporary result to rank the sales dates
    SELECT
        market_date, -- selecting the date
        total_sales, -- selecting the total sales we calculated above
        RANK() OVER (ORDER BY total_sales DESC) AS highest_rank, -- ranking from highest to lowest, so the best day is 1
        RANK() OVER (ORDER BY total_sales ASC) AS lowest_rank -- ranking from lowest to highest, so the worst day is 1
    FROM daily_sales -- using the results from our first temporary table
)

SELECT
    market_date, -- selecting the date
    total_sales, -- selecting the total sales
    'Highest' AS sales_type -- adding a column to show that this is the highest sales day
FROM ranked_sales -- getting the data from our ranked results
WHERE highest_rank = 1 -- only wanna see the highest ranked day

UNION -- combining the results of the two queries into one table

SELECT
    market_date, -- selecting the date
    total_sales, -- selecting total sales
    'Lowest' AS sales_type -- showing that this is the lowest sales day
FROM ranked_sales -- using the same ranked results
WHERE lowest_rank = 1; -- only wanna see the lowest ranked day


--END QUERY


-- INSERT
/*1.  Create a new table "product_units". 
This table will contain only products where the `product_qty_type = 'unit'`. 
It should use all of the columns from the product table, as well as a new column for the `CURRENT_TIMESTAMP`.  
Name the timestamp column `snapshot_timestamp`. */
--QUERY 9

CREATE TABLE product_units AS -- creating a new table called product_units
SELECT
    *, -- selecting all the columns from the original product table
    CURRENT_TIMESTAMP AS snapshot_timestamp -- adding a new column showing when we created the record
FROM product -- getting the data from the product table
WHERE product_qty_type = 'unit'; -- only wanna include products that are sold by unit


--END QUERY


/*2. Using `INSERT`, add a new row to the product_units table (with an updated timestamp). 
This can be any product you desire (e.g. add another record for Apple Pie). */
--QUERY 10

INSERT INTO product_units -- adding a new row to the table we just created
SELECT
    product.*, -- selecting all the original product information
    CURRENT_TIMESTAMP AS snapshot_timestamp -- giving the new record the current timestamp
FROM product -- getting the data from the original product table
WHERE product_name = 'Apple Pie'; -- only wanna insert the apple pie product


--END QUERY


-- DELETE
/* 1. Delete the older record for whatever product you added. 

HINT: If you don't specify a WHERE clause, you are going to have a bad time.*/
--QUERY 11


DELETE FROM product_units -- deleting from our new table
WHERE rowid = (
    SELECT rowid -- finding the specific row we wanna delete
    FROM product_units
    WHERE product_id = 7 -- only looking at apple pie
    ORDER BY snapshot_timestamp ASC, rowid ASC -- oldest record first, using rowid if timestamps match
    LIMIT 1 -- only deleting one record
)
AND product_id = 7; -- making sure we only delete apple pie
--END QUERY


-- UPDATE
/* 1.We want to add the current_quantity to the product_units table. 
First, add a new column, current_quantity to the table using the following syntax.

ALTER TABLE product_units
ADD current_quantity INT;

Then, using UPDATE, change the current_quantity equal to the last quantity value from the vendor_inventory details.

HINT: This one is pretty hard. 
First, determine how to get the "last" quantity per product. 
Second, coalesce null values to 0 (if you don't have null values, figure out how to rearrange your query so you do.) 
Third, SET current_quantity = (...your select statement...), remembering that WHERE can only accommodate one column. 
Finally, make sure you have a WHERE statement to update the right row, 
	you'll need to use product_units.product_id to refer to the correct row within the product_units table. 
When you have all of these components, you can run the update statement. */
--QUERY 12



ALTER TABLE product_units -- changing our existing table
ADD current_quantity INT; -- adding a new column to store the current quantity

UPDATE product_units -- updating the table we just changed
SET current_quantity = COALESCE( -- setting the quantity, and replacing null values with 0
    (
        SELECT vi.quantity -- selecting the quantity from vendor_inventory
        FROM vendor_inventory AS vi -- using vi as a shorter name for the table
        WHERE vi.product_id = product_units.product_id -- matching the product ids so we get the right quantity for each product
        ORDER BY vi.market_date DESC -- sorting by date so the most recent inventory is first
        LIMIT 1 -- only wanna use the last quantity recorded
    ),
    0 -- if there's no matching inventory, we wanna put 0 instead of null
)
WHERE product_units.product_id IS NOT NULL; -- only updating rows that have a product id


--END QUERY



