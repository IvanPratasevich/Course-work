-- 1) List of Orders with Products for a Specific User
select
  o.order_id,
  o.order_number,
  o.order_date,
  o.order_status,
  od.quantity,
  od.price_each,
  p.product_name,
  p.product_code,
  p.price
from
  orders o
  join order_details od on o.order_id = od.order_id
  join products p on od.product_id = p.product_id
where
  o.user_id = 22
order by
  o.order_date desc;

--- 2) Get the List of Favorite Products for a User
select
  f.favorite_id,
  p.product_name,
  p.product_code,
  p.price,
  f.stars,
  f.liked_date
from
  favorites f
  join products p on f.product_id = p.product_id
where
  f.user_id = 1
order by
  p.price desc;

-- 3) Calculate in which year there were the most deliveries
select
  extract(
    year
    from
      o.order_date
  ) as year,
  count(*) as delivery_count
from
  orders o
  join delivery_details dd on o.delivery_id = dd.delivery_id
group by
  year
order by
  delivery_count desc
limit
  1;

-- 4) Products sold by month
select
  date_part('year', o.order_date) as year,
  date_part('month', o.order_date) as month,
  count(od.product_id) as total_products_sold,
  array_agg(distinct p.product_name) as products
from
  orders o
  join order_details od on o.order_id = od.order_id
  join products p on od.product_id = p.product_id
group by
  date_part('year', o.order_date),
  date_part('month', o.order_date)
order by
  year,
  month;


-- The heaviest products
select
  p.product_name,
  pw.weight_value as weight
from
  products p
  join product_weights pw on p.weight_id = pw.weight_id
order by
  pw.weight_value desc
limit
  50;

-- 5) Number of products by brand
select
  b.brand_name as brand,
  count(p.product_id) as total_products
from
  brands b
  left join products p on b.brand_id = p.brand_id
group by
  b.brand_name
order by
  total_products desc;


select
  email
from
  shop_users
where
  first_name = 'Carl'
  and last_name = 'Wright';