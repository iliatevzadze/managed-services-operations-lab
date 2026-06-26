# Runbook: Backup and Restore

## Overview

| Field | Value |
|---|---|
| **Symptom** | Backup job failed, or restore required for recovery |
| **Typical alerts** | `BackupJobFailed`, `BackupAgeExceeded` |
| **Priority** | P2 (P1 if restore needed for active incident) |
| **Estimated time** | 30 min – several hours |

## Backup failure investigation

1. **Check backup job logs** — Disk space, auth, network?
2. **Verify target storage** — Writable? Quota exceeded?
3. **Test manual backup** — Run `database/backup.sh` (when implemented)
4. **Confirm database reachable** — Follow database-down if not

## Restore procedure (high level)

1. **Get approval** — Change record or incident commander sign-off
2. **Stop write traffic** — Scale app to 0 or enable maintenance mode
3. **Verify backup integrity** — Checksum, file size, age
4. **Execute restore** — `database/restore.sh <file>` (when implemented)
5. **Validate schema and row counts** — Smoke queries
6. **Restore traffic** — Gradual if possible
7. **Document** — Incident or change record with timeline

## Commands

```bash
# Placeholder scripts (Milestone 0)
./database/backup.sh
./database/restore.sh <backup-file>

# Verify PostgreSQL after restore
psql -h <host> -U <user> -d <db> -c "\dt"
psql -c "SELECT count(*) FROM <critical_table>;"
```

## Validation

- [ ] Backup completes without error (for backup failures)
- [ ] Application health `UP` after restore
- [ ] Critical data spot-checks pass
- [ ] Monitoring normal for observation period

## Related documents

- [../docs/backup-restore-guide.md](../docs/backup-restore-guide.md)
- [database-down.md](database-down.md)
