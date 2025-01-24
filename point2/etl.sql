--- Need to wait for the script to execute for 15 - 60 seconds script


create extension if not exists dblink;

insert into
  DimDate (
    DateKey,
    FullDate,
    day,
    month,
    MonthName,
    QUARTER,
    year
  )
select distinct
  extract(
    year
    from
      order_date
  ) * 10000 + extract(
    month
    from
      order_date
  ) * 100 + extract(
    day
    from
      order_date
  ) as DateKey,
  order_date as FullDate,
  extract(
    day
    from
      order_date
  ) as day,
  extract(
    month
    from
      order_date
  ) as month,
  to_char(order_date, 'Month') as MonthName,
  extract(
    QUARTER
    from
      order_date
  ) as QUARTER,
  extract(
    year
    from
      order_date
  ) as year
from
  dblink (
    'dbname=oltp_db user=postgres password=1234',
    'SELECT DISTINCT order_date FROM orders'
  ) as orders (order_date DATE)
where
  not exists (
    select
      1
    from
      DimDate
    where
      DateKey = extract(
        year
        from
          order_date
      ) * 10000 + extract(
        month
        from
          order_date
      ) * 100 + extract(
        day
        from
          order_date
      )
  );

insert into
  DimEmployee (
    EmployeeID,
    EmployeeEmail,
    FirstName,
    LastName,
    EmployeeRole,
    StartDate,
    EndDate,
    IsCurrent
  )
select
  employee_id,
  employee_email,
  first_name,
  last_name,
  employee_role,
  hire_date,
  hire_date + interval '1 year',
  true
from
  dblink (
    'dbname=oltp_db user=postgres password=1234',
    'SELECT employee_id, employee_email, first_name, last_name, employee_role, hire_date FROM employees'
  ) as employees (
    employee_id int,
    employee_email varchar,
    first_name varchar,
    last_name varchar,
    employee_role varchar,
    hire_date DATE
  )
where
  not exists (
    select
      1
    from
      DimEmployee
    where
      EmployeeID = employees.employee_id
      and IsCurrent = true
  );

insert into
  DimCategory (CategoryID, CategoryName, CategoryDesc)
select
  category_id,
  category_name,
  category_description
from
  dblink (
    'dbname=oltp_db user=postgres password=1234',
    'SELECT category_id, category_name, category_description FROM categories'
  ) as categories (
    category_id int,
    category_name varchar,
    category_description varchar
  )
where
  not exists (
    select
      1
    from
      DimCategory
    where
      CategoryID = categories.category_id
  );

insert into
  DimSubCategory (
    SubCategoryID,
    SubCategoryName,
    SubCategoryDesc,
    CategoryKey
  )
select
  subcategory_id,
  subcategory_name,
  subcategory_description,
  (
    select
      CategoryKey
    from
      DimCategory
    where
      CategoryID = subcategories.category_id
  )
from
  dblink (
    'dbname=oltp_db user=postgres password=1234',
    'SELECT subcategory_id, subcategory_name, category_id, subcategory_description FROM subcategories'
  ) as subcategories (
    subcategory_id int,
    subcategory_name varchar,
    category_id int,
    subcategory_description varchar
  )
where
  not exists (
    select
      1
    from
      DimSubCategory
    where
      SubCategoryID = subcategories.subcategory_id
  );

insert into
  DimProduct (
    ProductID,
    ProductName,
    ProductDesc,
    Price,
    Currency,
    Availability,
    PowerSupply,
    Color,
    Weight,
    Dimension,
    SubCategoryKey
  )
select
  product_id,
  product_name,
  product_description,
  price,
  currency,
  availability_status,
  power_supply,
  (
    select
      color_name
    from
      dblink (
        'dbname=oltp_db user=postgres password=1234',
        'SELECT color_id, color_name FROM product_colors'
      ) as colors (color_id int, color_name varchar)
    where
      colors.color_id = products.color_id
  ),
  (
    select
      weight_value
    from
      dblink (
        'dbname=oltp_db user=postgres password=1234',
        'SELECT weight_id, weight_value FROM product_weights'
      ) as weights (weight_id int, weight_value numeric)
    where
      weights.weight_id = products.weight_id
  ),
  (
    select
      dimension_value
    from
      dblink (
        'dbname=oltp_db user=postgres password=1234',
        'SELECT dimension_id, dimension_value FROM product_dimensions'
      ) as dimensions (dimension_id int, dimension_value varchar)
    where
      dimensions.dimension_id = products.dimension_id
  ),
  (
    select
      SubCategoryKey
    from
      DimSubCategory
    where
      SubCategoryID = products.subcategory_id
  )
