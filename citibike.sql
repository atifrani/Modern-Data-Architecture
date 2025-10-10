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

create table weather as
    select 
      v:"coco" as "coco",
      v:"country" as "country",
      v:"dwpt" as "dwpt",
      v:"elevation" as "elevation",
      v:"icao" as "icao",
      v:"latitude" as "latitude",
      v:"longitude" as "longitude",
      v:"name" as "name",
      v:"obsTime" as "obsTime",
      v:"prcp" as "prcp" ,
      v:"pres" as "pres",
      v:"region" as "region",
      v:"rhum" as "rhum",
      v:"snow" as "snow",
      v:"station" as "station",
      v:"temp" "temp",
      v:"timezone" as "timezone",
      v:"tsun" as "tsun",
      v:"wdir" as "wdir",
      v:"weatherCondition" as "weatherCondition",
      v:"wmo" as "wmo",
      v:"wpgt" as "wpgt",
      v:"wspd" as "wspd"
    from json_weather_data;




select * from weather;
