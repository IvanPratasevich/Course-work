create extension if not exists dblink;

truncate table dim_address,
dim_customer,
dim_website,
dim_brand,
dim_geography,
dim_category,
dim_subcategory,
dim_product,
dim_time,
fact_sales,
fact_delivery restart identity cascade;

drop table if exists staging_dim_address;

create table
  staging_dim_address (
    address_id int,
    city varchar(50),
    country varchar(50)
  );

drop table if exists staging_dim_customer;

create table
  staging_dim_customer (
    customer_id int,
    name varchar(100),
    email varchar(100),
    address_id int,
    start_date DATE,
    end_date DATE,
    is_current boolean
  );

drop table if exists staging_dim_brand;

create table
  staging_dim_brand (
    brand_id int,
    brand_name varchar(100),
    brand_description varchar(255),
    country_of_origin varchar(100),
    established_year int
  );

drop table if exists staging_dim_product;

create table
  staging_dim_product (
    product_id int,
    product_code varchar(50),
    product_name varchar(100),
    price decimal(10, 2),
    subcategory_id int,
    brand_id int,
    start_date DATE,
    end_date DATE,
    is_current boolean
  );

drop table if exists staging_fact_sales;

create table
  staging_fact_sales (
    sale_id int,
    product_id int,
    customer_id int,
    date DATE,
    quantity_sold int,
    total_sales decimal(10, 2)
  );

drop table if exists staging_dim_month;

create table
  staging_dim_month (
    month_id int primary key,
    month_number int not null,
    month_name varchar(20) not null,
    year int not null
  );

drop table if exists staging_dim_shipper;

create table
  staging_dim_shipper (
    shipper_id int primary key,
    name varchar(100),
    contact_id int,
    rating int
  );

drop table if exists staging_dim_shipper_contactinfo;

create table
  staging_dim_shipper_contactinfo (
    contact_id SERIAL primary key,
    phone_number varchar(50),
    contact_info varchar(255)
  );

drop table if exists staging_dim_quarter;

create table
  staging_dim_quarter (
    quarter_id int primary key,
    quarter_number int not null,
    quarter_name varchar(20) not null,
    year int not null
  );

drop table if exists staging_dim_time;

create table
  staging_dim_time (
    Date DATE primary key,
    year int not null,
    quarter int not null,
    month int not null,
    day int not null,
    month_id int not null,
    quarter_id int not null
  );

insert into
  staging_dim_address (address_id, city, country)
select distinct
  address_id,
  city,
  country
from
  dblink (
    'dbname=oltp_db user=postgres password=1234',
    'SELECT address_id, city, country FROM addresses'
  ) as source (
    address_id int,
    city varchar(50),
    country varchar(50)
  );

insert into
  staging_dim_customer (
    customer_id,
    name,
    email,
    address_id,
    start_date,
    end_date,
    is_current
  )
select distinct
  user_id,
  concat(first_name, ' ', last_name) as name,
  email,
  address_id,
  current_date,
  current_date + interval '30 days' + (random() * 30)::int * interval '1 day',
  true
from
  dblink (
    'dbname=oltp_db user=postgres password=1234',
    $dblink_query$
            SELECT
                u.user_id,
                u.first_name,
                u.last_name,
                u.email,
                dd.ship_address_id AS address_id
            FROM shop_users u, orders o, delivery_details dd
            WHERE u.user_id = o.user_id
              AND o.delivery_id = dd.delivery_id
            $dblink_query$
  ) as source (
    user_id int,
    first_name varchar(50),
    last_name varchar(50),
    email varchar(100),
    address_id int
  );

insert into
  staging_dim_brand (
    brand_id,
    brand_name,
    brand_description,
    country_of_origin,
    established_year
  )
select distinct
  brand_id,
  brand_name,
  brand_description,
  country_of_origin,
  established_year
from
  dblink (
    'dbname=oltp_db user=postgres password=1234',
    'SELECT brand_id, brand_name, brand_description, country_of_origin, established_year FROM brands'
  ) as source (
    brand_id int,
    brand_name varchar(100),
    brand_description varchar(255),
    country_of_origin varchar(100),
    established_year int
  );

insert into
  staging_dim_product (
    product_id,
    product_code,
    product_name,
    price,
    subcategory_id,
    brand_id,
    start_date,
    end_date,
    is_current
  )
select distinct
  product_id,
  product_code,
  product_name,
  price,
  subcategory_id,
  brand_id,
  current_date,
  current_date + interval '30 days' + (random() * 30)::int * interval '1 day',
  true
from
  dblink (
    'dbname=oltp_db user=postgres password=1234',
    'SELECT product_id, product_code, product_name, price, subcategory_id, brand_id FROM products'
  ) as source (
    product_id int,
    product_code varchar(50),
    product_name varchar(100),
    price decimal(10, 2),
    subcategory_id int,
    brand_id int
  );

