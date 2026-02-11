#!/bin/bash
set -euo pipefail

# --------------------------------------------------
# Dual logging: terminal + daily cron log
# --------------------------------------------------
CRON_LOG_DIR="/db1/myserver/mariadb/cronlog"
LOG_DATE="$(date +%F)"
CRON_LOG_FILE="$CRON_LOG_DIR/mariadb-cronlog-$LOG_DATE.log"

mkdir -p "$CRON_LOG_DIR"
exec > >(tee -a "$CRON_LOG_FILE") 2>&1

echo "--------------------------------------------------"
echo "[START] flush-logs-mariadb.sh | $(date '+%Y-%m-%d %H:%M:%S')"

# --------------------------------------------------
# MariaDB connection details
# --------------------------------------------------
MYSQL_BIN="/db1/myserver/mariadb/mariadb_files/bin/mysql"
MYSQL_SOCKET="/db1/myserver/mariadb/run/mysql.sock"
MYSQL_USER="root"

# >>> EMBEDDED PASSWORD (temporary) <<<
MYSQL_PASSWORD="Harsh0@server"

# --------------------------------------------------
# Flush logs
# --------------------------------------------------
echo "[INFO] Executing FLUSH LOGS;"

"$MYSQL_BIN" \
  --protocol=SOCKET \
  --socket="$MYSQL_SOCKET" \
  -u "$MYSQL_USER" \
  -p"$MYSQL_PASSWORD" \
  -e "FLUSH LOGS;"

echo "[SUCCESS] MariaDB logs flushed successfully."

echo "[END] flush-logs-mariadb.sh | $(date '+%Y-%m-%d %H:%M:%S')"
