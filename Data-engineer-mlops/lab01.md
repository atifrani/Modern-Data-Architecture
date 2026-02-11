# Lab 1 — Introduction Data engineering (Pas-à-pas)

## 0) Prérequis

- Compte Snowflake d’essai (**étudiants : 120 jours**) – inscrivez-vous avec l’adresse **de l’école**, société **MBAESG**, rôle **Étudiant**, **Edition : Enterprise**, **Cloud : AWS**, **Région : us-west-2**.
- lien pour créer votre compte:  https://signup.snowflake.com/?trial=student&cloud=aws&region=us-west-2&utm_source=handsonessentials&utm_campaign=uni-dww# 
- Bases de SQL (DDL/DML) et objets (database, schema, table…).  

## 1) Objectif:
Ce lab vous aide à comprendre comment utiliser les Snowflake Notebooks en tant que nouvel utilisateur.

* Utiliser les bibliothèques préinstallées dans les Notebooks et ajouter des packages supplémentaires via le sélecteur de packages

* Basculer entre des cellules SQL et Python dans un même notebook

* Utiliser Altair et Matplotlib pour visualiser vos données

* Utiliser la syntaxe Jinja pour faire référence à des variables Python dans des requêtes SQL, réutiliser les résultats de cellules précédentes dans vos requêtes SQL, et plus encore

![alt text](images/de1.png)


Dans ce cas d’usage, nous utilisons Snowflake Notebooks pour écrire et exécuter du code, visualiser les résultats et raconter l’histoire de votre analyse, le tout au même endroit.

* Contextualiser les résultats et ajouter des notes sur différents résultats à l’aide de cellules Markdown.
* Tirer parti du contrôle d’accès basé sur les rôles (RBAC) et des autres fonctionnalités de gouvernance des données disponibles dans Snowflake afin de permettre à d’autres utilisateurs disposant du même rôle de consulter et de collaborer sur le notebook.


Voici la traduction en français des instructions du notebook :

# Bienvenue dans ❄️ Snowflake Notebooks 📓

Faites passer votre traitement de données au niveau supérieur en travaillant de manière fluide avec Python et SQL dans Snowflake Notebooks.

## Ajouter des packages Python 🎒

Les Notebooks sont préinstallés avec des bibliothèques Python courantes pour la data science et le machine learning, telles que :

* numpy
* pandas
* matplotlib
* et d’autres

Si vous souhaitez utiliser d’autres packages, cliquez sur le menu déroulant **Packages** en haut à droite pour en ajouter.

Dans cette démonstration, les packages `matplotlib` et `scipy` ont été ajoutés via le fichier `environment.yml` lors de la création du notebook.

## Interroger en SQL en toute simplicité 💡

Vous pouvez facilement basculer entre des cellules Python et SQL dans le même notebook.

Écrivons une requête SQL pour générer des données d’exemple.

## Retour au travail en Python 🐍

Vous pouvez nommer vos cellules et faire référence à leurs résultats dans les cellules suivantes.

Il est possible d’accéder directement aux résultats SQL en Python et de les convertir en DataFrame pandas.

## 📊 Visualiser vos données

Nous pouvons utiliser **Altair** pour visualiser facilement la distribution de nos données sous forme d’histogramme.

## Personnaliser les graphiques avec Matplotlib

Si vous souhaitez personnaliser davantage votre graphique et tracer l’estimation de densité (KDE) ainsi que la médiane, vous pouvez utiliser Matplotlib pour représenter la distribution des prix.

La méthode `.plot` utilise `scipy` en arrière-plan pour calculer la courbe KDE, que nous avons ajouté précédemment.

## Travailler avec les données via Snowpark 🛠️

En plus d’utiliser vos bibliothèques Python préférées pour la data science, vous pouvez également utiliser l’API Snowpark pour interroger et traiter vos données à grande échelle directement dans le Notebook.

Vous pouvez récupérer la session active du notebook. Cette variable de session constitue le point d’entrée vers l’API Python de Snowflake.

### Enregistrer un DataFrame pandas dans Snowflake

Vous pouvez utiliser Snowpark pour enregistrer un DataFrame pandas dans une table Snowflake.

### Charger une table

Une fois la table créée, vous pouvez la charger en utilisant la syntaxe appropriée.

Si votre session est déjà positionnée sur la bonne base de données et le bon schéma, vous pouvez simplement référencer le nom de la table.

### Statistiques descriptives

Après avoir chargé la table, vous pouvez utiliser la méthode `describe` de Snowpark pour calculer des statistiques descriptives de base.


## Utiliser des variables Python dans des cellules SQL 🔖

Vous pouvez utiliser la syntaxe Jinja `{{ }}` pour faire référence à des variables Python dans vos requêtes SQL.

Les variables Python peuvent ainsi alimenter dynamiquement vos requêtes SQL.

## Simplifier les sous-requêtes

Vous pouvez simplifier des sous-requêtes complexes en utilisant des CTE (Common Table Expressions) et en combinant cela avec la référence aux résultats d’autres cellules via Jinja.

Dans Snowflake Notebooks, il est possible de filtrer le résultat d’une cellule SQL depuis une autre cellule SQL en la référencant avec `{{nom_de_cellule}}`.

## Créer une application interactive avec Streamlit 🪄

En combinant tout cela, vous pouvez construire une application Streamlit interactive pour explorer l’impact de différents paramètres sur la forme de la distribution des données.

## Gagner du temps avec les raccourcis clavier 🏃

Ces raccourcis permettent de naviguer plus rapidement dans votre notebook :

| Commande                                    | Raccourci           |
| ------------------------------------------- | ------------------- |
| Exécuter la cellule et passer à la suivante | SHIFT + ENTER       |
| Exécuter uniquement cette cellule           | CMD + ENTER         |
| Exécuter toutes les cellules                | CMD + SHIFT + ENTER |
| Ajouter une cellule en dessous              | b                   |
| Ajouter une cellule au-dessus               | a                   |
| Supprimer cette cellule                     | d + d               |

Vous pouvez consulter la liste complète des raccourcis en cliquant sur le bouton `?` en bas à droite.

## Nettoyage

Code permettant de supprimer la table créée à la fin du tutoriel.

## Continuez à explorer les Notebooks 🧭

Consultez la galerie d’exemples et la documentation officielle pour approfondir vos connaissances.
