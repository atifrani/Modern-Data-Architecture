# Streamlit

## Qu'est-ce que Streamlit ?  
Streamlit est une bibliothèque open-source qui permet aux data scientists/analyst de créer des applications web pour la visualisation de données de manière rapide et efficace. Avec peu de lignes de code, Streamlit transforme des scripts Python en applications web interactives.

## Setup Streamlit:  

* Install Visual Studio Code (VSCode)
* Install Python > 3.9
* Install VSCode extensions for Python and Snowflake
* Install Git and clone the project
```
git clone https://github.com/atifrani/Modern-Data-Warehouse.git
```
* Change to the working subfolder:
```
cd Modern-Data-Warehouse
```

* Create a virtual environment: 
```
python -m venv venv
```
* Activate the virtual environment: 
```
venv/scripts/activate
```
* Install all dependencies through the requirements.txt file: 
```
pip install -r requirements.txt
```
* CSV files are usually in a data subfolder.


## Création d'une Application de Base:

Créez un nouveau fichier Python et importez Streamlit :  
* Title:

```
import streamlit as st
st.title('Ma première application web')
```
Ce code permet de générer une application avec seulement un titre, on voudra généralement ajouter d'autres éléments.

## L'architecture d'une application:

La logique de Streamlit est assez simple.  

Chaque élément qui compose l'application est une méthode de streamlit. Dans notre cas, st.elem().  

* Header:
```
import streamlit as st
st.title('Ma première application web')
```

* Subheader: 
``` 
st.subheader("Another sub header")
```

* Sidebar:
```
st.sidebar.header("Example de Side Bar")
st.sidebar.text("Hello")
```

* Text:
```
st.text("For a simple text")
```

* Markdown:
```
st.markdown("#### A Markdown ")
```
* Error text:
```
st.success("Successful")
```
* Info alert:
```
st.info("This is an info alert ")
```
* Warning:
```
st.warning("This is a warning ")
```
* Erreur: 
```
st.error("This shows an error ")
```
* Writing some text:
```
st.error("This shows an error ")
```
* Display some JSON data:
```
st.text("Display JSON")
dico={'name':'hello','age':34}
st.json(dico)
```

### Comprendre les boutons et événements dans une application: 

* Bouton simple: 
```
st.button("Simple Button")
st.text("Une check box")
```
* Checkbox:
```
if st.checkbox("Show/Hide"):
    #do some action
    st.text("Some actions")
```
* Radio Button:
```
status = st.radio("Ton statut",('Active','Inactive'))
if status == 'Active':
    st.text("OK t'es Actif(ve)")
else:
    st.warning("Et un petit warning")

st.text("Petite boite de selection")
```
* SelectBox:
```
occupation = st.selectbox("Ton poste",['Data Scientist','Programmer','Doctor','Businessman'])
st.write("So, you are a ",occupation)

st.text("La selection multiple")
# MultiSelect
location = st.multiselect("Ou es tu ?",("Paris","London","New York","Accra","Kiev","Berlin","New Delhi", "Montpellier"))
st.write("You selected",len(location),"location")
```

* Slider:
```
salary = st.slider("Ton score aux QCM  :P  ",0,100)
```

### [Inclure Pandas et Seaborn dans des graphiques interactifs](#graph)

L'avantage de travailler avec Streamlit est que nous pouvons inclure facilement des librairies python dans notre application 🤓

Avant d'inclure des graphiques Pandas et Seaborn il faut importer ces librairies ! La suite ne change pas beaucoup de ce qu'on a vu dans les cours sur Pandas et Seaborn. 

On peut donc ce servir des boutons pour afficher un DataFrame `df` tel que :  


```python 
if st.checkbox("Show DataSet"):
	number = st.number_input("Number of Rows to View")
	st.dataframe(df.head(int(number)))
```

De la même manière on peut afficher les colonnes de `df` : 
```python 
if st.button("Columns Names"):
	st.write(df.columns.tolist())
```

### Stocker des information dans la mémoire cache de votre application 

Dans une application, il a souvent des actions répétitives et chronophage que nous n'avons pas envie de répéter plusieurs fois comme le chargement de données. On utilise pour cela un décorateur en amont de la déclaration de fonction tel que : 

```python 
@st.cache
def ma_fonction_a_garder_en_cache():
	return 0
```

