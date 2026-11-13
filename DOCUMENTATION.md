Data Warehousing : 
"Organize, structure , prepare"
--ETL/ELT :Processing 
--Data Architecture 
--Data Integration 
--Data cleasing
--Data load 
--Data modeling 

Exploratory Data analysis (EDA)
"Uderstan data"
-- Base queries
-- Data profiling
-- Simple aggregations
-- subquery

Advenced Data analytics (bi )
"Answer Business Quetions"
-- Complex Queries
-- Windows Functions 
-- CTE 
-- Subqueries
-- Reparts  



--------------------------Data Warehouse : c'est une grosse base de données centrale dont une entreprise stocke toutes ses données importantes , propore et organisée , pour les analser

Une Data Warehouse = le disque dur central, propre et historique de l'entreprise, conçu uniquement pour analyser et aider à prendre des décisions.

               Sert à : 
                       # Décider , par la crétion des tableaux des KPI , des rapports 
                       #comparaison entre les ventes 
                       #prémarer l'IA , data science , pour fournir des modèle de prédiction 
                
                Comment a marche :
                       # Extraction , on extracte les dnnnees d'apres des ressource , des fichier csv , json excel , CRM , des sites de e-commmerce des applications 
                       #Transformation : les nettoie , eleve les doublons , les formats ... 
                       l'etape de ETL/ELT
                       #Stockage+utilisation: on les stocke de façon optimisée pour l'nlse , et on les connecte à des outils comme POwer BI, Tableau ,looker  


                4 caracteristiques de data warehouse : 
                       1. Orienté sujet : organisée par thème (client , Produit, Vente ) et par application 

                       2.Integrée: tout le monde utilise la meme definition , un client c'et la meme chose pour tout le monde.

                       3.Non-volatile : On ne supprime pas on accumule l'historique , on peut l'evoluer avec le temps.

                       4. l'historisée : les données sont datées 

 Data Management = Le tout le Data Management (gestion des données) c'est l'ensemble des pratiques pour gérer les données d'une entreprise de A à Z.

Ça comprend :

Gouvernance : Qui a le droit de voir quoi ? C'est quoi la définition officielle d'un "client actif" ?
Qualité : Comment on enlève les doublons, les erreurs, les adresses vides ?
Sécurité : Comment on protège les données personnelles (RGPD) ?
Cycle de vie : Combien de temps on garde les données ? Quand on les archive / supprime ?
Architecture / Stockage : Où on met les données ? -> C'est ici qu'intervient la Data Warehouse.

Solution qu'l  donnée data warehouse : 
Avant, les données étaient éparpillées, incohérentes, sans historique, et les analyses plantaient les systèmes de production. La Data Warehouse a résolu ça en créant un entrepôt central, séparé, nettoyé et historisé, dédié uniquement à l'aide à la décision.


1 Etape d'une data warehouse , c'est de l'extraction des données : il y a 7 façons different de l'extractio  ; 

            $ Manual Data extraction: Extaction a la main , par copier les données      d'apres des fichier excel ... 
            $ Data base querying : Interaction direct avec base donnée aavec SQL 
            $FIle parsig : la lecture des fichier comme csv , excel , json ,logs .... 
            $API Calls : Appler une API pour réccuperer le données.
            $Event based Streaming : Recevoir les données en temps réel , via par exemple kafka
            $CDC : Change Data capture , Exemple : hier tu as copié 1 million de clients. Aujourd'hui, seuls 10 ont changé -> tu ne copies que les 10. Beaucoup plus rapide et sans bloquer la prod.
            $Web Scraping : Extraire les données depui des pages web 
            


2 Etape : Transformation 
L'extrction amène des données brutes et sales , la transformation les converti en " more freindly values for the analyzers" 
                    
            $ Normalisation et standardisation : Mettre tout au même format.
              Exemple : USA: 11/05/2026 vs France: 05/11/2026 -> on choisit 2026-11-05. Pareil pour $ vs €, M vs Male vs Homme. Sans ça, impossible d'analyser.

            $ Business Rules &logic : l'appliccation des règles metiers , demander par exemple par l'entreprise . 

            $ Data aggregations : Exemple , au lieu de garder 1M lignes de ventes , on calcule par exemple la somme SUM(ventes) par mois / region 

            $Data cleansing : Nettoyage 
               -------Remove duplicates , Outlier detection , data type 

            $Derived columns -colonnes calculées : création des nouvelles colonnes d'après les anciens ... , (ex: total = quantité*prix )....

            $Data integration : Fusion plusieurs sources , par exemple joindre clients de MySQL + commandes de l'API shopify avec JOIN ON CLIENT_ID pour avoir une seule table complète 

            $Data Enrichement : Ajouter des info externes pour donnees plus de valeurs 




