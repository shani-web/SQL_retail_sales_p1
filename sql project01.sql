--SQL Retail Sales Analysis
--CREATE DATABASE
CREATE DATABASE sql_project_01;


--Create Table
CREATE TABLE retail_sales
            (
                transaction_id INT PRIMARY KEY,	
                sale_date DATE,	 
                sale_time TIME,	
                customer_id	INT,
                gender	VARCHAR(15),
                age	INT,
                category VARCHAR(15),	
                quantity	INT,
                price_per_unit FLOAT,	
                cogs	FLOAT,
                total_sale FLOAT
            );

-- DATA EXPLORATION--

select * from retail_sales
limit 20


-- How many sales we have?
SELECT COUNT(*) as total_sale FROM retail_sales

-- How many uniuque customers we have ?

SELECT COUNT(DISTINCT customer_id) as total_sale FROM retail_sales

-- How many unique category we Have?
SELECT DISTINCT category FROM retail_sales

--Any Nulls we have?
SELECT * FROM retail_sales
WHERE 
    transaction_id IS NULL
    OR
    sale_date IS NULL
    OR 
    sale_time IS NULL
    OR
    gender IS NULL
    OR
    category IS NULL
    OR
    quantity IS NULL
    OR
    cogs IS NULL
    OR
    total_sale IS NULL;

--DATA CLEANING--


DELETE FROM retail_sales
WHERE 
    transaction_id IS NULL
    OR
    sale_date IS NULL
    OR 
    sale_time IS NULL
    OR
    gender IS NULL
    OR
    category IS NULL
    OR
    quantity IS NULL
    OR
    cogs IS NULL
    OR
    total_sale IS NULL;

-- How many sales we have after cleaning?
SELECT COUNT(*) as total_sale FROM retail_sales



-- Data Analysis & Business Key Problems & Answers

-- My Analysis & Findings
-- Q.1 Write a SQL query to retrieve all columns for sales made on '2022-11-05
-- Q.2 Write a SQL query to retrieve all transactions where the category is 'Clothing' and the quantity sold is more than 3 in the month of Nov-2022
-- Q.3 Write a SQL query to calculate the total sales (total_sale) for each category.
-- Q.4 Write a SQL query to find the average age of customers who purchased items from the 'Electronics' category.
-- Q.5 Write a SQL query to find all transactions where the total_sale is greater than 1000 and Gender is Female, sort the results
-- by Category in ascending order
-- Q.6 Write a SQL query to find the total number of transactions (transaction_id) made by each gender in each category.
-- Q.7 Write a SQL query to calculate the average sale for each month. Find out best selling month in each year
-- Q.8 Write a SQL query to find the top 5 customers based on the highest total sales 
-- Q.9 Write a SQL query to find the number of unique customers who purchased items from each category.
-- Q.10 Write a SQL query to create each shift and number of orders (Example Morning <=12, Afternoon Between 12 & 17, Evening >17)
-- Q.11 Write a SQl query to add a computed column that shows the total profit for each category?
--Q.12 Write a SQL query to find customers(s) who have the highest total (lifetime) purchase amount
--Q.13 For each age group (e.g., 10–19, 20–29…), what is the total quantity sold?

--These Questions includes:
-- Date/Time Based
-- Customer Demographics
-- Sales/Transaction Analysis
-- Computed Columns / Aggregations







-- Q.1 Write a SQL query to retrieve all columns for sales made on '2022-11-05'

SELECT * FROM retail_sales
	WHERE sale_date = '2022-11-05';


-- Q.2 Write a SQL query to retrieve all transactions where the category is 'Clothing' and the quantity sold is more than 3 
--in the month of Nov-2022

SELECT * FROM retail_sales
	WHERE category = 'Clothing'
	AND quantity >3
	AND TO_CHAR(sale_date, 'Mon-YYYY') = 'Nov-2022'


-- Q.3 Write a SQL query to calculate the total sales (total_sale) for each category.

