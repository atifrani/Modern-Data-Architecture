# Lab 2 — Pipelines de données continus avec Snowflake (Snowpipe • Streams • Tasks)

> **Objectifs**

> - Orchestrer des **tâches récurrentes** avec **Tasks** (planification CRON, dépendances).


## 0) Prérequis & contexte

- Compte Snowflake avec rôle **ACCOUNTADMIN**,
- Accès AWS (console IAM/S3) si vous réalisez la partie intégration de stockage avec **votre bucket**. Dans le cadre du cours, cette partie sera réalisée par votre instructeur.
- Pour le lab, un bucket déjà préparé peut être utilisé :  
  **`s3://logbrain-datalake/datasets/citibike_snowpipe/`**.

> **Rappel** — Snowflake propose :

> - **Tasks** : planification d’instructions SQL (timer ou CRON) et **arbres de dépendances**.

---

## 1) Mise en place : base, entrepôt, contexte

```sql

--  Basculer avec des privilèges élevés pour le lab
USE ROLE ACCOUNTADMIN;

-- Créer un entrepôt dédié
CREATE WAREHOUSE IF NOT EXISTS DATAPIPELINES_WH
  WITH WAREHOUSE_SIZE = 'XSMALL'
  AUTO_SUSPEND = 5
  AUTO_RESUME = TRUE;

-- Créer une base de données
CREATE DATABASE IF NOT EXISTS CITIBIKE;

-- Contexte d’exécution (DB/Schema/Warehouse)
USE WAREHOUSE DATAPIPELINES_WH;

USE DATABASE CITIBIKE;

USE SCHEMA PUBLIC;

```

**Vérifications :**
```sql
SHOW WAREHOUSES;

SHOW DATABASES;

SELECT CURRENT_ROLE(), CURRENT_WAREHOUSE(), CURRENT_DATABASE(), CURRENT_SCHEMA();
```

## 2) Chargement batch initial (stage + format + COPY)

### 2.1 Créer la table cible

```sql
CREATE OR REPLACE TABLE CITIBIKE.PUBLIC.TRIPS_NEW (
  tripduration            INTEGER,
  starttime               TIMESTAMP,
  stoptime                TIMESTAMP,
  start_station_id        INTEGER,
  start_station_name      STRING,
  start_station_latitude  FLOAT,
  start_station_longitude FLOAT,
  end_station_id          INTEGER,
  end_station_name        STRING,
  end_station_latitude    FLOAT,
  end_station_longitude   FLOAT,
  bikeid                  INTEGER,
  membership_type         STRING,
  usertype                STRING,
  birth_year              INTEGER,
  gender                  INTEGER
);
```

### 2.2 Définir un **file format** CSV

```sql
CREATE OR REPLACE FILE FORMAT CITBIKE.PUBLIC.CSV_FORMAT
  TYPE = CSV
  FIELD_DELIMITER = ','
  SKIP_HEADER = 1
  NULL_IF = ('NULL','null')
  FIELD_OPTIONALLY_ENCLOSED_BY = '\042'
  EMPTY_FIELD_AS_NULL = TRUE;
```

### 2.3 Créer le **stage** externe S3 (lié à l’intégration)

```sql
CREATE OR REPLACE STAGE CITIBIKE.PUBLIC.CSV_STAGE
  URL = 's3://logbrain-datalake/datasets/citibike_snowpipe/';

-- Vérifier le contenu
LIST @CSV_FOLDER;
```

### 2.4 Charger via **COPY INTO**

```sql
COPY INTO CITIBIKE.PUBLIC.TRIPS_NEW
  FROM @CITIBIKE.PUBLIC.CSV_STAGE
  FILE_FORMAT = CSV_FORMAT;
```

**Contrôle :**

```sql
SELECT COUNT(*) FROM CITIBIKE.PUBLIC.TRIPS_NEW;
```

> **Astuce** : si vous devez ajuster le format, modifiez le file format puis relancez `COPY`.  
> (Dans ce lab, nous conservons un seul file format cohérent pour éviter toute confusion.)

> ! Le stage est pour le moment vide car aucun fichier n'est déposé dans le dépôt **s3://logbrain-datalake/datasets/citibike_snowpipe/**

> Nous allons déposer un premier fichier et relancer la commande **Copy**


## 3) Tasks — Planifier et chaîner des Ingestions et des traitements

### 3.1 Base et table pour la démo

```sql

CREATE OR REPLACE TABLE CITIBIKE.PUBLIC.CUSTOMERS (
  CUSTOMER_ID INT AUTOINCREMENT START = 1 INCREMENT = 1,
  FIRST_NAME  VARCHAR(40) DEFAULT 'JENNIFER',
  CREATE_DATE TIMESTAMP
);
```

### 3.2 Créer une **task** récurrente (toutes les minutes)

