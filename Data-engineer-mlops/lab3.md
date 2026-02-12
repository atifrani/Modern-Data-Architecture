# Configuration de Snowflake pour utiliser Git
Lorsque vous connectez votre compte Snowflake à un référentiel Git distant, Snowflake crée un référentiel Git clone, en copiant la dernière version de tous les fichiers du référentiel (un clone)

## Configurer sans authentification:

Pour configurer Snowflake afin d’utiliser un référentiel Git sans authentification, procédez comme suit :

1. Allez sur votre compte github et créer un nouveau dépôt github public **snowflake_git_demo**

![alt text](images/git.png)

2.Créer une **intégration API** qui prend en charge l’accès sans authentification, et indiquez les détails suivants :

* **git_https_api** comme valeur du paramètre **API_PROVIDER**.

* Les points de terminaison **HTTPS** vers lesquels les requêtes doivent être limitées en tant que valeurs du paramètre **API_ALLOWED_PREFIXES**

* Ouvrez un **sql worksheet** ou un **sql file** exécutez la commande ci-dessous (/!\ modifiez **https://example.com/my-account** pas l'url de votre compte github )

```
CREATE OR REPLACE API INTEGRATION my_git_api_integration
  API_PROVIDER = git_https_api
  API_ALLOWED_PREFIXES = ('https://example.com/my-account')
  ENABLED = TRUE;
```

3. clonez le projet localement sur votre ordinateur et ovrez le dans VSCODE.

4. Copiez collez le [lab02](lab02.ipynb) dans votre projet local sur votre ordinateur.

5. Sychronisez votre projet local avec github:

5.a. Ouvrez un terminale VSCODE et positionnez vous à l'intérieur de votre projet:

```
cd snowflake_git_demo

git status

git add .

git commit -m 'add lab02'

git push origin main
```

6. Retournez sur snowflake et clickez sur **projects** >> **notebooks** >> **Create from repository**

![alt text](images/notebooke4.png)

![alt text](images/notebooke5.png)

![alt text](images/notebooke6.png)

![alt text](images/notebooke7.png)

![alt text](images/notebooke8.png)

![alt text](images/notebooke9.png)


## Comment planifier l'execution un notebook Snowflake

Lorsque vous créez une planification pour l’exécution de votre notebook, Snowflake crée une tâche pour exécuter votre notebook selon cette planification. Snowflake exécute le notebook en mode non interactif, cellule par cellule, de haut en bas. La tâche utilisée pour exécuter le notebook est propriétaire du rôle de propriétaire du notebook et utilise l’entrepôt du notebook pour s’exécuter. Par défaut, les tâches du notebook sont suspendues automatiquement après 10 échecs.

Avant de commencer à planfinier des éxécutions de notebook, nous allons commencer par explorer les tasks:  [lab04](lab04.md)

### Planifier votre notebook

Pour planifier l’exécution de votre notebook, créez une tâche en procédant comme suit :

1. Dans le menu de navigation, sélectionnez Projects » Notebooks.

2. Localisez et sélectionnez le notebook à planifier.

3. Dans le notebook, sélectionnez le bouton de planification, puis Create schedule.

![alt text](images/task.png)

La boîte de dialogue Schedule a notebook run apparaît.

4. Pour Schedule name, saisissez un nom pour la planification du notebook. Il s’agit du nom de la tâche qui exécute le notebook.

5. Pour Frequency, sélectionnez une fréquence d’exécution du notebook (par exemple, Daily).

6. En fonction de la fréquence que vous sélectionnez, définissez Scheduled time et les autres options pour qu’ils correspondent au moment où vous souhaitez que le notebook s’exécute.

7. En option, pour Parameter, vous pouvez ajouter des arguments de syntaxe de ligne de commande à transmettre au notebook planifié. Par exemple : key1=value1 key2=value2 --option2.

8. Examinez l’aperçu de la planification et sélectionnez Create