Un exemple dans le cas de chargement de données depuis Seaborn : 
```python
import seaborn 

@st.cache
def load_data(name):
    """ Load dataset from seaborn
        See the available list here : https://github.com/mwaskom/seaborn-data
    """
	return seaborn.load_dataset(str(name))

#utilisation de la fonction load_data()
df = load_data(iris)
```


### Afficher des graphiques avec la fonction `pyplot()`

Les graphiques Matplotlib et Seaborn ne sont pas affichés automatiquement dans Streamlit il faut donc ajouter à la suite de vos graphiques `st.pyplot()` 

Voici un exemple pour afficher une `Heatmap` de corrélation d'un DataFrame `df` si on clique sur le boutons : 

```python
# Seaborn Plot
if st.checkbox("Correlation Plot with Annotation[Seaborn]"):
	st.write(sns.heatmap(df.corr(),annot=True))
	st.pyplot()
```

## Se connecter a Snowflake avec Connecteur pour Python
Snowflake Connector pour Python doit être installé:   
```
pip install snowflake-connector-python.
```
Mettez à jours les information de connexion à snowflake.

Allez sur votre terminal et exécuter votre programme:  
```
python app.py.
```



```
import streamlit as st
from snowflake.snowpark.context import get_active_session

# Write directly to the app
st.title("Example Streamlit App :balloon:")
st.write(
    """This application show dashboard of number of trips by station name
    """
)

# Get the current credentials
session = get_active_session()

# execute sql statement
sql = f"select start_station_name, count(*) nbtrips from CITIBIKE.PUBLIC.TRIPS group by start_station_name"
data = session.sql(sql).collect()

# Execute the query and convert it into a Pandas dataframe
#queried_data = data.to_pandas()

# Create a simple bar chart
# See docs.streamlit.io for more types of charts
st.subheader("Number of high-fives")
st.bar_chart(data=data, x="START_STATION_NAME", y="NBTRIPS")

st.subheader("Underlying data")
st.dataframe(data, use_container_width=True)

```

## Ajout d'un slider pour l'interactivité:
```
# Import python packages
import streamlit as st
from snowflake.snowpark.context import get_active_session

# Write directly to the app
st.title("Example Streamlit App :balloon:")
st.write(
    """This application show dashboard of number of trips by station name
    """
)

# Get the current credentials
session = get_active_session()

# Use an interactive slider to get user input
num_station = st.slider(
    "Number of station",
    min_value=10,
    max_value=100,
    value=50,
    help="Use this to enter the number of high-fives you gave in Q3",
)
# execute sql statement
sql = f"select start_station_name, count(*) nbtrips from CITIBIKE.PUBLIC.TRIPS group by start_station_name limit "  + str(num_station)
data = session.sql(sql).collect()

# Execute the query and convert it into a Pandas dataframe
#queried_data = data.to_pandas()

# Create a simple bar chart
# See docs.streamlit.io for more types of charts
st.subheader("Number of high-fives")
st.bar_chart(data=data, x="START_STATION_NAME", y="NBTRIPS")

st.subheader("Underlying data")
st.dataframe(data, use_container_width=True)
```


### Exemple data citibike avec filtre:

```
import streamlit as st
from snowflake.snowpark.context import get_active_session

# Write directly to the app
st.title("Example Streamlit App :balloon:")
st.write(
    """This application show dashboard of number of trips by station name
    """
)
option = st.selectbox(
     'What is your favorite day of week?',
     ('Tue','Thu','Fri','Wed','Mon','Sat','Sun'))

# Get the current credentials
session = get_active_session()

# execute sql statement
sql = f"select start_station_name, count(*) nbtrips from CITIBIKE.PUBLIC.TRIPS  where dayname(starttime)= '{option}' group by start_station_name order by nbtrips limit 10"
# Execute the query and convert it into a Pandas dataframe
#queried_data = data.to_pandas()
data = session.sql(sql).collect()

# Create a simple bar chart
# See docs.streamlit.io for more types of charts
st.subheader("Number of high-fives")
st.bar_chart(data=data, x="START_STATION_NAME", y="NBTRIPS")

sql_new = f"select dayname(starttime) day_of_week, count(*) nb_trips from trips group by dayname(starttime)"

data_new = session.sql(sql_new).collect()

st.subheader("Number of trips by day of week")
st.bar_chart(data=data_new, x="DAY_OF_WEEK", y="NB_TRIPS")
```
