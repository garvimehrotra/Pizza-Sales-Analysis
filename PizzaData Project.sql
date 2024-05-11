--Pizza Order Project with Dummy Dataset
--Below Query is to view all the four tables
select * from Order_Details$
select * from [dbo].[Orders$]
select * from [dbo].[Pizzas$]
select * from [dbo].[PizzaTypes$]

--Basic Questions

--Retrieve the total number of orders placed.
Select count(*) from [dbo].[Orders$] 

--Calculate the total revenue generated from pizza sales.
SELECT CONCAT('$', CAST(ROUND(SUM(o.quantity * p.price), 2) AS DECIMAL(18,2))) AS Revenue 
FROM [dbo].[Pizzas$] p
JOIN Order_Details$ o ON p.pizza_id = o.pizza_id;

--Identify the highest-priced pizza.
select top 1 max(p.price)as HighestPrice,pt.[name] from [dbo].[Pizzas$] p
join [dbo].[PizzaTypes$] pt on p.[pizza_type_id]=pt.[pizza_type_id]
group by pt.[name]
order by max(p.price) desc

--Identify the most common pizza size ordered.
select p.size,count(o.order_id) totalorderplaced from [dbo].[Pizzas$] p
join Order_Details$ o on p.[pizza_id]=o.[pizza_id]
group by p.size
order by count(o.order_id) desc

--List the top 5 most ordered pizza types along with their quantities.
SELECT top 5 pt.[name], SUM(o.quantity) AS total_quantity
FROM [dbo].[PizzaTypes$] pt
JOIN [dbo].[Pizzas$] p ON pt.[pizza_type_id] = p.[pizza_type_id]
JOIN [dbo].[Order_Details$] o ON p.[pizza_id] = o.[pizza_id]
GROUP BY pt.[name]
order by sum(o.quantity) desc

--Intermediate Level Questions for deeper analysis

--Find the total quantity of each pizza category ordered.
SELECT pt.[category], SUM(o.quantity) AS total_quantity
FROM [dbo].[PizzaTypes$] pt
JOIN [dbo].[Pizzas$] p ON pt.[pizza_type_id] = p.[pizza_type_id]
JOIN [dbo].[Order_Details$] o ON p.[pizza_id] = o.[pizza_id]
GROUP BY pt.[category]
order by sum(o.quantity) desc

--Determine the distribution of orders by hour of the day.

SELECT CONCAT(DATEPART(HOUR, [time]), 
              CASE WHEN DATEPART(HOUR, [time]) < 12 THEN ' AM' ELSE ' PM' END) AS Hour_AM_PM,
       COUNT(order_id) AS Order_Count
FROM [dbo].[Orders$]
GROUP BY DATEPART(HOUR, [time])
order by COUNT(order_id) desc

--Find the category-wise distribution of pizzas.

select category, count(name) from [dbo].[PizzaTypes$]
group by category

--Group the orders by date and calculate the average number of pizzas ordered per day.
SELECT FORMAT([date], 'dd-MM-yyyy') AS formatted_date,
       AVG(quantity) AS average_pizzas_ordered_per_day
FROM (
    SELECT [date], SUM(quantity) AS quantity
    FROM [dbo].[Orders$] o
    JOIN [dbo].[Order_Details$] od ON o.order_id = od.order_id
    GROUP BY [formatted_date]

GROUP BY FORMAT([date], 'dd-MM-yyyy');

--Determine the top 3 most ordered pizza types based on revenue.
select top 3 pt.[name],round(sum((p.price)*(o.quantity)),2) as revenue from [dbo].[PizzaTypes$] pt
join [dbo].[Pizzas$] p  on pt.[pizza_type_id]=p.[pizza_type_id]
join [dbo].[Order_Details$] o on p.[pizza_id]=o.[pizza_id]
group by pt.[name]
order by revenue desc

--Advanced Questions

--Calculate the percentage contribution of each pizza type to total revenue.
SELECT pt.[category] AS Pizza_Type,
       format((SUM(p.price * od.quantity) / total_revenue) * 100,'0.00')+'%' AS Percentage_Contribution
FROM [Order_Details$] od
JOIN [dbo].[Pizzas$] p ON p.[pizza_id] = od.[pizza_id]
JOIN [dbo].[PizzaTypes$] pt ON p.[pizza_type_id] = pt.[pizza_type_id]
JOIN (
    SELECT SUM(p.price * od.quantity) AS total_revenue
    FROM [Order_Details$] od
    JOIN [dbo].[Pizzas$] p ON p.[pizza_id] = od.[pizza_id]
) AS TotalRevenue ON 1=1
GROUP BY pt.[category], TotalRevenue.total_revenue
order by percentage_Contribution desc;

--Analyze the cumulative revenue generated over time.

SELECT FORMAT([date], 'dd-MM-yyyy') AS formatted_date,
       SUM(revenue) OVER (ORDER BY [date]) AS cumulative_revenue
FROM (
    SELECT [date], SUM(p.price * od.quantity) AS revenue
    FROM [Order_Details$] od
    JOIN [dbo].[Pizzas$] p ON p.[pizza_id] = od.[pizza_id]
    JOIN [dbo].[Orders$] o ON o.[order_id] = od.[order_id]
    GROUP BY [date]
) AS RevenuePerDate;

--Determine the top 3 most ordered pizza types based on revenue for each pizza category. 
WITH PizzaTypeRevenue AS (
    SELECT pt.[name] AS Pizza_Type,
           pt.category,
           SUM(p.price * od.quantity) AS Revenue,
           RANK() OVER (PARTITION BY pt.category ORDER BY SUM(p.price * od.quantity) DESC) AS Rank
    FROM [Order_Details$] od
    JOIN [dbo].[Pizzas$] p ON p.[pizza_id] = od.[pizza_id]
    JOIN [dbo].[PizzaTypes$] pt ON p.[pizza_type_id] = pt.[pizza_type_id]
    GROUP BY pt.[name], pt.category
)
SELECT Pizza_Type, category, Revenue
FROM PizzaTypeRevenue
WHERE Rank <= 3;









