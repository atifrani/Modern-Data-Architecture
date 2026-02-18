
# Lab Snowflake – Introduction au Machine Learning  
## Cas pratique : Prédiction du churn client

## Objectif du lab

Dans ce lab, vous allez :

1. Créer un environnement de travail dans Snowflake  
2. Charger un dataset client pédagogique  
3. Explorer les données avec SQL  
4. Préparer les données pour un modèle de Machine Learning  
5. Entraîner un modèle simple avec Snowpark Python  
6. Évaluer ses performances  

**Niveau requis :** débutant en SQL, Python et Snowflake.



# Partie 1 – Préparation de l’environnement

```
from snowflake.snowpark.context import get_active_session
session = get_active_session()
# Add a query tag to the session. This helps with troubleshooting and performance monitoring.
session.query_tag = {"origin":"axelt", 
                     "name":"notebook_demo_ml", 
                     "version":{"major":1, "minor":0},
                     "attributes":{"is_quickstart":1, "source":"notebook", "vignette":"ml_demo"}}
print(session)
```

## Étape 1 – Création du warehouse, de la base et du schéma

Exécutez les commandes suivantes dans un notebook :

```
CREATE OR REPLACE WAREHOUSE ML_WH
  WITH WAREHOUSE_SIZE = 'XSMALL'
  AUTO_SUSPEND = 60
  AUTO_RESUME = TRUE;

USE WAREHOUSE ML_WH;

CREATE OR REPLACE DATABASE ML_LAB_DB;
USE DATABASE ML_LAB_DB;

CREATE OR REPLACE SCHEMA ML_SCHEMA;
USE SCHEMA ML_SCHEMA;
```

Vérifiez que vous travaillez bien dans :

* **Warehouse** : ML_WH
* **Database** : ML_LAB_DB
* **Schema** : ML_SCHEMA



# Partie 2 – Création du dataset client pédagogique

## Description des colonnes

| Colonne               | Description                        |
|  | - |
| customer_id           | Identifiant client                 |
| age                   | Âge                                |
| tenure_months         | Ancienneté en mois                 |
| monthly_spend         | Dépense mensuelle moyenne          |
| num_logins_last_month | Nombre de connexions               |
| support_tickets       | Nombre de tickets support          |
| churn                 | 1 = client parti, 0 = client actif |



## Étape 2 – Création de la table

```
CREATE OR REPLACE TABLE CUSTOMERS (
    customer_id INT,
    age INT,
    tenure_months INT,
    monthly_spend FLOAT,
    num_logins_last_month INT,
    support_tickets INT,
    churn INT
);
```

## Étape 3 – Chargement des données

1. Téléchargez le fichier [`customers_1000.csv`](../data/customers_1000.csv).
2. Depuis l’interface web Snowflake :

   * Allez dans **Data → Databases**
   * Sélectionnez la table `CUSTOMERS`
   * Cliquez sur **Load Data**
   * Suivez l’assistant pour importer le fichier CSV

Vérification :

```
SELECT COUNT(*) FROM CUSTOMERS;
```

Le résultat doit contenir **1000 lignes**.

# Partie 3 – Exploration des données avec SQL

## Étape 4 – Nombre total de clients

```
SELECT COUNT(*) AS total_clients
FROM CUSTOMERS;
```


## Étape 5 – Répartition churn / non churn

```
SELECT churn, COUNT(*) AS nb_clients
FROM CUSTOMERS
GROUP BY churn;
```

Interprétation :

* churn = 1 → client parti
* churn = 0 → client actif


## Étape 6 – Analyse simple

### Dépense mensuelle moyenne

```
SELECT AVG(monthly_spend) AS avg_monthly_spend
FROM CUSTOMERS;
```

### Ancienneté moyenne

```
SELECT AVG(tenure_months) AS avg_tenure
FROM CUSTOMERS;
```

# Partie 4 – Préparation des features

## Étape 7 – Création d’une vue simplifiée

```
CREATE OR REPLACE VIEW CUSTOMER_FEATURES AS
SELECT
    age,
    tenure_months,
    monthly_spend,
    num_logins_last_month,
    support_tickets,
    churn
FROM CUSTOMERS;
```

Vérification :

```
SELECT * FROM CUSTOMER_FEATURES;
```

# Partie 5 – Entraînement du modèle avec Snowpark Python

## Étape 8 – Charger les données

```
df = session.table("CUSTOMER_FEATURES")
df.show()
```

## Étape 9 – Conversion en pandas

```
pandas_df = df.to_pandas()

X = pandas_df.drop("CHURN", axis=1)
y = pandas_df["CHURN"]
```

## Étape 10 – Séparation train/test

```
from sklearn.model_selection import train_test_split

X_train, X_test, y_train, y_test = train_test_split(
    X, y, test_size=0.3, random_state=42
)
```

