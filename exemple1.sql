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


create or replace database weather;

create table json_weather_data (v variant);


create stage nyc_weather url = 's3://logbrain-datalake/datasets/weather-nyc-json';

 

list @nyc_weather;

copy into json_weather_data from @nyc_weather file_format = (type=json);

select * from json_weather_data;


select   v:country from json_weather_data;

select   v[1]:country from json_weather_data;

CREATE or REPLACE file format json 
type = 'JSON'
STRIP_OUTER_ARRAY=TRUE;

truncate json_weather_data;

copy into json_weather_data from @nyc_weather file_format = json;


select * from json_weather_data;


create or replace view weather_condition as
select v:country::varchar as "country",
        v:latitude::float as "latitude",
        v:longitude::float as "longitude",
        v:obsTime::timestamp as "obsTime",
        v:weatherCondition::varchar as "weatherCondition"
from json_weather_data;


select * from weather_condition;

create or replace view trips_weather as
select "weatherCondition" as weather_condition ,count(*) as num_trips
from 
    citibike.public.trips a
left outer join 
    weather.public.weather_condition b
on date("obsTime") = date(starttime)
where "weatherCondition" is not null
group by 1 order by 2 desc;



select "obsTime"  from weather.public.weather_condition;




```
# Import python packages
import streamlit as st
from snowflake.snowpark.context import get_active_session

# Write directly to the app
st.title(f"Correlation trajets velo vs la méteo")
st.write(
  """Ce tableau de bord résume la correlation qui
  pourrait exister entre les usagers de Vélo en fonction
  des conditions méteo.
  """
)

# Get the current credentials
session = get_active_session()

query="select * from weather.public.trips_weather"

data = session.sql(query).collect()

# Create a simple bar chart
# See docs.streamlit.io for more types of charts
st.subheader("Number of high-fives")
st.bar_chart(data=data, x="WEATHER_CONDITION", y="NUM_TRIPS")
```

