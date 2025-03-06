use project;
-- E COMMERCE COMPANY

/* Analyze Data.
You can analyze all the tables by describing their contents.
Describe the Tables: Customers, Products, Orders, OrderDetails */

desc customers;
desc products;
desc orders;
desc orderDetails;

/* Market Segmentation Analysis 
Identify the top 3 cities with the highest number of customers
 to determine key markets for targeted marketing and logistic optimization. */
 select location, count(*) as number_of_customers
from customers
group by location
order by number_of_customers desc
limit 3;

-- As per the above query, Delhi, Chennai and Jaipur must be focussed as a part of marketing strategies

/* Engagement Depth Analysis
Determine the distribution of customers by the number of orders placed. 
This insight will help in segmenting customers into one-time buyers, occasional shoppers,
 and regular customers for tailored marketing strategies. */
 
 with cte1 as(select customer_id, count(order_Id) as NumberofOrders from orders 
group by customer_id
)
select NumberofOrders, count(*) as CustomerCount
from cte1
group by NumberofOrders
order by NumberofOrders asc;

-- As per the above query, as the Number of orders increases, the Customer Count decreases
-- Also, The company experiences occasional shoppers the most

/* Purchase High Value Products
Identify products where the average purchase quantity per order is 2 
but with a high total revenue,
 suggesting premium product trends. */
 select Product_Id, avg(quantity) as AvgQuantity, sum(quantity*price_per_unit)
as TotalRevenue from orderdetails
group by Product_Id
having avg(quantity)=2 
order by TotalRevenue desc;

-- As per the above query, among the products with average purchase quantity of two, Product 1 exhibits the highest total revenue

/* Category- wise customer Reach 
For each product category, calculate the unique number of customers purchasing from it. 
This will help understand which categories have wider appeal across the customer base. */

select p.category, count(distinct o.customer_id) as unique_customers
from orders o join OrderDetails od on o.order_id=od.order_id
join Products p on p.product_id=od.product_id
group by p.category
order by unique_customers desc; 

-- As per the above query, Electronics product category needs more focus as it is in high demand among customers

/* Sales Trend Analysis
Analyze the month-on-month percentage change in total sales to identify growth trends. */
with cte1 as
(
select date_format(order_date, '%Y-%m') as Month, 
sum(total_amount) as TotalSales from orders
group by Month)
select Month, TotalSales, 
round((TotalSales- lag(TotalSales) over(order by Month))*100/ lag(TotalSales) over(order by Month),2)
as PercentChange from cte1;

-- As per the above query, Feb 2024 experienced the largest decline in sales
-- Also, Sales fluctuated with no clear trend from March to August

/* Average Order value Fluctuation
Examine how the average order value changes month-on-month. 
Insights can guide pricing and promotional strategies to enhance order value. */

with cte1 as
(
select date_format(order_date, '%Y-%m') as Month, 
avg(total_amount) as AvgOrderValue from orders
group by Month)
select Month, AvgOrderValue, 
round(AvgOrderValue- lag(AvgOrderValue) over(order by Month),2)
as ChangeInValue from cte1
order by ChangeInValue desc;

-- As per the above query, December had the highest change in the average order value

/* Inventory Refresh Rate
Based on sales data, identify products with the fastest turnover rates, 
suggesting high demand and the need for frequent restocking. */

select product_id, count(quantity*price_per_unit) as SalesFrequency
from orderdetails
group by product_id
order by SalesFrequency desc
limit 5;

-- As per the above query, product_id 7 had the highest turnover rates and needs to be restocked frequently

/* Low Engagement Products
List products purchased by less than 40% of the customer base,
 indicating potential mismatches between inventory and customer interest. */
 with cte1 as 
(
    select p.Product_id, p.name, count(distinct o.customer_id) as UniqueCustomerCount, 
(count(distinct o.customer_id)*100/ (select count(*) from Customers)) as Customer_percentage
from Products p
join OrderDetails od
on p.Product_id=od.Product_id
join Orders o 
on o.order_id=od.order_id
join Customers c
on c.customer_id=o.customer_id
group by p.Product_id, p.name
having (count(distinct o.customer_id)*100/ (select count(*) from Customers))< 40
order by UniqueCustomerCount
)
select  Product_id, name, UniqueCustomerCount from cte1;

-- As per the above query, Poor visibility on the platform might be the reason why certain products have purchase rates below 40% of the total customer base
-- A strategic action to improve the sales of these underperforming products can be to implement targeted marketing campaigns to raise awareness and interest

/* Customer Acquisition Trends
Evaluate the month-on-month growth rate in the customer base 
to understand the effectiveness of marketing campaigns and market expansion efforts. */
with cte1 as(select customer_id, min(date_format(order_date, '%Y-%m')) as FirstPurchaseMonth
from orders 
group by customer_id)
select FirstPurchaseMonth, count(*) as TotalNewCustomers
from cte1
group by FirstPurchaseMonth
order by FirstPurchaseMonth;

-- As per the above query, a downwared trend in the customer base can be inferred which implies that the marketing campaigns are not much effective

/* Peak Sales period Identification
Identify the months with the highest sales volume, aiding in planning for stock levels,
 marketing efforts, and staffing in anticipation of peak demand periods. */
 
 select date_format(order_date, '%Y-%m') as Month,
sum(total_amount) as TotalSales
from orders 
group by Month
order by TotalSales  desc
limit 3;

-- As per the above query, September, December months require major restocking of product and increased staffs