from
  dblink (
    'dbname=oltp_db user=postgres password=1234',
    'SELECT product_id, product_name, product_description, price, currency, availability_status, power_supply, color_id, weight_id, dimension_id, subcategory_id FROM products'
  ) as products (
    product_id int,
    product_name varchar,
    product_description text,
    price numeric,
    currency varchar,
    availability_status varchar,
    power_supply varchar,
    color_id int,
    weight_id int,
    dimension_id int,
    subcategory_id int
  )
where
  not exists (
    select
      1
    from
      DimProduct
    where
      ProductID = products.product_id
  );

insert into
  DimCustomerContactInfo (Email, Phone, IsVerified)
select
  email,
  phone,
  is_verified
from
  dblink (
    'dbname=oltp_db user=postgres password=1234',
    'SELECT DISTINCT email, phone, is_verified FROM shop_users'
  ) as users (email varchar, phone varchar, is_verified boolean)
where
  not exists (
    select
      1
    from
      DimCustomerContactInfo
    where
      Email = users.email
      and Phone = users.phone
  );

insert into
  DimCustomer (
    CustomerID,
    FirstName,
    LastName,
    CustomerContactInfoKey
  )
select
  user_id,
  first_name,
  last_name,
  (
    select
      CustomerContactInfoKey
    from
      DimCustomerContactInfo
    where
      Email = users.email
      and Phone = users.phone
  ) as CustomerContactInfoKey
from
  dblink (
    'dbname=oltp_db user=postgres password=1234',
    'SELECT user_id, first_name, last_name, email, phone FROM shop_users'
  ) as users (
    user_id int,
    first_name varchar,
    last_name varchar,
    email varchar,
    phone varchar
  )
where
  not exists (
    select
      1
    from
      DimCustomer
    where
      CustomerID = users.user_id
  );

insert into
  DimAddresses (AddressID, Address, City, Country)
select distinct
  address_id,
  address,
  city,
  country
from
  dblink (
    'dbname=oltp_db user=postgres password=1234',
    'SELECT address_id, address, city, country FROM addresses'
  ) as addresses (
    address_id int,
    address varchar,
    city varchar,
    country varchar
  )
where
  not exists (
    select
      1
    from
      DimAddresses
    where
      AddressID = addresses.address_id
  );

insert into
  FactSales (
    DateKey,
    EmployeeKey,
    CustomerKey,
    ProductKey,
    AddressKey,
    BrandName,
    OrderNumber,
    Quantity,
    PriceEach,
    TotalOrderAmountPrice,
    Currency
  )
select
  (
    extract(
      year
      from
        orders.order_date
    ) * 10000 + extract(
      month
      from
        orders.order_date
    ) * 100 + extract(
      day
      from
        orders.order_date
    )
  ) as DateKey,
  (
    select
      EmployeeKey
    from
      DimEmployee
    where
      EmployeeID = orders.employee_id
      and IsCurrent = true
  ) as EmployeeKey,
  coalesce(
    (
      select
        CustomerKey
      from
        DimCustomer
      where
        CustomerID = orders.user_id
    ),
    -1
  ) as CustomerKey,
  (
    select
      ProductKey
    from
      DimProduct
    where
      ProductID = order_details.product_id
  ) as ProductKey,
  (
    select
      AddressKey
    from
      DimAddresses
    where
      AddressID = delivery_details.ship_address_id
  ) as AddressKey,
  (
    select
      brand_name
    from
      dblink (
        'dbname=oltp_db user=postgres password=1234',
        'SELECT product_id, brand_id FROM products'
      ) as p (product_id int, brand_id int)
      join dblink (
        'dbname=oltp_db user=postgres password=1234',
        'SELECT brand_id, brand_name FROM brands'
      ) as b (brand_id int, brand_name varchar) on p.brand_id = b.brand_id
    where
      p.product_id = order_details.product_id
  ) as BrandName,
  orders.order_number,
  order_details.quantity,
  order_details.price_each,
  (order_details.quantity * order_details.price_each) as TotalOrderAmountPrice,
  (
    select
      currency
    from
      dblink (
        'dbname=oltp_db user=postgres password=1234',
        'SELECT product_id, currency FROM products'
      ) as products (product_id int, currency varchar)
    where
      products.product_id = order_details.product_id
  ) as Currency