insert into
  staging_fact_sales (
    sale_id,
    product_id,
    customer_id,
    date,
    quantity_sold,
    total_sales
  )
select distinct
  order_detail_id,
  product_id,
  user_id,
  order_date,
  quantity,
  quantity * price_each
from
  dblink (
    'dbname=oltp_db user=postgres password=1234',
    'SELECT od.order_detail_id, od.product_id, o.user_id, o.order_date, od.quantity, od.price_each FROM order_details od JOIN orders o ON od.order_id = o.order_id'
  ) as source (
    order_detail_id int,
    product_id int,
    user_id int,
    order_date DATE,
    quantity int,
    price_each decimal(10, 2)
  );

drop table if exists staging_dim_website;

create table
  staging_dim_website (
    website_id int,
    website_url varchar(255),
    logo_url varchar(255)
  );

drop table if exists staging_dim_geography;

create table
  staging_dim_geography (
    geography_id int,
    country varchar(100),
    region varchar(100),
    city varchar(100)
  );

drop table if exists staging_dim_category;

create table
  staging_dim_category (
    category_id int,
    category_name varchar(100),
    category_description varchar(255)
  );

drop table if exists staging_dim_subcategory;

create table
  staging_dim_subcategory (
    subcategory_id int,
    subcategory_name varchar(100),
    category_id int,
    subcategory_description varchar(255)
  );

drop table if exists staging_dim_status;

create table
  staging_dim_status (status_id int, status_name varchar(50));

drop table if exists staging_dim_payment_method;

create table
  staging_dim_payment_method (
    payment_method_id int,
    payment_method_name varchar(50)
  );

drop table if exists staging_fact_delivery;

create table
  staging_fact_delivery (
    delivery_id int,
    shipper_id int,
    order_id int,
    Date DATE,
    geography_id int,
    delivery_time decimal(10, 2),
    delivery_cost decimal(10, 2)
  );

truncate table staging_fact_delivery,
staging_fact_sales,
staging_dim_address,
staging_dim_customer,
staging_dim_brand,
staging_dim_website,
staging_dim_geography,
staging_dim_category,
staging_dim_subcategory,
staging_dim_product,
staging_dim_status,
staging_dim_payment_method restart identity cascade;

insert into
  staging_fact_sales (
    sale_id,
    product_id,
    customer_id,
    date,
    quantity_sold,
    total_sales
  )
select distinct
  order_detail_id,
  product_id,
  user_id,
  order_date,
  quantity,
  quantity * price_each
from
  dblink (
    'dbname=oltp_db user=postgres password=1234',
    'SELECT od.order_detail_id, od.product_id, o.user_id, o.order_date, od.quantity, od.price_each
             FROM order_details od
             JOIN orders o ON od.order_id = o.order_id'
  ) as source (
    order_detail_id int,
    product_id int,
    user_id int,
    order_date DATE,
    quantity int,
    price_each decimal(10, 2)
  );

insert into
  staging_fact_delivery (
    delivery_id,
    shipper_id,
    order_id,
    Date,
    geography_id,
    delivery_time,
    delivery_cost
  )
select distinct
  source.delivery_id,
  source.shipper_id,
  source.order_id,
  source.order_date as Date,
  geography.geography_id,
  cast(null as numeric) as delivery_time,
  cast(null as numeric) as delivery_cost
from
  (
    select
      delivery_id,
      shipper_id,
      ship_address_id,
      order_id,
      order_date
    from
      dblink (
        'dbname=oltp_db user=postgres password=1234',
        'SELECT delivery_details.delivery_id, delivery_details.shipper_id, delivery_details.ship_address_id, orders.order_id, orders.order_date
                 FROM delivery_details
                 JOIN orders ON delivery_details.delivery_id = orders.delivery_id'
      ) as dblink_result (
        delivery_id int,
        shipper_id int,
        ship_address_id int,
        order_id int,
        order_date DATE
      )
  ) as source
  left join staging_dim_geography geography on source.ship_address_id = geography.geography_id;

insert into
  staging_dim_address (address_id, city, country)
select distinct
  address_id,
  city,
  country
from
  dblink (
    'dbname=oltp_db user=postgres password=1234',
    'SELECT address_id, city, country FROM addresses'
  ) as source (
    address_id int,
    city varchar(50),
    country varchar(50)
  );

insert into
  staging_dim_customer (
    customer_id,
    name,
    email,
    address_id,
    start_date,
    end_date,
    is_current
  )
select distinct
  user_id,
  concat(first_name, ' ', last_name) as name,
  email,
  address_id,
  current_date,
  current_date + interval '30 days' + (random() * 30)::int * interval '1 day',
  true
