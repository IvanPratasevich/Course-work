set
  datestyle to 'ISO, MDY';

drop table
  if exists staging_addresses;

create table
  staging_addresses (
    address varchar(150),
    city varchar(50),
    country varchar(60)
  );

copy
  staging_addresses(address, city, country)
from
  'd:/Course-Work/point1/csv/addresses.csv' delimiter ',' csv header;

truncate
  table addresses restart identity cascade;

insert into
  addresses (address, city, country)
select
  distinct address,
  city,
  country
from
  staging_addresses on conflict
do
  nothing;

truncate
  table staging_addresses;

drop table
  if exists staging_shippers;

create table
  staging_shippers (
    shipper_name varchar(100),
    contact_info varchar(255),
    phone varchar(50),
    status BOOLEAN,
    website_url varchar(255),
    company_type varchar(100),
    tax_id varchar(50),
    insurance_number varchar(100),
    payment_terms varchar(100),
    rating INTEGER,
    max_weight_capacity INTEGER
  );

copy
  staging_shippers(
    shipper_name,
    contact_info,
    phone,
    status,
    website_url,
    company_type,
    tax_id,
    insurance_number,
    payment_terms,
    rating,
    max_weight_capacity
  )
from
  'd:/Course-Work/point1/csv/shippers.csv' delimiter ',' csv header;

truncate
  table shippers restart identity cascade;

insert into
  shippers (
    shipper_name,
    contact_info,
    phone,
    status,
    website_url,
    company_type,
    tax_id,
    insurance_number,
    payment_terms,
    rating,
    max_weight_capacity
  )
select
  distinct shipper_name,
  contact_info,
  phone,
  status,
  website_url,
  company_type,
  tax_id,
  insurance_number,
  payment_terms,
  rating,
  max_weight_capacity
from
  staging_shippers on conflict (shipper_name)
do
  nothing;

truncate
  table staging_shippers;

drop table
  if exists staging_categories;

create table
  staging_categories (
    category_name varchar(100),
    category_description varchar(255)
  );

copy
  staging_categories(category_name, category_description)
from
  'd:/Course-Work/point1/csv/categories.csv' delimiter ',' csv header;

truncate
  table categories restart identity cascade;

insert into
  categories (category_name, category_description)
select
  distinct category_name,
  category_description
from
  staging_categories on conflict (category_name)
do
  nothing;

truncate
  table staging_categories;

drop table
  if exists staging_subcategories;

create table
  staging_subcategories (
    subcategory_name varchar(100),
    category_name varchar(100),
    subcategory_description varchar(255)
  );

copy
  staging_subcategories(
    subcategory_name,
    category_name,
    subcategory_description
  )
from
  'd:/Course-Work/point1/csv/subcategories.csv' delimiter ',' csv header;

truncate
  table subcategories restart identity cascade;

insert into
  subcategories (
    subcategory_name,
    category_id,
    subcategory_description
  )
select
  subcategory_name,
  (
    select
      category_id
    from
      categories
    where
      categories.category_name = staging_subcategories.category_name
  ),
  subcategory_description
from
  staging_subcategories on conflict (subcategory_name)
do
  nothing;

truncate
  table staging_subcategories;

drop table
  if exists staging_brands;

create table
  staging_brands (
    brand_name varchar(100),
    brand_description TEXT,
    status BOOLEAN default true,
    website_url varchar(255),
    country_of_origin varchar(60),
    established_year INT,
    logo_url varchar(255)
  );

copy
  staging_brands(
    brand_name,
    brand_description,
    status,
    website_url,
    country_of_origin,
    established_year,
    logo_url
  )
from
  'd:/Course-Work/point1/csv/brands.csv' delimiter ',' csv header;

truncate
  table brands restart identity cascade;

insert into
  brands (
    brand_name,
    brand_description,
    status,
    website_url,
    country_of_origin,
    established_year,
    logo_url
  )
select
  distinct brand_name,
  brand_description,
  status,
  website_url,
  country_of_origin,
  established_year,
  logo_url
from
  staging_brands on conflict (brand_name)
do
  nothing;

truncate
  table staging_brands;

drop table
  if exists staging_manufacturers;

create table
  staging_manufacturers (
    manufacturer_name varchar(100),
    address varchar(150),
    city varchar(50),
    country varchar(60),
    contact_info varchar(255)
  );

copy
  staging_manufacturers(
    manufacturer_name,
    address,
    city,
    country,
    contact_info
  )
from
  'd:/Course-Work/point1/csv/manufacturers.csv' delimiter ',' csv header;

truncate
  table manufacturers restart identity cascade;

insert into
  manufacturers (
    manufacturer_name,
    manufacturer_address_id,
    contact_info
  )