3 Etape Loading : 
         Se divise en deux : 
         Processing types = Quand on charge ? : 
              a/ Batch Processing -> On charge les données en gros paquet , à heure fixe , par exemple à 2 heure minuit . 
              b/ Stream Processing -> En continu :
              En temps rèel , (exemple :  à chaque commande sur site , ça part directement dans la warehouse via kafka pour le temps rèel )
        
        Load Methods = Comment on écrit ? : 
              a/ Full loading : On charge tout a chaque fois , on efface e on réecrit 
                *** pour petit dataset 
              b/ Increment load -Chargement incrémental : on charge juste ce qu'on a chargé pour la derniere fois . 



                    EXTRACTION (données brutes, sales)
                                   |
                                   v
                    TRANSFORMATION (ici) = Nettoyer + Standardiser + Appliquer règles + Enrichir + Agréger
                                   |
                                   v
                    LOADING -> Tables propres Gold / Star Schema prêtes pour Power BI
                    LOAD : Quand ? -> Batch (la nuit) ou Stream (temps réel)
                           Comment ? -> Full (tout effacer + tout remettre) ou Incremental (juste nouveautés)





--Data Warehouse : C'est l'endroit où on stocke la donnée nettoyée, structurée, prête pour Power BI / analyse.
Concrètement dans ton projet : c'est ta base SQL Server DataWarehouse avec les schémas bronze, silver, gold.
(exemple de datawarehouse :SQL Server, Snowflake, BigQuery, Synapse, Redshift)

--Data Lake : c'est l'endroit où on a un stockge brut , massif, et de different format  fichier cv , json, images ,videos, audio .. 
, aussi c'est où on applique les ELT (exemple : S3, ADLS... ) pour ML

-- DATA LakeHouse: c'est un mixte entre les deux , c'est un endroit pour BI/ML (Exemples : Databricks Delta Lake, Microsoft Fabric, Snowflake Iceberg)


--Data Mesh = organisation décentralisée. On peut même faire un Data Mesh avec des Lakehouse dans chaque domaine.


On travaille avec data warehouse : qu'il aussi basé sur 4 approches : 
1: Inmon 
2:Kimall
3:Data vault 
4:Medallion 

--------------------Approche Inmon : 
      1: Source -->
      2: STaging : là où la raw data atterit 
      3: EDW (Entreprise DATA Warehouse),on organises tes données en 3rd normal form / format normalisé. Tu construis un nouveau modèle de données intégré à partir des multiples sources.
      4: Data Marts: on prends un petit subset du warehouse et tu le designs pour être consommé par le reporting, focus sur un seul topic : customers, sales ou products par exemple.
      5:on connecte ontre outil BI : PowerBI ou Tableau aux Data Marts.


      Donc 3 couches avant le reporting : Staging -> EDW -> Data Marts.


-----------------------Approche kimball 
           Meme chose que INmon , juste l'etape de EDW est supprimer 
           Donc par la suite 2 couches : 
             Staging -> Data Marts.

----------------------- Data vault : 
                 Meme chose que INMON , JUste à la place de EDW on le remplace par , 
                 RAW vault , et Busiess Vault 


      Donc 4 couches avant le reporting : 
             Staging -> Raw  vault ->Business vault -> Data Marts.
            
----------------------- Approche Medallion ;  Data lakehouse 
       c'est l'archi choisi pour notre projet : 
       BRONZE -> SILVER ->GOLD 

       Bronze : données brutes ingérées telles quelles, sans transformation. JSON, CSV, API, bases, IoT, logs. On ne perd rien.

       Silver : données nettoyées, dédupliquées, typées, jointes, historisées. C'est la version fiable et exploitable.

       Gold : données modélisées métier, agrégées, prêtes pour la BI. Souvent en modèle en étoile / Kimball : faits + dimensions.

       POURQUOI???? :: 
       BRONZE Layer: Garder la donnée brut telle que des sources.Objectif = Traceability and debugging .Si problème , on reviens toujours à Bronze pour inverstiguer la root-cause.(type : tables , Load method : Full load (truncate & Insert) , Data transormation : none as _is ) 

       SILVER layer : Transformations , data cleansing mais sans business rules , Données propres , standarisées .
       (Type: Tables , Lod method : Full load (truncate & Insert), 
       Data transormation ; --Data cleaning /Strandarization/Normalization /Derived Columns/Enrichment)
 
       GOLD-DATA Marts layer: not only for reporting but as well for machine learning , for IA .Ce sont des business ready ojectifs que tu partages comme data product 
       (TYpe : Views  , load method=none , Data transformation : 
       --Data Integration/aggregation/business logic & rules)

