# Airbnb use case:

Cet atelier consiste à manipuler les données des réservations sur Airbnb.  
Les données sont stockées sur ce bucket: **s3://logbrain-datalake/datasets/airbnb/**  
Voici la liste des fichiers csv à charger:  

* hosts.csv  

* listings.csv  

* reviews.csv  

* seed_full_moon_dates.csv  
  
Pour pouvoir charger les données dans snowflake, il faut:  
   * Créer une base de données airbnb  
   * Créer un schema de données BRONZE  
   * créer un stage vers les données sur aws  
   * créer un file format pour les données CSV et JSON
   * Créer un table pour stocker chaque fichier.  

![alt text](../images/medallion.png)
 
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

```
-- Create Databse
CREATE  DATABASE IF NOT EXISTS  AIRBNB;

-- Create Schema BRONZE
CREATE SCHEMA IF NOT EXISTS AIRBNB.BRONZE;

CREATE TABLE IF NOT EXISTS  AIRBNB.BRONZE.HOSTS
                    (id string,
                     name string,
                     is_superhost string,
                     created_at string,
                     updated_at string);

-- Create Stage                     
CREATE OR REPLACE STAGE AIRBNB.BRONZE.airbnb_stage
  URL = 's3://logbrain-datalake/datasets/airbnb/';

-- Copy the data into table
COPY INTO AIRBNB.BRONZE.HOSTS
FROM @airbnb_stage/hosts.csv
FILE_FORMAT = (TYPE = 'CSV' SKIP_HEADER = 1 FIELD_OPTIONALLY_ENCLOSED_BY = '"');

-- Check table
SELECT * FROM AIRBNB.BRONZE.HOSTS


-- Create table
CREATE TABLE IF NOT EXISTS AIRBNB.BRONZE.REVIEWS
                    (listing_id string,
                     date string,
                     reviewer_name string,
                     comments string,
                     sentiment string);

-- Copy the data into table
COPY INTO AIRBNB.BRONZE.REVIEWS
FROM @airbnb_stage/reviews.csv
FILE_FORMAT = (TYPE = 'CSV' SKIP_HEADER = 1 FIELD_OPTIONALLY_ENCLOSED_BY = '"');

-- Check table
select * from AIRBNB.BRONZE.REVIEWS;


-- Create table
CREATE TABLE IF NOT EXISTS AIRBNB.BRONZE.LISTINGS
                    (data VARIANT
                    );

-- Copy the data into table
COPY INTO AIRBNB.BRONZE.LISTINGS
FROM @airbnb_stage/listings.json
FILE_FORMAT = (TYPE = 'JSON');

-- Check table
select * from AIRBNB.BRONZE.LISTINGS;

-- Create Schema SILVER
CREATE SCHEMA IF NOT EXISTS AIRBNB.SILVER;

-- Create table 
CREATE TABLE IF NOT EXISTS AIRBNB.SILVER.HOSTS 
AS
SELECT
    id AS host_id,
    name AS host_name,
    is_superhost::BOOLEAN AS is_superhost,
    created_at,
    updated_at
FROM AIRBNB.BRONZE.HOSTS ;

-- Check table
select * from AIRBNB.SILVER.HOSTS;

-- Create table 
CREATE TABLE IF NOT EXISTS AIRBNB.SILVER.REVIEWS  
AS
SELECT
    listing_id,
    date as review_date,
    reviewer_name,
    comments as review_text, -- rename column
    sentiment
FROM AIRBNB.BRONZE.REVIEWS;

-- Check table
select * from AIRBNB.SILVER.REVIEWS;


-- Create table 
CREATE TABLE IF NOT EXISTS AIRBNB.SILVER.LISTINGS 
AS
SELECT
    data:ID::INT AS id,
    data:LISTING_URL::STRING AS listing_url,
    data:NAME::STRING AS name,
    data:ROOM_TYPE::STRING AS room_type,
    data:MINIMUM_NIGHTS::INT AS minimum_nights,
    data:HOST_ID::INT AS host_id,
    data:PRICE::STRING AS price,
    data:CREATED_AT::TIMESTAMPTZ AS created_at,
    data:UPDATED_AT::TIMESTAMPTZ AS updated_at
FROM AIRBNB.BRONZE.LISTINGS;

-- Check table
select * from AIRBNB.SILVER.LISTINGS;

-- Create table
CREATE TABLE IF NOT EXISTS AIRBNB.SILVER.FULL_MOON_DATE
(
    date_day date
);

-- Copy the data into table
COPY INTO AIRBNB.SILVER.FULL_MOON_DATE
FROM @airbnb_stage/full_moon_date.json
FILE_FORMAT = (TYPE = 'CSV' SKIP_HEADER = 1 FIELD_OPTIONALLY_ENCLOSED_BY = '"');

-- Check table
select * from AIRBNB.SILVER.FULL_MOON_DATE;
```
![alt text](../images/data_model_silver.png)

