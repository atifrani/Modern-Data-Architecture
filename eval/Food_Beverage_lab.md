# Workshop – Data-Driven Marketing Analytics avec Snowflake et Streamlit

## Contexte du workshop

AnyCompany Food & Beverage (entreprise fictive) est un fabricant de produits alimentaires et de boissons présent sur le marché depuis plus de 25 ans. En 2025, l’entreprise se trouve à un tournant critique de son histoire.

Malgré une réputation solide et une distribution internationale de produits premium, AnyCompany fait face à une **baisse des ventes sans précédent** sur le dernier exercice fiscal, combinée à une **réduction de 30 % de son budget marketing**.

Dans le même temps, le marché est devenu beaucoup plus concurrentiel avec l’arrivée de marques *digital-first* et de startups en vente directe au consommateur (D2C). Ces nouveaux acteurs proposent des produits comparables à des prix inférieurs de 5 à 15 %, s’appuyant sur des chaînes logistiques optimisées et des stratégies marketing fortement pilotées par la donnée.
Résultat : la part de marché d’AnyCompany est passée de **28 % à 22 % en seulement huit mois**.

![alt text](../images/fb1.png)


## Initiative de transformation digitale

Face à cette situation, le PDG a lancé une **initiative de transformation digitale**, plaçant le **marketing data-driven** au cœur de la stratégie de redressement.

Il confie cette mission à **Sarah**, Senior Marketing Executive, qui constitue une petite équipe transverse et spécialisée composée de:
* Data Engineer
* Data Analyst 
* Business Analyst

### Objectif business

L’équipe doit :

* Inverser la tendance à la baisse des ventes
* Atteindre une **augmentation de 10 points de part de marché (de 22 % à 32 %) d’ici le T4 2025**
* Opérer dans un contexte de **budget marketing réduit**

Le succès repose sur une exploitation rapide et efficace des données existantes afin de cibler les produits et segments à plus fort potentiel.

## Parcours du lab

Ce lab reproduit les premières étapes de cette transformation data-driven, depuis la préparation des données jusqu’à l’analyse business, en s’appuyant sur **Snowflake** comme plateforme analytique centrale.

## Prérequis

- Compte Snowflake d’essai (**étudiants : 120 jours**) – inscrivez-vous avec une adresse mail valide , société **MBAESG**, rôle **Étudiant**, **Edition : Enterprise**, **Cloud : AWS**, **Région : us-west-2**.
- lien pour créer votre compte:  https://signup.snowflake.com/?trial=student&cloud=aws&region=us-west-2&utm_source=handsonessentials&utm_campaign=uni-dww# 
- Connaissances de Bases en SQL (DDL/DML) et objets (database, schema, table…).  
- Connaissances des formats **CSV** et **JSON**.

**Bon à savoir – Crédits**  
Conservez **Auto-Suspend** activé et utilisez une **taille d’entrepôt raisonnable** pour éviter d’épuiser vos crédits.  

![alt text](../images/fb2.png)

# Phase 1 – Data Preparation & Ingestion

## Objectif

Mettre en place un socle de données fiable dans Snowflake en chargeant l’ensemble des fichiers CSV et JSON fournis et en les rendant exploitables pour les analyses futures.

Cette phase correspond au travail d’une équipe **Data Engineering / Analytics Engineering**.

## Environnement technique

Nous utilisons **Snowflake** comme plateforme analytique.

* Les données sources sont stockées dans **Amazon S3**: "s3://logbrain-datalake/datasets/food-beverage/"
* Snowflake est utilisé pour :

  * Le chargement des données
  * Le stockage analytique
  * Les requêtes SQL


## Contexte métier

En tant que membres de l’équipe Data Engineering, vous devez préparer des tables permettant de **corréler les performances de vente avec les actions marketing et promotionnelles**.

Les données proviennent de plusieurs domaines métier : ventes, promotions, marketing, clients, logistique, inventaire et service client.


## Fichiers fournis

Les fichiers suivants sont mis à disposition pour le lab :