from
  dblink (
    'dbname=oltp_db user=postgres password=1234',
    'SELECT u.user_id, u.first_name, u.last_name, u.email, dd.ship_address_id AS address_id
             FROM shop_users u
             JOIN orders o ON u.user_id = o.user_id
             JOIN delivery_details dd ON o.delivery_id = dd.delivery_id'
  ) as source (
    user_id int,
    first_name varchar(50),
    last_name varchar(50),
    email varchar(100),
    address_id int
  );

insert into
  staging_dim_brand (
    brand_id,
    brand_name,
    brand_description,
    country_of_origin,
    established_year
  )
select distinct
  brand_id,
  brand_name,
  brand_description,
  country_of_origin,
  established_year
from
  dblink (
    'dbname=oltp_db user=postgres password=1234',
    'SELECT brand_id, brand_name, brand_description, country_of_origin, established_year FROM brands'
  ) as source (
    brand_id int,
    brand_name varchar(100),
    brand_description varchar(255),
    country_of_origin varchar(100),
    established_year int
  );

insert into
  staging_dim_website (website_id, website_url, logo_url)
select distinct
  brand_id as website_id,
  website_url,
  logo_url
from
  dblink (
    'dbname=oltp_db user=postgres password=1234',
    'SELECT brand_id, website_url, logo_url FROM brands'
  ) as source (
    brand_id int,
    website_url varchar(255),
    logo_url varchar(255)
  );

insert into
  staging_dim_geography (geography_id, country, region, city)
select distinct
  address_id as geography_id,
  country,
  null as region,
  city
from
  dblink (
    'dbname=oltp_db user=postgres password=1234',
    'SELECT address_id, country, city FROM addresses'
  ) as source (
    address_id int,
    country varchar(100),
    city varchar(100)
  );

insert into
  staging_dim_category (category_id, category_name, category_description)
select distinct
  category_id,
  category_name,
  category_description
from
  dblink (
    'dbname=oltp_db user=postgres password=1234',
    'SELECT category_id, category_name, category_description FROM categories'
  ) as source (
    category_id int,
    category_name varchar(100),
    category_description varchar(255)
  );

insert into
  staging_dim_subcategory (
    subcategory_id,
    subcategory_name,
    category_id,
    subcategory_description
  )
select distinct
  subcategory_id,
  subcategory_name,
  category_id,
  subcategory_description
from
  dblink (
    'dbname=oltp_db user=postgres password=1234',
    'SELECT subcategory_id, subcategory_name, category_id, subcategory_description FROM subcategories'
  ) as source (
    subcategory_id int,
    subcategory_name varchar(100),
    category_id int,
    subcategory_description varchar(255)
  );

insert into
  dim_product (
    product_id,
    product_code,
    name,
    price,
    subcategory_id,
    start_date,
    end_ate,
    is_current
  )
select
  product_id,
  cast(product_code as integer),
  product_name as name,
  price,
  subcategory_id,
  start_date,
  end_date,
  is_current
from
  staging_dim_product;

insert into
  staging_dim_status (status_id, status_name)
select distinct
  row_number() over (
    order by
      order_status
  ) as status_id,
  order_status as status_name
from
  dblink (
    'dbname=oltp_db user=postgres password=1234',
    'SELECT DISTINCT order_status FROM orders'
  ) as source (order_status varchar(50));

insert into
  staging_dim_payment_method (payment_method_id, payment_method_name)
select distinct
  row_number() over (
    order by
      payment_method
  ) as payment_method_id,
  payment_method as payment_method_name
from
  dblink (
    'dbname=oltp_db user=postgres password=1234',
    'SELECT DISTINCT payment_method FROM orders WHERE payment_method IS NOT NULL'
  ) as source (payment_method varchar(50));

insert into
  staging_dim_month (month_id, month_number, month_name, year)
select distinct
  extract(
    month
    from
      order_date
  ) as month_id,
  extract(
    month
    from
      order_date
  ) as month_number,
  to_char(order_date, 'Month') as month_name,
  extract(
    year
    from
      order_date
  ) as year
from
  dblink (
    'dbname=oltp_db user=postgres password=1234',
    'SELECT DISTINCT order_date FROM orders'
  ) as source (order_date DATE)
on conflict (month_id) do nothing;

insert into
  staging_dim_quarter (quarter_id, quarter_number, quarter_name, year)
select distinct
  extract(
    quarter
    from
      order_date
  ) as quarter_id,
  extract(
    quarter
    from
      order_date
  ) as quarter_number,
  concat(
    'Q',
    extract(
      quarter
      from
        order_date
    )
  ) as quarter_name,
  extract(
    year
    from
      order_date
  ) as year
from
  dblink (
    'dbname=oltp_db user=postgres password=1234',
    'SELECT DISTINCT order_date FROM orders'
  ) as source (order_date DATE)