SELECT category, 
	SUM(total_sale) AS net_sale
	FROM retail_sales
	GROUP BY 1


-- Q.4 Write a SQL query to find the average age of customers who purchased items from the 'Electronics' category.

SELECT ROUND(AVG(age)) AS avg_age 
	FROM retail_sales
	WHERE category = 'Electronics';

-- Q.5 Write a SQL query to find all transactions where the total_sale is greater than 1000 and Gender is Female, sort the results
-- by Category in ascending order

SELECT * FROM retail_sales
	WHERE total_sale >1000
	AND gender = 'Female'
	ORDER BY category;


-- Q.6 Write a SQL query to find the total number of transactions (transaction_id) made by each gender in each category.


SELECT gender, category, COUNT(*)  AS total_trans
	FROM retail_sales
	GROUP BY 1,2
	ORDER BY 2


-- Q.7 Write a SQL query to calculate the average sale for each month. Find out best selling month in each year


SELECT 
       year,
       month,
    avg_sale
FROM 
(    
SELECT 
    EXTRACT(YEAR FROM sale_date) as year,
    EXTRACT(MONTH FROM sale_date) as month,
    ROUND(AVG(total_sale)) as avg_sale,
    DENSE_RANK() OVER(PARTITION BY EXTRACT(YEAR FROM sale_date) ORDER BY AVG(total_sale) DESC) as rank
FROM retail_sales
GROUP BY 1, 2
) as t1
WHERE rank = 1


-- Q.8 Write a SQL query to find the top 5 customers based on the highest total sales 

SELECT 
    customer_id,
    SUM(total_sale) as total_sales
FROM retail_sales
GROUP BY 1
ORDER BY 2 DESC
LIMIT 5

-- Q.9 Write a SQL query to find the number of unique customers who purchased items from each category.


SELECT 
    category,    
    COUNT(DISTINCT customer_id) AS unique_customers
FROM retail_sales
GROUP BY category


-- Q.10 Write a SQL query to create each shift and number of orders (Example Morning <=12, Afternoon Between 12 & 17, Evening >17)

SELECT *,
	CASE 
		WHEN EXTRACT(HOUR FROM sale_time)<12 THEN 'Morning'
		WHEN EXTRACT(HOUR FROM sale_time) BETWEEN 12 AND 17 THEN 'Afternoon'
		ELSE 'Evening' 
	END AS shift
		FROM retail_sales
		ORDER BY sale_time;




-- Q.11 Write a SQl query to add a computed column that shows the total profit for each category?



WITH nets AS (
  SELECT 
    category, 
    ROUND(SUM(total_sale)) AS net_sales,
    ROUND(SUM(cogs)) AS net_cogs
  FROM retail_sales
  GROUP BY category
)
SELECT 
  category,
  net_sales,
  net_cogs,
  net_sales - net_cogs AS net_profit
FROM nets;


--Q.12 Write a SQL query to find customers(s) who have the highest total (lifetime) purchase amount

SELECT customer_id, total_purchase
FROM (
  SELECT customer_id, SUM(total_sale) AS total_purchase,
         DENSE_RANK() OVER (ORDER BY SUM(total_sale) DESC) AS rnk
  FROM retail_sales
  GROUP BY customer_id
) sub
WHERE rnk = 1;



--Q.13 For each age group (e.g., 10–19, 20–29…), what is the total quantity sold?

SELECT
  CASE 
    WHEN age BETWEEN 10 AND 19 THEN '10-19'
    WHEN age BETWEEN 20 AND 29 THEN '20-29'
    WHEN age BETWEEN 30 AND 39 THEN '30-39'
    WHEN age BETWEEN 40 AND 49 THEN '40-49'
    WHEN age BETWEEN 50 AND 59 THEN '50-59'
    ELSE 'Above 59'
  END AS age_group,
  SUM(total_sale) AS total_quantity
FROM retail_sales
GROUP BY age_group
ORDER BY age_group;


--End of project


			