* `customer_demographics.csv` – données démographiques clients
```
| customer_id | name              | date_of_birth | gender | region | country   | city          | marital_status | annual_income |
| ----------- | ----------------- | ------------- | ------ | ------ | --------- | ------------- | -------------- | ------------- |
| 5911743     | Lisa Fowler       | 1983-05-29    | Male   | Asia   | Sri Lanka | Gonzalesport  | Widowed        | 49 526        |
| 6494773     | Donald Lambert    | 1946-04-07    | Male   | Europe | Italy     | West James    | Married        | 193 290       |
| 6500166     | Michelle Gonzalez | 1978-01-04    | Female | Europe | Italy     | North Joshua  | Divorced       | 78 877        |
| 7519735     | Kirsten White     | 1947-05-11    | Male   | Europe | Italy     | North Anthony | Divorced       | 159 820       |
| 5708869     | Ashley Johnson    | 1961-03-17    | Other  | Europe | France    | Mckenziehaven | Married        | 50 226        |
```
* `customer_service_interactions.csv` – interactions avec le service client
```
| interaction_id | interaction_date | interaction_type | issue_category  | description                                       | duration_minutes | resolution_status | follow_up_required | customer_satisfaction |
| -------------- | ---------------- | ---------------- | --------------- | ------------------------------------------------- | ---------------- | ----------------- | ------------------ | --------------------- |
| CSI5042956     | 2012-08-19       | Phone            | Complaints      | Listen beat tonight other. Pm eye down its fin... | 59               | Pending           | Yes                | 3                     |
| CSI7596382     | 2015-08-05       | Phone            | Complaints      | Commercial attorney soon possible successful...   | 45               | Resolved          | No                 | 4                     |
| CSI2063198     | 2022-04-10       | Phone            | Returns         | Whole benefit stock. Popular ready enjoy land...  | 41               | Resolved          | Yes                | 4                     |
| CSI5112324     | 2013-07-18       | Email            | Returns         | Art tend manager their happy could. Sense nor...  | 44               | Pending           | No                 | 4                     |
| CSI4198852     | 2011-11-06       | Chat             | Product Inquiry | Mr week four. Challenge local phone ten.          | 8                | Escalated         | Yes                | 5                     |
```
* `financial_transactions.csv` – transactions de ventes
```
| transaction_id | transaction_date | transaction_type | amount   | payment_method | entity                      | region        | account_code |
| -------------- | ---------------- | ---------------- | -------- | -------------- | --------------------------- | ------------- | ------------ |
| TRX7743665     | 2015-12-13       | Investment       | 513.22   | Bank Transfer  | Hartman, Martinez and Huff  | Oceania       | YAZJGBI2     |
| TRX7009965     | 2019-11-13       | Refund           | 5 648.71 | Bank Transfer  | Salas-Le                    | Asia          | GYFRGB7I     |
| TRX2049301     | 2015-02-23       | Tax Payment      | 8 588.94 | PayPal         | Roberts, Waters and Lindsey | Africa        | KDXAGBBP     |
| TRX2827313     | 2012-04-28       | Sale             | 7 784.09 | Credit Card    | Nguyen, Wise and Cannon     | North America | FNNQGB6G     |
| TRX9053105     | 2017-01-14       | Investment       | 970.64   | Bank Transfer  | Hawkins, Huff and Vargas    | Europe        | ACCBGB61     |
```

