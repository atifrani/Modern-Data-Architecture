## Utilisation Copilot pour analyser les données.
Dans cette partie, nous allons utiliser la base de données SNOWFLAKE_SAMPLE_DATA.
Nous commencerons par demander à Copilot de fournir une vue d’ensemble de cet ensemble de données.

**prompt** : Tell me about this data.

Now, we will ask COPILOT to calculate the total income grouped by region.
**prompt** : Calculate the total income by region.

Next, we will ask for top 10 customers grouped by region.
**prompt** : Compute the top 10 customers by region.

Last, we will ask to summarize the income performance for all regions.
**prompt** : Summarize income performance across all regions.

Nous pouvons essayer de faire le même exercice sur les données de la base CITIBIKE.


## Utilisation de Cortex:

Nous allons maintenant aller plus loin en utilisant Cortex et un modèle de langage de grande taille (LLM).

Pour commencer, nous allons examiner un exemple simple.


* **CORTEX TRANSLATE :**

```sql
select SNOWFLAKE.CORTEX.TRANSLATE('Hello Everyone', '', 'fr') AS greeting;
```

* **CORTEX SENTIMENTS :**

```sql
select SNOWFLAKE.CORTEX.SENTIMENT('This course is amazing') AS greeting;
```

* **EXTRACT_ANSWER :**

```sql
select SNOWFLAKE.CORTEX.EXTRACT_ANSWER('The motto of France is Liberty, Equality, Fraternity. It originated during the French Revolution of 1789 and embodies the fundamental values of the French Republic.', 'what is the motto france') AS response;
```

* **COMPLETE :**

```sql

CREATE WAREHOUSE IF NOT EXISTS CORTEX_WH
  WITH WAREHOUSE_SIZE = 'XLARGE'
  AUTO_SUSPEND = 5
  AUTO_RESUME = TRUE;

USE WAREHOUSE CORTEX_WH;

select SNOWFLAKE.CORTEX.COMPLETE('mistral-large2', 'Quelle est la capitale de la France?') as response_to_prompt;
```

**Une autre maniére d'écrire**:

```sql
SET prompt ='Quelle est la capitale de la France?';

select SNOWFLAKE.CORTEX.COMPLETE('mistral-large2', $prompt) as response_to_prompt;
```

Maintenant nous allons ecrire un prompt pour analyser les données de **CITIBIKE**, pour faire vite on va tester sur un échantillion des données.

```sql
SET prompt ='What is the total number of trips?';

select SNOWFLAKE.CORTEX.COMPLETE('mistral-large2', $prompt) as response_to_prompt from 
CITIBIKE.PUBLIC.TRIPS_NEW;
```


