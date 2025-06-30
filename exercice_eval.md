
# 🧊 Projet : Analyse des Offres d'Emploi LinkedIn avec Snowflake
## 🎯 Objectif
Ce projet vise à évaluer votre capacité à manipuler des données en utilisant Snowflake et streamlit. Vous exploiterez un ensemble de données provenant de LinkedIn pour effectuer des analyses pertinentes sur le marché de l'emploi.

## 📁 Jeu de Données
Les fichiers sont disponibles dans le bucket S3 public suivant : **s3://snowflake-lab-bucket/**

Vous y trouverez les fichiers suivants :

* benefits.csv

* companies.json

* company_industries.json

* company_specialities.json

* employee_counts.csv

* industries.json

* job_industries.json

* job_postings.csv

* job_skills.csv

* salaries.csv

* skills.csv

Chaque fichier contient des informations spécifiques détaillées dans la description des colonnes.

## 🛠️ Prérequis
Création d'un compte Snowflake gratuit (120 jours) via ce lien si vous n'avez pas de compte.

Connaissances de base en SQL, Python et manipulation de fichiers CSV/JSON.

Utilisation exclusive de scripts pour toutes les opérations (pas d'interface graphique).

# 🔧 Étapes à Suivre
Création de la base de données : Créez une base nommée **linkedin**.

Création d'un stage externe : Configurez un stage pointant vers le bucket S3 fourni.

Définition des formats de fichiers : Spécifiez les formats appropriés pour les fichiers CSV et JSON.

Création des tables : Créez les tables correspondantes aux fichiers, en respectant les schémas fournis.

Chargement des données : Utilisez la commande COPY INTO pour importer les données depuis le stage.

Transformations nécessaires : Effectuez les transformations requises pour assurer la cohérence et l'intégrité des données.

## 📊 Analyse des Données
Réalisez les analyses suivantes :

1. Top 10 des titres de postes les plus publiés par industrie.

2. Top 10 des postes les mieux rémunérés par industrie.

3. Répartition des offres d’emploi par taille d’entreprise.

4. Répartition des offres d’emploi par secteur d’activité.

5. Répartition des offres d’emploi par type d’emploi (temps plein, stage, temps partiel).

Pour chaque analyse, créez une visualisation appropriée en utilisant **Streamlit** directement dans Snowflake.

📄 Livrable Attendu
Un dépôt github détaillant :

1. Les commandes SQL utilisées, avec explications.

2. Le code Streamlit pour chaque visualisation, accompagné des résultats obtenus.

3. Les problèmes rencontrés et les solutions apportées.

4. Des commentaires explicatifs pour chaque étape.

Le projet doit être réalisé en binôme, avec une répartition équitable des tâches. Les livrables identiques entre groupes seront considérés comme du plagiat et sanctionnés en conséquence.

## 📬 Soumission
Envoyez votre livrable avec intitulé **MBAESG_EVALUATION_ARCHITECTURE_BIGDATA** à l'adresse suivante : axel@logbrain.fr