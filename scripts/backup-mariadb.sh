#!/bin/bash
set -euo pipefail

CRON_LOG_DIR="/db1/myserver/mariadb/cronlog"
LOG_DATE="$(date +%F)"
CRON_LOG_FILE="$CRON_LOG_DIR/mariadb-cronlog-$LOG_DATE.log"

mkdir -p "$CRON_LOG_DIR"
exec > >(tee -a "$CRON_LOG_FILE") 2>&1

echo "--------------------------------------------------"
echo "[START] backup-mariadb.sh | $(date '+%Y-%m-%d %H:%M:%S')"

BACKUP_DATE=$(date +%F)
BACKUP_DIR="/db1/backup/mariadb"
MYSQLDUMP="/db1/myserver/mariadb/mariadb_files/bin/mysqldump"
MYCNF="/db1/myserver/mariadb/config/mariadb.cnf"

BACKUP_FILE="$BACKUP_DIR/all-databases-$BACKUP_DATE.sql"

"$MYSQLDUMP" --defaults-file="$MYCNF" -u root -pHarsh0@server --all-databases > "$BACKUP_FILE"

echo "[INFO] Backup completed: $BACKUP_FILE"
echo "[END] backup-mariadb.sh | $(date '+%Y-%m-%d %H:%M:%S')"
