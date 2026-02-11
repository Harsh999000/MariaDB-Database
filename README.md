# MariaDB Database Server – Manual Linux Setup

This project documents a manually configured MariaDB server running on Debian Linux with a structured automation and logging lifecycle.

The system is built as a learning-focused infrastructure project with production-style discipline.

---

## Overview

This server includes:

- Dedicated MariaDB instance (port 3306)
- Manual service control scripts (start / stop / status)
- Automated backup process
- Deterministic log rotation
- Log sanitization
- Retention-based log cleanup
- Controlled GitHub archival of logs
- Cron-based execution pipeline

Logs from other internal projects can be stored and version-controlled here for structured long-term archival.

---

## Daily Automation Flow

12:01 A.M – Backup MariaDB database  
12:02 A.M – Rotate logs  
12:03 A.M – Flush logs  
12:04 A.M – Sanitize logs  
12:05 A.M – Delete old logs (retention policy)  
12:06 A.M – Auto-push logs to GitHub  

---

## Design Principles

- Full isolation from MySQL instance
- Dedicated port, socket, PID file, and data directory
- PID-file-based process management (no `pgrep` collisions)
- Append-only GitHub log archival
- Logs ignored by default via `.gitignore`
- Explicit forced-add for controlled log uploads
- Clear separation between runtime server directory and Git-controlled directory
- Deterministic execution order for daily operations

---

## Environment

- Debian Linux
- Manual MariaDB installation (no systemd dependency)
- Cron-based automation
- Local development laptop + server laptop architecture

---

## Purpose

This repository serves as:

- A learning infrastructure project
- A structured MariaDB server implementation
- A logging and automation architecture reference
- A foundation for future production-style hardening