* `promotions-data.csv` – données de promotions
```
| promotion_id | product_category  | promotion_type   | discount_percentage | start_date | end_date   | region                       |
| ------------ | ----------------- | ---------------- | ------------------- | ---------- | ---------- | ---------------------------- |
| PROMO55666   | Organic Beverages | Beverage Bonanza | 0.15                | 2022-02-22 | 2022-03-12 | Middle East and North Africa |
| PROMO81620   | Organic Beverages | Sip into Savings | 0.10                | 2024-12-07 | 2024-12-25 | Africa                       |
| PROMO58220   | Organic Beverages | Juice Jamboree   | 0.20                | 2023-02-06 | 2023-03-03 | Oceania                      |
| PROMO55882   | Organic Beverages | Autumn Elixir    | 0.12                | 2023-11-20 | 2023-12-07 | Africa                       |
| PROMO35148   | Organic Beverages | Spring Refresh   | 0.08                | 2022-06-15 | 2022-07-02 | Oceania                      |

```
* `marketing_campaigns.csv` – campagnes marketing
```
| campaign_id | campaign_name                  | campaign_type     | product_category | target_audience | start_date | end_date   | region                       | budget     | reach   | conversion_rate |
| ----------- | ------------------------------ | ----------------- | ---------------- | --------------- | ---------- | ---------- | ---------------------------- | ---------- | ------- | --------------- |
| CAMP45204   | Allen, Hughes and Mitchell     | Print             | Electronics      | Families        | 2015-10-24 | 2015-11-06 | South America                | 106 162.48 | 713 532 | 0.0614          |
| CAMP32929   | Robinson-Clark                 | Print             | Personal Care    | Seniors         | 2016-07-25 | 2016-08-02 | Africa                       | 477 223.66 | 265 229 | 0.0504          |
| CAMP79923   | Diaz-Willis                    | Email             | Beverages        | Professionals   | 2015-03-30 | 2015-04-04 | Middle East and North Africa | 468 146.23 | 921 472 | 0.0804          |
| CAMP77067   | Craig-Robertson                | Email             | Beverages        | Families        | 2017-06-04 | 2017-06-09 | Europe                       | 444 889.42 | 788 091 | 0.0739          |
| CAMP28254   | Johnson, Ferguson and Garrison | Content Marketing | Baby Food        | Young Adults    | 2016-09-26 | 2016-10-04 | Oceania                      | 438 735.03 | 745 935 | 0.0795          |

```
* `product_reviews.csv` – avis et notes produits
```
| review_id | product_id | reviewer_id    | reviewer_name   | rating | review_date | review_title | review_text                                            | product_category              |
| --------- | ---------- | -------------- | --------------- | ------ | ----------- | ------------ | ------------------------------------------------------ | ----------------------------- |
| 1         | B001EO5QW8 | A2GHZ2UTV2B0CD | JERRY REITH     | 4      | 2014-08-19  | it's oatmeal | What else do you need to know? Oatmeal...              | Organic Beverages             |
| 2         | B001EO5QW8 | AQLL2R1PPR46X  | grumpyrainbow   | 3      | 2013-06-12  | decent       | dairy-free alternative, but texture could be better... | Organic Beverages             |
| 3         | B0026Y3YBK | A38BUM0OXH38VK | singlewinder    | 5      | 2015-01-03  | excellent    | creamy and convenient, works well with cereal...       | Plant-based Milk Alternatives |
| 4         | B001IUKD76 | A2KVCXTQVN18KI | A. Martin       | 4      | 2016-09-18  | good product | fortified with essential vitamins and minerals...      | Baby Food                     |
| 5         | B001ELL6O8 | A1PTPN5SY7C7SW | Leonard Kocurek | 2      | 2014-11-02  | disappointed | expected better taste, not worth the price...          | Snacks                        |

```
* `inventory.json` – niveaux de stock
```
[
  {
    "product_id": "PROD726146",
    "product_category": "Personal Care",
    "region": "Middle East and North Africa",
    "country": "Turkey",
    "warehouse": "Martin-Fuentes",
    "current_stock": 6569,
    "reorder_point": 288,
    "lead_time": 19,
    "last_restock_date": "2025-01-12"
  }
]
```
* `store_locations.json` – informations géographiques des magasins
```
[
  {
    "store_id": "STR102",
    "store_name": "Hernandez Group",
    "store_type": "Supermarket",
    "region": "Africa",
    "country": "Ghana",
    "city": "Port Kyleton",
    "address": "850 Maria Corner Suite 332",
    "postal_code": 52228,
    "square_footage": 6924.88,
    "employee_count": 37
  }
]
```
* `logistics_and_shipping.csv` – données logistiques
```
| shipment_id | order_id  | ship_date  | estimated_delivery | shipping_method | status     | shipping_cost | destination_region           | destination_country | carrier                 |
| ----------- | --------- | ---------- | ------------------ | --------------- | ---------- | ------------- | ---------------------------- | ------------------- | ----------------------- |
| SHP3906092  | 871839849 | 2015-01-17 | 2015-01-19         | Standard        | Shipped    | 8.91          | Europe                       | Colombia            | Preston and Sons        |
| SHP7311779  | 535657542 | 2015-06-20 | 2015-06-25         | Express         | Returned   | 24.21         | Middle East and North Africa | Argentina           | Nielsen, Mann and Gross |
| SHP7775247  | 622528708 | 2018-09-20 | 2018-09-25         | Express         | Delivered  | 60.76         | South America                | UK                  | Montes-Boyer            |
| SHP8373435  | 529834260 | 2021-05-19 | 2021-05-30         | Next Day        | In Transit | 5.93          | Middle East and North Africa | France              | David-Fields            |
| SHP3799770  | 504874920 | 2018-11-25 | 2018-12-09         | Next Day        | Delivered  | 37.           |                              |                     |                         |

```
* `supplier_information.csv` – informations fournisseurs
```
| supplier_id | supplier_name                  | product_category | region        | country        | city               | lead_time | reliability_score | quality_rating |
| ----------- | ------------------------------ | ---------------- | ------------- | -------------- | ------------------ | --------- | ----------------- | -------------- |
| SUPP88746   | Wilson, Washington and Herring | Baby Food        | South America | Argentina      | North Robert       | 24        | 0.86              | A              |
| SUPP71209   | Hill-Hubbard                   | Snacks           | South America | Brazil         | Martinezview       | 11        | 0.86              | C              |
| SUPP40724   | Pierce-Powell                  | Household        | Africa        | Nigeria        | Angelside          | 17        | 0.80              | A              |
| SUPP34583   | Robinson-Scott                 | Electronics      | South America | Brazil         | South Anthonyshire | 12        | 0.81              | C              |
| SUPP48499   | Brown, Calderon and Ingram     | Snacks           | Europe        | Czech Republic | Smithfurt          | 11        | 0.64              | A              |

```
* `employee_records.csv` – données organisationnelles
```
| employee_id | name            | date_of_birth | hire_date  | department | job_title                | salary     | region        | country     | email                                                         |
| ----------- | --------------- | ------------- | ---------- | ---------- | ------------------------ | ---------- | ------------- | ----------- | ------------------------------------------------------------- |
| EMP81111    | Richard Mendoza | 1984-02-15    | 2004-09-08 | Sales      | Manager Customer Service | 119 350.91 | South America | Mexico      | [nyoung@example.net](mailto:nyoung@example.net)               |
| EMP68614    | Denise Higgins  | 1992-07-30    | 2011-02-18 | Sales      | Manager Sales            | 146 941.63 | South America | Peru        | [castrodorothy@example.com](mailto:castrodorothy@example.com) |
| EMP71675    | Rhonda Smith    | 1968-04-15    | 2004-05-06 | Finance    | Director Operations      | 91 676.49  | Europe        | North Korea | [gholland@example.org](mailto:gholland@example.org)           |
| EMP47352    | Robert Reynolds | 1972-06-27    | 2015-12-22 | Sales      | Specialist Finance       | 129 516.03 | Oceania       | Peru        | [edwardsangela@example.com](mailto:edwardsangela@example.com) |
| EMP15901    | Amy Guzman      | 2004-09-22    | 2010-03-26 | Sales      | Associate Operations     | 114 922.66 | North America | Fiji        | [petersnicole@example.net](mailto:petersnicole@example.net)   |

```
## Travail demandé – Phase 1

