# Lab 2 — Pipelines de données continus avec Snowflake (Snowpipe • Streams • Tasks)

> **Objectifs**

> - Orchestrer des **tâches récurrentes** avec **Tasks** (planification CRON, dépendances).


## 0) Prérequis & contexte

- Compte Snowflake avec rôle **ACCOUNTADMIN**,
- Accès AWS (console IAM/S3) si vous réalisez la partie intégration de stockage avec **votre** bucket. Dans le cadre du cours, cette partie sera réalisée par votre instructeur.
- Pour le lab, un bucket déjà préparé peut être utilisé :  
  **`s3://logbrain-datalake/datasets/citibike_snowpipe/`**.

> **Rappel** — Snowflake propose :

> - **Streams** : capture **CDC** (Change Data Capture) sur une table (INSERT/UPDATE/DELETE).
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

-- Contexte d’exécution (DB/Schema/Warehouse)
USE DATABASE CITIBIKE;
USE SCHEMA PUBLIC;
USE WAREHOUSE DATAPIPELINES_WH;
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
CREATE OR REPLACE TABLE TRIPS_NEW (
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
CREATE OR REPLACE FILE FORMAT CITBIKE.FILE_FORMATS.CSV
  TYPE = CSV
  FIELD_DELIMITER = ','
  SKIP_HEADER = 1
  NULL_IF = ('NULL','null')
  FIELD_OPTIONALLY_ENCLOSED_BY = '\042'
  EMPTY_FIELD_AS_NULL = TRUE;
```

### 2.3 Créer le **stage** externe S3 (lié à l’intégration)

```sql
CREATE OR REPLACE STAGE CITIBIKE.EXTERNAL_STAGES.CSV_FOLDER
  URL = 's3://logbrain-datalake/datasets/citibike_snowpipe/'
  FILE_FORMAT = CITIBIKE.FILE_FORMATS.CSV;

-- Vérifier le contenu
LIST @CSV_FOLDER;
```

### 2.4 Charger via **COPY INTO**

```sql
COPY INTO CITIBIKE.PUBLIC.TRIPS_NEW
  FROM @CITIBIKE.EXTERNAL_STAGES.CSV_FOLDER
  PATTERN = '.*\.csv.*';
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

CREATE OR REPLACE TABLE CUSTOMERS (
  CUSTOMER_ID INT AUTOINCREMENT START = 1 INCREMENT = 1,
  FIRST_NAME  VARCHAR(40) DEFAULT 'JENNIFER',
  CREATE_DATE TIMESTAMP
);
```

### 3.2 Créer une **task** récurrente (toutes les minutes)

```sql
CREATE OR REPLACE TASK CUSTOMER_INSERT
  WAREHOUSE = DATAPIPELINES_WH
  SCHEDULE  = 'USING CRON * * * * * UTC'
AS
INSERT INTO CUSTOMERS(CREATE_DATE) VALUES (CURRENT_TIMESTAMP);
```

> **Référence CRON**  
> `min hour day-of-month month day-of-week [timezone]`
n planificateur CRON comporte 5 champs (parfois 6 si les secondes sont incluses). Dans l’ordre :

* **Minute** → * = chaque minute

* **Heure** → * = chaque heure

* **Jour du mois** → * = chaque jour du mois

* **Mois** → * = chaque mois

* **Jour de la semaine** → * = chaque jour de la semaine

**Signification:**

* * * * * signifie exécuter la tâche chaque minute, de chaque heure, de chaque jour, de chaque mois, quel que soit le jour de la semaine.

Le UTC à la fin précise le fuseau horaire dans lequel cette planification est interprétée. Ainsi, la tâche sera déclenchée une fois par minute, en continu, en Temps Universel Coordonné (UTC).

Activer / suspendre et contrôler :
```sql
SHOW TASKS;

ALTER TASK CUSTOMER_INSERT RESUME;   -- démarrer
SELECT * FROM CUSTOMERS;

ALTER TASK CUSTOMER_INSERT SUSPEND;  -- arrêter
```

### 3.3 Exemples de planification

```sql
-- Tous les jours à 06:00 UTC
ALTER TASK CUSTOMER_INSERT SET SCHEDULE = 'USING CRON 0 6 * * * UTC';

-- Toutes les heures de 9h à 17h (UTC)
ALTER TASK CUSTOMER_INSERT SET SCHEDULE = 'USING CRON 0 9-17 * * * UTC';

-- Tous les dimanches à la minute 0 de chaque heure (America/Los_Angeles)
ALTER TASK CUSTOMER_INSERT SET SCHEDULE = 'USING CRON 0 * * * SUN America/Los_Angeles';
```

### 3.4 Arbre de tasks (dépendances)

```sql
-- Table 2 et 3
CREATE OR REPLACE TABLE CUSTOMERS2 (
  CUSTOMER_ID INT, 
  FIRST_NAME VARCHAR(40), 
  CREATE_DATE TIMESTAMP
);

CREATE OR REPLACE TABLE CUSTOMERS3 (
  CUSTOMER_ID INT, 
  FIRST_NAME VARCHAR(40), 
  CREATE_DATE TIMESTAMP,
  INSERT_DATE DATE DEFAULT DATE(CURRENT_TIMESTAMP)
);

-- Task enfant, après CUSTOMER_INSERT
CREATE OR REPLACE TASK CUSTOMER_INSERT2
  WAREHOUSE = DATAPIPELINES_WH
  AFTER CUSTOMER_INSERT
AS
INSERT INTO CUSTOMERS2 SELECT * FROM CUSTOMERS;

-- Task enfant (niveau 2), après CUSTOMER_INSERT2
CREATE OR REPLACE TASK CUSTOMER_INSERT3
  WAREHOUSE = DATAPIPELINES_WH
  AFTER CUSTOMER_INSERT2
AS
INSERT INTO CUSTOMERS3 (CUSTOMER_ID, FIRST_NAME, CREATE_DATE)
SELECT CUSTOMER_ID, FIRST_NAME, CREATE_DATE FROM CUSTOMERS2;

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
CREATE OR REPLACE TASK CITIBIKE_COPY
  WAREHOUSE = DATAPIPELINES_WH
  SCHEDULE  = 'USING CRON 2 * * * * UTC'
AS
COPY INTO CITIBIKE.PUBLIC.TRIPS_NEW FROM @CITIBIKE.EXTERNAL_STAGES.CSV_FOLDER   PATTERN = '.*\.csv.*';
```

**Contrôle :**
```sql
SELECT COUNT(*) FROM CITIBIKE.PUBLIC.TRIPS_NEW;
```

> ! il faut déposer des nouveaux fichier dans le bucket data-lake.

## 4) Checklist de fin
 
- [ ] **Stage** externe + **File Format** opérationnels.  
- [ ] **COPY** batch initial exécuté vers `TRIPS_NEW`.  
- [ ] **Tasks** : planification, exécution, dépendances testées.  

