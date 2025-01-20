SELECT DISTINCT
    s.sale_id,
    p.product_id,
    s.customer_id,
    s.Date,
    s.brand_id,
    s.payment_method_id,
    s.status_id,
    s.quantity_sold,
    s.total_sales
FROM
    fact_sales s
JOIN
    dim_product p ON s.product_id = p.product_id
WHERE
    s.customer_id = 22
ORDER BY
    s.Date DESC;


-- Calculate in which year there were the most deliveries

SELECT
    EXTRACT(YEAR FROM date) AS year,
    COUNT(*) AS delivery_count
FROM
    fact_delivery
GROUP BY
    year
ORDER BY
    delivery_count DESC
LIMIT 1;
