# Entrepôt de données SQL

Projet de construction d’un entrepôt de données avec SQL Server. Il rassemble
des données CRM et ERP fournies en CSV, les charge dans une architecture
Bronze–Silver–Gold, puis expose des vues analytiques pour l’analyse des ventes,
des clients et des produits.

## Objectifs

- Centraliser les données de plusieurs sources.
- Conserver les données sources dans une couche Bronze.
- Nettoyer et standardiser les données dans la couche Silver.
- Fournir des vues Gold lisibles pour l’analyse et le reporting.
- Documenter les données et leur traçabilité.

## Architecture

```text
CSV CRM et ERP
     │
     ▼
Bronze — données brutes chargées depuis les sources
     │
     ▼
Silver — données nettoyées, standardisées et intégrées
     │
     ▼
Gold — vues métiers prêtes pour l’analyse
```

Le projet utilise les schémas `bronze`, `silver` et `gold` dans la base
`DataWarehouse`.

## Sources de données

-----------------------------------------------------------------------------------------------------
| Système    |                   Fichier               |                     Contenu                |
|            |                                         |                                            |
----------------------------------------------------------------------------------------------------
| CRM        | `datasets/source_crm/cust_info.csv`     | Informations clients                       |
-----------------------------------------------------------------------------------------------------
| CRM        | `datasets/source_crm/prd_info.csv`      | Informations produits                      |
-----------------------------------------------------------------------------------------------------
| CRM        | `datasets/source_crm/sales_details.csv` | Lignes de vente                            |
-----------------------------------------------------------------------------------------------------
| ERP        | `datasets/source_erp/CUST_AZ12.csv`     | Date de naissance et genre des clients     |
-----------------------------------------------------------------------------------------------------
| ERP        | `datasets/source_erp/LOC_A101.csv`      | Pays des clients                           |
-----------------------------------------------------------------------------------------------------
| ERP        | `datasets/source_erp/PX_CAT_G1V2.csv`   | Catégories et sous-catégories de produits  |
-----------------------------------------------------------------------------------------------------

## Modèle Gold

Les objets Gold sont des **vues** :

- `gold.dim_customers` : une ligne par client, enrichie avec les données ERP.
- `gold.dim_products` : les produits courants, enrichis avec leur catégorie.
- `gold.fact_sales` : les lignes de vente associées aux clés des dimensions.

La description des colonnes, des clés, des jointures et de la traçabilité est
disponible dans [`data_catalogue.md`](./data_catalogue.md).

## Structure du dépôt

```text
.
├── datasets/
│   ├── source_crm/
│   └── source_erp/
├── scripts/
│   ├── schema.sql
│   ├── db_bronze.sql
│   ├── load_data_bronze.sql
│   ├── cleaning_data_bronze _to_silver.sql
│   └── build_gold_data.sql
├── data_catalogue.md
├── DOCUMENTATION.md
└── docker-compose.yml
```

## Technologies

- Microsoft SQL Server (le fichier Docker Compose utilise SQL Server 2022).
- T-SQL pour la création des schémas, le chargement, les transformations et
  les vues.
- CSV comme format des données sources.
- Docker Compose, optionnel, pour l’environnement conteneurisé.

## Préparation et exécution

1. Préparer une instance SQL Server et une base de données accessible.
2. Vérifier les chemins de fichiers utilisés par les commandes `BULK INSERT`
   dans `scripts/load_data_bronze.sql`. SQL Server doit pouvoir lire les CSV
   depuis son propre environnement.
3. Exécuter les scripts dans l’ordre prévu :
   `schema.sql`, `db_bronze.sql`, chargement Bronze, transformations Silver,
   puis création des vues Gold.
4. Vérifier les résultats en interrogeant les vues, par exemple :

   ```sql
   SELECT TOP (10) * FROM gold.dim_customers;
   SELECT TOP (10) * FROM gold.dim_products;
   SELECT TOP (10) * FROM gold.fact_sales;
   ```

### État de configuration

Les scripts et la configuration Docker doivent être vérifiés avant une
exécution de bout en bout : le chargement Bronze référence des fichiers sous
`/tmp`, alors que les CSV du dépôt se trouvent dans `datasets/`. De plus, le
fichier `docker-compose.yml` référence des dossiers de montage
(`01_datasets`, `03_scripts`, `04_tests`) qui ne correspondent pas à
l’arborescence actuelle. Les définitions des tables Silver sont également à
fournir. Enfin, corriger la syntaxe de l’expression `gender` dans
`scripts/build_gold_data.sql` avant de créer les vues. Il faut donc aligner ces
éléments et s’assurer que les objets requis sont créés dans SQL Server avant
d’exécuter les procédures.

Le mot de passe SQL Server doit être configuré localement dans l’environnement
ou dans un fichier `.env` non partagé. Ne jamais publier de mot de passe ou
autre secret dans le dépôt.

## Documentation complémentaire

- [`data_catalogue.md`](./data_catalogue.md) — description et traçabilité des
  vues Gold.
- [`DOCUMENTATION.md`](./DOCUMENTATION.md) — notes détaillées sur l’entrepôt,
  les couches et les transformations.
