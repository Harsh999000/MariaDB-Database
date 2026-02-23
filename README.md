# MariaDB Server Lifecycle System

This repository documents the automated operational lifecycle of the MariaDB server instance running on the server laptop.

The system is designed for deterministic daily execution, script-managed log rotation, and controlled resource allocation within a multi-database environment.

---

## Execution Schedule

MariaDB lifecycle runs daily at 12:15 A.M.

15 0 * * * /db1/myserver/mariadb/scripts/run-mariadb-lifecycle.sh

Execution is sequential and halts on failure.

---

## Nightly Lifecycle Sequence

Each cycle performs:

1. Database Backup
2. Log Rotation
3. Log Flush
4. Log Sanitization
5. Retention Cleanup
6. Git Commit and Push

This ensures recoverability, observability, and controlled archival.

---

## Logging Strategy

MariaDB does not perform automatic date-based rotation.

Lifecycle scripts explicitly:

- Rename active logs to date-stamped format
- Recreate fresh active log files
- Sanitize rotated logs
- Copy logs to GitHub directory
- Apply retention policies
- Push sanitized logs to the remote repository

This provides full operational control over log lifecycle management.

---

## Resource Configuration

MariaDB is tuned for shared lab infrastructure.

Memory settings:

- InnoDB Buffer Pool → 64M
- Key Buffer → 16M
- Max Connections → 30

This prevents unnecessary allocation and preserves system headroom.

Swap usage remains zero under normal operation.

---

## Isolation Characteristics

MariaDB runs independently from:

- MySQL (port 3310)
- PostgreSQL (port 5432)

Isolation includes:

- Dedicated port 3306
- Dedicated socket file
- Dedicated PID file
- Dedicated data directory
- Dedicated log directory

No cross-engine process assumptions exist.

---

## Retention Policy

- GitHub local logs → 7 days
- Internal rotated logs → 14 days
- Cron logs → 14 days
- Active logs are never deleted

The remote GitHub repository acts as an immutable historical archive.

---

## Architectural Intent

The MariaDB lifecycle is intentionally:

- Deterministic
- Script-controlled
- Resource-governed
- Isolated from other database engines
- Designed for observability and auditability

This architecture provides a stable foundation for future enhancements such as replication testing, monitoring integration, remote backups, and production-grade hardening.
