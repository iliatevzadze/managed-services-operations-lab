# Backup and Restore Guide

## Scope

PostgreSQL backup and restore procedures for the Support Portal API datastore.

> **Milestone 0:** Scripts are placeholders. Full implementation in a later milestone.

## Backup strategy (planned)

| Aspect | Policy |
|---|---|
| Full backup | Daily at 02:00 UTC |
| Retention | 30 days |
| Storage | Encrypted off-host volume |
| Verification | Weekly restore drill to non-production |

## Backup script

Location: [../database/backup.sh](../database/backup.sh)

Planned behavior:

```bash
# Future usage (preview)
./database/backup.sh
# Creates timestamped pg_dump archive
```

## Restore script

Location: [../database/restore.sh](../database/restore.sh)

Planned behavior:

```bash
# Future usage (preview)
./database/restore.sh <backup-file>
# Pre-restore confirmation and integrity check
```

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