## Étape 11 – Entraînement du modèle

```
from sklearn.linear_model import LogisticRegression

model = LogisticRegression()
model.fit(X_train, y_train)
```

## Étape 12 – Prédictions et métriques

```
from sklearn.metrics import accuracy_score, precision_score, recall_score

y_pred = model.predict(X_test)

accuracy = accuracy_score(y_test, y_pred)
precision = precision_score(y_test, y_pred)
recall = recall_score(y_test, y_pred)

accuracy, precision, recall
```

Les trois valeurs correspondent à :

* **Accuracy**
* **Précision**
* **Rappel**

# Partie 6 – Interprétation

Posez-vous les questions suivantes :

* Le modèle détecte-t-il correctement les clients churn ?
* Génère-t-il beaucoup de fausses alertes ?
* Quelle métrique est la plus importante pour le métier ?

Dans un cas réel de churn :

* Un **faible rappel** signifie que vous laissez partir des clients sans les détecter.
* Une **faible précision** signifie que vous ciblez des clients qui n’auraient pas quitté.

# Partie 7 – Génération des prédictions globales

```
pandas_df["prediction"] = model.predict(X)
pandas_df
```

Vous obtenez maintenant une colonne supplémentaire avec les prédictions.

## Étape 1 – Créer une table de scoring

Après l’entraînement du modèle dans votre worksheet Python, exécutez ce code pour :
- calculer la **prédiction** pour chaque client
- écrire les résultats dans une table Snowflake `CUSTOMER_PREDICTIONS`

```
def age_cat(age: int) -> str:
    if age < 25:
        return "<25"
    elif age < 35:
        return "25-34"
    elif age < 45:
        return "35-44"
    elif age < 55:
        return "45-54"
    else:
        return "55+"

pandas_df["age_category"] = pandas_df["AGE"].apply(age_cat)

# Convertir en Snowpark dataframe
sp_df = session.create_dataframe(pandas_df)

# Écrire dans une table Snowflake
sp_df.write.mode("overwrite").save_as_table("CUSTOMER_PREDICTIONS")
```

## Étape 2 – Créer une vue d’agrégation (pratique pour Streamlit)

Cette vue calcule le nombre de churn prédits par catégorie d’âge.

```
CREATE OR REPLACE VIEW CHURN_PRED_BY_AGE_CATEGORY AS
SELECT
  "age_category" as AGE_CATEGORY,
  COUNT(*) AS nb_customers,
  SUM("prediction") AS nb_churn_predicted,
  ROUND(100 * SUM("prediction") / COUNT(*), 2) AS churn_predicted_rate_pct
FROM CUSTOMER_PREDICTIONS
GROUP BY "age_category"
ORDER BY
  CASE "age_category"
    WHEN '<25' THEN 1
    WHEN '25-34' THEN 2
    WHEN '35-44' THEN 3
    WHEN '45-54' THEN 4
    ELSE 5
  END;

```

Vérification:

```
SELECT * FROM CHURN_PRED_BY_AGE_CATEGORY;
```

## Étape 3 – Code Streamlit (dataviz + tableau)


```
import streamlit as st
import pandas as pd

# Snowflake
from snowflake.snowpark.context import get_active_session


st.title("📊 Prédictions de churn par catégorie d’âge")

session = get_active_session()

# Charger les agrégations
agg_df = session.table("CHURN_PRED_BY_AGE_CATEGORY").to_pandas()

# KPI simples
col1, col2, col3 = st.columns(3)
col1.metric("Catégories d’âge", int(agg_df["AGE_CATEGORY"].nunique()))
col2.metric("Clients (total)", int(agg_df["NB_CUSTOMERS"].sum()))
col3.metric("Churn prédit (total)", int(agg_df["NB_CHURN_PREDICTED"].sum()))

st.subheader("Churn prédit par catégorie d’âge")

# Bar chart : churn prédit
chart_df = agg_df.set_index("AGE_CATEGORY")[["NB_CHURN_PREDICTED"]]
st.bar_chart(chart_df)

st.subheader("Taux de churn prédit (%) par catégorie d’âge")
rate_df = agg_df.set_index("AGE_CATEGORY")[["CHURN_PREDICTED_RATE_PCT"]]
st.line_chart(rate_df)

with st.expander("Voir les données agrégées"):
    st.dataframe(agg_df, use_container_width=True)

```

# Validation finale

Vérifiez que :

* Les objets Snowflake existent
* La table contient bien 1000 lignes
* Les requêtes SQL fonctionnent
* Le modèle s’entraîne sans erreur
* Les métriques sont affichées

# Ce que vous avez appris

* Créer un environnement Snowflake
* Charger et explorer des données
* Préparer des features
* Utiliser Snowpark Python
* Entraîner un modèle de classification simple
* Interpréter accuracy, précision et rappel

