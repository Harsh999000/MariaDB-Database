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
# PATHS & DATE
# =====================

MARIADB_LOG_DIR="/db1/myserver/mariadb/logs"
GITHUB_LOG_DIR="/db1/github/mariadb/logs"

YESTERDAY="$(date -d 'yesterday' +%F)"

mkdir -p "$GITHUB_LOG_DIR"

log "Starting MariaDB log rotation"
log "MariaDB log directory : $MARIADB_LOG_DIR"
log "GitHub log directory  : $GITHUB_LOG_DIR"
log "Rotation date         : $YESTERDAY"

# =====================
# LOG FILES TO ROTATE
# =====================

LOG_FILES=(
  "general.log"
  "error.log"
  "slow.log"
  "startup.log"
)

for log_name in "${LOG_FILES[@]}"; do
  logfile="$MARIADB_LOG_DIR/$log_name"
  base_name="${log_name%.log}"
  rotated="$MARIADB_LOG_DIR/${base_name}-${YESTERDAY}.log"

  if [ ! -f "$logfile" ]; then
    log "Log not found, skipping: $log_name"
    continue
  fi

  if [ ! -s "$logfile" ]; then
    log "Log empty, skipping rotation: $log_name"
    continue
  fi

  if [ -f "$rotated" ]; then
    log "Rotated log already exists, skipping: $(basename "$rotated")"
    continue
  fi

  log "Rotating log: $log_name → $(basename "$rotated")"
  mv "$logfile" "$rotated"

  log "Copying rotated log to GitHub: $(basename "$rotated")"
  cp "$rotated" "$GITHUB_LOG_DIR/"

  case "$log_name" in
    general.log|error.log|slow.log)
      log "Creating fresh log file: $log_name"
      touch "$logfile"
      chmod 640 "$logfile"
      ;;
    startup.log)
      log "Startup log rotated only (not recreated)"
      ;;
  esac
done

log "MariaDB log rotation completed"
