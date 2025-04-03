-- https://s3.amazonaws.com/snowflake-workshop-lab/OnlineZTS_LabGuide.pdf
-- https://s3.amazonaws.com/snowflake-workshop-lab/lab_scripts_OnlineZTS.sql

-- This SQL file is for the Hands On Lab Guide for the 30-day free Snowflake trial account
-- The numbers below correspond to the sections of the Lab Guide in which SQL is to be run in a Snowflake worksheet
-- Modules 1 and 2 of the Lab Guide have no SQL to execute

/* *********************************************************************************** */
/* *** MODULE 2  ********************************************************************* */
/* *********************************************************************************** */
USE ROLE SYSADMIN;

-- using GUI create  DB (citibike) and WH (compute_wh)


create or replace database citibike;

-- do using gui;
CREATE  WAREHOUSE IF NOT EXISTS "COMPUTE_WH"
WITH WAREHOUSE_SIZE = 'X-SMALL'
AUTO_SUSPEND = 60
AUTO_RESUME = TRUE
MIN_CLUSTER_COUNT = 1
MAX_CLUSTER_COUNT = 1
SCALING_POLICY = 'STANDARD'
INITIALLY_SUSPENDED = TRUE
COMMENT = 'VW for ZTS';

-- using gui

CREATE or replace STAGE citibike.public.citibike_trips
URL = 's3://snowflake-workshop-lab/citibike-trips';

LIST @citibike_trips;


-- CREATE FILE FORMAT


create or replace file format csv type='csv'
  compression = 'auto' field_delimiter = ',' record_delimiter = '\n'
  skip_header = 0 field_optionally_enclosed_by = '\042' trim_space = false
  error_on_column_count_mismatch = false escape = 'none' escape_unenclosed_field = '\134'
  date_format = 'auto' timestamp_format = 'auto' null_if = ('');



/* *********************************************************************************** */
/* *** MODULE 3  ********************************************************************* */
/* *********************************************************************************** */


-- RESIZE THE FONT OF THE BROWSER


-- 3.1.4
use role sysadmin;
use database citibike;
use schema public;
use warehouse compute_wh;


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

-- 3.2

create or replace stage citibike_trips
url = 's3://snowflake-workshop-lab/citibike-trips';

-- 3.2.4

ls @citibike_trips;


select $1, $2, $3, $4, $5, $6, $7, $8, $9, $10, $11, $12, $13, $14, $15, $16
from @CITIBIKE_TRIPS/trips_2013_0_0_0.csv.gz limit 100;

select $1, $2, $3, $4, $5, $6, $7, $8, $9, $10, $11, $12, $13, $14, $15, $16
from @CITIBIKE_TRIPS/trips_2013_1_0_0.csv.gz (file_format => CSV) limit 100;

list @citibike_trips;

-- how much data is that?
select floor(sum($2)/power(1024, 3),1) total_compressed_storage_gb,
    floor(avg($2)/power(1024, 2),1) avg_file_size_mb,
    count(*) as num_files
  from table(result_scan(last_query_id()));


-- 3.3






/* *********************************************************************************** */
/* *** MODULE 4  ********************************************************************* */
/* *********************************************************************************** */


-- warehouse config - increase to small

alter warehouse  compute_wh set warehouse_size=medium;

-- 4.2.2

copy into trips from @citibike_trips file_format=csv;

-- 33sec for small size
-- 18sec   for medium size
--  11 sec  for large size

select * from trips limit 10;

select count(*) from trips;


-- 4.2.4



truncate table trips;

-- resize warehouse

-- 4.2.7

alter warehouse  compute_wh set warehouse_size=large;
copy into trips from @citibike_trips file_format=csv;
--copy into trips from @citibike_trips file_format=csv force=true;
alter warehouse  compute_Wh set warehouse_size='SMALL';

-- 4.3

create or replace warehouse analytics_wh with warehouse_size = 'large' warehouse_type = 'standard'
  auto_suspend = 600 auto_resume = true;

/* *********************************************************************************** */
/* *** MODULE 5  ********************************************************************* */
/* *********************************************************************************** */

