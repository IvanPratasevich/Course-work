-- create database olap_db;

create table
  DimDate (
    DateKey int not null primary key,
    FullDate DATE not null,
    day int not null,
    month int not null,
    MonthName varchar(20),
    QUARTER int,
    year int
  );

create table
  DimEmployee (
    EmployeeKey SERIAL primary key,
    EmployeeID int not null,
    EmployeeEmail varchar(100),
    FirstName varchar(80),
    LastName varchar(80),
    EmployeeRole varchar(50),
    StartDate DATE not null,
    EndDate DATE null,
    IsCurrent boolean not null default true
  );

create table
  DimCategory (
    CategoryKey SERIAL primary key,
    CategoryID int not null,
    CategoryName varchar(100) not null,
    CategoryDesc varchar(255)
  );

create table
  DimSubCategory (
    SubCategoryKey SERIAL primary key,
    SubCategoryID int not null,
    SubCategoryName varchar(100) not null,
    SubCategoryDesc varchar(255),
    CategoryKey int not null,
    foreign key (CategoryKey) references DimCategory (CategoryKey)
  );

create table
  DimProduct (
    ProductKey SERIAL primary key,
    ProductID int not null,
    ProductName varchar(100) not null,
    ProductDesc text,
    Price numeric(10, 2),
    Currency varchar(3),
    Availability varchar(50),
    PowerSupply varchar(50),
    Color varchar(50),
    Weight numeric(10, 2),
    Dimension varchar(100),
    SubCategoryKey int,
    foreign key (SubCategoryKey) references DimSubCategory (SubCategoryKey)
  );

create table
  DimCustomer (
    CustomerKey SERIAL primary key,
    CustomerID int not null,
    FirstName varchar(80),
    LastName varchar(80),
    Email varchar(100),
    Phone varchar(50),
    IsVerified boolean
  );

create table
  DimShipperContactInfo (
    ShipperContactInfoKey SERIAL primary key,
    ContactInfo varchar(255),
    Phone varchar(50),
    WebsiteURL varchar(255)
  );

create table
  DimShipper (
    ShipperKey SERIAL primary key,
    ShipperID int not null,
    ShipperName varchar(100),
    Status boolean default true,
    ShipperContactInfoKey int,
    foreign key (ShipperContactInfoKey) references DimShipperContactInfo (ShipperContactInfoKey)
  );

create table
  FactSales (
    FactSalesKey SERIAL primary key,
    DateKey int not null,
    EmployeeKey int not null,
    CustomerKey int not null,
    ProductKey int not null,
    BrandName varchar(100),
    OrderNumber varchar(50),
    Quantity int not null,
    PriceEach numeric(10, 2) not null,
    TotalOrderAmountPrice numeric(10, 2) not null,
    Currency varchar(3),
    foreign key (DateKey) references DimDate (DateKey),
    foreign key (EmployeeKey) references DimEmployee (EmployeeKey),
    foreign key (CustomerKey) references DimCustomer (CustomerKey),
    foreign key (ProductKey) references DimProduct (ProductKey)
  );

create table
  FactDelivery (
    FactDeliveryKey SERIAL primary key,
    DateKey int not null,
    EmployeeKey int not null,
    CustomerKey int not null,
    ShipperKey int not null,
    OrderNumber varchar(50),
    DeliveryMethod varchar(50),
    ShippingCost numeric(10, 2),
    Currency varchar(3),
    DeliveryDurationDays int,
    foreign key (DateKey) references DimDate (DateKey),
    foreign key (EmployeeKey) references DimEmployee (EmployeeKey),
    foreign key (CustomerKey) references DimCustomer (CustomerKey),
    foreign key (ShipperKey) references DimShipper (ShipperKey)
  );