-- Query 1: Counting Unique Nodes
-- Counting the total number of unique nodes in the Data Bank system.
SELECT COUNT(DISTINCT node_id) AS Num_of_nodes
FROM customer_nodes;

-- Query 2: Nodes Per Region
-- Finding the number of nodes in each region and ordering them by the highest count.
SELECT region_name, COUNT(node_id) AS nodes_in_region
FROM customer_nodes
INNER JOIN regions USING(region_id)
GROUP BY region_name
ORDER BY nodes_in_region DESC;

-- Query 3: Customers Per Region
-- Determining the number of customers allocated to each region and ordering by the highest count.
SELECT region_name, COUNT(DISTINCT customer_id) AS number_of_customer
FROM customer_nodes
INNER JOIN regions USING(region_id)
GROUP BY region_name
ORDER BY number_of_customer DESC;

-- Query 4: Average Reallocation Days
-- Calculating the average number of days customers are reallocated to a different node.
SELECT ROUND(AVG(DATEDIFF(end_date, start_date))) AS Avg_Reallocation_day
FROM customer_nodes
WHERE YEAR(end_date) <> 9999;

-- Query 5: Reallocation Days Metrics by Region
-- Finding the median, 80th, and 95th percentiles for reallocation days in each region.