from
  dblink (
    'dbname=oltp_db user=postgres password=1234',
    'SELECT o.order_id, o.order_date, o.order_number, o.employee_id, o.user_id
       FROM orders o'
  ) as orders (
    order_id int,
    order_date DATE,
    order_number varchar,
    employee_id int,
    user_id int
  )
  join dblink (
    'dbname=oltp_db user=postgres password=1234',
    'SELECT order_id, product_id, quantity, price_each FROM order_details'
  ) as order_details (
    order_id int,
    product_id int,
    quantity int,
    price_each numeric
  ) on orders.order_id = order_details.order_id
  join dblink (
    'dbname=oltp_db user=postgres password=1234',
    'SELECT delivery_id, ship_address_id FROM delivery_details'
  ) as delivery_details (
    delivery_id int,
    ship_address_id int
  ) on orders.order_id = delivery_details.delivery_id
where
  not exists (
    select
      1
    from
      FactSales
    where
      OrderNumber = orders.order_number
      and ProductKey = (
        select
          ProductKey
        from
          DimProduct
        where
          ProductID = order_details.product_id
      )
  );


insert into
  DimShipperContactInfo (ContactInfo, Phone, WebsiteURL)
select distinct
  contact_info,
  phone,
  website_url
from
  dblink (
    'dbname=oltp_db user=postgres password=1234',
    'SELECT contact_info, phone, website_url FROM shippers'
  ) as shippers (
    contact_info varchar,
    phone varchar,
    website_url varchar
  )
where
  not exists (
    select
      1
    from
      DimShipperContactInfo
    where
      ContactInfo = shippers.contact_info
      and Phone = shippers.phone
      and WebsiteURL = shippers.website_url
  );

insert into
  DimShipper (
    ShipperID,
    ShipperName,
    Status,
    ShipperContactInfoKey
  )
select distinct
  shipper_id,
  shipper_name,
  status,
  (
    select
      ShipperContactInfoKey
    from
      DimShipperContactInfo
    where
      ContactInfo = shippers.contact_info
      and Phone = shippers.phone
      and WebsiteURL = shippers.website_url
  )
from
  dblink (
    'dbname=oltp_db user=postgres password=1234',
    'SELECT shipper_id, shipper_name, status, contact_info, phone, website_url FROM shippers'
  ) as shippers (
    shipper_id int,
    shipper_name varchar,
    status boolean,
    contact_info varchar,
    phone varchar,
    website_url varchar
  )
where
  not exists (
    select
      1
    from
      DimShipper
    where
      ShipperID = shippers.shipper_id
  );

insert into
  FactDelivery (
    DateKey,
    EmployeeKey,
    CustomerKey,
    ShipperKey,
    AddressKey,
    OrderNumber,
    DeliveryMethod,
    ShippingCost,
    DeliveryDurationDays,
    Currency
  )
select
  (
    select
      DateKey
    from
      DimDate
    where
      FullDate = data.order_date
  ) as DateKey,
  (
    select
      EmployeeKey
    from
      DimEmployee
    where
      EmployeeID = data.employee_id
      and IsCurrent = true
  ) as EmployeeKey,
  coalesce(
    (
      select
        CustomerKey
      from
        DimCustomer
      where
        CustomerID = data.user_id
    ),
    -1
  ) as CustomerKey,
  (
    select
      ShipperKey
    from
      DimShipper
    where
      ShipperID = data.shipper_id
  ) as ShipperKey,
  (
    select
      AddressKey
    from
      DimAddresses
    where
      AddressID = data.ship_address_id
  ) as AddressKey,
  data.order_number,
  data.delivery_method,
  round(
    (
      select
        sum(fs.TotalOrderAmountPrice)
      from
        FactSales fs
      where
        fs.OrderNumber = data.order_number
    ) * (0.03 + random() * (0.20 - 0.03))
  ) as ShippingCost,
  floor(1 + (random() * 30)) as DeliveryDurationDays,
  'USD' as Currency
from
  dblink (
    'dbname=oltp_db user=postgres password=1234',
    'SELECT o.order_id, o.order_number, o.order_date, o.employee_id, o.user_id, dd.shipper_id, dd.ship_address_id, dd.delivery_method
            FROM orders o
            INNER JOIN delivery_details dd ON o.delivery_id = dd.delivery_id'
  ) as data (
    order_id int,
    order_number varchar,
    order_date DATE,
    employee_id int,
    user_id int,
    shipper_id int,
    ship_address_id int,
    delivery_method varchar
  )
where
  not exists (
    select
      1
    from
      FactDelivery
    where
      OrderNumber = data.order_number
      and ShipperKey = (
        select
          ShipperKey
        from
          DimShipper
        where
          ShipperID = data.shipper_id
      )
  );

select
  *
from
  FactSales limit 100;