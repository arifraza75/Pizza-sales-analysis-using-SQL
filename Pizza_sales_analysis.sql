-- At first, we created a database with the name of pizzahut.
create database pizzahut;
use pizzahut;



-- Now after cleaning the data we imported the dataset from csv files.
show tables;



-- Lets do the analysis as per the business requirement.
-- 1. Total number of orders placed.
SELECT 
    COUNT(*) AS total_order
FROM
    orders;
    
-- Total order placed is 21350. 




-- 2. Total revenue generated from pizza sales.
SELECT 
    ROUND(SUM(o.quantity * p.price), 2) AS total_revenue
FROM
    order_details o
        JOIN
    pizzas p ON o.pizza_id = p.pizza_id;
    
-- Total revenue generated is 817860.05




-- 3. Top 3 highest-priced pizza.
SELECT 
    pt.name, p.size, p.price
FROM
    pizza_types pt
        JOIN
    pizzas p ON pt.pizza_type_id = p.pizza_type_id
ORDER BY price DESC
LIMIT 3;

/*
Pizza_Name				Size	Price
The Greek Pizza			XXL		35.95
The Greek Pizza			XL		25.5
The Brie Carre Pizza	S		23.65
*/




-- 4. Most & least pizza size ordered.
SELECT 
    p.size, SUM(quantity) AS total_quantity
FROM
    pizzas p
        JOIN
    order_details o ON p.pizza_id = o.pizza_id
GROUP BY size
ORDER BY 2 DESC;

-- L-size pizza is most commonly ordered & XXL-size is least ordered.




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

/*
Name						Total_quantity
The Classic Deluxe Pizza	2453
The Barbecue Chicken Pizza	2432
The Hawaiian Pizza			2422
The Pepperoni Pizza			2418
The Thai Chicken Pizza		2371
*/




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

/*
category		Total_quantity
Classic			14888
Veggie			11649
Supreme			11987
Chicken			11050
*/



-- 7. Distribution of orders by hour of the day.
SELECT 
    EXTRACT(HOUR FROM order_time) AS hour, COUNT(*) order_count
FROM
    orders
GROUP BY hour
ORDER BY 1;

/*
Hour	order_count
9		1
10		8
11		1231
12		2520
13		2455
14		1472
15		1468
16		1920
17		2336
18		2399
19		2009
20		1642
21		1198
22		663
23		28
*/




-- 8. Category-wise distribution of pizzas.
SELECT 
    category, COUNT(*)
FROM
    pizza_types
GROUP BY category;

/*
Category	Count
Chicken		6
Classic		8
Supreme		9
Veggie		9
*/




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

-- On an average total 138 order happened per day.




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

/*
Name							Revenue
The Thai Chicken Pizza			43434.25
The Barbecue Chicken Pizza		42768
The California Chicken Pizza	41409.5
*/




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

/*
Category		Revenue_percentage
Classic			26.91
Supreme			25.46
Chicken			23.96
Veggie			23.68
*/




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

/*
Category		Name					     Total_revenue
Chicken		The Thai Chicken Pizza			    43434	
Chicken		The Barbecue Chicken Pizza		    42768	
Chicken		The California Chicken Pizza	    41410	
Classic		The Classic Deluxe Pizza		    38180	
Classic		The Hawaiian Pizza				    32273	
Classic		The Pepperoni Pizza				    30162	
Supreme		The Spicy Italian Pizza			    34831	
Supreme		The Italian Supreme Pizza		    33477	
Supreme		The Sicilian Pizza				    30940	
Veggie		The Four Cheese Pizza			    32266	
Veggie		The Mexicana Pizza				    26781	
Veggie		The Five Cheese Pizza			    26066	
*/