on conflict (quarter_id) do nothing;

insert into
  staging_dim_time (
    Date,
    year,
    quarter,
    month,
    day,
    month_id,
    quarter_id
  )
select distinct
  order_date as Date,
  extract(
    year
    from
      order_date
  ) as year,
  extract(
    quarter
    from
      order_date
  ) as quarter,
  extract(
    month
    from
      order_date
  ) as month,
  extract(
    day
    from
      order_date
  ) as day,
  extract(
    month
    from
      order_date
  ) as month_id,
  extract(
    quarter
    from
      order_date
  ) as quarter_id
from
  dblink (
    'dbname=oltp_db user=postgres password=1234',
    'SELECT DISTINCT order_date FROM orders'
  ) as source (order_date DATE);

insert into
  staging_dim_shipper (shipper_id, name, contact_id, rating)
select distinct
  shipper_id,
  shipper_name as name,
  row_number() over (
    order by
      shipper_id
  ) as contact_id,
  rating
from
  dblink (
    'dbname=oltp_db user=postgres password=1234',
    'SELECT shipper_id, shipper_name, rating FROM shippers'
  ) as source (
    shipper_id int,
    shipper_name varchar(100),
    rating int
  );

insert into
  dim_address (address_id, city, country)
select
  address_id,
  city,
  country
from
  staging_dim_address;

insert into
  dim_customer (
    customer_id,
    name,
    email,
    address_id,
    start_date,
    end_date,
    is_current
  )
select
  customer_id,
  name,
  email,
  address_id,
  start_date,
  end_date,
  is_current
from
  staging_dim_customer
on conflict (customer_id) do nothing;

insert into
  dim_brand (
    brand_id,
    brand_name,
    brand_description,
    country_of_origin,
    established_year
  )
select
  brand_id,
  brand_name,
  brand_description,
  country_of_origin,
  established_year
from
  staging_dim_brand;

insert into
  dim_product (
    product_id,
    product_code,
    name,
    price,
    subcategory_id,
    start_date,
    end_ate,
    is_current
  )
select
  product_id,
  cast(product_code as integer),
  product_name as name,
  price,
  subcategory_id,
  start_date,
  end_date,
  is_current
from
  staging_dim_product
on conflict (product_id) do nothing;

insert into
  fact_sales (
    sale_id,
    product_id,
    customer_id,
    date,
    quantity_sold,
    total_sales
  )
select
  sale_id,
  product_id,
  customer_id,
  date,
  quantity_sold,
  total_sales
from
  staging_fact_sales sfs
where
  exists (
    select
      1
    from
      dim_product dp
    where
      dp.product_id = sfs.product_id
  );

insert into
  dim_website (website_id, website_url, logo_url)
select
  website_id,
  website_url,
  logo_url
from
  staging_dim_website;

insert into
  dim_geography (geography_id, country, region, city)
select
  geography_id,
  country,
  region,
  city
from
  staging_dim_geography;

insert into
  dim_category (category_id, category_name)
select
  category_id,
  category_name
from
  staging_dim_category;

insert into
  dim_subcategory (subcategory_id, subcategory_name, category_id)
select
  subcategory_id,
  subcategory_name,
  category_id
from
  staging_dim_subcategory;

insert into
  dim_status (status_id, status_name)
select
  status_id,
  status_name
from
  staging_dim_status
on conflict (status_id) do nothing;

insert into
  dim_payment_method (payment_method_id, payment_method_name)
select
  payment_method_id,
  payment_method_name
from
  staging_dim_payment_method
on conflict (payment_method_id) do nothing;

insert into
  dim_month (month_id, month_number, month_name, year)
select
  month_id,
  month_number,
  month_name,
  year
from
  staging_dim_month
on conflict (month_id) do nothing;

insert into
  dim_quarter (quarter_id, quarter_number, quarter_name, year)
select
  quarter_id,
  quarter_number,
  quarter_name,
  year
from
  staging_dim_quarter
on conflict (quarter_id) do nothing;

insert into
  dim_time (
    date,
    year,
    quarter,
    month,
    day,
    month_id,
    quarter_id
  )
select
  date,
  year,
  quarter,
  month,
  day,
  month_id,
  quarter_id
from
  staging_dim_time;

insert into
  dim_shipper_contactinfo (contact_id, phone_number, contact_info)
select
  contact_id,
  phone_number,
  contact_info
from
  staging_dim_shipper_contactinfo;

insert into
  dim_shipper (shipper_id, name, contact_id, rating)
select
  shipper_id,
  name,
  contact_id,
  rating
from
  staging_dim_shipper sds
where
  exists (
    select
      1
    from
      dim_shipper_contactinfo dsci
    where
      dsci.contact_id = sds.contact_id
  );

select
  *
from
  staging_dim_product;