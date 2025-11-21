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
