CREATE EXTENSION IF NOT EXISTS dblink;

CREATE SCHEMA IF NOT EXISTS staging;

CREATE TABLE IF NOT EXISTS
  staging.addresses (
    address_id INT PRIMARY KEY,
    address VARCHAR(150),
    city VARCHAR(50),
    country VARCHAR(60)
  );

CREATE TABLE IF NOT EXISTS
  staging.employees (
    employee_id INT PRIMARY KEY,
    employee_email VARCHAR(100),
    first_name VARCHAR(80),
    last_name VARCHAR(80),
    hire_date DATE,
    birthdate DATE,
    address_id INT,
    employee_role VARCHAR(50)
  );

CREATE TABLE IF NOT EXISTS
  staging.shippers (
    shipper_id INT PRIMARY KEY,
    shipper_name VARCHAR(100),
    contact_info VARCHAR(255),
    phone VARCHAR(50),
    status BOOLEAN,
    website_url VARCHAR(255),
    company_type VARCHAR(100),
    tax_id VARCHAR(50),
    insurance_number VARCHAR(100),
    payment_terms VARCHAR(100),
    rating INT,
    max_weight_capacity INT
  );

CREATE TABLE IF NOT EXISTS
  staging.categories (
    category_id INT PRIMARY KEY,
    category_name VARCHAR(100),
    category_description VARCHAR(255)
  );

CREATE TABLE IF NOT EXISTS
  staging.subcategories (
    subcategory_id INT PRIMARY KEY,
    subcategory_name VARCHAR(100),
    category_id INT
  );

CREATE TABLE IF NOT EXISTS
  staging.brands (
    brand_id INT PRIMARY KEY,
    brand_name VARCHAR(100),
    brand_description VARCHAR(255),
    status BOOLEAN,
    website_url VARCHAR(255),
    country_of_origin VARCHAR(100),
    established_year INT,
    logo_url VARCHAR(255)
  );

CREATE TABLE IF NOT EXISTS
  staging.manufacturers (
    manufacturer_id INT PRIMARY KEY,
    manufacturer_name VARCHAR(100),
    manufacturer_address_id INT,
    contact_info VARCHAR(255)
  );

CREATE TABLE IF NOT EXISTS
  staging.products (
    product_id INT PRIMARY KEY,
    product_code VARCHAR(50),
    product_name VARCHAR(100),
    product_description TEXT,
    price NUMERIC(10, 2),
    currency VARCHAR(10),
    availability_status VARCHAR(50),
    color_id INT,
    weight_id INT,
    dimension_id INT,
    power_supply VARCHAR(50),
    subcategory_id INT,
    brand_id INT,
    manufacturer_id INT
  );

CREATE TABLE IF NOT EXISTS
  staging.shop_users (
    user_id INT PRIMARY KEY,
    email VARCHAR(100),
    first_name VARCHAR(80),
    last_name VARCHAR(80),
    username VARCHAR(50),
    PASSWORD VARCHAR(255),
    ROLE VARCHAR(50),
    phone VARCHAR(50),
    status BOOLEAN,
    birthdate DATE,
    is_verified BOOLEAN,
    profile_picture_url VARCHAR(255)
  );

CREATE TABLE IF NOT EXISTS
  staging.delivery_details (
    delivery_id INT PRIMARY KEY,
    delivery_method VARCHAR(50),
    ship_address_id INT,
    shipper_id INT
  );

CREATE TABLE IF NOT EXISTS
  staging.orders (
    order_id INT PRIMARY KEY,
    order_number VARCHAR(50),
    user_id INT,
    order_date TIMESTAMP,
    order_status VARCHAR(50),
    employee_id INT,
    payment_method VARCHAR(50),
    delivery_id INT
  );

CREATE TABLE IF NOT EXISTS
  staging.order_details (
    order_detail_id INT PRIMARY KEY,
    order_id INT,
    product_id INT,
    quantity INT,
    price_each NUMERIC(10, 2)
  );

INSERT INTO
  staging.addresses (address_id, address, city, country)
SELECT
  *
