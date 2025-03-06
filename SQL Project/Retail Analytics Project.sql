-- Retail Analytics Project
-- Datasets Tables:
-- Sales Transaction: Records of sales transactions, including transaction ID, customer ID, product ID, quantity purchased, transaction date, and price.
-- Customer Profiles: Information on customers, including customer ID, age, gender, location, and join date.
-- Product Inventory: Data on product inventory, including product ID, product name, category, stock level, and price.


/* Remove Duplicates 
Write a query to identify the number of duplicates in "sales transaction" table.
Also, create a separate table containing the unique volues and remove the the original table from the databases. 
Replace the name of the new table with the original name.*/

select transactionID, count(*)
from sales_transaction
group by transactionID
having count(*)>1;
create table sales_1 as
select distinct * from sales_transaction;
select* from sales_1;
drop table sales_transaction;
alter table sales_1
rename to sales_transaction;

/* Fix Incorrect Prices 
Write a query to identify the discrepancies in the price of the same product in "sales_transaction" and "product_inventory" tables. 
Also, update those discrepancies to match the price in both the tables.*/

select s.transactionID, s.Price as TransactionPrice, p.Price as InventoryPrice
from sales_transaction s
join product_Inventory p
on s.productID=p.ProductID
where s.Price<>p.Price;
update sales_transaction s
set Price = (select p.Price from product_inventory p where s.ProductID=p.ProductID)
where s.productID in  (select p.ProductID from product_inventory p where s.Price<>p.Price);
select* from sales_transaction;

/* Fixing Null Values
Write a SQL query to identify the null values in the dataset and replace those by “Unknown”.*/

select count(*) 
from customer_profiles
where location is NULL;
update customer_profiles
set location = 'Unknown'
where location is NULL;
select * from customer_profiles;

/* Cleaning Date 
Write a SQL query to clean the DATE column in the dataset.*/

create table sales1 as
select *, str_to_date(TransactionDate,'%Y-%m-%d') as TransactionDate_updated
from sales_transaction;
select * from sales1;
drop table sales_transaction;
alter table sales1
rename to sales_transaction;

/* Total Sales Summary
Write a SQL query to summarize the total sales and quantities sold per product by the company.*/

select ProductID, sum(QuantityPurchased) as TotalUnitsSold, sum(QuantityPurchased*Price) as TotalSales
from sales_transaction
group by ProductID
order by TotalSales desc;

/* Customer Purchase Frequency
Write a SQL query to count the number of transactions per customer to understand purchase frequency. */

select CustomerID, count(TransactionID) as NumberOfTransactions
from sales_transaction
group by CustomerID
order by NumberOfTransactions desc;

/* Product Categories Performance
Write a SQL query to evaluate the performance of the product categories based on the total sales 
which help us understand the product categories which needs to be promoted in the marketing campaigns. */

select p.Category, sum(s.QuantityPurchased) as TotalUnitsSold, sum(s.QuantityPurchased*s.Price) as TotalSales
from sales_transaction s
join product_inventory p
on s.ProductID=p.ProductID
group by p.Category
order by TotalSales desc;

/* High Sales Products
Write a SQL query to find the top 10 products with the highest total sales revenue from the sales transactions. 
This will help the company to identify the High sales products which needs to be focused to increase the revenue of the company. */

select ProductID, sum(QuantityPurchased*Price) as TotalRevenue
from sales_transaction
group by ProductID
order by TotalRevenue desc
limit 10;

/* Low Sales Products
Write a SQL query to find the ten products with the least amount of units sold from the sales transactions, 
provided that at least one unit was sold for those products.*/

select ProductID, sum(QuantityPurchased) as TotalUnitsSold
from sales_transaction
group by ProductID
having sum(QuantityPurchased)>=1
order by TotalUnitsSold asc
limit 10;

/* Sales Trend
Write a SQL query to identify the sales trend to understand the revenue pattern of the company.*/

select TransactionDate_updated as DATETRANS, count(*)  as Transaction_count, sum(QuantityPurchased) as TotalUnitsSold, sum(QuantityPurchased*Price) as TotalSales
from sales_transaction
group by DATETRANS
order by DATETRANS desc;

/* Growth Rate Of Sales
Write a SQL query to understand the month on month growth rate of sales of the company which will help understand the growth trend of the company.*/

With monthly_sales as (  
    Select  
        extract(month from TransactionDate) as month,  
        sum(QuantityPurchased * Price) as total_sales  
    From sales_transaction  
    Group by Extract(month from TransactionDate)  
)  
Select 
    month,  
    total_sales,  
    lag(total_sales) over (order by month) as previous_month_sales,  
    ((total_sales - lag(total_sales) over (order by month)) / lag(total_sales) over (order by month)) * 100 as mom_growth_percentage  
from monthly_sales  
order by month;

/* High Purchase Frequency
Write a SQL query that describes the number of transaction along with the total amount spent by each customer 
which are on the higher side and will help us understand the customers who are the high frequency purchase customers in the company.*/

select CustomerID, count(*) as NumberOfTransactions, sum(price*quantityPurchased)  as totalspent
from sales_transaction
group by CustomerID
having count(*) > 10
and sum(price*quantityPurchased)> 1000
order by totalspent desc;

/* Occasional Customers
Write a SQL query that describes the number of transaction along with the total amount spent by each customer, 
which will help us understand the customers who are occasional customers or have low purchase frequency in the company.*/

select CustomerID, count(*) as NumberofTransactions, sum(quantitypurchased*price)
as TotalSpent from sales_transaction
group by CustomerID
having NumberofTransactions<=2 
order by NumberofTransactions asc, TotalSpent desc;

/* Repeat Purchases
Write a SQL query that describes the total number of purchases made by each customer 
against each productID to understand the repeat customers in the company.*/

select CustomerID, ProductID, count(*) as TimesPurchased
from sales_transaction
group by CustomerID, ProductID
having TimesPurchased>1
order by TimesPurchased desc;

/* Loyality Indicators
Write a SQL query that describes the duration between the first and the last purchase of the customer 
in that particular company to understand the loyalty of the customer.*/

with cte1 as(select CustomerID, min(str_to_date(TransactionDate, '%Y-%m-%d')) as FirstPurchase,
max(str_to_date(TransactionDate, '%Y-%m-%d')) as LastPurchase from sales_transaction
group by CustomerID)
select *, datediff(LastPurchase,FirstPurchase) as DaysBetweenPurchases
from cte1
where datediff(LastPurchase,FirstPurchase)>0
order by DaysBetweenPurchases desc;

/* Customer Segmentation
Write an SQL query that segments customers based on the total quantity of products they have purchased. 
Also, count the number of customers in each segment which will help us target a particular segment for marketing.*/

Create table customer_segment as
select s.CustomerID, case
when sum(s.quantityPurchased) >30 then 'High'
when sum(s.quantityPurchased)between 10 and 30 then 'Med'
else 'Low'
end as CustomerSegment
from sales_transaction s
join customer_profiles c on
s.CustomerID=c.CustomerID
group by  CustomerID;
select CustomerSegment, count(*)
from customer_segment
group by CustomerSegment;




