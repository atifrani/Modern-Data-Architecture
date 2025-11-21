# Airbnb use case:

Cet atelier consiste à manipuler les données des réservations sur Airbnb.  
Les données sont stockées sur ce bucket: **s3://logbrain-datalake/datasets/airbnb/**  
Voici la liste des fihciers csv à charger:  

* hosts.csv  

* listings.csv  

* reviews.csv  

* seed_full_moon_dates.csv  

  Pour pouvoir charger les données dans snowflake, il faut:  
   * Créer une base de données airbnb  
   * créer un stage vers les données sur aws  
   * créer un file format pour les données CSV  
   * Créer un table pour stocker chaque fichier.  
 
## Descriptif des tables:

* Table Reviews:  
  listing_id,  
  date,  
  reviewer_name,  
  comments,  
  sentiment  

* Table seed_full_moon_date:  
  full_moon_date  

* Table Listings:  
  id,  
  listing_url,  
  name,  
  room_type,  
  minimum_nights,  
  host_id,  
  price,  
  created_at,  
  updated_at  


* Table Hosts:  
  id,  
  name,  
  is_superhost,  
  created_at,  
  updated_at  




CREATE OR REPLACE DATABASE AIRBNB;

CREATE OR REPLACE TABLE raw_hosts
                    (id string,
                     name string,
                     is_superhost string,
                     created_at string,
                     updated_at string);

create or replace table silver_hosts as select
    cast(id as int) as id,
    name as name,
    cast(is_superhost as boolean) as is_superhost ,
    cast(created_at as timestamp) as created_at,
    cast(updated_at as timestamp) as updated_at
from  raw_hosts;


select * from silver_hosts;

                     
CREATE OR REPLACE STAGE airbnb_stage
  URL = 's3://logbrain-datalake/datasets/airbnb/';


COPY INTO raw_hosts
FROM @airbnb_stage/hosts.csv
FILE_FORMAT = (TYPE = 'CSV' SKIP_HEADER = 1 FIELD_OPTIONALLY_ENCLOSED_BY = '"');



CREATE OR REPLACE TABLE raw_reviews
                    (listing_id string,
                     date string,
                     reviewer_name string,
                     comments string,
                     sentiment string);


COPY INTO raw_reviews
FROM @airbnb_stage/reviews.csv
FILE_FORMAT = (TYPE = 'CSV' SKIP_HEADER = 1 FIELD_OPTIONALLY_ENCLOSED_BY = '"');

select * from raw_reviews;

SELECT SNOWFLAKE.CORTEX.TRANSLATE('Hello my name is Axel', '', 'fr') AS TRANSLATED_TEXT;


SELECT 
comments , 
SNOWFLAKE.CORTEX.TRANSLATE(comments, '', 'fr') as french_comments, 
SNOWFLAKE.CORTEX.SENTIMENT(comments) AS SENTIMENT_GENERATED,
from (select comments from raw_reviews limit 10);




