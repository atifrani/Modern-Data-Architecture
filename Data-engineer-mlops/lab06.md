# Lab Snowflake – Introduction au Machine Learning  
## Cas pratique : Prédiction du churn client

# Objectif du lab

Dans ce lab, vous allez :

1. Créer un environnement de travail dans Snowflake  
2. Charger un dataset client pédagogique  
3. Explorer les données avec SQL  
4. Préparer les données pour un modèle de Machine Learning  
5. Entraîner un modèle simple avec Snowpark Python  
6. Évaluer ses performances  

Niveau requis : débutant en SQL, Python et Snowflake.

# Partie 1 – Préparation de l’environnement

## Étape 1 – Création du warehouse, de la base et du schéma

Exécutez les commandes suivantes dans un worksheet SQL :

```sql
CREATE OR REPLACE WAREHOUSE ML_WH
  WITH WAREHOUSE_SIZE = 'XSMALL'
  AUTO_SUSPEND = 60
  AUTO_RESUME = TRUE;

USE WAREHOUSE ML_WH;

CREATE OR REPLACE DATABASE ML_LAB_DB;
USE DATABASE ML_LAB_DB;

CREATE OR REPLACE SCHEMA ML_SCHEMA;
USE SCHEMA ML_SCHEMA;
````

Vérifiez que vous travaillez bien dans :

* Warehouse : `ML_WH`
* Database : `ML_LAB_DB`
* Schema : `ML_SCHEMA`


# Partie 2 – Création du dataset client pédagogique

## Description des colonnes

| Colonne               | Description                        |
| --------------------- | ---------------------------------- |
| customer_id           | Identifiant client                 |
| age                   | Âge                                |
| tenure_months         | Ancienneté en mois                 |
| monthly_spend         | Dépense mensuelle moyenne          |
| num_logins_last_month | Nombre de connexions               |
| support_tickets       | Nombre de tickets support          |
| churn                 | 1 = client parti, 0 = client actif |

## Étape 2 – Création de la table

```sql
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

## Étape 3 – Insertion des données

```sql
INSERT INTO CUSTOMERS VALUES
(1, 25, 3, 45.0, 5, 2, 1),
(2, 40, 24, 120.0, 18, 0, 0),
(3, 31, 12, 60.0, 10, 1, 0),
(4, 22, 2, 30.0, 3, 3, 1),
(5, 35, 36, 150.0, 25, 0, 0),
(6, 29, 6, 55.0, 7, 2, 1),
(7, 45, 48, 200.0, 30, 0, 0),
(8, 33, 18, 80.0, 12, 1, 0),
(9, 27, 4, 40.0, 4, 4, 1),
(10, 38, 30, 130.0, 20, 0, 0);
```

Vérification :

```sql
SELECT * FROM CUSTOMERS;
```

Le résultat doit contenir 10 lignes.

# Partie 3 – Exploration des données avec SQL

## Étape 4 – Nombre total de clients

```sql
SELECT COUNT(*) AS total_clients
FROM CUSTOMERS;
```

## Étape 5 – Répartition churn / non churn

```sql
SELECT churn, COUNT(*) AS nb_clients
FROM CUSTOMERS
GROUP BY churn;
```

Interprétation :

* churn = 1 → client parti
* churn = 0 → client actif

## Étape 6 – Analyse simple

Dépense moyenne :

```sql
SELECT AVG(monthly_spend) AS avg_monthly_spend
FROM CUSTOMERS;
```

Ancienneté moyenne :

```sql
SELECT AVG(tenure_months) AS avg_tenure
FROM CUSTOMERS;
```

# Partie 4 – Préparation des features

## Étape 7 – Création d’une vue simplifiée

```sql
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

```sql
SELECT * FROM CUSTOMER_FEATURES;
```

# Partie 5 – Entraînement du modèle avec Snowpark Python

## Étape 8 – Créer un worksheet Python

Dans Snowflake :

* Ouvrez un nouveau Worksheet
* Sélectionnez le langage **Python (Snowpark)**
* Vérifiez que vous utilisez la base `ML_LAB_DB` et le schéma `ML_SCHEMA`

## Étape 9 – Charger les données

```python
df = session.table("CUSTOMER_FEATURES")
df.show()
```

## Étape 10 – Conversion en pandas

```python
pandas_df = df.to_pandas()

X = pandas_df.drop("CHURN", axis=1)
y = pandas_df["CHURN"]
```

## Étape 11 – Séparation train/test

```python
from sklearn.model_selection import train_test_split

X_train, X_test, y_train, y_test = train_test_split(
    X, y, test_size=0.3, random_state=42
)
```

## Étape 12 – Entraînement du modèle

```python
from sklearn.linear_model import LogisticRegression

model = LogisticRegression()
model.fit(X_train, y_train)
```

## Étape 13 – Prédictions et métriques

```python
from sklearn.metrics import accuracy_score, precision_score, recall_score

y_pred = model.predict(X_test)

accuracy = accuracy_score(y_test, y_pred)
precision = precision_score(y_test, y_pred)
recall = recall_score(y_test, y_pred)

accuracy, precision, recall
```

Les trois valeurs correspondent à :

* Accuracy
* Précision
* Rappel

# Partie 6 – Interprétation

Posez-vous les questions suivantes :

* Le modèle détecte-t-il bien les churn ?
* Fait-il beaucoup de fausses alertes ?
* Quelle métrique est la plus importante pour le business ?

Dans un cas réel de churn :

* Un faible rappel signifie que vous laissez partir des clients sans les détecter.
* Une faible précision signifie que vous ciblez des clients qui n’auraient pas quitté.

# Partie 7 – Génération de prédictions globales

```python
pandas_df["prediction"] = model.predict(X)
pandas_df
```

Vous obtenez maintenant une colonne supplémentaire avec les prédictions.

# Validation finale

Vérifiez que :

* Les objets Snowflake existent
* La table contient bien 10 lignes
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
