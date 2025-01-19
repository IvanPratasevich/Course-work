--create database olap_db;

drop table if exists fact_sales cascade;
drop table if exists fact_delivery cascade;
drop table if exists dim_customer cascade;
drop table if exists dim_address cascade;
drop table if exists dim_brand cascade;
drop table if exists dim_website cascade;
drop table if exists dim_geography cascade;
drop table if exists dim_category cascade;
drop table if exists dim_subcategory cascade;
drop table if exists dim_product cascade;
drop table if exists dim_status cascade;
drop table if exists dim_payment_method cascade;
drop table if exists dim_month cascade;
drop table if exists dim_quarter cascade;
drop table if exists dim_time cascade;
drop table if exists dim_shipper cascade;
drop table if exists dim_shipper_contactinfo cascade;


create table
  dim_address (
    address_id int primary key,
    city varchar(50),
    country varchar(50)
  );

create table
  dim_customer (
    customer_id int primary key,
    name varchar(100),
    email varchar(100),
    address_id int,
    start_date DATE,
    end_date DATE,
    is_current boolean,
    foreign key (address_id) references dim_address (address_id)
  );

create table
  dim_website (
    website_id int primary key,
    website_url varchar(255) default 'Not provided',
    logo_url varchar(255)
  );


create table
  dim_brand (
    brand_id int primary key,
    brand_sk int,
    brand_name varchar(100),
    brand_description varchar(255),
    website_id int,
    start_date DATE,
    end_date DATE,
    is_current boolean,
    country_of_origin varchar(100),
    established_year int,
    foreign key (website_id) references dim_website (website_id)
  );

create table
  dim_geography (
    geography_id int primary key,
    country varchar(100),
    region varchar(100),
    city varchar(100)
  );

create table
  dim_category (
    category_id int primary key,
    category_name varchar(100)
  );


create table
  dim_subcategory (
    subcategory_id int primary key,
    subcategory_name varchar(100),
    category_id int,
    foreign key (category_id) references dim_category (category_id)
  );


create table
  dim_product (
    product_id int unique,
    product_code varchar primary key,
    name varchar(100),
    price decimal(10, 2),
    subcategory_id int,
    start_date DATE,
    end_ate DATE,
    is_current boolean,
    foreign key (subcategory_id) references dim_subcategory (subcategory_id)
  );

create table
  dim_month (
    month_id int primary key,
    month_number int not null,
    month_name varchar(20) not null,
    year int not null
  );

create table
  dim_quarter (
    quarter_id int primary key,
    quarter_number int not null,
    quarter_name varchar(20) not null,
    year int not null
  );


create table
  dim_time (
    Date DATE primary key,
    year int,
    quarter int,
    month int,
    day int,
    month_id int,
    quarter_id int,
    foreign key (month_id) references dim_month (month_id),
    foreign key (quarter_id) references dim_quarter (quarter_id)
  );


create table
  dim_shipper_contactinfo (
    contact_id int primary key,
    phone_number varchar(50),
    contact_info varchar(255)
  );


create table
  dim_shipper (
    shipper_id int primary key,
    name varchar(100),
    contact_id int,
    rating int check (rating between 1 and 5),
    foreign key (contact_id) references dim_shipper_contactinfo (contact_id)
  );

create table
  dim_payment_method (
    payment_method_id int primary key,
    payment_method_name varchar(50) not null
  );

create table
  dim_status (
    status_id int primary key,
    status_name varchar(50) not null
  );

create table
  fact_sales (
    sale_id int primary key,
    product_id int unique,
    customer_id int,
    Date DATE,
    brand_id int,
    payment_method_id int,
    status_id int,
    quantity_sold int,
    total_sales decimal(10, 2),
    foreign key (product_id) references dim_product (product_id),
    foreign key (customer_id) references dim_customer (customer_id),
    foreign key (brand_id) references dim_brand (brand_id),
    foreign key (Date) references dim_time (Date),
    foreign key (payment_method_id) references dim_payment_method (payment_method_id),
    foreign key (status_id) references dim_status (status_id)
  );

create table
  fact_delivery (
    delivery_id int primary key,
    shipper_id int,
    order_id int,
    Date DATE,
    geography_id int,
    delivery_time decimal(10, 2) NULL,
    delivery_cost decimal(10, 2) NULL,
    foreign key (shipper_id) references dim_shipper (shipper_id),
    foreign key (geography_id) references dim_geography (geography_id),
    foreign key (Date) references dim_time (Date)
  );

select * from fact_sales


