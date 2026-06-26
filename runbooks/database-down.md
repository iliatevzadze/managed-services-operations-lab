# Runbook: Database Down

## Overview

| Field | Value |
|---|---|
| **Symptom** | Application cannot connect to PostgreSQL; health checks fail |
| **Typical alerts** | `DatabaseConnectionPoolExhausted`, `PostgresDown`, `ActuatorHealthDown` |
| **Priority** | P1 |
| **Estimated time** | 15–45 min |

## Prerequisites

- Access to application and database logs
- Database credentials (from secrets manager / env — not in repo)
- Escalation contact for DBA / cloud DBA

## Investigation steps

1. **Confirm scope** — Is only this service affected or multiple consumers?
2. **Check application logs** — Connection refused, timeout, authentication errors?
3. **Check database container/pod status** — Running? Restarting? OOMKilled?
4. **Test connectivity** — `psql` or `pg_isready` from application network
5. **Review recent changes** — Deployments, config, maintenance window
6. **Check disk and connections** — Full disk or `max_connections` exhausted?

## Commands

```bash
# Container status (local lab)
docker compose ps postgres
docker compose logs --tail=100 postgres

# Kubernetes (staging/prod)
kubectl get pods -l app=postgres
kubectl logs -l app=postgres --tail=100

# Connectivity
pg_isready -h <host> -p 5432

# Active connections (if reachable)
psql -h <host> -U <user> -d <db> -c "SELECT count(*) FROM pg_stat_activity;"
```

## Resolution paths

| Root cause | Action |
|---|---|
| Database pod/container stopped | Restart service; validate health |
| Connection pool exhausted | Restart app or reduce leak; scale pool temporarily |
| Disk full | Free space or expand volume; escalate to DBA |
| Bad credentials after change | Rollback env change (CHG-004) |
| Provider outage | Escalate to cloud/platform team |

## Validation

- [ ] `pg_isready` succeeds
- [ ] Application `/actuator/health` shows database `UP`
- [ ] Error rate returned to baseline
- [ ] Observation period 15 min without recurrence

## Escalation

Escalate to DBA / 3rd level if: data corruption suspected, restore required, or no progress in 30 min (P1).

## Related records

- Incident example: [../incidents/INC-001-database-down.md](../incidents/INC-001-database-down.md)
- Problem record: [../problem-records/PRB-001-recurring-database-timeout.md](../problem-records/PRB-001-recurring-database-timeout.md)
- Backup: [backup-and-restore.md](backup-and-restore.md)
