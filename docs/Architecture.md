# MariaDB Server Architecture

This document describes the automated operational lifecycle of the MariaDB server instance running on the server laptop.

The system is designed for deterministic daily execution and clean separation of responsibilities.

---

## Daily Automation Schedule

All operations are executed sequentially starting at **12:01 A.M.**

---

### 12:01 A.M – Backup MariaDB Database  
**Script:** `backup-mariadb.sh`

**Purpose:**

- Creates a full backup of MariaDB database data.
- Ensures recoverability in case of corruption or failure.
- Backup is stored in the designated backup directory.
- One backup file is generated per day using date-based naming.

This step protects database data before any log manipulation begins.

---

### 12:02 A.M – Rotate Logs  
**Script:** `rotate-logs-mariadb.sh`

**Purpose:**

- Renames active logs to dated format:
  - `general-YYYY-MM-DD.log`
  - `error-YYYY-MM-DD.log`
  - `slow-YYYY-MM-DD.log`
  - `startup-YYYY-MM-DD.log`
- Creates fresh empty log files for:
  - `general.log`
  - `error.log`
  - `slow.log`
- Copies rotated logs to the GitHub logs directory for archival.

This ensures:

- Daily log separation  
- Clean lifecycle management  
- Compatibility with retention policy  

---

### 12:03 A.M – Flush Logs  
**Script:** `flush-logs-mariadb.sh`

**Purpose:**

- Forces MariaDB to close and reopen log file descriptors.
- Ensures MariaDB writes to newly created log files.
- Prevents continued writing to rotated files.

This guarantees correct log rotation behavior.

---

### 12:04 A.M – Sanitize Logs  
**Script:** `sanitize-logs-mariadb.sh`

**Purpose:**

- Removes sensitive information from logs.
- Sanitizes:
  - Email addresses
  - IP addresses
  - Phone numbers
  - Password-like patterns
  - Port references
- Cleans entries before archival.
- Ensures logs are safe for long-term storage and version control.

This step protects sensitive data before pushing to GitHub.

---

### 12:05 A.M – Delete Logs (Retention Policy)  
**Script:** `delete-logs-mariadb.sh`

#### Retention Rules:

**GitHub logs directory (local copy only):**
- Delete logs older than **7 days**.

**Internal MariaDB rotated logs:**
- Delete logs older than **14 days**.

**Cron execution logs:**
- Delete logs older than **14 days**.

**Active logs (`general.log`, `error.log`, `slow.log`) are never deleted.**

This enforces controlled storage usage on the server laptop.

---

### 12:06 A.M – Auto Push Logs to GitHub  
**Script:** `auto-push-logs-mariadb.sh`

**Purpose:**

- Stages only existing `.log` files.
- Commits new logs only.
- Does not stage deletions.
- Pushes updates to the remote GitHub repository.

**Important:**

- Deleted local logs do NOT get deleted from GitHub.
- GitHub acts as an append-only archive.
- The local GitHub folder maintains a rolling 7-day window.
- The remote repository preserves full historical log records.

---

## Isolation Principles

This MariaDB instance is fully isolated from the MySQL instance by:

- Dedicated port (**3306**)
- Dedicated socket file
- Dedicated PID file
- Dedicated data directory
- Dedicated log directory
- PID-file-based process management (no `pgrep` or process-name-based killing)

This prevents cross-instance interference and accidental shutdown of other database engines.

---

## Design Philosophy

- Deterministic execution order
- Strict process isolation
- Clear log lifecycle
- Retention policy enforcement
- Append-only archival strategy in GitHub
- Safe automation via cron scheduling
- Separation of runtime state and version-controlled infrastructure
