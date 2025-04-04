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
create table retaildb.public.customers
(
customer_id integer not null,
customer_fname varchar,
customer_lname varchar,
customer_email varchar,
customer_password varchar,
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


Now, let's create a new tables:

Create table top_product (product_id, product_name, category_name, month, year, sales )
Create table top_customer (customer_id, customer_name, customer_street, customer_city,customer_zipcode, month, year, sales )
