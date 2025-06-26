-- requete pour créer une base de données
create or replace database mydb;

-- requete pour créer un schema
create or replace schema HR;

--  requete pori créer la table employees
create or replace table employees
    (
        emp_id	varchar,
        fname	varchar,	
        lname	varchar,	
        address	varchar,	
        city	varchar,	
        state	varchar,	
        zipcode	int,
        job_title	varchar,	
        email	varchar,	
        active	boolean,
        salary int
    );


    select * from employees;



    create or replace table employees_json
    (
        data  variant
    );

    select * from employees_json;

create or replace view employees_csv as
select 
        data:"birth-date" as "birth-date",
        data:"first-name" as "first-name",
        data:"job-title" as "job-title",
        data:"last-name" as "last-name",
        data:"location" as "location"
from employees_json;


select * from employees_csv;
