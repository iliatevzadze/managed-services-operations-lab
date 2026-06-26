# Runbook: Database Down

## Overview

| Field | Value |
|---|---|
| **Symptom** | Application cannot connect to PostgreSQL; health checks fail |
| **Typical alerts** | `SupportApiDatabaseDown`, `SupportApiDown` |
| **Priority** | P1 |
| **Estimated time** | 15–45 min |
| **Lab simulation** | `./scripts/incidents/simulate-database-down.sh` |

## Detection

- Prometheus alert `SupportApiDatabaseDown` fires (`support_api_database_up == 0`)
- Grafana **Database Health** panel shows `0`
- Customer ticket: "Cannot load support cases"
- `/health` returns `status: DEGRADED`, `database: DOWN`

## Impact check

```bash
# Customer-facing path (Nginx)
curl -s http://localhost:18081/health | jq .

# Direct API (troubleshooting)
curl -s http://localhost:18080/health | jq .

# Confirm metric
curl -s 'http://localhost:19090/api/v1/query?query=support_api_database_up' | jq .
```

Assess: are all persistence endpoints affected? Is this isolated to one customer or platform-wide?

## Investigation steps

1. **Confirm scope** — Single service or multiple consumers?
2. **Check container status** — `docker compose ps postgres`
3. **Review database logs** — `docker compose logs --tail=100 postgres`
4. **Review application logs** — JDBC/connection errors
5. **Test connectivity** — `pg_isready -h localhost -p 15434 -U supportuser`
6. **Review recent changes** — Deployments, maintenance, backup jobs
7. **Check disk and connections** — Full disk or `max_connections` exhausted?

## Commands

```bash
docker compose ps
docker compose logs --tail=100 postgres
docker compose logs --tail=100 spring-support-api | grep -i postgres
pg_isready -h localhost -p 15434 -U supportuser
curl -s http://localhost:19090/alerts | grep SupportApiDatabaseDown
```

## Safe restore

| Root cause | Action |
|---|---|
| Container stopped | `docker compose start postgres` or `./scripts/incidents/restore-database-down.sh` |
| Connection pool exhausted | Restart app after DB healthy |
| Disk full | Free space; escalate to DBA |
| Bad credentials after change | Revert env change (CHG-004); recreate container |
| Provider outage | Escalate to platform team |

**Do not** delete volumes without change record approval.

## Validation

```bash
docker compose ps postgres                    # healthy
curl -s http://localhost:18081/health | jq .  # status UP, database UP
curl -s 'http://localhost:19090/api/v1/query?query=support_api_database_up' | jq .
curl -s http://localhost:18081/tickets | jq 'length'   # smoke test
```

- [ ] `support_api_database_up = 1` for 15 min
- [ ] Alert inactive at http://localhost:19090/alerts
- [ ] Incident record updated

## Escalation

Escalate to DBA / 3rd level if: data corruption suspected, restore from backup required, or no progress in 30 min (P1).

## Prevention

- Monitor `support_api_database_up` and host disk usage
- Automated backup verification (see `database/backup.sh`)
- Capacity review in service improvement plan
- Problem record PRB-001 for recurring timeout patterns

## Related records

- Incident: [../incidents/INC-001-database-down.md](../incidents/INC-001-database-down.md)
- Problem: [../problem-records/PRB-001-recurring-database-timeout.md](../problem-records/PRB-001-recurring-database-timeout.md)
- Restore script: [../scripts/incidents/restore-database-down.sh](../scripts/incidents/restore-database-down.sh)