-- 5.1.1

use role sysadmin;
use warehouse analytics_wh;
use database citibike;
use schema public;

-- 5.1.2
--61m rows
select count(*) from trips;

select * from trips limit 20;

-- 5.1.3


--basic hourly statistics on Citi Bike usage.
select date_trunc('hour', starttime) as "date",
count(*) as "num trips",
avg(tripduration)/60 as "avg duration (mins)",
avg(haversine(start_station_latitude, start_station_longitude, end_station_latitude, end_station_longitude)) as "avg distance (km)"
from trips
group by 1 order by 1;

-- 5.1.4
-- result cache for same query
select date_trunc('hour', starttime) as "date",
count(*) as "num trips",
avg(tripduration)/60 as "avg duration (mins)",
avg(haversine(start_station_latitude, start_station_longitude, end_station_latitude, end_station_longitude)) as "avg distance (km)"
from trips
group by 1 order by 1;

alter session set use_cached_result=false;
alter session set use_cached_result=true;



-- 5.1.5
-- which is busiest month
select monthname(starttime) as "month",
    count(*) as "num trips"
from trips
group by 1 order by 2 desc;


select date_trunc('hour', starttime) as "date",
count(*) as "num trips",
avg(tripduration)/60 as "avg duration (mins)",
avg(haversine(start_station_latitude, start_station_longitude, end_station_latitude,
end_station_longitude)) as "avg distance (km)"
from trips
group by 1 order by 1;

-- run again to see result cahche


select
 dayname(starttime) as "day of week",
 count(*) as "num trips"
from trips
group by 1 order by 2 desc;



-- 5.2.1  zero copy clone
select count(*) from trips;

create table trips_dev clone trips;

select count(*) from trips_Dev;

select * from trips_dev limit 20;

/*
select *
from citibike.information_schema.table_storage_metrics
where table_catalog LIKE 'TRIPS%';

select * from "SNOWFLAKE"."ACCOUNT_USAGE"."TABLE_STORAGE_METRICS" where table_catalog = 'citibike' and table_schema='PUBLIC';

SELECT *
FROM table(citibike.information_schema.database_storage_usage_history(dateadd('days', -10, current_date()), current_date(), 'TRIPS'));

select *     from snowflake.account_usage.tables     where  table_catalog='citibike';
  --  group by table_schema;




*/

delete from trips_dev where start_station_id=499;

select * from trips_dev where start_station_id=499;

select * from trips where start_station_id=499 limit 10;

show tables like 'TRIPS%';

DROP TABLE TRIPS_DEV;





/* *********************************************************************************** */
/* *** MODULE 6  Semi Structured data                                                  */
/* *********************************************************************************** */

-- 6.1.1

create database weather;

-- 6.1.2

use role sysadmin;
use warehouse compute_wh;
use database weather;
use schema public;

-- 6.1.3
-- variant data type
create table json_weather_data (v variant);

-- 6.2.1

-- external stage

create stage nyc_weather url = 's3://snowflake-workshop-lab/weather-nyc';

create or replace file format json_format type = 'json';

-- 6.2.2

list @nyc_weather;

select  $1 from @nyc_weather  (file_format => json_format)  w limit 10;

-- 6.3.1

copy into json_weather_data
from @nyc_weather
file_format = (type=json);

-- 6.3.2

select * from json_weather_data limit 10;

-- 6.4.1

create view json_weather_data_view as
select
  v:time::timestamp as observation_time,
  v:city.id::int as city_id,
  v:city.name::string as city_name,
  v:city.country::string as country,
  v:city.coord.lat::float as city_lat,
  v:city.coord.lon::float as city_lon,
  v:clouds.all::int as clouds,
  (v:main.temp::float)-273.15 as temp_avg,
  (v:main.temp_min::float)-273.15 as temp_min,
  (v:main.temp_max::float)-273.15 as temp_max,
  v:weather[0].main::string as weather,
  v:weather[0].description::string as weather_desc,
  v:weather[0].icon::string as weather_icon,
  v:wind.deg::float as wind_dir,
  v:wind.speed::float as wind_speed
