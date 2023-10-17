use pizza_sales;

"CREATE TABLE order_details(
order_details_id int primary key,
order_id int,
pizza_id text,
quantity text
);"



load data infile 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/order_details.csv'
into table order_details
fields terminated by ","
lines terminated by "\n"
ignore 1 lines;

select * from order_details;
select * from pizzas;
select * from pizza_types;

create view pizza_details as 
select p.pizza_id,p.pizza_type_id,pt.name,pt.category,p.size,p.price,pt.ingredients
from pizzas p
inner join pizza_types pt
on
p.pizza_type_id=pt.pizza_type_id;

alter table orders
modify date date;

alter table orders
modify time time;

-- total revenue
select round(sum(od.quantity * p.price),2) as total_revenue
from order_details as od
join pizzas as p
on od.pizza_id = p.pizza_id;

-- total no of pizza sold
select sum(od.quantity) as pizza_sold
from order_details od;

-- total orders
select count(distinct(od.order_id)) as total_orders
from order_details as od;

-- average order value
select round(sum(od.quantity * p.price) / count(distinct(od.order_id)),2) as avg_order_value
from order_details as od
join pizzas p
on od.pizza_id = p.pizza_id;

-- average pizza per order
select round(sum(od.quantity)/count(distinct(order_id)),0) as avg_no_of_pizza_per_order
from order_details as od;

-- total revenue per category
select pd.category,round(sum(od.quantity * pd.price),2) as total_revenue_per_category, 
count(distinct(od.order_id)) as total_orders
from order_details od
join pizza_details pd
on od.pizza_id = pd.pizza_id
group by pd.category;

select pd.size,
round(sum(od.quantity * pd.price),2) as total_revenue_per_category, 
count(distinct(od.order_id)) as total_orders
from order_details od
join pizza_details pd
on od.pizza_id = pd.pizza_id
group by pd.size
order by total_orders;

-- hourly trend in orders and revenue of pizza
select case
	when hour(o.time) between 9 and 11 then 'Late Morining'
    when hour(o.time) between 12 and 15 then 'Lunch'
    when hour(o.time) between 15 and 18 then 'Mid Afternoon'
    when hour(o.time) between 18 and 21 then 'Dinner'
    when hour(o.time) between 21 and 23 then 'Late Night'
    else 'Others'
end as meal_time,
count(distinct(o.order_id)) as total_orders,
round(sum(derived.calc_revenue),2) as total_revenue
from orders o
join
(select od.order_id, sum(od.quantity * p.price) as calc_revenue
from order_details od
join pizzas p 
on
od.pizza_id = p.pizza_id
group by od.order_id) as derived
on
o.order_id = derived.order_id
group by meal_time
order by total_revenue desc;

-- weekday with total orders
select dayname(o.date) as day_name, count(distinct(od.order_id)) as total_weekday_orders
from order_details od
join
orders o
on od.order_id = o.order_id
group by day_name
order by total_weekday_orders desc;

-- monthlywise 
select monthname(o.date) as month_name, count(distinct(od.order_id)) as total_monthly_orders
from order_details od
join
orders o
on od.order_id = o.order_id
group by month_name
order by total_monthly_orders desc;

-- which pizza is favorite
select p.name,p.size,count(od.order_id) as count_pizzas
from order_details as od
join 
pizza_details as p
on od.pizza_id = p.pizza_id
group by p.name,p.size
order by total_orders desc;

-- top 5 pizza by revenue
select pd.name as pizza_name,
round(sum(od.quantity * pd.price),2) as total_revenue_by_pizza
from
order_details od
join pizza_details pd
on od.pizza_id = pd.pizza_id
group by pizza_name
order by total_revenue_by_pizza desc
limit 5;

-- total sales by pizza
select pd.name as pizza_name,
sum(od.quantity) as pizza_sold
from
order_details od
join pizza_details pd
on od.pizza_id = pd.pizza_id
group by pizza_name
order by pizza_sold desc
limit 5;


-- pizza highest and lowest price
select name, price 
from pizza_details
order by price desc
limit 1;

-- top ingredients
select ingredients , count(*) as highly_used
from pizza_details
group by ingredients
order by highly_used desc;

