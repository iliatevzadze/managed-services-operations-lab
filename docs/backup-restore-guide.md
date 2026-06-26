# Backup and Restore Guide

## Scope

PostgreSQL backup and restore procedures for the Support Portal API datastore, using the Docker Compose stack from Milestone 2.

> **Prerequisite:** the stack must be running (`docker compose up -d`) so the `postgres` service is available.

## Backup strategy

| Aspect | Policy |
|---|---|
| Full backup | Daily at 02:00 UTC (operational target) |
| Retention | 30 days |
| Storage | Encrypted off-host volume |
| Verification | Weekly restore drill to non-production |

In this lab, backups are written locally to `database/backups/` as timestamped `.sql` files. Generated backups are git-ignored.

## Backup script

Location: [../database/backup.sh](../database/backup.sh)

Creates `database/backups/` if missing and writes a timestamped logical dump using `pg_dump` inside the `postgres` container.

```bash
./database/backup.sh
# -> database/backups/supportdb-YYYYMMDD-HHMMSS.sql
```

Behavior:

- Fails fast (`set -euo pipefail`) if the dump cannot be produced.
- Uses `docker compose exec -T postgres pg_dump -U supportuser supportdb`.
- Prints the resulting backup file path.

## Restore script

Location: [../database/restore.sh](../database/restore.sh)

Requires a backup file path argument and restores it into `supportdb`.

```bash
./database/restore.sh database/backups/supportdb-YYYYMMDD-HHMMSS.sql
```

Behavior:

- Fails fast if the argument is missing or the file does not exist.
- Prints a warning that existing data may be overwritten; quiesce the application first.
- Uses `docker compose exec -T postgres psql -U supportuser -d supportdb`.

## Pre-restore checklist

- [ ] Confirm target environment (never restore prod dump to prod without change record)
- [ ] Notify stakeholders if service interruption required
- [ ] Verify backup file integrity and age
- [ ] Stop application writes to database
- [ ] Document restore in change or incident record

## When to restore

| Scenario | Action |
|---|---|
| Data corruption | Restore to point before corruption; coordinate with DBA |
| Failed migration | Rollback migration or restore pre-migration backup |
| Disaster recovery drill | Restore to isolated environment |

## Operational runbook

Detailed steps: [../runbooks/backup-and-restore.md](../runbooks/backup-and-restore.md)

## Related documents

- [../runbooks/database-down.md](../runbooks/database-down.md)
- [change-management-process.md](change-management-process.md)