FROM
  dblink (
    'dbname=oltp_db user=postgres password=1234',
    'SELECT address_id, address, city, country FROM addresses'
  ) AS t (
    address_id INT,
    address VARCHAR,
    city VARCHAR,
    country VARCHAR
  )
ON CONFLICT (address_id) DO NOTHING;

INSERT INTO
  staging.employees (
    employee_id,
    employee_email,
    first_name,
    last_name,
    hire_date,
    birthdate,
    address_id,
    employee_role
  )
SELECT
  *
FROM
  dblink (
    'dbname=oltp_db user=postgres password=1234',
    'SELECT employee_id, employee_email, first_name, last_name, hire_date, birthdate, address_id, employee_role FROM employees'
  ) AS t (
    employee_id INT,
    employee_email VARCHAR,
    first_name VARCHAR,
    last_name VARCHAR,
    hire_date DATE,
    birthdate DATE,
    address_id INT,
    employee_role VARCHAR
  )
ON CONFLICT (employee_id) DO NOTHING;

INSERT INTO
  staging.shippers (
    shipper_id,
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
SELECT
  *
FROM
  dblink (
    'dbname=oltp_db user=postgres password=1234',
    'SELECT shipper_id, shipper_name, contact_info, phone, status, website_url, company_type, tax_id, insurance_number, payment_terms, rating, max_weight_capacity FROM shippers'
  ) AS t (
    shipper_id INT,
    shipper_name VARCHAR,
    contact_info VARCHAR,
    phone VARCHAR,
    status BOOLEAN,
    website_url VARCHAR,
    company_type VARCHAR,
    tax_id VARCHAR,
    insurance_number VARCHAR,
    payment_terms VARCHAR,
    rating INT,
    max_weight_capacity INT
  )
ON CONFLICT (shipper_id) DO NOTHING;

INSERT INTO
  staging.categories (category_id, category_name, category_description)
SELECT
  *
FROM
  dblink (
    'dbname=oltp_db user=postgres password=1234',
    'SELECT category_id, category_name, category_description FROM categories'
  ) AS t (
    category_id INT,
    category_name VARCHAR,
    category_description VARCHAR
  )
ON CONFLICT (category_id) DO NOTHING;

INSERT INTO
  staging.subcategories (subcategory_id, subcategory_name, category_id)
SELECT
  *
FROM
  dblink (
    'dbname=oltp_db user=postgres password=1234',
    'SELECT subcategory_id, subcategory_name, category_id FROM subcategories'
  ) AS t (
    subcategory_id INT,
    subcategory_name VARCHAR,
    category_id INT
  )
ON CONFLICT (subcategory_id) DO NOTHING;

INSERT INTO
  staging.products (
    product_id,
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
SELECT
  *
FROM
  dblink (
    'dbname=oltp_db user=postgres password=1234',
    'SELECT product_id, product_code, product_name, product_description, price, currency, availability_status, color_id, weight_id, dimension_id, power_supply, subcategory_id, brand_id, manufacturer_id FROM products'
  ) AS t (
    product_id INT,
    product_code VARCHAR,
    product_name VARCHAR,
    product_description TEXT,
    price NUMERIC,
    currency VARCHAR,
    availability_status VARCHAR,
    color_id INT,
    weight_id INT,
    dimension_id INT,
    power_supply VARCHAR,
    subcategory_id INT,
    brand_id INT,
    manufacturer_id INT
  )
ON CONFLICT (product_id) DO NOTHING;

INSERT INTO
  staging.brands (
    brand_id,
    brand_name,
    brand_description,
    status,
    website_url,
    country_of_origin,
    established_year,
    logo_url
  )
SELECT
  *
FROM
  dblink (
    'dbname=oltp_db user=postgres password=1234',
    'SELECT brand_id, brand_name, brand_description, status, website_url, country_of_origin, established_year, logo_url FROM brands'
  ) AS t (
    brand_id INT,
    brand_name VARCHAR,
    brand_description VARCHAR,
    status BOOLEAN,
    website_url VARCHAR,
    country_of_origin VARCHAR,
    established_year INT,
    logo_url VARCHAR
  )
ON CONFLICT (brand_id) DO NOTHING;

INSERT INTO
  staging.manufacturers (
    manufacturer_id,
    manufacturer_name,
    manufacturer_address_id,
    contact_info
  )
SELECT
  *
FROM
  dblink (
    'dbname=oltp_db user=postgres password=1234',
    'SELECT manufacturer_id, manufacturer_name, manufacturer_address_id, contact_info FROM manufacturers'
  ) AS t (
    manufacturer_id INT,
    manufacturer_name VARCHAR,
    manufacturer_address_id INT,
    contact_info VARCHAR
  )
ON CONFLICT (manufacturer_id) DO NOTHING;

INSERT INTO
  staging.shop_users (
    user_id,
    email,
    first_name,
    last_name,
    username,
    PASSWORD,
    ROLE,
    phone,
    status,
    birthdate,
    is_verified,
    profile_picture_url
  )
SELECT
  *
FROM
  dblink (
    'dbname=oltp_db user=postgres password=1234',
    'SELECT user_id, email, first_name, last_name, username, password, role, phone, status, birthdate, is_verified, profile_picture_url FROM shop_users'
  ) AS t (
    user_id INT,
    email VARCHAR,
    first_name VARCHAR,
    last_name VARCHAR,
    username VARCHAR,
    PASSWORD VARCHAR,
    ROLE VARCHAR,
    phone VARCHAR,
    status BOOLEAN,
    birthdate DATE,
    is_verified BOOLEAN,
    profile_picture_url VARCHAR
  )
ON CONFLICT (user_id) DO NOTHING;

INSERT INTO
  staging.delivery_details (
    delivery_id,
    delivery_method,
    ship_address_id,
    shipper_id
  )
SELECT
  *
FROM
  dblink (
    'dbname=oltp_db user=postgres password=1234',
    'SELECT delivery_id, delivery_method, ship_address_id, shipper_id FROM delivery_details'
  ) AS t (
    delivery_id INT,
    delivery_method VARCHAR,
    ship_address_id INT,
    shipper_id INT
  )
ON CONFLICT (delivery_id) DO NOTHING;

INSERT INTO
  staging.orders (
    order_id,
    order_number,
    user_id,
    order_date,
    order_status,
    employee_id,
    payment_method,
    delivery_id
  )
SELECT
  *
FROM
  dblink (
    'dbname=oltp_db user=postgres password=1234',
    'SELECT order_id, order_number, user_id, order_date, order_status, employee_id, payment_method, delivery_id FROM orders'
  ) AS t (
    order_id INT,
    order_number VARCHAR,
    user_id INT,
    order_date TIMESTAMP,
    order_status VARCHAR,
    employee_id INT,
    payment_method VARCHAR,
    delivery_id INT
  )
ON CONFLICT (order_id) DO NOTHING;

INSERT INTO
  staging.order_details (
    order_detail_id,
    order_id,
    product_id,
    quantity,
    price_each
  )
SELECT
  *
FROM
  dblink (
    'dbname=oltp_db user=postgres password=1234',
    'SELECT order_detail_id, order_id, product_id, quantity, price_each FROM order_details'
  ) AS t (
    order_detail_id INT,
    order_id INT,
    product_id INT,
    quantity INT,
    price_each NUMERIC
  )
ON CONFLICT (order_detail_id) DO NOTHING;

INSERT INTO
  dim_address (address_id, city, country)
SELECT DISTINCT
  address_id,
  city,
  country
FROM
  staging.addresses
ON CONFLICT (address_id) DO NOTHING;

INSERT INTO
  dim_brand (
    brand_id,
    brand_sk,
    brand_name,
    brand_description,
    website_id,
    start_date,
    end_date,
    is_current,
    country_of_origin,
    established_year
  )
SELECT
  b.brand_id,
  b.brand_id AS brand_sk,
  b.brand_name,
  b.brand_description,
  NULL AS website_id,
  CURRENT_DATE AS start_date,
  CURRENT_DATE + INTERVAL '1 year' AS end_date,
  TRUE AS is_current,
  b.country_of_origin,
  b.established_year
FROM
  staging.brands b
ON CONFLICT (brand_id) DO NOTHING;

INSERT INTO
  dim_customer (
    customer_id,
    NAME,
    email,
    address_id,
    start_date,
    end_date,
    is_current
  )
SELECT
  u.user_id,
  CONCAT(u.first_name, ' ', u.last_name) AS NAME,
  u.email,
  a.address_id,
  CURRENT_DATE AS start_date,
  CURRENT_DATE + INTERVAL '1 year' AS end_date,
  TRUE AS is_current
FROM
  staging.shop_users u
  LEFT JOIN staging.addresses a ON u.user_id = a.address_id
ON CONFLICT (customer_id) DO NOTHING;

INSERT INTO
  dim_category (category_id, category_name)
SELECT DISTINCT
  category_id,
  category_name
FROM
  staging.categories
ON CONFLICT (category_id) DO NOTHING;

INSERT INTO
  dim_subcategory (subcategory_id, subcategory_name, category_id)
SELECT DISTINCT
  subcategory_id,
  subcategory_name,
  category_id
FROM
  staging.subcategories
ON CONFLICT (subcategory_id) DO NOTHING;

INSERT INTO
  dim_product (
    product_id,
    product_code,
    NAME,
    price,
    subcategory_id,
    start_date,
    end_ate,
    is_current
  )
SELECT
  p.product_id,
  p.product_code,
  p.product_name,
  p.price,
  p.subcategory_id,
  CURRENT_DATE AS start_date,
  CURRENT_DATE + (FLOOR(RANDOM() * 30) || ' days')::INTERVAL AS end_ate,
  TRUE AS is_current
FROM
  staging.products p
ON CONFLICT (product_code) DO
UPDATE
SET
  NAME = EXCLUDED.name,
  price = EXCLUDED.price,
  subcategory_id = EXCLUDED.subcategory_id,
  start_date = EXCLUDED.start_date,
  end_ate = EXCLUDED.end_ate,
  is_current = EXCLUDED.is_current;

INSERT INTO
  dim_shipper (shipper_id, NAME, contact_id, rating)
SELECT
  s.shipper_id,
  s.shipper_name,
  NULL AS contact_id,
  s.rating
FROM
  staging.shippers s
ON CONFLICT (shipper_id) DO NOTHING;

INSERT INTO
  dim_month (month_id, month_number, month_name, YEAR)
SELECT DISTINCT
  EXTRACT(
    YEAR
    FROM
      o.order_date
  ) * 100 + EXTRACT(
    MONTH
    FROM
      o.order_date
  ) AS month_id,
  EXTRACT(
    MONTH
    FROM
      o.order_date
  ) AS month_number,
  TO_CHAR(o.order_date, 'Month') AS month_name,
  EXTRACT(
    YEAR
    FROM
      o.order_date
  ) AS YEAR
FROM
  staging.orders o
ON CONFLICT (month_id) DO NOTHING;

INSERT INTO
  dim_quarter (quarter_id, quarter_number, quarter_name, YEAR)
SELECT DISTINCT
  EXTRACT(
    YEAR
    FROM
      o.order_date
  ) * 10 + CEIL(
    EXTRACT(
      MONTH
      FROM
        o.order_date
    ) / 3.0
  ) AS quarter_id,
  CEIL(
    EXTRACT(
      MONTH
      FROM
        o.order_date
    ) / 3.0
  ) AS quarter_number,
  CASE
    WHEN CEIL(
      EXTRACT(
        MONTH
        FROM
          o.order_date
      ) / 3.0
    ) = 1 THEN 'Q1'
    WHEN CEIL(
      EXTRACT(
        MONTH
        FROM
          o.order_date
      ) / 3.0
    ) = 2 THEN 'Q2'
    WHEN CEIL(
      EXTRACT(
        MONTH
        FROM
          o.order_date
      ) / 3.0
    ) = 3 THEN 'Q3'
    ELSE 'Q4'
  END AS quarter_name,
  EXTRACT(
    YEAR
    FROM
      o.order_date
  ) AS YEAR
FROM
  staging.orders o
ON CONFLICT (quarter_id) DO NOTHING;

INSERT INTO
  dim_time (
    Date,
    YEAR,
    QUARTER,
    MONTH,
    DAY,
    month_id,
    quarter_id
  )
SELECT DISTINCT
  o.order_date AS Date,
  EXTRACT(
    YEAR
    FROM
      o.order_date
  ) AS YEAR,
  CEIL(
    EXTRACT(
      MONTH
      FROM
        o.order_date
    ) / 3.0
  ) AS QUARTER,
  EXTRACT(
    MONTH
    FROM
      o.order_date
  ) AS MONTH,
  EXTRACT(
    DAY
    FROM
      o.order_date
  ) AS DAY,
  EXTRACT(
    YEAR
    FROM
      o.order_date
  ) * 100 + EXTRACT(
    MONTH
    FROM
      o.order_date
  ) AS month_id,
  EXTRACT(
    YEAR
    FROM
      o.order_date
  ) * 10 + CEIL(
    EXTRACT(
      MONTH
      FROM
        o.order_date
    ) / 3.0
  ) AS quarter_id
FROM
  staging.orders o
ON CONFLICT (Date) DO NOTHING;

INSERT INTO
  dim_status (status_id, status_name)
SELECT DISTINCT
  ROW_NUMBER() OVER (
    ORDER BY
      order_status
  ) AS status_id,
  order_status AS status_name
FROM
  staging.orders
WHERE
  order_status IS NOT NULL
ON CONFLICT (status_id) DO
UPDATE
SET
  status_name = EXCLUDED.status_name;

INSERT INTO
  dim_payment_method (payment_method_id, payment_method_name)
SELECT DISTINCT
  ROW_NUMBER() OVER (
    ORDER BY
      payment_method
  ) AS payment_method_id,
  payment_method AS payment_method_name
FROM
  staging.orders
WHERE
  payment_method IS NOT NULL
ON CONFLICT (payment_method_id) DO
UPDATE
SET
  payment_method_name = EXCLUDED.payment_method_name;

INSERT INTO
  fact_sales (
    sale_id,
    product_id,
    customer_id,
    Date,
    brand_id,
    payment_method_id,
    status_id,
    quantity_sold,
    total_sales
  )
SELECT
  ROW_NUMBER() OVER (
    ORDER BY
      od.order_id,
      od.product_id
  ) AS sale_id,
  od.product_id,
  o.user_id AS customer_id,
  o.order_date AS Date,
  dp.brand_id,
  pm.payment_method_id,
  s.status_id,
  od.quantity,
  od.quantity * sp.price AS total_sales
FROM
  staging.order_details od
  JOIN staging.orders o ON od.order_id = o.order_id
  JOIN staging.products sp ON od.product_id = sp.product_id
  JOIN dim_brand dp ON sp.brand_id = dp.brand_id
  JOIN dim_payment_method pm ON TRIM(LOWER(o.payment_method)) = TRIM(LOWER(pm.payment_method_name))
  JOIN dim_status s ON TRIM(LOWER(o.order_status)) = TRIM(LOWER(s.status_name))
ON CONFLICT (sale_id) DO NOTHING;

SELECT
  *
FROM
  fact_sales;

INSERT INTO
  fact_delivery (
    delivery_id,
    shipper_id,
    order_id,
    Date,
    geography_id,
    delivery_time,
    delivery_cost
  )
SELECT
  dd.delivery_id,
  ds.shipper_id,
  o.order_id,
  o.order_date,
  NULL AS geography_id,
  (FLOOR(RANDOM() * 21) + 1)::DECIMAL(10, 2) AS delivery_time,
  100.0 + (RANDOM() * 50)::NUMERIC(10, 2) AS delivery_cost
FROM
  staging.orders o
  JOIN staging.delivery_details dd ON o.delivery_id = dd.delivery_id
  JOIN dim_shipper ds ON dd.shipper_id = ds.shipper_id
ON CONFLICT (delivery_id) DO NOTHING;

SELECT
  *
FROM
  fact_sales;