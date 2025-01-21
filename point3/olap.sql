-- 1)

SELECT
    fs.OrderNumber,
    dd.FullDate AS OrderDate,
    fs.Quantity,
    fs.PriceEach,
    dp.ProductName,
    dp.ProductID,
    dp.Price
FROM
    FactSales fs
JOIN
    DimCustomer dc ON fs.CustomerKey = dc.CustomerKey
JOIN
    DimDate dd ON fs.DateKey = dd.DateKey
JOIN
    DimProduct dp ON fs.ProductKey = dp.ProductKey
WHERE
    dc.CustomerID = 22
ORDER BY
    dd.FullDate DESC;

--- 3)

SELECT
    dd.year AS delivery_year,
    COUNT(*) AS delivery_count
FROM
    FactDelivery fd
JOIN
    DimDate dd ON fd.DateKey = dd.DateKey
GROUP BY
    dd.year
ORDER BY
    delivery_count DESC
LIMIT 1;
