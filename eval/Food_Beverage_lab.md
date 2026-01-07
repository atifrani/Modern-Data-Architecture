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
* `customer_service_interactions.csv` – interactions avec le service client
* `financial_transactions.csv` – transactions de ventes
* `promotions-data.csv` – données de promotions
* `marketing_campaigns.csv` – campagnes marketing
* `product_reviews.csv` – avis et notes produits
* `inventory.json` – niveaux de stock
* `store_locations.json` – informations géographiques des magasins
* `logistics_and_shipping.csv` – données logistiques
* `supplier_information.csv` – informations fournisseurs
* `employee_records.csv` – données organisationnelles

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


**Partie 3.4 – Interprétation et recommandations business**

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

### 3. Visualisations Streamlit

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
