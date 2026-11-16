#!/usr/bin/env bash
# Lance tout le pipeline dans le conteneur SQL Server :
#   schémas -> tables Bronze -> tables Silver -> chargement Bronze -> chargement Silver -> vues Gold -> tests
#
# Usage :  cp .env.example .env   (puis choisir un mot de passe)
#          ./run_all.sh
set -euo pipefail
cd "$(dirname "$0")"

if [ ! -f .env ]; then
  echo "Fichier .env introuvable. Lance d'abord : cp .env.example .env" >&2
  exit 1
fi

echo ">>> Démarrage de SQL Server (attente du healthcheck)..."
docker compose up -d --wait sqlserver

# sqlcmd s'exécute DANS le conteneur ; \$MSSQL_SA_PASSWORD y est déjà défini.
# -b : s'arrête avec un code d'erreur si un script échoue.   
run_sql () {
  echo ">>> $1"
  docker compose exec -T sqlserver bash -c \
    "/opt/mssql-tools18/bin/sqlcmd -S localhost -U sa -P \"\$MSSQL_SA_PASSWORD\" -C -b -I -i '$1'"
}

run_sql /scripts/schema.sql            # base DataWarehouse + schémas bronze / silver / gold
run_sql /scripts/db_bronze.sql         # tables Bronze
run_sql /scripts/db_silver.sql         # tables Silver
run_sql /scripts/load_data_bronze.sql  # procédure + chargement des CSV (Bronze)
run_sql /scripts/load_silver.sql       # procédure + nettoyage (Silver)
run_sql /scripts/build_gold_data.sql   # vues Gold (modèle en étoile)
run_sql /tests/quality_checks.sql      # contrôles qualité

echo ">>> Terminé. Connexion : localhost,1433 / utilisateur sa / base DataWarehouse"