```
-- Create schema Gold
CREATE SCHEMA AIRBNB.GOLD;

-- Create table DIM_HOSTS
CREATE OR REPLACE VIEW AIRBNB.GOLD.DIM_HOSTS AS
SELECT
    host_id::INT AS host_id,
    NVL(host_name::STRING, 'Anonymous') AS host_name,
    IS_SUPERHOST::BOOLEAN AS IS_SUPERHOST,
    CREATED_AT::TIMESTAMPTZ AS CREATED_AT,
    UPDATED_AT::TIMESTAMPTZ AS UPDATED_AT
FROM AIRBNB.SILVER.HOSTS;

Select * from AIRBNB.GOLD.DIM_HOSTS;


-- Create table DIM_LISTINGS

CREATE OR REPLACE VIEW AIRBNB.GOLD.DIM_LISTINGS AS
SELECT
    ID AS LISTING_ID,
    LISTING_URL,
    NAME AS LISTING_NAME,
    ROOM_TYPE,
    CASE 
        WHEN (MINIMUM_NIGHTS)::INT IS NULL THEN 1
        WHEN (MINIMUM_NIGHTS)::INT = 0 THEN 1 
        ELSE (MINIMUM_NIGHTS)::INT 
    END AS MINIMUM_NIGHTS,
    HOST_ID,
    TO_NUMBER(REPLACE(PRICE, '$', ''))::INT AS PRICE,
    CREATED_AT,
    UPDATED_AT
FROM AIRBNB.SILVER.LISTINGS;

-- Check tables
Select * from AIRBNB.GOLD.DIM_LISTINGS;

-- Create table FACT_REVIEWS
CREATE OR REPLACE TABLE AIRBNB.GOLD.FACT_REVIEWS
  AS
  SELECT 
    *
  FROM AIRBNB.SILVER.reviews
  WHERE review_text IS NOT NULL
  order by review_date desc;

-- Check tables
Select * from AIRBNB.GOLD.FACT_REVIEWS;


-- Create data product FULL_MOON_REVIEWS

CREATE OR REPLACE TABLE AIRBNB.GOLD.FULL_MOON_REVIEWS
AS
SELECT 
    fr.*, 
    CASE 
        WHEN fm.date_day IS NULL THEN 'not full moon'
        ELSE 'full moon'
    END AS is_full_moon
FROM 
    AIRBNB.GOLD.FACT_REVIEWS fr 
LEFT JOIN 
    AIRBNB.GOLD.FULL_MOON_DATE fm 
ON 
    (TO_DATE(fr.REVIEW_DATE) = DATEADD(DAY, 1, fm.date_day));


-- Check table 
SELECT * FROM AIRBNB.GOLD.FULL_MOON_REVIEWS;

```

### Analyse des avis clients

**Snowflake Cortex AI** : Snowflake Cortex AI est un service entièrement managé conçu pour exploiter le potentiel de cette technologie auprès de tous les collaborateurs d’une organisation, quels que soient leurs niveaux de compétences techniques. Il donne accès à des modèles de langage de grande taille (LLM) de premier plan, permettant aux utilisateurs de concevoir et de déployer facilement des applications basées sur l’IA.

Dans cet exercice, nous explorons Cortex Analyst, l’une des fonctionnalités phares de la famille Snowflake Cortex AI.

**Cortex Analyst :**
Cortex Analyst permet aux utilisateurs métiers d’interagir avec des données structurées en langage naturel, afin d’obtenir des réponses plus rapidement, d’accéder à des analyses en libre-service et de gagner un temps précieux.

Commençons par un exemple simple utilisant la fonction **TRANSLATE** :

```
select SNOWFLAKE.CORTEX.TRANSLATE('Hello Everyone', '', 'fr') AS greeting;
```