### Étape 1 – Préparation de l’environnement Snowflake

* Créer une base de données dédiée (ex. `ANYCOMPANY_LAB`)
* Créer deux schémas `BRONZE` et `SILVER`
    - `BRONZE` pour les données brutes
    - `SILVER` pour les données nettoyées
* Créer un stage Snowflake pour le chargement des fichiers

### Étape 2 – Création des tables

Pour chaque fichier :

* Identifier la structure (colonnes, types)
* Créer la table correspondante dans le schéma `BRONZE`
* Choisir des types adaptés aux usages analytiques


### Étape 3 – Chargement des données

* Charger les fichiers avec `COPY INTO`
* Vérifier les volumes chargés
* Corriger les éventuelles erreurs de parsing



### Étape 4 – Vérifications

* Vérifier le nombre de lignes
* Inspecter un échantillon (`SELECT * LIMIT 10`)
* Identifier les colonnes clés (IDs, dates, produits, régions)

### Étape 5 –

Créer des tables nettoyées, cohérentes et exploitables dans le schéma **SILVER** à partir des données brutes du schéma **BRONZE**.

Pour chaque table dans le schéma **BRONZE** :

1. Nettoyer les données :

* Gestion des valeurs manquantes

* Suppression ou traitement des doublons

2. Harmoniser les formats :

