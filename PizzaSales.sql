create database if not exists pizzahut;
use pizzahut;
show tables;

/*Basic Insights*/

-- 1. Retrieve the total number of orders placed.
SELECT 
    COUNT(order_id) AS total_orders
FROM
    orders;
-- 2. Calculate the total revenue generated from pizza sales.
SELECT 
    ROUND(SUM(orders_details.quantity * pizzas.price),
            2) AS total_sales
FROM
    orders_details
        JOIN
    pizzas ON orders_details.pizza_id = pizzas.pizza_id;
-- 3. Identify the highest-priced pizza.
SELECT 
    pizza_types.name, pizzas.price
FROM
    pizzas
        JOIN
    pizza_types ON pizzas.pizza_type_id = pizza_types.pizza_type_id
ORDER BY pizzas.price DESC
LIMIT 1;
-- 4. Identify the most common pizza size ordered.
-- select quantity, count(order_details_id) from orders_details group by quantity;
SELECT 
    pizzas.size, COUNT(orders_details.order_details_id)
FROM
    orders_details
        JOIN
    pizzas ON orders_details.pizza_id = pizzas.pizza_id
GROUP BY pizzas.size
ORDER BY COUNT(orders_details.order_details_id) DESC
LIMIT 1;
-- 5.List the top 5 most ordered pizza types along with their quantities.
SELECT 
    pizza_types.name, SUM(orders_details.quantity)
FROM
    orders_details
        JOIN
    pizzas ON orders_details.pizza_id = pizzas.pizza_id
        JOIN
    pizza_types ON pizza_types.pizza_type_id = pizzas.pizza_type_id
GROUP BY pizza_types.name
ORDER BY SUM(orders_details.quantity) DESC
LIMIT 5;

/* Intermediate: */
-- 1. Join the necessary tables to find the total quantity of each pizza category ordered.
SELECT 
    pizza_types.category,
    SUM(orders_details.quantity) AS total_quantity
FROM
    orders_details
        JOIN
    pizzas ON orders_details.pizza_id = pizzas.pizza_id
        JOIN
    pizza_types ON pizza_types.pizza_type_id = pizzas.pizza_type_id
GROUP BY pizza_types.category;
-- 2. Determine the distribution of orders by hour of the day.
 
-- select hour(order_time), count(hour(order_time)) from orders group by hour(order_time);

SELECT 
    HOUR(order_time), COUNT(order_id)
FROM
    orders
GROUP BY HOUR(order_time);
-- 3.Join relevant tables to find the category-wise distribution of pizzas.
 
SELECT 
    category, COUNT(name)
FROM
    pizza_types
GROUP BY category;
-- 4. Group the orders by date and calculate the average number of pizzas ordered per day.
SELECT 
    ROUND(AVG(quantity), 2)
FROM
    (SELECT 
        orders.Order_date,
            COUNT(orders_details.order_details_id) AS orders,
            SUM(orders_details.quantity) AS quantity
    FROM
        orders
    JOIN orders_details ON orders.order_id = orders_details.Order_id
    GROUP BY orders.Order_date) AS order_quantity;
    -- 5. Determine the top 3 most ordered pizza types based on revenue.

    SELECT 
    pizza_types.name,
    SUM(orders_details.quantity * pizzas.price) AS revenue
FROM
    pizza_types
        JOIN
    pizzas ON pizza_types.pizza_type_id = pizzas.pizza_type_id
        JOIN
    orders_details ON orders_details.pizza_id = pizzas.pizza_id
GROUP BY pizza_types.name
ORDER BY revenue DESC
LIMIT 3;

/*Advanced:*/
-- 1. Calculate the percentage contribution of each pizza type to total revenue.
SELECT 
    pizza_types.category,
    ROUND((SUM(orders_details.quantity * pizzas.price) / (SELECT 
                    SUM(orders_details.quantity * pizzas.price)
                FROM
                    orders_details
                        JOIN
                    pizzas ON orders_details.pizza_id = pizzas.pizza_id)) * 100,
            2) AS total_revenue
FROM
    orders_details
        JOIN
    pizzas ON orders_details.pizza_id = pizzas.pizza_id
        JOIN
    pizza_types ON pizzas.pizza_type_id = pizza_types.pizza_type_id
GROUP BY pizza_types.category order by total_revenue desc;
-- 2. Analyze the cumulative revenue generated over time.
select order_date, sum(revenue) over(order by order_date) as cum_rev from
(select orders.Order_date, sum(orders_details.quantity*pizzas.price) as revenue from
orders_details join	pizzas
on orders_details.pizza_id=pizzas.pizza_id 
join orders
on orders.order_id=orders_details.Order_id group by orders.Order_date) as sales;

-- 3. Determine the top 3 most ordered pizza types based on revenue for each pizza category.
select category, name, revenue, rn from
(select category, name, revenue, rank() over(partition by category order by revenue desc) as rn
from
(select pizza_types.category,pizza_types.name, sum(orders_details.quantity * pizzas.price) as revenue
from pizza_types join pizzas on pizza_types.pizza_type_id=pizzas.pizza_type_id
join orders_details
on orders_details.pizza_id = pizzas.pizza_id group by pizza_types.name, pizza_types.category) as a) as b where rn <=3;




   
 