```sql
CREATE OR REPLACE TASK CITIBIKE.PUBLIC.CUSTOMER_INSERT
  WAREHOUSE = DATAPIPELINES_WH
  SCHEDULE  = 'USING CRON * * * * * UTC'
AS
INSERT INTO CITIBIKE.PUBLIC.CUSTOMERS(CREATE_DATE) VALUES (CURRENT_TIMESTAMP);
```

> **Référence CRON**  

> `min hour day-of-month month day-of-week [timezone]`

Un planificateur CRON comporte 5 champs (parfois 6 si les secondes sont incluses). Dans l’ordre :

* **Minute** → * = chaque minute

* **Heure** → * = chaque heure

* **Jour du mois** → * = chaque jour du mois

* **Mois** → * = chaque mois

* **Jour de la semaine** → * = chaque jour de la semaine

**Signification:**

* * * * * signifie exécuter la tâche chaque minute, de chaque heure, de chaque jour, de chaque mois, quel que soit le jour de la semaine.

Le UTC à la fin précise le fuseau horaire dans lequel cette planification est interprétée. Ainsi, la tâche sera déclenchée une fois par minute, en continu, en Temps Universel Coordonné (UTC).

**Activer / suspendre et contrôler** :

```sql
SHOW TASKS;

ALTER TASK CUSTOMER_INSERT RESUME;   -- démarrer

SELECT * FROM CUSTOMERS;

ALTER TASK CUSTOMER_INSERT SUSPEND;  -- arrêter
```

### 3.3 Exemples de planification

```sql
-- Tous les jours à 06:00 UTC
ALTER TASK CITIBIKE.PUBLIC.CUSTOMER_INSERT SET SCHEDULE = 'USING CRON 0 6 * * * UTC';

-- Toutes les heures de 9h à 17h (UTC)
ALTER TASK CITIBIKE.PUBLIC.CUSTOMER_INSERT SET SCHEDULE = 'USING CRON 0 9-17 * * * UTC';

-- Tous les dimanches à la minute 0 de chaque heure (America/Los_Angeles)
ALTER TASK CITIBIKE.PUBLIC.CUSTOMER_INSERT SET SCHEDULE = 'USING CRON 0 * * * SUN America/Los_Angeles';
```

### 3.4 Arbre de tasks (dépendances)

```sql
-- Table 2 et 3
CREATE OR REPLACE TABLE CITIBIKE.PUBLIC.CUSTOMERS2 (
  CUSTOMER_ID INT, 
  FIRST_NAME VARCHAR(40), 
  CREATE_DATE TIMESTAMP
);

CREATE OR REPLACE TABLE CITIBIKE.PUBLIC.CUSTOMERS3 (
  CUSTOMER_ID INT, 
  FIRST_NAME VARCHAR(40), 
  CREATE_DATE TIMESTAMP,
  INSERT_DATE DATE DEFAULT DATE(CURRENT_TIMESTAMP)
);

-- Task enfant, après CUSTOMER_INSERT
CREATE OR REPLACE TASK CITIBIKE.PUBLIC.CUSTOMER_INSERT2
  WAREHOUSE = DATAPIPELINES_WH
  AFTER CITIBIKE.PUBLIC.CUSTOMER_INSERT
AS
INSERT INTO CITIBIKE.PUBLIC.CUSTOMERS2 SELECT * FROM CITIBIKE.PUBLIC.CUSTOMERS;

-- Task enfant (niveau 2), après CUSTOMER_INSERT2
CREATE OR REPLACE TASK CITIBIKE.PUBLIC.CUSTOMER_INSERT3
  WAREHOUSE = DATAPIPELINES_WH
  AFTER CITIBIKE.PUBLIC.CUSTOMER_INSERT2
AS
INSERT INTO CITIBIKE.PUBLIC.CUSTOMERS3 (CUSTOMER_ID, FIRST_NAME, CREATE_DATE)
SELECT CUSTOMER_ID, FIRST_NAME, CREATE_DATE FROM CITIBIKE.PUBLIC.CUSTOMERS2;

-- Démarrage de la chaîne (on relance la racine)
ALTER TASK CUSTOMER_INSERT   RESUME;

ALTER TASK CUSTOMER_INSERT2  RESUME;

ALTER TASK CUSTOMER_INSERT3  RESUME;

-- Contrôle
SHOW TASKS;

SELECT * FROM CUSTOMERS2;

SELECT * FROM CUSTOMERS3;

-- Stopper
ALTER TASK CUSTOMER_INSERT   SUSPEND;

ALTER TASK CUSTOMER_INSERT2  SUSPEND;

ALTER TASK CUSTOMER_INSERT3  SUSPEND;
```

### 3.5 Ingestion en continue:

Nous allons utliser les tasks pour simuler une ingestion continue des données CITIBIKE. Pour cela nous allons créer une task qui va exécuter la commande **Copy** toutes les deux minutes.

