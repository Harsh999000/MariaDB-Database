#!/bin/bash
set -euo pipefail

SCRIPT_NAME="$(basename "$0")"

CRONLOG_DIR="/db1/myserver/mariadb/cronlog"
LOG_DATE="$(date +%F)"
CRONLOG_FILE="$CRONLOG_DIR/mariadb-cronlog-$LOG_DATE.log"

mkdir -p "$CRONLOG_DIR"

log() {
  {
    echo "--------------------------------------------------"
    echo "[ $(date '+%Y-%m-%d %H:%M:%S') ] [$SCRIPT_NAME]"
    echo "$@"
  } | tee -a "$CRONLOG_FILE"
}

# =====================
# PATHS & RETENTION
# =====================

GITHUB_LOG_DIR="/db1/github/mariadb/logs"
MARIADB_LOG_DIR="/db1/myserver/mariadb/logs"
CRON_LOG_DIR="/db1/myserver/mariadb/cronlog"

GITHUB_RETENTION_DAYS=7
MARIADB_RETENTION_DAYS=14
CRON_RETENTION_DAYS=14

log "Starting MariaDB log cleanup"

# =====================
# GITHUB LOG CLEANUP (7 days)
# =====================

if [ -d "$GITHUB_LOG_DIR" ]; then
  log "Deleting GitHub MariaDB logs older than $GITHUB_RETENTION_DAYS days"
  find "$GITHUB_LOG_DIR" -type f -name "*.log" \
    -mtime +"$GITHUB_RETENTION_DAYS" -print -delete
else
  log "GitHub log directory not found: $GITHUB_LOG_DIR"
fi

# =====================
# MARIADB MAIN LOG CLEANUP (14 days)
# =====================

if [ -d "$MARIADB_LOG_DIR" ]; then
  log "Deleting MariaDB rotated logs older than $MARIADB_RETENTION_DAYS days"

  find "$MARIADB_LOG_DIR" -type f -name "*.log" \
    -mtime +"$MARIADB_RETENTION_DAYS" \
    ! -name "error.log" \
    ! -name "general.log" \
    ! -name "slow.log" \
    -print -delete
else
  log "MariaDB log directory not found: $MARIADB_LOG_DIR"
fi

# =====================
# CRON LOG CLEANUP (14 days)
# =====================

if [ -d "$CRON_LOG_DIR" ]; then
  log "Deleting MariaDB cron logs older than $CRON_RETENTION_DAYS days"
  find "$CRON_LOG_DIR" -type f -name "*.log" \
    -mtime +"$CRON_RETENTION_DAYS" -print -delete
else
  log "Cron log directory not found: $CRON_LOG_DIR"
fi

log "MariaDB log cleanup completed"
