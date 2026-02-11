#!/bin/bash

CRON_LOG_DIR="/db1/myserver/mariadb/cronlog"
LOG_DATE="$(date +%F)"
CRON_LOG_FILE="$CRON_LOG_DIR/mariadb-cronlog-$LOG_DATE.log"

mkdir -p "$CRON_LOG_DIR"
exec > >(tee -a "$CRON_LOG_FILE") 2>&1

echo "--------------------------------------------------"
echo "[START] status-mariadb.sh | $(date '+%Y-%m-%d %H:%M:%S')"

BASE="/db1/myserver/mariadb"
RUN_DIR="$BASE/run"
PID_FILE="$RUN_DIR/mysqld.pid"
SOCKET="$RUN_DIR/mysql.sock"
MYSQLADMIN="$BASE/mariadb_files/bin/mysqladmin"

if [ ! -f "$PID_FILE" ]; then
    echo "Status : NOT RUNNING"
    exit 1
fi

PID=$(cat "$PID_FILE")

if kill -0 "$PID" 2>/dev/null; then
    echo "Status : RUNNING (PID $PID)"
else
    echo "Status : NOT RUNNING (stale PID)"
    exit 1
fi

if "$MYSQLADMIN" --protocol=SOCKET -u root -S "$SOCKET" ping >/dev/null 2>&1; then
    echo "Health : OK"
else
    echo "Health : ping failed"
fi
