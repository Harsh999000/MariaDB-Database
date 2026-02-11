#!/bin/bash
set -euo pipefail

CRON_LOG_DIR="/db1/myserver/mariadb/cronlog"
LOG_DATE="$(date +%F)"
CRON_LOG_FILE="$CRON_LOG_DIR/mariadb-cronlog-$LOG_DATE.log"

mkdir -p "$CRON_LOG_DIR"
exec > >(tee -a "$CRON_LOG_FILE") 2>&1

echo "--------------------------------------------------"
echo "[START] sanitize-logs-mariadb.sh | $(date '+%Y-%m-%d %H:%M:%S')"

LOG_DIR="/db1/github/mariadb/logs"

find "$LOG_DIR" -type f -name "*.log" | while read -r file; do
  echo "Sanitizing: $file"
  sed -i 's/[A-Za-z0-9._%+-]\+@[A-Za-z0-9.-]\+\.[A-Za-z]\{2,10\}/xxx@xxx/g' "$file"
  sed -i 's/[0-9]\{1,3\}\(\.[0-9]\{1,3\}\)\{3\}/xxx.xxx.xxx.xxx/g' "$file"
done

echo "[END] sanitize-logs-mariadb.sh | $(date '+%Y-%m-%d %H:%M:%S')"
