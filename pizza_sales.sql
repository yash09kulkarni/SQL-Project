-- Basic
-- 1) RETRIEVE THE TOTAL NUMBER OF ORDERS PLCED.

select count(order_id) as total_orders
from orders;


-- 2) CALCULATE THE TOTAL REVENUE GENERATED FROM PIZZA SALES.

select round(sum(order_details.quantity * pizzas.price),2) as total_sales
from order_details join pizzas
on pizzas.pizza_id = order_details.pizza_id;


-- 3) IDENTIFY THE HIGHEST-PRIZE PIZZA.

select pizza_types.name, pizzas.price
from pizza_types join pizzas
on pizza_types.pizza_type_id = pizzas.pizza_type_id
order by pizzas.price desc limit 1;


-- 4) IDENTIFY THE MOST COMMON PIZZA SIZE ORDERD.

select pizzas.size, count(order_details.order_details_id) as order_count
from pizzas join order_details
on pizzas.pizza_id = order_details.pizza_id
group by pizzas.size
order by order_count desc;


-- 5) LIST THE TOP 5 MOST ORDERED PIZZA TYPES ALONG WITH THEIR QUANTITIES.

select pizza_types.name, sum(order_details.quantity) as quantity
from pizza_types join pizzas
on pizza_types.pizza_type_id = pizzas.pizza_type_id
join order_details
on order_details.pizza_id = pizzas.pizza_id
group by pizza_types.name
order by quantity desc limit 5;


-- Intermediate
-- 6) JOIN THE NECESSARY TABLES TO FIND THE TOTAL QUANTITY OF EACH PIZZA CATEGORY ORDERED.

select pizza_types.category, sum(order_details.quantity) as quantity
from pizza_types join pizzas
on pizza_types.pizza_type_id = pizzas.pizza_type_id
join order_details
on order_details.pizza_id = pizzas.pizza_id
group by pizza_types.category
order by quantity desc;


-- 7) DETERMINE THE DISTRIBUTION OF ORDERS BY HOUR OF THE DAY.

select hour(orders.time) as hour, count(order_id) as order_count
from orders
group by hour;


-- 8) JOIN RELEVENT TABLES TO FIND THE CATEGORY-WISE DISTRIBUTION OF PIZZAS.

select category, count(name) from pizza_types
group by category;


-- 9) GROUP THE ORDERS BY DATE & CALCULATE THE AVERAGE NUMBERS OF PIZZAS ORDERED PER DAY.

select round(avg(quantity),0) as avg_pizza_ordered_per_day
from
(select orders.date, sum(order_details.quantity) as quantity
from orders join order_details
on orders.order_id = order_details.order_id
group by orders.date) as order_quantity;


-- 10) DETERMINE THE TOP 3 MOST ORDERED PIZZA TYPES BASED ON REVENUE.

select pizza_types.name, sum(order_details.quantity * pizzas.price) as revenue
from pizza_types join pizzas
on pizza_types.pizza_type_id = pizzas.pizza_type_id
join order_details
on order_details.pizza_id = pizzas.pizza_id
group by pizza_types.name
order by revenue desc limit 3;


-- Advanced
-- 11) CALCULATE THE PERCENTAGE CONTRIBUTION OF EACH PIZZATYPE TO TOTAL REVENUE.

select pizza_types.category,
round((sum(order_details.quantity * pizzas.price) / (select round(sum(order_details.quantity * pizzas.price),
2) as total_sales
from order_details join pizzas
on pizzas.pizza_id = order_details.pizza_id)) * 100,2) as revenue
from pizza_types join pizzas
on pizza_types.pizza_type_id = pizzas.pizza_type_id
join order_details
on order_details.pizza_id = pizzas.pizza_id
group by pizza_types.category
order by revenue desc;


-- 12) ANALYZE THE CUMULATIVE REVENUE GENERATED OVER TIME.

select sales.date,
sum(sales.revenue) over (order by sales.date) as cum_revenue
from
(select orders.date, sum(order_details.quantity * pizzas.price) as revenue
from order_details join pizzas
on order_details.pizza_id = pizzas.pizza_id
join orders
on orders.order_id = order_details.order_id
group by orders.date) as sales; 


-- 13) DETERMINE THE TOP 3 MOST ORDERED PIZZA TYPES BASED ON REVENUE FOR EACH PIZZA CATEGORY.

select name, revenue from
(select category, name, revenue,
rank() over(partition by category order by revenue desc) as rn
from
(select pizza_types.category, pizza_types.name,
sum(order_details.quantity * pizzas.price) as revenue
from pizza_types join pizzas
on pizza_types.pizza_type_id = pizzas.pizza_type_id
join order_details
on order_details.pizza_id = pizzas.pizza_id
group by pizza_types.category, pizza_types.name) as a) as b
where rn <= 3;