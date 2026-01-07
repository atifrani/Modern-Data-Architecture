# Projet: Evaluation module Architecture Big Data

**Énoncé de l’Exercice**: Identification des Clients Uniques et Analyse de la Localisation des Commandes

Dans le cadre de ce projet, vous travaillerez sur un jeu de données issu d’un site e-commerce. Celui-ci contient des informations relatives aux clients, à leur localisation, ainsi qu’aux commandes passées sur la plateforme.

🎯 **Objectif général:**

Votre mission est d’analyser les données clients afin de :

1. Identifier les clients uniques, indépendamment des identifiants attribués dans le système.

2. Analyser les localisations de livraison des commandes en vous appuyant sur les informations géographiques disponibles.

3. Comprendre les comportements d’achat récurrents en détectant les clients ayant effectué plusieurs commandes.

📘 **Contexte:**

Le système de gestion utilisé par l’entreprise attribue un **customer_id** unique pour chaque commande. Ainsi, lorsqu’un même client passe plusieurs commandes, le système lui génère un nouvel identifiant à chaque transaction.  

Pour pallier cette limitation, le dataset inclut un champ **customer_unique_id**, qui correspond à un identifiant stable permettant de reconnaître un client de manière persistante. Ce champ est essentiel, car il permet :

* d’identifier correctement les clients récurrents ;

* d’éviter de considérer chaque commande comme provenant d’un client différent ;

* d’étudier les comportements de réachat et la fidélité client.

Vous devrez utiliser cette information pour reconstruire une vision consolidée du client au sein du jeu de données.

🗂️ **Travail attendu:**

À partir du dataset fourni et du schéma des données :

🔍 1. Identifier les clients uniques

* Déduire le nombre réel de clients, en utilisant customer_unique_id.

* Comparer ce nombre avec celui obtenu à partir de customer_id.

📦 2. Analyser les réachats

Identifier les clients ayant passé plus d’une commande:

* le nombre moyen de commandes par client récurrent,

* la part de clients récurrents dans la base,

* les produits ou catégories les plus fréquemment rachetés.

🌍 3. Étudier la localisation des commandes

Associer chaque commande à la localisation du client. Identifier les régions / villes présentant :

* les volumes de commandes par régions / villes ,

* les taux de réachat par régions / villes .

📊 4. Valoriser vos résultats

Vous présenterez vos analyses sous la forme de visualisations pertinentes utilisant SQL + Streamlit, directement dans Snowflake.

📄 **Livrables attendus:**

1. Scripts SQL utilisés, accompagnés de commentaires explicatifs.

2. Tableaux de résultats et visualisations Streamlit.

3. Une brève analyse interprétative des observations réalisées (clients uniques, réachats, zones géographiques clés).

4. Un récapitulatif des difficultés rencontrées et des solutions mises en œuvre.


## 📬 Soumission
1. Le livrable doit être sous la forme d'un projet sur github.
2. Il est nécessaire de fournir des accès à votre compte snwoflake (URL, User, Password) 
Envoyez votre livrable avec intitulé **MBAESG_EVALUATION_ARCHITECTURE_BIGDATA** à l'adresse suivante : **axel@logbrain.fr**