Etape 1 

Project Requirements 
Building the data Warehouse (data engineering)
Objective : 
Develop a modern data warehouse using SQL server to consolidate sales data , enabling analytical reporting and informed decison -making 

Specifications: 
-data Sources : Import data from two sources systems (ERP and CRM) provided as a CSV files . 
-Dat quality : Cleanse and resolve data quality issues prior to analysis.
-Integration :Combine both sources into a single , user-friendly data moel designed for analytical queries.
-Scope : Focus on the latest only ; hisorization of data is not required.
Documentation :Provide clear documentation of the data model to support both business stakeholders and analytics teams 


Apres quand on dessiner le flux et l'architecture de projet , on passe a la prochaine etape , c'est Name conventions

On met les regles de guide , pour nommer tout dans le projet 
- Databse 
- Schema 
- Tables
- Store Pocedures 
--> We gonna work with lower_snake : lower_case , all with underscore

Bronze RUles : 
all name of table should start with the source system name , with this forme : <sourcesystem>_<entity> 
<sourcesystem> : Name of the source system CRM , ERP
<entity> : Extarct table nam from the source system 
EXAMPLE : crm_customer_info --> Customer information from the CRM source 

And the same rules with siver RUles 
But with Gold rules , rules change , why ?? because we need to a data model , 
SOo all names must use meaningful , business-aligned names fore tables , starting with category prefix :
ith this forme : <category>_<entity>
<category>: Describes the roles of the table,such as dim (dimension) os fact (fact table)
<entity> : decsrive name of the table , aligne with the business domaine (customer,products,sales)
EXEMPLE: dim_customer , fact_slaes .. 
 
 ------------------------------------------
 glossary of category Patterns : 

 -------------------------------------------------------------------------------
 |Pattern             | Meaning              |Exemples 
 -------------------------------------------------------------------------------
 |  dim_              |  dimension table     | dim_customer , dim_product
 --------------------------------------------------------------------------------
 | fact_              | fact table           | fact_sales
 --------------------------------------------------------------------------------
 | agg_               | aggregte table       | agg_customers , agg_sales_monthly
 ---------------------------------------------------------------------------------


SUrrogate keys 
ALl primary keys in dimension tables must use the suffix _key 
<table_name>_key
exemple : customer_key 

Technical columns : All technical columns must start with the prefix dwh , followed by a descriptive name indicating the column's purpose 
dwh_<column_name>
Exemple : dwh_load_date -> sys-generated column used to store the date when the record wa loaded. 

Stored Procedure : 
all stored procedures used for loading data must follow the naming pattern : load _<layer>
Exemples : load_bronze , load_silver , 


Schema of tables , bronze , silver , gold