select
  distinct manufacturer_name,
  (
    select
      address_id
    from
      addresses
    where
      addresses.address = staging_manufacturers.address
      and addresses.city = staging_manufacturers.city
      and addresses.country = staging_manufacturers.country
  ),
  contact_info
from
  staging_manufacturers
where
  exists (
    select
      1
    from
      addresses
    where
      addresses.address = staging_manufacturers.address
      and addresses.city = staging_manufacturers.city
      and addresses.country = staging_manufacturers.country
  ) on conflict (manufacturer_name)
do
  nothing;

truncate
  table staging_manufacturers;

drop table
  if exists staging_product_colors;

create table
  staging_product_colors (color_name varchar(50), description TEXT);

copy
  staging_product_colors(color_name, description)
from
  'd:/Course-Work/point1/csv/product_colors.csv' delimiter ',' csv header;

truncate
  table product_colors restart identity cascade;

insert into
  product_colors (color_name, description)
select
  distinct color_name,
  description
from
  staging_product_colors on conflict (color_name)
do
  nothing;

truncate
  table staging_product_colors;

drop table
  if exists staging_product_weights;

create table
  staging_product_weights (weight_value numeric(10, 2));

copy
  staging_product_weights(weight_value)
from
  'd:/Course-Work/point1/csv/product_weights.csv' delimiter ',' csv header;

insert into
  product_weights (weight_value)
select
  distinct weight_value
from
  staging_product_weights on conflict (weight_value)
do
  nothing;

truncate
  table staging_product_weights;

drop table
  if exists staging_product_dimensions;

create table
  staging_product_dimensions (dimension_value varchar(50), description TEXT);

copy
  staging_product_dimensions(dimension_value, description)
from
  'd:/Course-Work/point1/csv/product_dimensions.csv' delimiter ',' csv header;

insert into
  product_dimensions (dimension_value, description)
select
  distinct dimension_value,
  description
from
  staging_product_dimensions on conflict (dimension_value)
do
  nothing;

truncate
  table staging_product_dimensions;

drop table
  if exists staging_products;

do
  $$
BEGIN
    IF NOT EXISTS (SELECT 1 FROM pg_type WHERE typname = 'currency_type') THEN
        CREATE TYPE currency_type AS ENUM ('USD', 'EUR', 'GBP');
    END IF;
END $$;

create table
  staging_products (
    product_code varchar(50),
    product_name varchar(100),
    product_description TEXT,
    price numeric(10, 2),
    currency currency_type,
    availability_status varchar(50),
    color_name varchar(50),
    weight_value numeric(10, 2),
    dimension_value varchar(100),
    power_supply varchar(50),
    subcategory_name varchar(100),
    brand_name varchar(100),
    manufacturer_name varchar(100)
  );

copy
  staging_products(
    product_code,
    product_name,
    product_description,
    price,
    currency,
    availability_status,
    color_name,
    weight_value,
    dimension_value,
    power_supply,
    subcategory_name,
    brand_name,
    manufacturer_name
  )
from
  'd:/Course-Work/point1/csv/products.csv' delimiter ',' csv header;

truncate
  table products restart identity cascade;

insert into
  products (
    product_code,
    product_name,
    product_description,
    price,
    currency,
    availability_status,
    color_id,
    weight_id,
    dimension_id,
    power_supply,
    subcategory_id,
    brand_id,
    manufacturer_id
  )
select
  product_code,
  product_name,
  product_description,
  price,
  currency,
  availability_status,
  (
    select
      color_id
    from
      product_colors
    where
      product_colors.color_name = staging_products.color_name
  ),
  (
    select
      weight_id
    from
      product_weights
    where
      product_weights.weight_value = staging_products.weight_value
  ),
  (
    select
      dimension_id
    from
      product_dimensions
    where
      product_dimensions.dimension_value = staging_products.dimension_value
  ),
  power_supply,
  (
    select
      subcategory_id
    from
      subcategories
    where
      subcategories.subcategory_name = staging_products.subcategory_name
  ),
  (
    select
      brand_id
    from
      brands
    where
      brands.brand_name = staging_products.brand_name
  ),
  (
    select
      manufacturer_id
    from
      manufacturers
    where
      manufacturers.manufacturer_name = staging_products.manufacturer_name
  )
from
  staging_products on conflict (product_code)
do
update
set
  product_name = excluded.product_name,
  product_description = excluded.product_description,
  price = excluded.price,
  currency = excluded.currency,
  availability_status = excluded.availability_status,
  color_id = excluded.color_id,
  weight_id = excluded.weight_id,
  dimension_id = excluded.dimension_id,
  power_supply = excluded.power_supply,
  subcategory_id = excluded.subcategory_id,
  brand_id = excluded.brand_id,
  manufacturer_id = excluded.manufacturer_id;

