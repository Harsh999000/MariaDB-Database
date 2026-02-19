# MariaDB Server Architecture

This document describes the automated operational lifecycle of the MariaDB server instance running on the server laptop.

The system is designed for deterministic daily execution, script-managed log rotation, and clean separation of responsibilities between the database engine and automation scripts.

---

## Daily Automation Schedule

All operations are executed sequentially starting at 12:01 A.M.

MariaDB does not perform automatic date-based log rotation in this setup. Log rotation is handled explicitly by lifecycle scripts to ensure full control over archival, sanitization, retention, and Git synchronization.

---

### 12:01 A.M – Backup Database  
Script: backup-mariadb.sh  

Purpose:  
Creates a full logical backup of all MariaDB databases before any log manipulation occurs.  
Ensures data safety and recovery capability prior to lifecycle maintenance operations.

---

### 12:02 A.M – Rotate Logs  
Script: rotate-logs-mariadb.sh  

Purpose:  
Renames active log files (`error.log`, `general.log`, `slow.log`) to a date-based format:

- error-YYYY-MM-DD.log  
- general-YYYY-MM-DD.log  
- slow-YYYY-MM-DD.log  

Creates fresh active log files after rotation.  
Copies rotated logs to the GitHub archival directory.

---

### 12:03 A.M – Flush Logs  
Script: flush-logs-mariadb.sh  

Purpose:  
Forces MariaDB to reopen log file descriptors after rotation.  
Prevents ghost file descriptor issues and ensures logging continuity.

---

### 12:04 A.M – Sanitize Logs  
Script: sanitize-logs-mariadb.sh  

Purpose:  
Cleans rotated logs before archival.  
Removes sensitive or unnecessary entries while preserving diagnostic value.

---

### 12:05 A.M – Delete Old Logs  
Script: delete-logs-mariadb.sh  

Purpose:  
Applies retention policies:

- GitHub logs → 7 days  
- Local MariaDB logs → 14 days  
- Cron logs → 14 days  

Ensures disk space stability and controlled archival lifecycle.

---

### 12:06 A.M – Auto Push Logs  
Script: auto-push-logs-mariadb.sh  

Purpose:  
Force-adds sanitized rotated logs to the Git repository.  
Commits and pushes logs to GitHub for version-controlled archival.

---

## Execution Characteristics

- Single orchestrator script: `run-mariadb-lifecycle.sh`
- Sequential execution (halts on failure)
- Runs under user `harsh`
- No systemd dependency
- Fully isolated from MySQL installation
- Deterministic, time-driven operational model

---

## Design Philosophy

The MariaDB lifecycle is intentionally:

- Deterministic  
- Script-controlled  
- Log-centric  
- Isolated from other database engines  
- Designed for observability and auditability  

This architecture provides a controlled foundation for future enhancements such as replication, remote backups, monitoring integration, and production-grade hardening.