La colonne REVIEW_TEXT de FACT_REVIEWS contient des avis dans différentes langues. Commençons par les traduire en anglais afin de vérifier si le sentiment correspond bien au contenu de l’avis.

* Créez un nouvel entrepôt (Warehouse) avec davantage de ressources de calcul.

```
CREATE OR REPLACE WAREHOUSE XLARGE_COMPUTE_WH WITH
COMMENT = 'Large warehouse for cortex analyst'
    WAREHOUSE_TYPE = 'standard'
    WAREHOUSE_SIZE = 'xlarge'
    MIN_CLUSTER_COUNT = 1
    MAX_CLUSTER_COUNT = 2
    SCALING_POLICY = 'standard'
    AUTO_SUSPEND = 60
    AUTO_RESUME = true
    INITIALLY_SUSPENDED = true;
```
 
```
USE WAREHOUSE XLARGE_COMPUTE_WH;
```

```
CREATE OR REPLACE TABLE AIRBNB.GOLD.FULL_MOON_REVIEWS_TRANSLATED AS
SELECT 
    LISTING_ID,
    REVIEW_DATE, 
    REVIEWER_NAME, 
    REVIEW_TEXT, 
    SNOWFLAKE.CORTEX.TRANSLATE(REVIEW_TEXT, '', 'en') AS TRANSLATED_REVIEW_TEXT,
    SENTIMENT,
    IS_FULL_MOON  
    FROM AIRBNB.GOLD.FULL_MOON_REVIEWS
    LIMIT 100;
```

* Ensuite, nous utiliserons les modèles pré-entraînés de Snowflake Cortex pour générer des scores de sentiment pour chaque avis.

```
CREATE OR REPLACE TABLE AIRBNB.GOLD.FULL_MOON_REVIEWS_AUGMENTED AS
SELECT 
    LISTING_ID,
    REVIEW_DATE, 
    REVIEWER_NAME, 
    TRANSLATED_REVIEW_TEXT,
    SENTIMENT,
    SNOWFLAKE.CORTEX.SENTIMENT(TRANSLATED_REVIEW_TEXT) AS SENTIMENT_GENERATED,
    IS_FULL_MOON  
    FROM AIRBNB.GOLD.FULL_MOON_REVIEWS_TRANSLATED;
```

* Les scores de sentiment vont de -1 (totalement négatif) à 1 (totalement positif). Nous les classerons en trois catégories : négatif (-1 à -0,3), neutre (-0,3 à 0,3) et positif (0,3 à 1).

```
select min(SENTIMENT_GENERATED), max(SENTIMENT_GENERATED) from AIRBNB.GOLD.FULL_MOON_REVIEWS_AUGMENTED;
```


```
CREATE OR REPLACE TABLE AIRBNB.GOLD.FULL_MOON_REVIEWS_AUGMENTED AS
SELECT 
    LISTING_ID,
    REVIEW_DATE, 
    REVIEWER_NAME, 
    TRANSLATED_REVIEW_TEXT,
    SENTIMENT,
    CASE 
        WHEN SNOWFLAKE.CORTEX.SENTIMENT(TRANSLATED_REVIEW_TEXT) < -0.3 THEN 'negative'
     
        WHEN SNOWFLAKE.CORTEX.SENTIMENT(TRANSLATED_REVIEW_TEXT) BETWEEN -0.3 AND 0.3  THEN 'neutral'
     
        WHEN SNOWFLAKE.CORTEX.SENTIMENT(TRANSLATED_REVIEW_TEXT) > 0.3 THEN 'positive'
    END AS  SENTIMENT_GENERATED,
    IS_FULL_MOON  
    FROM AIRBNB.GOLD.FULL_MOON_REVIEWS_TRANSLATED;
```

* Interrogez la table `FULL_MOON_REVIEWS_AUGMENTED`.

```
SELECT * FROM AIRBNB.GOLD.FULL_MOON_REVIEWS_AUGMENTED
```

* Dans les exemples suivants, nous montrerons comment exploiter les fonctions `EXTRACT_ANSWER` et `SUMMARIZE` afin d’obtenir davantage d’informations et d’analyses à partir de nos données.

* EXTRACT_ANSWER:

