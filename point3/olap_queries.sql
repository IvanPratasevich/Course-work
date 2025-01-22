-- 1)
select
  fs.OrderNumber,
  dd.FullDate as OrderDate,
  fs.Quantity,
  fs.PriceEach,
  dp.ProductName,
  fs.BrandName,
  dp.ProductID,
  dp.Price
from
  FactSales fs
  join DimCustomer dc on fs.CustomerKey = dc.CustomerKey
  join DimDate dd on fs.DateKey = dd.DateKey
  join DimProduct dp on fs.ProductKey = dp.ProductKey
where
  dc.CustomerID = 22
order by
  dd.FullDate desc;

--- 3)
select
  dd.year as delivery_year,
  count(*) as delivery_count
from
  FactDelivery fd
  join DimDate dd on fd.DateKey = dd.DateKey
group by
  dd.year
order by
  delivery_count desc
limit
  1;

-- Products sold by month
select
  dd.year,
  dd.month,
  dd.MonthName,
  count(fs.ProductKey) as total_products_sold,
  array_agg(distinct dp.ProductName) as products
from
  FactSales fs
  join DimDate dd on fs.DateKey = dd.DateKey
  join DimProduct dp on fs.ProductKey = dp.ProductKey
group by
  dd.year,
  dd.month,
  dd.MonthName
order by
  dd.year,
  dd.month;


-- The heaviest products
select
  dp.ProductName,
  dp.Weight as weight
from
  DimProduct dp
where
  dp.Weight is not null
order by
  dp.Weight desc
limit
  50;


-- Number of products by brand
select
  BrandName as brand,
  count(distinct ProductKey) as total_products
from
  FactSales
group by
  BrandName
order by
  total_products desc;