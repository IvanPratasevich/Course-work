-- create database oltp_db;

create table addresses (
    address_id serial primary key,
    address varchar(150) not null,
    city varchar(50) not null,
    country varchar(60) not null
);

create table employees (
    employee_id serial primary key,
    employee_email varchar(100) unique not null,
    first_name varchar(80) not null,
    last_name varchar(80) not null,
    hire_date date not null default current_date,
    birthdate date not null,
    address_id integer not null,
    employee_role varchar(50) default 'staff',
    foreign key (address_id) references addresses (address_id) on delete cascade on update cascade
);

create table shippers (
    shipper_id serial primary key,
    shipper_name varchar(100) unique not null,
    contact_info varchar(255),
    phone varchar(50),
    status boolean default true,
    website_url varchar(255) default 'Not provided',
    company_type varchar(100),
    tax_id varchar(50),
    insurance_number varchar(100),
    payment_terms varchar(100),
    rating integer CHECK (rating >= 1 AND rating <= 5),
    max_weight_capacity integer
);

create table categories (
    category_id serial primary key,
    category_name varchar(100) unique not null,
    category_description varchar(255)
);

create table subcategories (
    subcategory_id serial primary key,
    subcategory_name varchar(100) unique not null,
    category_id integer not null,
    subcategory_description varchar(255),
    foreign key (category_id) references categories (category_id) on delete cascade on update cascade
);

create table brands (
    brand_id serial primary key,
    brand_name varchar(100) unique not null,
    brand_description varchar(255),
    status boolean default true,
    website_url varchar(255) default 'Not provided',
    country_of_origin varchar(100),
    established_year integer,
    logo_url varchar(255)
);

create table manufacturers (
    manufacturer_id serial primary key,
    manufacturer_name varchar(100) unique not null,
    manufacturer_address_id integer not null,
    contact_info varchar(255),
    foreign key (manufacturer_address_id) references addresses (address_id) on delete cascade on update cascade
);

create type currency_type as enum ('USD', 'EUR', 'GBP');

create table product_weights (
    weight_id serial primary key,
    weight_value numeric(10, 2) not null
);

create table product_dimensions (
    dimension_id serial primary key,
    dimension_value varchar(100) not null,
    description varchar(255)
);

create table product_colors (
    color_id serial primary key,
    color_name varchar(50) unique not null,
    description varchar(255)
);

create table products (
    product_id serial primary key,
    product_code varchar(50) unique not null,
    product_name varchar(100) not null,
    product_description text,
    price numeric(10, 2) not null,
    currency currency_type not null,
    availability_status varchar(50) default 'in stock',
    color_id integer,
    weight_id integer,
    dimension_id integer,
    power_supply varchar(50),
    subcategory_id integer not null,
    brand_id integer not null,
    manufacturer_id integer not null,
    foreign key (color_id) references product_colors (color_id) on delete set null on update cascade,
    foreign key (weight_id) references product_weights (weight_id) on delete set null on update cascade,
    foreign key (dimension_id) references product_dimensions (dimension_id) on delete set null on update cascade,
    foreign key (subcategory_id) references subcategories (subcategory_id) on delete cascade on update cascade,
    foreign key (brand_id) references brands (brand_id) on delete cascade on update cascade,
    foreign key (manufacturer_id) references manufacturers (manufacturer_id) on delete cascade on update cascade
);

create table shop_users (
    user_id serial primary key,
    email varchar(100) unique not null,
    first_name varchar(80) not null,
    last_name varchar(80) not null,
    username varchar(50) not null,
    password varchar(255) not null,
    role varchar(50) default 'customer',
    phone varchar(50),
    status boolean default true,
    birthdate date,
    is_verified boolean,
    profile_picture_url varchar(255)
);

create table baskets (
    basket_id serial primary key,
    user_id integer not null,
    creation_date timestamp not null,
    foreign key (user_id) references shop_users (user_id) on delete cascade on update cascade
);

create table basket_details (
    basket_detail_id serial primary key,
    basket_id integer not null,
    product_id integer not null,
    quantity int not null,
    price_when_added numeric(10, 2) not null,
    foreign key (basket_id) references baskets (basket_id) on delete cascade on update cascade,
    foreign key (product_id) references products (product_id) on delete cascade on update cascade
);

create table delivery_details (
    delivery_id serial primary key,
    delivery_method varchar(50),
    ship_address_id integer not null,
    shipper_id integer not null,
    foreign key (ship_address_id) references addresses (address_id) on delete cascade on update cascade,
    foreign key (shipper_id) references shippers (shipper_id) on delete cascade on update cascade
);

create table orders (
    order_id serial primary key,
    order_number varchar(50) unique not null,
    user_id integer not null,
    order_date timestamp not null default current_timestamp,
    order_status varchar(50) default 'pending',
    employee_id integer not null,
    payment_method varchar(50),
    delivery_id integer not null,
    foreign key (user_id) references shop_users (user_id) on delete cascade on update cascade,
    foreign key (employee_id) references employees (employee_id) on delete cascade on update cascade,
    foreign key (delivery_id) references delivery_details (delivery_id) on delete cascade on update cascade
);

create table order_details (
    order_detail_id serial primary key,
    order_id integer not null,
    product_id integer not null,
    quantity int not null,
    price_each numeric(10, 2) not null,
    foreign key (order_id) references orders (order_id) on delete cascade on update cascade,
    foreign key (product_id) references products (product_id) on delete cascade on update cascade
);

create table favorites (
    favorite_id serial primary key,
    user_id integer not null,
    product_id integer not null,
    liked_date timestamp not null default current_timestamp,
    stars int not null,
    foreign key (user_id) references shop_users (user_id) on delete cascade,
    foreign key (product_id) references products (product_id) on delete cascade
);