* Dates

3. Appliquer des règles de qualité :

* Valeurs positives pour les montants

Créer les nouvelles tables nettoyées dans le schéma **SILVER**

**Exemples** :

RAW.financial_transactions → SILVER.financial_transactions_clean

RAW.promotions_data → SILVER.promotions_clean

### Résultat attendu

* Une base Snowflake opérationnelle
* Une table par fichier
* Des données propres et exploitables
* Un socle prêt pour la Phase 2

# Phase 2 – Exploration des données et analyses business

## Objectif

Explorer les données chargées dans Snowflake afin de :

* Comprendre leur contenu et leur qualité
* Identifier des tendances et corrélations
* Produire des **insights business exploitables pour le marketing**

Cette phase correspond au travail d’une équipe **Business Analyst / Data Analyst**.

## Travail demandé – Phase 2

### Partie 2.1 – Compréhension des jeux de données

Pour chaque table du schéma `SILVER` :

* Identifier le périmètre métier
* Identifier les colonnes clés
* Vérifier volumes et périodes couvertes
* Vérifier valeurs manquantes et anomalies

### Partie 2.2 – Analyses exploratoires descriptives

À l’aide de requêtes SQL Snowflake :

* Analyse de l’évolution des ventes dans le temps
* Performance par produit, catégorie et région
* Répartition des clients par segments démographiques

### Partie 2.3 – Analyses business transverses

1. **Ventes et promotions**

   * Comparaison ventes avec / sans promotion
   * Sensibilité des catégories aux promotions

2. **Marketing et performance commerciale**

   * Lien campagnes ↔ ventes
   * Identification des campagnes les plus efficaces

3. **Expérience client**

   * Impact des avis produits sur les ventes
   * Influence des interactions service client

4. **Opérations et logistique**

   * Ruptures de stock
   * Impact des délais de livraison


## Phase 3 – Data Product & Machine Learning

L’objectif de cette phase est de transformer les analyses exploratoires en actifs data réutilisables, puis de développer des modèles Machine Learning permettant de soutenir concrètement les décisions marketing.

À l’issue de cette phase, vous devrez être capable de :

