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




-- créer la base de données citibike
create or replace database citibike;

-- créer la table trips
create or replace table trips
(tripduration integer,
starttime timestamp,
stoptime timestamp,
start_station_id integer,
start_station_name string,
start_station_latitude float,
start_station_longitude float,
end_station_id integer,
end_station_name string,
end_station_latitude float,
end_station_longitude float,
bikeid integer,
membership_type string,
usertype string,
birth_year integer,
gender integer);


-- Create external S3 stage 
create stage citibike_csv  URL ='s3://logbrain-datalake/datasets/citibike-trips-csv/';

list @citibike_csv;

-- créer un file format pour les fichiers CSV
CREATE or replace FILE FORMAT csv 
TYPE = 'CSV' 
FIELD_DELIMITER = ',' 
RECORD_DELIMITER = '\n' 
SKIP_HEADER = 1
field_optionally_enclosed_by = '\042'
null_if = ('');

select * from trips;


copy into trips from @citibike_csv file_format=csv PATTERN = '.*csv.*' ;

select * from trips;

select count(*) from trips;


create or replace view analyse_moy_trajet as
select  date_trunc('hour', starttime) as "hours",
        count(*) as "num trips",
        avg(tripduration)/60 as "avg duration (mins)",
        avg(haversine(start_station_latitude, 
        start_station_longitude, 
        end_station_latitude,
        end_station_longitude)) as "avg distance (km)"
from trips
group by 1 
order by 1;

select * from analyse_moy_trajet;

select case "day of week"
            WHEN 'Tue' Then 'Mardi'
            WHEN 'Thu' Then 'Jeudi'
            WHEN 'Fri' Then 'Vendredi'
            WHEN 'Wed' Then 'Mercredi'
            WHEN 'Mon' Then 'Lundi'
            WHEN 'Sat' Then 'Samedi'
            WHEN 'Sun' Then 'Dimanche'
            END as "Jours de semaine",
        "num trips"
FROM 
    (select
        dayname(starttime) as "day of week",
        count(*) as "num trips"
      from trips
      group by 1 order by 2 desc
      ) temp_table;




create or replace view analyse_day_week as
select  "day of week", 
        SNOWFLAKE.CORTEX.TRANSLATE("day of week", 'EN', 'FR') as "jours de semaine",
        "num trips"
FROM 
    (select
        dayname(starttime) as "day of week",
        count(*) as "num trips"
      from trips
      group by 1 order by 2 desc
      ) temp_table;


select * from analyse_day_week;