```
select TRANSLATED_REVIEW_TEXT,SENTIMENT_GENERATED, SNOWFLAKE.CORTEX.EXTRACT_ANSWER(TRANSLATED_REVIEW_TEXT, 'Were the guests satisfied with their stay?'):[answer] as extract_answer from AIRBNB.GOLD.FULL_MOON_REVIEWS_AUGMENTED limit 100;
```

* SUMMARIZE:

```
select TRANSLATED_REVIEW_TEXT, SNOWFLAKE.CORTEX.SUMMARIZE(TRANSLATED_REVIEW_TEXT) as Summary from AIRBNB.GOLD.FULL_MOON_REVIEWS_AUGMENTED limit 100;
```

## Créer des applications web de données :
Streamlit est une bibliothèque Python open source qui facilite la création et le partage d’applications web personnalisées pour l’analytique et la data science.

Nous allons commencer par développer notre première application web à partir de données Airbnb.

```
import streamlit as st
from snowflake.snowpark.context import get_active_session


st.title(f"AIRBNB Web App")
st.write(
  """This is our first Streamlit web app 
     application baseb on AIRBNB data!
  """
)

# Get connection
session = get_active_session()

# execute sql statement
sql = f"select count(*) as NB_LISTINGS, SENTIMENT_GENERATED from  AIRBNB.GOLD.FULL_MOON_REVIEWS_AUGMENTED group by SENTIMENT_GENERATED order by NB_LISTINGS asc;"

data = session.sql(sql).collect()

# Create a simple bar chart

st.subheader("Sentiment-Based Distribution of Listings")
st.bar_chart(data=data, x="SENTIMENT_GENERATED", y="NB_LISTINGS", color="SENTIMENT_GENERATED")

st.subheader("Underlying data")
st.dataframe(data, use_container_width=True)

```

![alt text](../images/img33.png)


* Ensuite, nous améliorerons le diagramme en barres en y ajoutant des filtres interactifs pour offrir une expérience utilisateur plus dynamique.

```
import streamlit as st
from snowflake.snowpark.context import get_active_session


st.title(f"AIRBNB Web App")
st.write(
  """This is our first Streamlit web app 
     application baseb on AIRBNB data!
  """
)

# Get connection
session = get_active_session()

# Create a select box
option = st.selectbox(
     'Select the Review Name?',
( 'Michael','Daniel','Thomas','David','Anna','Laura','Alexander','Julia','Maria','Martin','Andrea','Sarah','Christian','Lisa','Alex','Simon','Mark','Chris','Paul','Stefan','Nicole','Robert'))

# execute sql statement
sql = f"select count(*) as NB_LISTINGS, SENTIMENT_GENERATED from  AIRBNB.GOLD.FULL_MOON_REVIEWS_AUGMENTED  where reviewer_name= '{option}'group by SENTIMENT_GENERATED order by NB_LISTINGS asc;"

data = session.sql(sql).collect()

# Create a simple bar chart

st.subheader("Sentiment-Based Distribution of Listings")
st.bar_chart(data=data, x="SENTIMENT_GENERATED", y="NB_LISTINGS", color="SENTIMENT_GENERATED")

st.subheader("Underlying data")
st.dataframe(data, use_container_width=True)

```

![alt text](../images/img34.png)

## Réinitialisez votre compte Snowflake.
Exécutez les scripts ci-dessous pour rétablir votre compte dans l’état requis afin de relancer cet atelier.

```
USE ROLE ACCOUNTADMIN;

USE DATABASE AIRBNB;

USE SCHEMA SILVER;

DROP TABLE IF EXISTS HOSTS;

DROP TABLE IF EXISTS LISTINGS; 

DROP TABLE IF EXISTS REVIEWS; 

DROP TABLE IF EXISTS FULL_MOON_DATE; 

USE SCHEMA GOLD;

DROP VIEW IF EXISTS DIM_HOSTS;

DROP VIEW IF EXISTS DIML_ISTINGS; 

DROP TABLE IF EXISTS FACT_REVIEWS; 

DROP TABLE IF EXISTS FULL_MOON_REVIEWS;

DROP TABLE IF EXISTS FULL_MOON_REVIEWS_TRANSLATED;

DROP TABLE IF EXISTS FULL_MOON_REVIEWS_AUGMENTED;

DROP DATABASE IF EXISTS AIRBNB;

DROP WAREHOUSE IF EXISTS XLARGE_COMPUTE_WH;

```
