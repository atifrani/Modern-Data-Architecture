CREATE OR REPLACE DATABASE CITIBIKE;

use database citibike;

create or replace table citibike.public.trips
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

-- CREATE STAGE TO ACCESS DATA

create stage citibike_csv  URL ='s3://logbrain-datalake/datasets/citibike-trips-csv/';

list @citibike_csv;


CREATE or replace FILE FORMAT csv 
TYPE = 'CSV' 
FIELD_DELIMITER = ',' 
RECORD_DELIMITER = '\n' 
SKIP_HEADER = 1
field_optionally_enclosed_by = '\042'
null_if = ('');

copy into trips from @citibike_csv file_format=csv PATTERN = '.*csv.*' ;

select * from trips;

select count(*) from trips;



create table json_weather_data (v variant);

create stage nyc_weather url = 's3://logbrain-datalake/datasets/weather-nyc-json';

list @nyc_weather;

CREATE or REPLACE file format json 
type = 'JSON'
STRIP_OUTER_ARRAY=TRUE;

copy into json_weather_data from @nyc_weather file_format = json;


select * from json_weather_data;

create or replace table weather as
    select 
      v:"coco"::STRING as "coco" ,
      v:"country"::STRING as "country",
      v:"dwpt"::FLOAT as "dwpt",
      v:"elevation"::STRING as "elevation",
      v:"icao"::STRING as "icao",
      v:"latitude"::DECIMAL as "latitude",
      v:"longitude"::DECIMAL as "longitude",
      v:"name"::STRING as "name",
      v:"obsTime"::TIMESTAMP as "obsTime",
      v:"prcp"::STRING as "prcp" ,
      v:"pres"::DECIMAL as "pres",
      v:"region"::STRING as "region",
      v:"rhum"::STRING as "rhum",
      v:"snow"::STRING as "snow",
      v:"station"::STRING as "station",
      v:"temp"::DECIMAL "temp",
      v:"timezone"::STRING as "timezone",
      v:"tsun"::STRING as "tsun",
      v:"wdir"::STRING as "wdir",
      v:"weatherCondition"::STRING as "weatherCondition",
      v:"wmo"::STRING as "wmo",
      v:"wpgt"::STRING as "wpgt",
      v:"wspd"::DECIMAL as "wspd"
    from json_weather_data;

select "weatherCondition" from weather;

create or replace warehouse ANALYTICS_WH
  warehouse_size = 'LARGE'
  auto_suspend = 5
  auto_resume = true
  initially_suspended = true;

  
use warehouse ANALYTICS_WH;


select
  date_trunc('day', starttime) as "date",
  count(*)                           as "num trips",
  avg(tripduration)/60               as "avg duration (mins)",
  avg(haversine(
    start_station_latitude, start_station_longitude,
    end_station_latitude,  end_station_longitude
  ))                                 as "avg distance (km)"
from TRIPS
group by 1
order by 1;



select
  dayname(starttime) as "day of week",
  count(*)           as "num trips"
from TRIPS
group by 1
order by 2 desc;

select  case 
            when dayname(starttime) = 'Tue' then 'Mardi'
            when dayname(starttime) = 'Thu' then 'Jeudi'
            when dayname(starttime) = 'Fri' then 'Vendredi'
            when dayname(starttime) = 'Wed' then 'Mercredi'
            when dayname(starttime) = 'Mon' then 'Lundi' 
            when dayname(starttime) = 'Sat' then 'Samedi'
            when dayname(starttime) = 'Sun' then 'Dimanche'
            else 'Jour inconnu'
            end as "Jour_semaine",
            count(*) as "nombre_trajet"
        from trips
        group by 1
        order by 2 desc;


create or replace table TRIPS_DEV clone TRIPS;



use database CITIBIKE;  
use schema PUBLIC;
use warehouse ANALYTICS_WH;

select
  "weatherCondition",
  count(*) as num_trips
from CITIBIKE.PUBLIC.TRIPS
left join CITIBIKE.PUBLIC.WEATHER
  on date("obsTime") = date(starttime)
where "weatherCondition" is not null
group by 1
order by 2 desc;


select weatherCondition from  CITIBIKE.PUBLIC.WEATHER;
