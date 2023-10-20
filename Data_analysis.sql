-- In order to know what we are dealing with, let's look at the info we have about our warehouses

select * from warehouses; 

-- Let's look further into the warehouses capacities. 

-- Knowing the currentStock and the PctCap we can determine the maximum capacity and the left capacity for each warehouse. 
create temporary table warehouseCapacity as
select p.warehouseCode, p.currentStock, w.warehousePctCap, truncate((100 * p.currentStock / w.warehousePctCap), 0) as maxCapacity, (truncate((100 * p.currentStock / w.warehousePctCap), 0) - p.currentStock) as currentCapLeft
from
	(select warehouseCode, sum(quantityInStock) as currentStock -- This query from the products table has relevant info we can use to calculate the warehouses capacities. 
	from products
	group by warehouseCode) 
as p
join warehouses as w
on p.warehouseCode = w.warehouseCode;

select *
from warehouseCapacity;

-- It looks like even though warehouse c has the lowest occupation, it is a lot bigger than warehouse d and somewhat bigger than warehouse a. 
-- One could start thinking that d, being the smallest one, can be a good candidate for elimination. But this very little info. 


-- Now that we have this info, let's now work with the orders. There should be very valuable information there. 

-- ------------------------------------------------------------------------------------------

-- First thing first. In order to get meaninful insights from past orders, we need to evaluate the status of the orders

select Status, count(orderNumber) as amt_orders
from orders
group by status
order by amt_orders desc;

-- Looks like there is a negligible amount of orders with problems (cancelled/on hold/disputed): 13/326. 6/326 In Process. 
-- Even though we know there are just a few orders with problems, to avoid issues we will now work with Shipped and Resolved orders.

-- Let's get rid of the unwanted orders.
create temporary table completedOrderdetails
select od.*
from orders o
join orderdetails od
on o.orderNumber = od.orderNumber
where o.status = 'shipped' or o.status = 'resolved';

-- Now let's get more info about the products. 
select * from completedOrderdetails;

-- It looks like the same product can be sold at different prices, no matter the quantity sold in each order. There are orders with low quantity with a lower price that orders with higher quantities of the same products. One would thing that the higher the amount ordered, the lower the price. This is not the case. Here is an example:
select * from completedOrderdetails
where productCode = 'S18_1749';

-- We could see the avg price they were sold with an avg function, but we need to take into account that each order sold a different amount of products, so the avg could vary significantly. The best way to procede is to create a new column were we can see the total revenue and with it get the respective average price. 
select sq.*, TotalRevenue / sq.TotalQtyOrdered as AvgPriceEach
from (
select productCode, sum(quantityOrdered) as TotalQtyOrdered, sum(quantityordered * priceEach) as TotalRevenue 
from completedOrderdetails
group by productCode
order by TotalQtyOrdered desc ) as sq;


-- Let's consolidate this info creating a table and adding the profit margin for each product and to which warehouse they belong. 
drop table productsSold;
create temporary table productsSold
select p.ProductCode, temp.TotalQtyOrdered, WarehouseCode, BuyPrice, round((TotalRevenue / TotalQtyOrdered),2) as AvgPriceEach, round((((TotalRevenue / TotalQtyOrdered) - buyPrice) / buyPrice * 100),2) as PctProfitMargin
from (
	select productCode, sum(quantityOrdered) as TotalQtyOrdered, sum(quantityordered * priceEach) as TotalRevenue 
    from completedOrderdetails
	group by productCode
    ) as temp
join products as p
on p.productCode = temp.productCode
order by TotalQtyOrdered desc;

-- Here is our new table
select * from productsSold;

-- Now that we know how many units were sold of each product, let's have a glance at the total products sold
select sum(TotalQtyOrdered)
from productsSold; -- 98.801 products sold. 

-- let's look how many products were sold by warehouse:
create temporary table warehouseDistribution
select subquery.warehousecode, subquery.TotalQtyOrdered, round((TotalQtyOrdered / sum(TotalQtyOrdered) over ()) * 100, 2) PctTotalOrdered
from (
	select warehouseCode, sum(TotalQtyOrdered) TotalQtyOrdered
	from productsSold
	group by warehousecode
	order by warehousecode
	) as subquery
;

select * from warehouseDistribution;
-- We now have a better picture of the situation. The distributions of the sales among the different warehouse, being warehouse b the best performer: it accounts for 34.05% of the total products sold.

-- At this point, we will complement the distribution findings with the profits generated.
drop table warehouseProfits;
create temporary table warehouseProfits
select sq.*,
	round((TotalCost / sum(TotalCost) over () * 100),2) as PctTotalCost,
    round((TotalRevenue / sum(TotalRevenue) over () * 100),2) as PctTotalRevenue,
	round((TotalProfit / sum(TotalProfit) over () * 100),2) as PctTotalProfit
from 
(
select warehouseCode, 
	sum(TotalQtyOrdered * BuyPrice) as TotalCost, 
    sum(TotalQtyOrdered * AvgPriceEach) as TotalRevenue, 
    sum(round((TotalQtyOrdered * BuyPrice * (PctProfitMargin / 100)),2)) as TotalProfit,
    round(avg(PctProfitMargin),2) as PctProfitMargin
from productsSold
group by warehouseCode
order by warehousecode
 ) as sq;
 
 select * from warehouseProfits;
 
-- 
-- The margins are very similar with the highest being 71.48% (warehouse c) and the lowest 68.72% (warehouse b)
-- We now see that both warehouse d and c account for almost the same amount (18.70% - 19.07%) of the total profit. This is very valuable info, specially knowing that c is 2.5 times bigger than d. 

-- Let's join warehouseDistribution, warehouseProfits and warehouseCapacity to see what we can get

select
	d.warehousecode, 
	d.PctTotalOrdered,
    round((currentStock / sum(currentStock) over () * 100), 2) as PctCurrentStock,
	p.PctTotalProfit,
    round((d.TotalQtyOrdered / maxCapacity * 100),2) as SoldProductsCapacityUsage
from warehouseDistribution d
join warehouseProfits p
on d.warehousecode = p.warehousecode
join warehouseCapacity c
on p.warehousecode = c.warehousecode;

-- In this last table we are able to see that in relation to the amount sold by each warehouse, c acounts for almost the same profit as d but all the products that were stored there only accounted for 8.54% of the maximum capacity, whereas in warehouse d, this number arises to almost 20%, which means that the space of the warehouse is being better utilized. In that regard, warehouse d is by far the best one. 
-- On the other hand, warehouse b, even though that is bigger than c, it is also better utilized than c. And let's not forget that it accounts of almost half the profit. 

-- With this info, and with the info from warehouseCapacity, I could confidently state that base on this data, warehouse c would be the warehouse that should be shutted down. Also, all its inventory could be redistributed to the 3 other warehouses and there would still be some space left. 

select currentStock 
from warehouseCapacity
where warehousecode = 'c';

select sum(currentCapLeft)
from warehouseCapacity
where warehouseCode != 'c'; 


