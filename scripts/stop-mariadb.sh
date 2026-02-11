#!/bin/bash
set -euo pipefail

CRON_LOG_DIR="/db1/myserver/mariadb/cronlog"
LOG_DATE="$(date +%F)"
CRON_LOG_FILE="$CRON_LOG_DIR/mariadb-cronlog-$LOG_DATE.log"

mkdir -p "$CRON_LOG_DIR"
exec > >(tee -a "$CRON_LOG_FILE") 2>&1

echo "--------------------------------------------------"
echo "[START] stop-mariadb.sh | $(date '+%Y-%m-%d %H:%M:%S')"

BASE="/db1/myserver/mariadb"
RUN_DIR="$BASE/run"
PID_FILE="$RUN_DIR/mysqld.pid"
SOCKET="$RUN_DIR/mysql.sock"
MYSQLADMIN="$BASE/mariadb_files/bin/mysqladmin"
DB_PASSWORD='Harsh0@server'

if [ ! -f "$PID_FILE" ]; then
    echo "[INFO] MariaDB not running."
    exit 0
fi

PID=$(cat "$PID_FILE")

if ! kill -0 "$PID" 2>/dev/null; then
    echo "[WARN] Stale PID file. Removing."
    rm -f "$PID_FILE"
    exit 0
fi

echo "[INFO] Attempting graceful shutdown..."
"$MYSQLADMIN" -u root -p"$DB_PASSWORD" -S "$SOCKET" shutdown || true

sleep 3

if kill -0 "$PID" 2>/dev/null; then
    echo "[WARN] Force killing MariaDB (PID $PID)"
    kill -9 "$PID"
fi

rm -f "$PID_FILE"
echo "[SUCCESS] MariaDB stopped."
