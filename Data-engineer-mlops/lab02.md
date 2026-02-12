# Comment charger des fichiers CSV depuis un stage vers Snowflake Notebooks 📁

Dans cet exemple, nous allons montrer comment charger un fichier CSV depuis un stage et créer une table avec Snowpark.

Commençons par utiliser la commande `get_active_session` afin d’obtenir la variable de contexte de session pour travailler avec Snowpark :

```python
from snowflake.snowpark.context import get_active_session
session = get_active_session()
# Add a query tag to the session. This helps with troubleshooting and performance monitoring.
session.query_tag = {"origin":"sf_sit-is", 
                     "name":"notebook_demo_s3", 
                     "version":{"major":1, "minor":0},
                     "attributes":{"is_quickstart":2, "source":"notebook", "vignette":"csv_from_s3"}}
print(session)
```


## Créer un stage externe

Nous allons maintenant créer un stage externe qui référence des fichiers de données stockés en dehors de Snowflake. Dans cet exemple, les données sont stockées dans un bucket S3.

```sql

CREATE DATABASE IF NOT EXISTS CITIBIKE;

USE DATABASE CITIBIKE;

USE SCHEMA PUBLIC;

CREATE STAGE IF NOT EXISTS CITIBIKE_STAGE 
	URL = 's3://logbrain-datalake/datasets/citibike-trips-csv/';
```

## Vérifier les fichiers présents dans le stage

Examinons les fichiers disponibles dans le stage.

```sql
LS @CITIBIKE_STAGE;
```

## Charger le fichier CSV avec Snowpark

Nous pouvons utiliser **Snowpark DataFrameReader** pour lire le fichier CSV.

En utilisant l’option `infer_schema = True`, Snowflake déduira automatiquement le schéma à partir des types de données présents dans le fichier CSV, ce qui évite de devoir le définir manuellement.

```python
# Create a DataFrame that is configured to load data from the CSV file.
df = session.read.options({"infer_schema":True}).csv('@CITIBIKE_STAGE/trips_2018_0_0_0.csv.gz')
```

```python
df
```

## Travailler avec le DataFrame Snowpark

Une fois les données chargées dans un DataFrame Snowpark, nous pouvons les manipuler à l’aide de l’API Snowpark DataFrame.

Par exemple, nous pouvons calculer des statistiques descriptives sur les colonnes :

```python
df.describe()
```

## Écrire le DataFrame dans une table Snowflake

Nous pouvons enregistrer le DataFrame dans une table nommée `TRIPS` puis l’interroger en SQL.

```python
df.write.mode("overwrite").save_as_table("TRIPS")
```

```sql
-- Preview the newly created TRIPS table
SELECT * from TRIPS;
```

## Relire la table dans Snowpark

Enfin, nous pouvons relire la table dans Snowpark en utilisant la syntaxe `session.table`.

```python
df = session.table("TRIPS")
df
```

## Continuer le traitement des données

À partir d’ici, vous pouvez continuer à interroger et traiter les données.

```python
df.groupBy('"start_station_name"').count()
```

## Charger les données de méteo:

nous allons créer un nouveau stage pour les données météo

```

USE DATABASE CITBIKE;

CREATE STAGE IF NOT EXISTS WEATHER_STAGE 
	URL = 's3://logbrain-datalake/datasets/weather-nyc-json/';
```

## Vérifier les fichiers présents dans le stage

```
LS @WEATHER_STAGE;
```

## Charger le fichier CSV avec Snowpark

Nous pouvons utiliser Snowpark DataFrameReader pour lire le fichier JSON.

En utilisant l’option infer_schema = True, Snowflake déduira automatiquement le schéma à partir des types de données présents dans le fichier JSON, ce qui évite de devoir le définir manuellement.

```
# Create a DataFrame that is configured to load data from the json file.
df = session.read.options({"infer_schema":True}).csv('@WEATHER_STAGE/hourlyData-2018-1.json.gz')
```

```
df
```
## Travailler avec le DataFrame Snowpark
 
```
df.describe()
```

## Écrire le DataFrame dans une table Snowflake

```
df.write.mode("overwrite").save_as_table("WEATHER_JSON")
```

```
-- Preview the newly created weather table
SELECT * from WEATHER_JSON;
```

## Relire la table dans Snowpark

```
df = session.table("WEATHER_JSON")
df
```

##  Process the JSON data

```
USE DATABASE CITBIKE;

CREATE TABLE IF NOT EXISTS weather as
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
 from WEATHER_JSON;

```

```
-- Preview the newly created weather table
SELECT * from WEATHER;
```

## Relire la table dans Snowpark

```
df = session.table("WEATHER")
df
```

## Nettoyage des ressources

Suppression de la table et du stage créés dans cet exemple :

```sql
-- Teardown table and stage created as part of this example
DROP TABLE TRIPS;
DROP TABLE WEATHER;
DROP TABLE WEATHER_JSON;
DROP STAGE CITIBIKE_STAGE;
DROP DATABASE CITIKIE;
```
## Conclusion

Dans cet exemple, nous avons vu comment charger des fichiers CSV depuis un stage externe afin de traiter et interroger les données dans un notebook à l’aide de Snowpark.
