#!/bin/bash
set -euo pipefail

CRON_LOG_DIR="/db1/myserver/mariadb/cronlog"
LOG_DATE="$(date +%F)"
CRON_LOG_FILE="$CRON_LOG_DIR/mariadb-cronlog-$LOG_DATE.log"

mkdir -p "$CRON_LOG_DIR"
exec > >(tee -a "$CRON_LOG_FILE") 2>&1

echo "--------------------------------------------------"
echo "[START] start-mariadb.sh | $(date '+%Y-%m-%d %H:%M:%S')"

BASE="/db1/myserver/mariadb"
CNF="$BASE/config/mariadb.cnf"
RUN_DIR="$BASE/run"
LOG_DIR="$BASE/logs"
PID_FILE="$RUN_DIR/mysqld.pid"
SOCKET="$RUN_DIR/mysql.sock"

MYSQLADMIN="$BASE/mariadb_files/bin/mysqladmin"
MYSQLD_SAFE="$BASE/mariadb_files/bin/mysqld_safe"
DB_PASSWORD='Harsh0@server'

mkdir -p "$RUN_DIR" "$LOG_DIR" "$BASE/tmp"

# Check using PID file
if [ -f "$PID_FILE" ]; then
    PID=$(cat "$PID_FILE")
    if kill -0 "$PID" 2>/dev/null; then
        echo "[INFO] MariaDB already running (PID $PID)."
        exit 0
    else
        echo "[WARN] Stale PID file found. Removing."
        rm -f "$PID_FILE"
    fi
fi

echo "[INFO] Starting MariaDB..."
"$MYSQLD_SAFE" --defaults-file="$CNF" >> "$LOG_DIR/startup-$(date +%F).log" 2>&1 &

# Wait until ready
for i in {1..30}; do
    if "$MYSQLADMIN" --protocol=SOCKET -u root -p"$DB_PASSWORD" -S "$SOCKET" ping >/dev/null 2>&1; then
        echo "[OK] MariaDB started successfully."
        exit 0
    fi
    sleep 1
done

echo "[ERROR] MariaDB did not start."
exit 1