from json_weather_data
where city_id = 5128638
;

-- 6.4.4

select * from json_weather_data_view
where date_trunc('month',observation_time) = '2018-01-01'
limit 20;

-- aggregated query to find avg weather in a month
select city_name, date_part(month,observation_time), avg(temp_avg)
from json_weather_data_view
group by city_name,date_part(month,observation_time);

-- 6.5.1

select weather as conditions
    ,count(*) as num_trips
from citibike.public.trips
left outer join json_weather_data_view
    on date_trunc('hour', observation_time) = date_trunc('hour', starttime)
where conditions is not null
group by 1 order by 2 desc;


/* *********************************************************************************** */
/* *** MODULE 7  Time Travel                                                           */
/* *********************************************************************************** */

-- 7.1.1

drop table json_weather_data;

-- 7.1.2

select * from json_weather_data limit 10;

-- 7.1.3

undrop table json_weather_data;

-- 7.2.1

use database citibike;
use schema public;

-- 7.2.2

update trips set start_station_name = 'oops';

select * from trips limit 10;



-- 7.2.3

select start_station_name as station
    ,count(*) as rides
from trips
group by 1
order by 2 desc
limit 20;


-- 7.2.4

select query_id , QUERY_TEXT , start_time from
table(information_schema.query_history_by_session (result_limit=>100))
where query_text like 'update%' order by start_time limit 10;
-- 0198fe0a-06ef-a9a7-000e-ab03001d6292

set query_id =
(select query_id from
table(information_schema.query_history_by_session (result_limit=>5))
where query_text like 'update%' order by start_time limit 1);


select * from trips before (statement =>'0198fe0a-06ef-a9a7-000e-ab03001d6292' ) limit 100;




-- 7.2.5
create or replace table trips as
(select * from trips before (statement => $query_id));

create or replace table trips as
(select * from trips before (statement => '0198f957-060a-1c24-000e-ab03001d3932'));

/*
create table triptemp as (select * from trips before (statement=>'0197b844-0516-54c0-000e-ab030013c04e'));

alter table trips swap with triptemp;
*/

-- 7.2.6

select start_station_name as "station"
    ,count(*) as "rides"
from trips
group by 1
order by 2 desc
limit 20;


/* *********************************************************************************** */
/* *** MODULE 8  Role based access control                                             */
/* *********************************************************************************** */

-- 8.1.1

use role accountadmin;

-- 8.1.3 (NOTE - enter your unique user name into the second row below)

create or replace role junior_dba;
grant role junior_dba to user upatel;--YOUR_USER_NAME_GOES HERE;

-- 8.1.4

use role junior_dba;

-- 8.1.6

use role accountadmin;
grant usage on database citibike to role junior_dba;
grant usage on database weather to role junior_dba;

grant usage on schema citibike.public to role junior_dba;
grant usage on schema weather.public to role junior_dba;

grant select on citibike.public.trips to role junior_dba;
grant select on weather.public.json_weather_data to role junior_dba;


-- 8.1.7

use role junior_dba;



-- Data Share


select * from "COVID19"."PUBLIC"."WHO_DAILY_REPORT" order by cases_total desc;

select * from "COVID19"."PUBLIC"."JHU_COVID_19"
where date > current_date()-40
order by date desc
;



--What is the number of COVID-19 deaths per 1 million population in the UK?
SELECT * FROM "ATLAS"."COVID19"."kaziajg" WHERE "Location Name" = 'United Kingdom' AND "Indicator Name" = 'Deaths, per million people' ORDER BY "Date";

--END---clean up db---
use role accountadmin;
drop database atlas;
drop database "STARSCHEMA_COVID19";

use role accountadmin;
drop role junior_dba;
--drop share citibikeshrae;
use role sysadmin;
drop view weather.public.json_weather_data_view;
drop table weather.public.json_weather_data;
drop table if exists trips_Dev;
drop table citibike.public.trips;
drop database citibike;
drop database weather;
drop warehouse if exists analytics_wh;
drop warehouse if exists compute_wh;
