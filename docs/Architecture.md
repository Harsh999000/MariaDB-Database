# MariaDB Server Architecture

This document describes the automated operational lifecycle of the MariaDB server instance running on the server laptop.

The system is designed for deterministic daily execution, controlled resource allocation, and strict separation of responsibilities between the database engine and automation scripts.

---

## Daily Automation Schedule

MariaDB lifecycle is executed via cron at **12:15 A.M.**

15 0 * * * /db1/myserver/mariadb/scripts/run-mariadb-lifecycle.sh

This offset ensures:

- No overlap with MySQL lifecycle (00:00 A.M.)
- No overlap with PostgreSQL lifecycle (00:30 A.M.)
- Controlled disk I/O sequencing
- Reduced resource contention across engines

All lifecycle steps execute sequentially and halt on failure.

---

## Runtime Configuration

### Networking

- Port: 3306
- Bind Address: 0.0.0.0
- Dedicated socket file
- Dedicated PID file

### File System Isolation

- Basedir: /db1/myserver/mariadb/mariadb_files
- Datadir: /db1/myserver/mariadb/data
- Logs: /db1/myserver/mariadb/logs
- Temp directory: /db1/myserver/mariadb/tmp

This ensures full separation from MySQL and PostgreSQL instances.

---

## Memory Governance

MariaDB is tuned for a multi-database lab environment.

Configured limits:

- innodb_buffer_pool_size = 64M
- key_buffer_size = 16M
- max_connections = 30

Rationale:

- No MyISAM tables in use
- Minimal InnoDB dataset
- Prevent unnecessary allocation
- Preserve memory headroom for future services
- Maintain zero swap usage

---

## Lifecycle Execution Order

---

### 12:15 A.M – Backup Database  
Script: backup-mariadb.sh

Purpose:

- Creates full logical backup of MariaDB databases
- Protects data prior to log manipulation
- Generates date-based backup files
- Ensures daily recoverability

---

### 12:16 A.M – Rotate Logs  
Script: rotate-logs-mariadb.sh

Purpose:

- Renames active logs:
  - general.log
  - error.log
  - slow.log
  - startup.log

To:

- general-YYYY-MM-DD.log
- error-YYYY-MM-DD.log
- slow-YYYY-MM-DD.log
- startup-YYYY-MM-DD.log

Rotation uses the previous day’s date to reflect log coverage.

Fresh active logs are recreated (except startup log).  
Rotated logs are copied to the GitHub archival directory.

---

### 12:17 A.M – Flush Logs  
Script: flush-logs-mariadb.sh

Purpose:

- Forces MariaDB to reopen log file descriptors
- Ensures writing continues to newly created log files
- Prevents stale file handle issues

---

### 12:18 A.M – Sanitize Logs  
Script: sanitize-logs-mariadb.sh

Purpose:

- Removes sensitive information from logs
- Sanitizes:
  - Email addresses
  - IP addresses
  - Phone numbers
  - Password-like patterns
  - Port references

Ensures logs are safe for Git archival.

---

### 12:19 A.M – Retention Enforcement  
Script: delete-logs-mariadb.sh

Retention Rules:

GitHub logs directory (local copy only):
- Delete logs older than 7 days

Internal MariaDB rotated logs:
- Delete logs older than 14 days

Cron execution logs:
- Delete logs older than 14 days

Active logs (general.log, error.log, slow.log) are never deleted.

---

### 12:20 A.M – Auto Push Logs to GitHub  
Script: auto-push-logs-mariadb.sh

Purpose:

- Fetch latest changes
- Rebase onto origin/main
- Stage only existing .log files
- Commit new logs only
- Push updates to the remote GitHub repository

Important:

- Deleted local logs are NOT deleted from GitHub
- GitHub acts as append-only archive
- Local GitHub folder maintains rolling retention window
- Remote repository preserves full historical log records

---

## Isolation Principles

MariaDB is fully isolated from other database engines by:

- Dedicated port (3306)
- Dedicated socket
- Dedicated PID file
- Dedicated data directory
- Dedicated log directory
- PID-file-based process management

This prevents cross-instance interference and accidental shutdown of other database engines.

---

## Design Philosophy

- Deterministic execution order
- Resource-aware configuration
- Strict engine isolation
- Clear log lifecycle
- Retention policy enforcement
- Append-only archival strategy in GitHub
- Safe automation via cron scheduling
- Separation of runtime state and version-controlled infrastructure