truncate
  table staging_products;

drop table
  if exists staging_shop_users;

create table
  staging_shop_users (
    email varchar(100),
    first_name varchar(80),
    last_name varchar(80),
    username varchar(50),
    password varchar(255),
    role varchar(50),
    phone varchar(50),
    status BOOLEAN,
    birthdate DATE,
    is_verified BOOLEAN,
    profile_picture_url varchar(255)
  );

copy
  staging_shop_users(
    email,
    first_name,
    last_name,
    username,
    password,
    role,
    phone,
    status,
    birthdate,
    is_verified,
    profile_picture_url
  )
from
  'd:/Course-Work/point1/csv/shop_users.csv' delimiter ',' csv header;

truncate
  table shop_users restart identity cascade;

insert into
  shop_users (
    email,
    first_name,
    last_name,
    username,
    password,
    role,
    phone,
    status,
    birthdate,
    is_verified,
    profile_picture_url
  )
select
  distinct email,
  first_name,
  last_name,
  username,
  password,
  role,
  phone,
  status,
  birthdate,
  is_verified,
  profile_picture_url
from
  staging_shop_users on conflict (email)
do
update
set
  first_name = excluded.first_name,
  last_name = excluded.last_name,
  username = excluded.username,
  password = excluded.password,
  role = excluded.role,
  phone = excluded.phone,
  status = excluded.status,
  birthdate = excluded.birthdate,
  is_verified = excluded.is_verified,
  profile_picture_url = excluded.profile_picture_url;

truncate
  table staging_shop_users;

drop table
  if exists staging_baskets;

create table
  staging_baskets (user_email varchar(100), creation_date TIMESTAMP);

copy
  staging_baskets(user_email, creation_date)
from
  'd:/Course-Work/point1/csv/baskets.csv' delimiter ',' csv header;

truncate
  table baskets restart identity cascade;

insert into
  baskets (user_id, creation_date)
select
  distinct (
    select
      user_id
    from
      shop_users
    where
      shop_users.email = staging_baskets.user_email
  ),
  creation_date
from
  staging_baskets;

truncate
  table staging_baskets;

drop table
  if exists staging_basket_details;

create table
  staging_basket_details (
    user_email varchar(100),
    creation_date TIMESTAMP,
    product_code varchar(50),
    quantity INT,
    price_when_added numeric(10, 2)
  );

copy
  staging_basket_details(
    user_email,
    creation_date,
    product_code,
    quantity,
    price_when_added
  )
from
  'd:/Course-Work/point1/csv/basket_details.csv' delimiter ',' csv header;

truncate
  table basket_details restart identity cascade;

insert into
  basket_details (basket_id, product_id, quantity, price_when_added)
select
  distinct (
    select
      basket_id
    from
      baskets
    where
      baskets.creation_date = staging_basket_details.creation_date
      and baskets.user_id = (
        select
          user_id
        from
          shop_users
        where
          shop_users.email = staging_basket_details.user_email
      )
  ),
  (
    select
      product_id
    from
      products
    where
      products.product_code = staging_basket_details.product_code
  ),
  quantity,
  price_when_added
from
  staging_basket_details;

truncate
  table staging_basket_details;

drop table
  if exists staging_delivery_details;

create table
  staging_delivery_details (
    delivery_method varchar(50),
    address varchar(150),
    city varchar(50),
    country varchar(60),
    shipper_name varchar(100)
  );

copy
  staging_delivery_details(
    delivery_method,
    address,
    city,
    country,
    shipper_name
  )
from
  'd:/Course-Work/point1/csv/delivery_details.csv' delimiter ',' csv header;

truncate
  table delivery_details restart identity cascade;

insert into
  delivery_details (delivery_method, ship_address_id, shipper_id)
select
  distinct delivery_method,
  (
    select
      address_id
    from
      addresses
    where
      addresses.address = staging_delivery_details.address
      and addresses.city = staging_delivery_details.city
      and addresses.country = staging_delivery_details.country
  ),
  (
    select
      shipper_id
    from
      shippers
    where
      shippers.shipper_name = staging_delivery_details.shipper_name
  )
from
  staging_delivery_details;

truncate
  table staging_delivery_details;

drop table
  if exists staging_employees;

create table
  staging_employees (
    employee_email varchar(100),
    first_name varchar(80),
    last_name varchar(80),
    hire_date DATE,
    birthdate DATE,
    address varchar(150),
    city varchar(50),
    country varchar(60),
    employee_role varchar(50)
  );

copy
  staging_employees(
    employee_email,
    first_name,
    last_name,
    hire_date,
    birthdate,
    address,
    city,
    country,
    employee_role
  )
from
  'd:/Course-Work/point1/csv/employees.csv' delimiter ',' csv header;

