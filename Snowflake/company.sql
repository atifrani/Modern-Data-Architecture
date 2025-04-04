-- create retail-db database
create database retaildb;

-- create table categories:
create table retaildb.public.categories
(
category_id integer not null,
departement_id integer,
category_name varchar
);

-- create table customers:
create or replace table retaildb.public.customers
(
customer_id integer not null,
customer_fname varchar,
customer_lname varchar,
customer_street varchar,
customer_city varchar,
customer_state varchar,
customer_zipcode varchar
);

--create table departments:
create table retaildb.public.departments
(
department_id integer not null,
departement_name varchar
);

--create table order_items:
create table retaildb.public.order_items
(
order_item_id integer not null,
order_item_order_id integer,
order_item_product_id integer,
order_item_quantity integer,
order_item_subtotal float,
order_item_price float
);

--create table orders:
create table retaildb.public.orders
(
order_id integer not null,
order_date date,
order_customer_id integer,
order_status varchar
);

--create table products:
create table retaildb.public.products
(
product_id integer not null,
product_category_id integer,
product_name varchar,
product_description varchar,
product_price float,
product_image varchar );

-- create stage
create stage company_csv URL ='s3://logbrain-datalake/datasets/company';

list @company_csv;

-- Create file format
CREATE or replace FILE FORMAT tsv_with_header 
TYPE = 'CSV' 
FIELD_DELIMITER = '\t' 
RECORD_DELIMITER = '\n' 
SKIP_HEADER = 1
null_if = ('');

CREATE or replace FILE FORMAT csv_with_header 
TYPE = 'CSV' 
FIELD_DELIMITER = ',' 
RECORD_DELIMITER = '\n' 
SKIP_HEADER = 1
null_if = ('');

CREATE or replace FILE FORMAT csv_without_header 
TYPE = 'CSV' 
FIELD_DELIMITER = ',' 
RECORD_DELIMITER = '\n' 
SKIP_HEADER = 0
field_optionally_enclosed_by = '\042'
null_if = ('')
;

-- load data into customers 
copy into customers  from @company_csv file_format=tsv_with_header PATTERN = '.*customers.*' ;
select * from customers;


-- load data into categories
copy into categories  from @company_csv file_format=csv_with_header PATTERN = '.*categories.*' ;
select * from categories;

-- load data into departments
copy into departments  from @company_csv file_format=csv_with_header PATTERN = '.*departments.*' ;
select * from departments;

-- load data into products
copy into products  from @company_csv file_format=csv_without_header PATTERN = '.*products.*' ;
select * from products;

-- load data into order_items
copy into order_items  from @company_csv file_format=csv_without_header PATTERN = '.*order_items.*' ;
select * from order_items;

-- load data into orders
copy into orders  from @company_csv file_format=csv_without_header PATTERN = '.*orders.*' ;
select * from orders;


Now, let's create a new tables/datamarts:

-- Create table top_product (product_id, product_name, category_name, month, year, sales )
```
create table top_product as 
select 
products.product_id,
products.product_name,
products.PRODUCT_CATEGORY_ID,
month(orders.order_date) as month,
year(orders.order_date) as year,
sum(order_item_price) as sales
from 
products join order_items on products.product_id = order_items.order_item_product_id 
join orders on orders.order_id = order_items.order_item_order_id
group by products.product_id,
products.product_name,
products.PRODUCT_CATEGORY_ID,
month,
year;
```
  
-- Create table top_customer (customer_id, customer_name, customer_street, customer_city,customer_zipcode, month, year, sales )
