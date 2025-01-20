-- List of Orders with Products for a Specific User

SELECT
    o.order_id,
    o.order_number,
    o.order_date,
    o.order_status,
    od.quantity,
    od.price_each,
    p.product_name,
    p.product_code,
    p.price
FROM
    orders o
JOIN
    order_details od ON o.order_id = od.order_id
JOIN
    products p ON od.product_id = p.product_id
WHERE
    o.user_id = 22  -- user ID
ORDER BY
    o.order_date DESC;


--- Get the List of Favorite Products for a User

SELECT
    f.favorite_id,
    p.product_name,
    p.product_code,
    p.price,
    f.stars,
    f.liked_date
FROM
    favorites f
JOIN
    products p ON f.product_id = p.product_id
WHERE
    f.user_id = 1  -- user ID
ORDER BY
    p.price DESC;

-- Calculate in which year there were the most deliveries

SELECT
    EXTRACT(YEAR FROM o.order_date) AS year,
    COUNT(*) AS delivery_count
FROM
    orders o
JOIN
    delivery_details dd ON o.delivery_id = dd.delivery_id
GROUP BY
    year
ORDER BY
    delivery_count DESC
LIMIT 1;

