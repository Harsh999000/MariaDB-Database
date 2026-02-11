#!/bin/bash
set -euo pipefail

# --------------------------------------------------
# Cron logging (NON-interactive part only)
# --------------------------------------------------
CRON_LOG_DIR="/db1/myserver/mariadb/cronlog"
LOG_DATE="$(date +%F)"
CRON_LOG_FILE="$CRON_LOG_DIR/mariadb-cronlog-$LOG_DATE.log"

mkdir -p "$CRON_LOG_DIR"

echo "--------------------------------------------------" | tee -a "$CRON_LOG_FILE"
echo "[START] login-mariadb.sh | $(date '+%Y-%m-%d %H:%M:%S')" | tee -a "$CRON_LOG_FILE"

# --------------------------------------------------
# MariaDB client paths
# --------------------------------------------------
MYSQL_BIN="/db1/myserver/mariadb/mariadb_files/bin/mysql"
MYSQL_SOCKET="/db1/myserver/mariadb/run/mysql.sock"

# --------------------------------------------------
# Interactive login (DO NOT tee this)
# --------------------------------------------------
read -p "username: " MYSQL_USER
read -s -p "password: " MYSQL_PASSWORD
echo

echo "[INFO] Launching MariaDB interactive client for user '$MYSQL_USER'" \
  | tee -a "$CRON_LOG_FILE"

# Hand over full TTY control to mysql
"$MYSQL_BIN" \
  --protocol=SOCKET \
  --socket="$MYSQL_SOCKET" \
  -u "$MYSQL_USER" \
  -p"$MYSQL_PASSWORD"

EXIT_CODE=$?

echo "[END] login-mariadb.sh | exit=$EXIT_CODE | $(date '+%Y-%m-%d %H:%M:%S')" \
  | tee -a "$CRON_LOG_FILE"

exit "$EXIT_CODE"