insert into
  employees (
    employee_email,
    first_name,
    last_name,
    hire_date,
    birthdate,
    address_id,
    employee_role
  )
select
  distinct employee_email,
  first_name,
  last_name,
  hire_date,
  birthdate,
  (
    select
      address_id
    from
      addresses
    where
      addresses.address = staging_employees.address
      and addresses.city = staging_employees.city
      and addresses.country = staging_employees.country
  ),
  employee_role
from
  staging_employees
where
  exists (
    select
      1
    from
      addresses
    where
      addresses.address = staging_employees.address
      and addresses.city = staging_employees.city
      and addresses.country = staging_employees.country
  );

truncate
  table staging_employees;

drop table
  if exists staging_orders;

create table
  staging_orders (
    order_number varchar(50),
    user_email varchar(100),
    order_date TIMESTAMP,
    order_status varchar(50),
    employee_email varchar(100),
    payment_method varchar(50),
    delivery_method varchar(50),
    address varchar(150),
    city varchar(50),
    country varchar(60),
    shipper_name varchar(100)
  );

copy
  staging_orders(
    order_number,
    user_email,
    order_date,
    order_status,
    employee_email,
    payment_method,
    delivery_method,
    address,
    city,
    country,
    shipper_name
  )
from
  'd:/Course-Work/point1/csv/orders.csv' delimiter ',' csv header;

truncate
  table orders restart identity cascade;

insert into
  orders (
    order_number,
    user_id,
    order_date,
    order_status,
    employee_id,
    payment_method,
    delivery_id
  )
select
  distinct order_number,
  (
    select
      user_id
    from
      shop_users
    where
      shop_users.email = staging_orders.user_email
  ),
  order_date,
  order_status,
  (
    select
      employee_id
    from
      employees
    where
      employees.employee_email = staging_orders.employee_email
  ),
  payment_method,
  (
    select
      delivery_id
    from
      delivery_details
    where
      delivery_details.delivery_method = staging_orders.delivery_method
      and delivery_details.ship_address_id = (
        select
          address_id
        from
          addresses
        where
          addresses.address = staging_orders.address
          and addresses.city = staging_orders.city
          and addresses.country = staging_orders.country
      )
      and delivery_details.shipper_id = (
        select
          shipper_id
        from
          shippers
        where
          shippers.shipper_name = staging_orders.shipper_name
      )
  )
from
  staging_orders;

truncate
  table staging_orders;

drop table
  if exists staging_order_details;

create table
  staging_order_details (
    order_number varchar(50),
    product_code varchar(50),
    quantity INT,
    price_each numeric(10, 2)
  );

copy
  staging_order_details(order_number, product_code, quantity, price_each)
from
  'd:/Course-Work/point1/csv/order_details.csv' delimiter ',' csv header;

truncate
  table order_details restart identity cascade;

insert into
  order_details (order_id, product_id, quantity, price_each)
select
  distinct (
    select
      order_id
    from
      orders
    where
      orders.order_number = staging_order_details.order_number
  ),
  (
    select
      product_id
    from
      products
    where
      products.product_code = staging_order_details.product_code
  ),
  quantity,
  price_each
from
  staging_order_details;

truncate
  table staging_order_details;

drop table
  if exists staging_favorites;

create table
  staging_favorites (
    email varchar(100),
    product_code varchar(50),
    liked_date TIMESTAMP,
    stars INT
  );

copy
  staging_favorites(email, product_code, liked_date, stars)
from
  'd:/Course-Work/point1/csv/favorites.csv' delimiter ',' csv header;

truncate
  table favorites restart identity cascade;

insert into
  favorites (user_id, product_id, liked_date, stars)
select
  distinct (
    select
      user_id
    from
      shop_users
    where
      shop_users.email = staging_favorites.email
  ),
  (
    select
      product_id
    from
      products
    where
      products.product_code = staging_favorites.product_code
  ),
  liked_date,
  stars
from
  staging_favorites;

truncate
  table staging_favorites;

-- select
--   *
-- from
--   products;
-- select
--   *
-- from
--   shippers;
-- select
--   *
-- from
--   shop_users;
-- select *
-- from addresses;

-- select *
-- from basket_details;

-- select *
-- from baskets;

-- select *
-- from brands;

-- select *
-- from categories;

-- select *
-- from delivery_details;

-- select *
-- from employees;

-- select *
-- from favorites;

-- select *
-- from manufacturers;

-- select *
-- from order_details;

-- select *
-- from orders;

-- select *
-- from product_colors;

-- select *
-- from product_dimensions;

-- select *
-- from product_weights;

select *
from products;

-- select *
-- from shippers;

-- select *
-- from shop_users;

-- select *
-- from orders;

-- select *
-- from subcategories;