```sql
CREATE OR REPLACE TASK CITIBIKE.PUBLIC.CITIBIKE_COPY
  WAREHOUSE = DATAPIPELINES_WH
  SCHEDULE  = 'USING CRON 2 * * * * UTC'
AS
COPY INTO CITIBIKE.PUBLIC.TRIPS_NEW
  FROM @CITIBIKE.PUBLIC.CSV_STAGE
  FILE_FORMAT = CSV_FORMAT;
```

**Contrôle :**

```sql
SELECT COUNT(*) FROM CITIBIKE.PUBLIC.TRIPS_NEW;
```

> ! il faut déposer des nouveaux fichier dans le bucket **s3://logbrain-datalake/datasets/citibike_snowpipe**.

## 4) Checklist de fin
 
- [ ] **Stage** + **File Format** opérationnels.  
- [ ] **COPY** batch initial exécuté vers `TRIPS_NEW`.  
- [ ] **Tasks** : planification, exécution, dépendances testées.  


## Les tables dynamiques:

Les tables dynamiques sont des tables qui s’actualisent automatiquement en fonction d’une requête définie et du niveau d’actualisation de la cible, ce qui simplifie la transformation des données et la gestion du pipeline sans nécessiter de mises à jour manuelles ou de planification personnalisée.

![alt text](../images/dynamic.png)

Les tables dynamiques sont idéales dans les cas suivants :

* Vous souhaitez matérialiser les résultats de requêtes sans écrire de code personnalisé.

* Vous voulez éviter le suivi manuel des dépendances de données et la gestion des plannings de rafraîchissement. Les tables dynamiques permettent de définir les résultats d’un pipeline de manière déclarative, sans avoir à gérer manuellement les étapes de transformation.

* Vous souhaitez enchaîner plusieurs tables pour réaliser des transformations de données au sein d’un pipeline.

* Vous n’avez pas besoin d’un contrôle fin des fréquences de rafraîchissement et il vous suffit de définir un objectif de fraîcheur des données pour le pipeline. Snowflake se charge alors de l’orchestration des rafraîchissements, y compris la planification et l’exécution, en fonction de vos exigences de fraîcheur.

Commençons avec une table de base simple **base_orders** et une table dynamique **dynamic_base_orders**.

```
CREATE OR REPLACE TABLE CITIBIKE.PUBLIC.base_orders (
  order_id INT,
  customer_id INT,
  order_amount NUMBER
);

INSERT INTO CITIBIKE.PUBLIC.base_orders (order_id, customer_id, order_amount) VALUES
(1, 101, 250.50),
(2, 102, 100.00),
(3, 103, 75.75);
```

Nous allons maintenant créer une table dynamique:

```
CREATE OR REPLACE DYNAMIC TABLE CITIBIKE.PUBLIC.dynamic_base_orders
  TARGET_LAG = '1 minute'
  WAREHOUSE = DATAPIPELINES_WH
  AS SELECT * FROM CITIBIKE.PUBLIC.base_orders;  
```

Vérifions le résultat:

```
SELECT * FROM CITIBIKE.PUBLIC.dynamic_base_orders
```

Insérons de nouvelles valeurs dans le table 

```
INSERT INTO CITIBIKE.PUBLIC.base_orders (order_id, customer_id, order_amount) VALUES
(4, 104, 150.50),
(6, 104, 80.00),
(6, 106, 65.75);
```

Vérifions le résultat:

```
SELECT * FROM CITIBIKE.PUBLIC.dynamic_base_orders
```

Voici un exemple de code montrant comment nous pourrions créer une table dynamique en utilisant notre table **TRIPS_NEW** comme base. Parcourez-le, et nous le détaillerons ensuite.

```
# Your Dynamic Table parameters
CREATE OR REPLACE Dynamic Table CITIBIKE.PUBLIC.TRIPS_AGG_START_STATION
  TARGET_LAG = '1 minutes'
  WAREHOUSE = 'DATAPIPELINES_WH'
  REFRESH_MODE = auto
  INITIALIZE = on_create
  AS
# Your SQL query for the table itself
  SELECT
    start_station_name,
    COUNT(*) AS NB_TRIPS,
  FROM CITIBIKE.PUBLIC.TRIPS_NEW
  GROUP BY start_station_name;
```

* **TARGET_LAG** : spécifie l’exigence de fraîcheur. Vous pouvez définir une durée ici, ou indiquer **"DOWNSTREAM"** si une autre table dynamique consomme déjà ces données.

* **WAREHOUSE** : détermine les ressources de calcul. Veillez à sélectionner le bon *warehouse* Snowflake afin de disposer de suffisamment de ressources pour générer la table de manière rentable.

* **REFRESH_MODE** : peut être défini explicitement sur **INCREMENTAL** ou **FULL**. J’ai choisi **AUTO** pour laisser Snowflake déterminer la méthode optimale.

* **INITIALIZE** : détermine quand la table est initialisée. **ON_CREATE** signifie que la table est initialisée immédiatement. En le réglant sur **ON_SCHEDULE**, la table sera initialisée une fois que la première période de **TARGET_LAG** sera atteinte.