* Concevoir un data product analytique (Une table/view qui contient les KPIs nécessaires pour piloter l'activité) prêt à être consommé

* Construire et évaluer des modèles ML orientés marketing

* Relier les résultats techniques à des cas d’usage business concrets

Cette phase correspond au travail d’une équipe Analytics Engineering & Data Science.

* **Contexte**:

À l’issue de la Phase 2, l’équipe analytics a identifié plusieurs insights clés :

* Les promotions influencent significativement certaines catégories

* Certains segments clients présentent un fort potentiel de croissance

* Les performances varient fortement selon les régions et les campagnes

Ces constats doivent maintenant être industrialisés sous forme :

* de tables analytiques stables

* de features réutilisables

* de modèles ML exploitables par les équipes marketing

* **Travail demandé – Phase 3**

**Partie 3.1 – Création du Data Product**

Créer un produit data centralisé combinant ventes, promotions, marketing et dimensions clés, prêt à être consommé par des outils analytiques et des modèles ML.

**Tâches**:

1. Concevoir une ou plusieurs tables analytiques dans Snowflake (schéma ANALYTICS) :

* Table ventes enrichies

* Table promotions actives

* Table clients enrichis

2. Mettre en place :

* Des clés de jointure claires

* Une granularité maîtrisée (vente, client, produit, date)

* Une documentation du schéma et des champs

3. Vérifier :

* La cohérence métier

**Partie 3.2 – Feature Engineering** --> OPTIONNELLE

Préparer des features ML à partir du data product.

**Exemples de features attendues**

* Nombre de promotions actives au moment de l’achat

* Historique d’achat client (fréquence, panier moyen)

* Variables temporelles (saisonnalité, récence)

**Partie 3.3 – Modélisation Machine Learning** --> OPTIONNELLE

Développer des modèles ML pour soutenir les décisions marketing.

**Cas d’usage proposés (au choix)**

1. Segmentation clients

* Clustering basé sur comportement d’achat

* Identification de segments à fort potentiel

2. Modèle de propension à l’achat

* Probabilité qu’un client achète un produit

3. Réponse aux promotions

* Prédire l’impact d’une promotion sur les ventes


**Partie 3.4 – Interprétation et recommandations business** --> OPTIONNELLE

Pour chaque modèle :

* Évaluer les performances (metrics adaptées)

* Interpréter les résultats (features importantes)

* Traduire les résultats en recommandations marketing concrètes


## Livrable attendu – Projet GitHub

Le livrable des phase 1, 2 et 3 doit être un **projet GitHub structuré**, contenant :

### 0. SQL ETL

* Les requêtes SQL pour le chargement des données
* Les requêtes SQL pour le nettoyage des données
* Scripts stockés dans `sql/`
* Requêtes commentées et exécutables dans Snowflake

### 1. SQL analytique

* Une requête SQL par analyse business
* Scripts stockés dans `sql/`
* Requêtes commentées et exécutables dans Snowflake

### 2. Visualisations Streamlit

* Une page Streamlit par type d'analyse
* Code stocké dans `streamlit/`
* Visualisations claires et orientées décision

### 3. Machine Learning

* Scripts SQL de création des tables analytiques (analytics/)
* Documentation du data product
* Notebooks ou scripts Python (ml/)
* Un document dédié (ml_insights.md) contenant les résultats des modèles et leur interprétation métier.

### 4. Synthèse des constats business

Un document (`README.md` ou `business_insights.md`) présentant :

* Les constats clés
* Leur interprétation métier
* Leur impact potentiel sur la stratégie marketing

### Structure attendue

```
project-name/
├── sql/
|   ├── Load_data.sql
|   ├── clean_data.sql
│   ├── sales_trends.sql
│   ├── promotion_impact.sql
│   └── campaign_performance.sql
├── streamlit/
│   ├── sales_dashboard.py
│   ├── promotion_analysis.py
│   └── marketing_roi.py
├── ml/
│   ├── customer_segmentation.ipynb
│   ├── purchase_propensity.ipynb
│   └── promotion_response_model.ipynb
├── README.md
└── business_insights.md
```

⚠️ **Attention**:
Le projet doit être réalisé en groupe, avec une répartition équitable des tâches. Les livrables identiques entre groupes seront considérés comme du plagiat et sanctionnés en conséquence.

### Modalités de soumission

Le rendu du projet doit être envoyé par email avec les éléments suivants :

**Objet de l’email**:  MBAESG_EVALUATION_ARCHITECTURE_BIGDATA_2026

**Contenu de l’email**

Veuillez inclure :

* 🔗 Le lien vers votre dépôt GitHub contenant l’ensemble du projet (SQL, Streamlit, documentation)

* 🔐 Les accès à votre compte Snowflake, incluant :

        - URL du compte Snowflake

        - Nom d’utilisateur

        - Mot de passe

**Adresse de soumission** : 📧 axel@logbrain.fr
