# INC-001 — Database Unavailable

## Incident ID

INC-001

## Title

PostgreSQL database unreachable — Support Portal API fully degraded

## Priority

P1 — Critical

## Affected Service

Support Portal API (all endpoints requiring persistence)

## Alert Source

Prometheus alert: `PostgresDown`  
Grafana dashboard: Service Overview — Database panel red  
Customer ticket: #4521 — "Cannot load support cases"

## Impact

- 100% of API write operations failing
- Support agents unable to open or update cases
- Estimated 120 active users affected during business hours
- SLA availability at risk for monthly window

## Symptoms

- `/actuator/health` returns `DOWN` with database component failed
- Application logs: `org.postgresql.util.PSQLException: Connection refused`
- Nginx returning 503 to clients
- Prometheus: `up{job="postgres"}` = 0

## Investigation Steps

1. Confirmed alert at 09:14 UTC; opened incident bridge for P1
2. Checked `docker compose ps` — postgres container in `Exit 137` state
3. Reviewed postgres logs — OOM kill followed by failed restart
4. Verified disk on host: `/var/lib/postgresql` mount at 98% capacity
5. Ruled out application-side misconfiguration — connection string unchanged
6. Checked recent changes — no deployment in last 24h; backup job ran at 02:00

## Commands Used

```bash
docker compose ps
docker compose logs --tail=150 postgres
df -h /var/lib/postgresql
pg_isready -h localhost -p 5432
docker compose logs --tail=50 spring-support-api | grep -i postgres
```

## Root Cause

PostgreSQL container terminated due to **host disk exhaustion** (98% full). WAL and log growth prevented clean restart; container entered crash loop until disk space reclaimed.

## Resolution

1. Identified large orphaned backup files in local volume (non-production drill environment)
2. Removed expired backup archives per retention policy (with team lead approval)
3. Restarted postgres container: `docker compose up -d postgres`
4. Validated connectivity with `pg_isready` and application health endpoint
5. Monitored error rate for 30 minutes — returned to baseline

## Prevention

- Implement disk usage alerting before 85% threshold
- Enforce backup retention cleanup automation
- Schedule capacity review in service improvement plan
- Open problem record PRB-001 for related timeout patterns under load

## Related Runbook

[runbooks/database-down.md](../runbooks/database-down.md)

## Related Problem Record

[problem-records/PRB-001-recurring-database-timeout.md](../problem-records/PRB-001-recurring-database-timeout.md)

## Related Change Record

None for immediate incident. Follow-up monitoring change planned: CHG-002 (disk alert — future).