----------------------------------------------- for bronze schema 
DataWarehouse
 └── Schema: bronze
      │
      ├── 📂 Sources CRM (Customer Relationship Management)
      │    ├── 📄 crm_cust_info       (Informations clients : ID, clés, nom, prénom, statut marital, genre, date de création)
      │    ├── 📄 crm_prd_info        (Informations produits : ID, clés, nom, coût, gamme, dates début/fin)
      │    └── 📄 crm_sales_details   (Détails des ventes : num de commande, clé produit, ID client, dates de commande/expédition/livraison, chiffre d'affaires, quantité, prix)
      │
      └── 📂 Sources ERP (Enterprise Resource Planning)
           ├── 📄 erp_loc_a101        (Localisation des clients : ID client, pays)
           ├── 📄 erp_cust_az12       (Données démographiques ERP : ID client, date de naissance, genre)
           └── 📄 erp_px_cat_g1v2     (Catégorisation des produits : ID, catégorie, sous-catégorie, maintenance)


           How to build Bronze layer: 
           ------- Analysing :INterview source syst experts
           --------Coding : data ingestion
           ------- Validating : data completeness & schema check
          --------- Docs & version : data documenting ,versioning in git 



---------------- Cleaning for silver data with sql
1  : For crm_cust_info table ; 
    We select the data of table filterd by id to eliminate duplicates with this SQL queries 

    SELECT cst_id , COUNT(*) As Ocerrences 
    FROM crm_cust_info 
    GROUP BY cst_id 
    HAVING COUNT(*)>1

RESULT : 
    ------------------------------------------------------
    |      cst_id                | Occurrences            |
    ------------------------------------------------------
    |           29449             |      2                
    -----------------------------------------------------
     |   29466                     |       3                
    -----------------------------------------------------
     |    29433                   |        2               
    -----------------------------------------------------
     |       NULL                 |        2                
    -----------------------------------------------------
     |           29473            |         2               
    -----------------------------------------------------
    |     29483                   |     2
     -----------------------------------------------------


this mean we have dup customers with id , so we need to delete dupplacates
row , but we need first to see culomns content for choose the best row for each customer data 

--------------- On selecct one of id_cst to visualize the common point of same id_cst to use it for filre : 


SELECT * FROM crm_cust_info 
WHERE cst_id = '29466'

RESULT : 

    ------------------------------------------------------------------------------------------------------------
    |   cst_id   |cst_key     |cst_firstname  | cust_lastname| cst_marital_status| cst_gndr | cst_creat_date
    ------------------------------------------------------------------------------------------------------------
    |   29466    | AW00029466 | NULL          |NULL         | NULL               |NULL      | 2026-01-26
    ---------------------------------------------------------------------------------------------------------------
    |   29466    | AW00029466 | Lance         | Jimenez     | M                  |NULL      |2026-01-26
   -----------------------------------------------------------------------------------------------------------------
    |   29466    | AW00029466 | Lance         | Jimenez     | M                  |M         |2026-01-27                            
    -----------------------------------------------------------------------------------------------------------------
   
      

 ---- So to visualize number of dup for each row , we use windows function 

SELECT * 
ROW_NUMBER() OVER (PRTITION BY CST_ID ORDER BY csT_CREATE_Date DESC )  AS flag_last 
FROM bronze.crm_cust_info 

------ this query add a new culomn flag_last , and in this flag_last , the value 1 identify the most recent state o each custmer , 
Why ? By analyzing duplicate records (cust_id ) with count>1 , we observed that older enries often contain mising values (NULL ),
on a hanger the most  recent entry contains complete data 

WE select with window function ROW_NUMBER(): 
SELECT *
FROM (
       SELECT * , 
       ROW_NUMBER() OVER (PARTITION BY cst_id ORDER BY cst_create_date DESC )AS flag_last
       FROM bronze.crm_cust_info
) t 
WHERE flag_last =1;


--------------------------------- Part 2 of data cleaning  (DATA QUALITY CHECK): Check unwanted spaces : with TRIM() /

TRIM() : Only removes spaces located at both ends of a string , but don't touche spaces in the middle of the text at all , exemple 
" jean   " ________ 'jean'

Applicate it on all columns , cst_firstname , cst_lastname, cst_gndr  

SELECT cst_firstname
FROM bronze.crm_cust_info
WHERE cst_firstname  !=TRIM(cst_firstname); // 

------------------------------------ verification of gender & standarization : 
values (M,F) change Fto MALE wuith CASE WHIN ............ THEN 
Remove spces with TRIM () 
UPPER , for male -->MALE

--------------------------------------- Standariztion of cst_marital : 
S to signle , M to married , null to n/a 



------------------Handling missing Data 
fills in the blanks by adding a default value  



--------------------------- Problem in date_start / date : null

Product History and temporal incoherence mangement : 
TO ensure the reliabilty of product timelines within the Silver layer ,the anlytic function as solution  LEAD() was implemented . By ordering ech product's  version chronologically (ORDER BY prd_start_dt) , this method automatically determines the validity end date (prd_end_dt) of each record by retrieving
the start date of subsequent version . this approach simultaneously resolves missing value issues (NULL )
and date inversions , therb ensuring a clean , continuous , and overlap_free history for each product reference 


------------------------ RUle of price : 
SOMMe of sales = quantity * price 
---- Price , negtif value , zeros , null 

1 : If sales is negative , zero , or null , derive it using quntity and price ,
2 : If price is zero , calculate it using sales and quantity 
3: If price is negative , convert it to positive value 





Cette fonction SUBSTRING(cid, 4, LEN(cid)) sert à couper et supprimer le préfixe

cid : C'est la colonne d'origine (par exemple : NASAW00019902).

4 : C'est la position de départ. Cela signifie qu'on demande à SQL de commencer à partir du 4ème caractère (en ignorant donc les 3 premiers caractères N, A et S).  

LEN(cid) : C'est la longueur totale de la chaîne de caractères. Cela indique à la fonction qu'il faut continuer à extraire des caractères jusqu'à la fin de l'identifiant.   
  
  
bdate > GETDATE() : Permet de repérer les erreurs de saisie où une personne aurait une date de naissance future par rapport à aujourd'hui.











---------------------------------------- Dimension  vs Fact table 

Une table de dimension (Dimension Table) sert à stocker le contexte descriptif (le « qui », le « quoi », le « où », le « comment ») autour d'un sujet ou d'un thème métier bien précis (comme les clients, les produits, les magasins, etc.).


Qu'est-ce que c'est ? C'est la table centrale d'un schéma en étoile ou flocon. Elle stocke les mesures quantitatives, numériques et additives liées à un événement métier (les transactions ou les actions qui se produisent).
