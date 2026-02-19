#!/bin/bash
set -euo pipefail

# ==================================================
# MariaDB Nightly Lifecycle Orchestrator
# Executes all maintenance steps sequentially.
# If any step fails, execution stops immediately.
# ==================================================

SCRIPT_NAME="$(basename "$0")"
CRONLOG_DIR="/db1/myserver/mariadb/cronlog"
LOG_DATE="$(date +%F)"
CRONLOG_FILE="$CRONLOG_DIR/mariadb-cronlog-$LOG_DATE.log"

mkdir -p "$CRONLOG_DIR"

log() {
  {
    echo "=================================================="
    echo "[ $(date '+%Y-%m-%d %H:%M:%S') ] [$SCRIPT_NAME]"
    echo "$@"
  } | tee -a "$CRONLOG_FILE"
}

BASE="/db1/myserver/mariadb/scripts"

log "Starting MariaDB full lifecycle"

# --------------------------------------------------
# Backup Database
# Ensures data safety before any log manipulation.
# --------------------------------------------------
"$BASE/backup-mariadb.sh" &&
log "Backup completed"

# --------------------------------------------------
# Rotate Logs
# Renames active logs to dated format and creates new ones.
# --------------------------------------------------
"$BASE/rotate-logs-mariadb.sh" &&
log "Log rotation completed"

# --------------------------------------------------
# Flush Logs
# Forces MariaDB to reopen log file descriptors.
# --------------------------------------------------
"$BASE/flush-logs-mariadb.sh" &&
log "Log flush completed"

# --------------------------------------------------
# Sanitize Logs
# Cleans logs before archival.
# --------------------------------------------------
"$BASE/sanitize-logs-mariadb.sh" &&
log "Log sanitization completed"

# --------------------------------------------------
# Delete Old Logs
# Applies retention policy.
# --------------------------------------------------
"$BASE/delete-logs-mariadb.sh" &&
log "Log cleanup completed"

# --------------------------------------------------
# Auto Push Logs
# Force-adds rotated logs and pushes to GitHub.
# --------------------------------------------------
"$BASE/auto-push-logs-mariadb.sh" &&
log "Log push completed"

log "MariaDB lifecycle completed successfully"
