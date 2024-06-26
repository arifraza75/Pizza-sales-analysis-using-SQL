/*
										PIZZA SALES ANALYSIS
*/


-- At first, we need to create a database with the name of pizzahut.
create database pizzahut;
use pizzahut;



-- Now, we imported the dataset from csv files.
show tables;



-- Check the datatypes,Null values from the tables
show columns from order_details;
show columns from orders;
show columns from pizza_types;
show columns from pizzas;



-- Lets do the analysis as per the business requirement.
-- 1. Total number of orders placed.
SELECT 
    COUNT(*) AS total_order
FROM
    orders;




-- 2. Total revenue generated from pizza sales.
SELECT 
    ROUND(SUM(o.quantity * p.price), 2) AS total_revenue
FROM
    order_details o
        JOIN
    pizzas p ON o.pizza_id = p.pizza_id;




-- 3. Top 3 highest-priced pizza.
SELECT 
    pt.name, p.size, p.price
FROM
    pizza_types pt
        JOIN
    pizzas p ON pt.pizza_type_id = p.pizza_type_id
ORDER BY price DESC
LIMIT 3;




-- 4. Most & least pizza size ordered.
SELECT 
    p.size, SUM(quantity) AS total_quantity
FROM
    pizzas p
        JOIN
    order_details o ON p.pizza_id = o.pizza_id
GROUP BY size
ORDER BY 2 DESC;





-- 5. List the top 5 most ordered pizza types along with their quantities.
SELECT 
    pt.name, SUM(o.quantity) AS total_quantity
FROM
    pizza_types pt
        JOIN
    pizzas p ON pt.pizza_type_id = p.pizza_type_id
        JOIN
    order_details o ON p.pizza_id = o.pizza_id
GROUP BY name
ORDER BY 2 DESC
LIMIT 5;




-- 6. Total quantity of each pizza category ordered.
SELECT 
    pt.category, SUM(quantity) AS total_quantity
FROM
    pizza_types pt
        JOIN
    pizzas p ON pt.pizza_type_id = p.pizza_type_id
        JOIN
    order_details o ON p.pizza_id = o.pizza_id
GROUP BY 1;




-- 7. Distribution of orders by hour of the day.
SELECT 
    EXTRACT(HOUR FROM order_time) AS hour, COUNT(*) order_count
FROM
    orders
GROUP BY hour
ORDER BY 1;




-- 8. Category-wise distribution of pizzas.
SELECT 
    category, COUNT(*)
FROM
    pizza_types
GROUP BY category;




-- 9. Average number of pizzas ordered per day.
SELECT 
    ROUND(AVG(total), 2) avg_order_per_day
FROM
    (SELECT 
        o.order_date, SUM(od.quantity) AS total
    FROM
        orders o
    JOIN order_details od ON o.order_id = od.order_id
    GROUP BY o.order_date) AS day_wise_order_summary;




-- 10. Top 3 most ordered pizza types based on revenue.
SELECT 
    name, SUM(quantity * price) AS revenue
FROM
    pizza_types pt
        JOIN
    pizzas p ON pt.pizza_type_id = p.pizza_type_id
        JOIN
    order_details od ON p.pizza_id = od.pizza_id
GROUP BY name
ORDER BY 2 DESC
LIMIT 3;




-- 11. Percentage contribution of each pizza category to total revenue.
SELECT 
    pt.category,
    ROUND(SUM(price * quantity) / (SELECT 
                    SUM(price * quantity)
                FROM
                    order_details o
                        JOIN
                    pizzas p USING (pizza_id)) * 100,
            2) AS revenue_percentage
FROM
    pizza_types pt
        JOIN
    pizzas p ON pt.pizza_type_id = p.pizza_type_id
        JOIN
    order_details od ON p.pizza_id = od.pizza_id
GROUP BY pt.category
ORDER BY 2 DESC; 




-- 12. Analysis of cumulative revenue generated over time.
SELECT *,
       ROUND(SUM(revenue_generated) OVER (ORDER BY order_date), 2) AS cumulative_rev
FROM
    (SELECT order_date,
            ROUND(SUM(price * quantity), 2) AS revenue_generated
     FROM orders o 
     JOIN order_details od ON o.order_id = od.order_id
     JOIN pizzas p ON od.pizza_id = p.pizza_id
     GROUP BY order_date) AS revenue_summary;




-- 13. Top 3 most ordered pizza types based on revenue for each pizza category.
SELECT *
FROM (
    SELECT 
        pt.category,
        pt.name,
        ROUND(SUM(od.quantity * p.price)) AS revenue,
        DENSE_RANK() OVER (PARTITION BY pt.category ORDER BY SUM(od.quantity * p.price) DESC) AS rnk
    FROM 
        pizza_types pt 
        JOIN pizzas p ON pt.pizza_type_id = p.pizza_type_id
        JOIN order_details od ON p.pizza_id = od.pizza_id
    GROUP BY 
        pt.category, pt.name
) AS x
WHERE 
    rnk <= 3;
