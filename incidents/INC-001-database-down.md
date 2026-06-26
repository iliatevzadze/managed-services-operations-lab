# INC-001 — Database Unavailable

## Incident ID

INC-001

## Title

PostgreSQL database unreachable — Support Portal API degraded

## Priority

P1 — Critical

## Affected Service

Support Portal API (all endpoints requiring persistence)

## Alert Source

Prometheus alert: `SupportApiDatabaseDown` (critical)  
Grafana dashboard: Managed Services Operations Overview — Database Health panel  
Lab trigger: `./scripts/incidents/simulate-database-down.sh`

## Impact

- Customer-facing API returns `status: DEGRADED`, `database: DOWN` on `/health`
- Ticket list and create operations fail when database is required
- `support_api_database_up` metric drops to `0`
- Nginx proxy at `http://localhost:18081` forwards errors to support agents
- SLA availability at risk if prolonged in production

## Symptoms

- `curl http://localhost:18081/health` → `"status":"DEGRADED","database":"DOWN"`
- `curl http://localhost:18080/health` → same (direct API troubleshooting path)
- Prometheus: `support_api_database_up == 0`
- `docker compose ps` → `msol-postgres` stopped or unhealthy
- Application logs: `Database health check failed`, JDBC connection errors

## Investigation Steps

1. Confirmed `SupportApiDatabaseDown` alert at Prometheus http://localhost:19090/alerts
2. Checked customer impact via Nginx: `curl -s http://localhost:18081/health | jq .`
3. Verified direct API path: `curl -s http://localhost:18080/health | jq .`
4. Inspected container state: `docker compose ps`
5. Reviewed PostgreSQL logs: `docker compose logs --tail=50 postgres`
6. Queried metric: `curl -s 'http://localhost:19090/api/v1/query?query=support_api_database_up'`
7. Ruled out application code change — incident started when database container stopped

## Commands Used

```bash
docker compose ps
docker compose logs --tail=50 postgres
curl -s http://localhost:18081/health | jq .
curl -s http://localhost:18080/health | jq .
curl -s 'http://localhost:19090/api/v1/query?query=support_api_database_up' | jq .
curl -s http://localhost:19090/alerts | grep SupportApiDatabaseDown
```

## Root Cause

PostgreSQL container (`msol-postgres`) was stopped during a controlled lab drill simulating database outage. The Support Portal API could not reach `jdbc:postgresql://postgres:5432/supportdb`, causing health degradation and `support_api_database_up = 0`.

In a production scenario, root causes include: container crash, disk exhaustion, network partition, or cloud provider outage.

## Resolution

1. Restored PostgreSQL: `docker compose start postgres` (or `./scripts/incidents/restore-database-down.sh`)
2. Waited 15s for `pg_isready` health check to pass
3. Validated health: `curl -s http://localhost:18081/health | jq .` → `status: UP`, `database: UP`
4. Confirmed metric recovery: `support_api_database_up = 1`
5. Verified alert returned to inactive at http://localhost:19090/alerts
6. Observed stable state for 15 minutes before closing incident

## Prevention

- Monitor `support_api_database_up` and disk usage proactively
- Document restore procedure in runbook; test backup/restore quarterly
- Open problem record PRB-001 for recurring timeout patterns under load
- Add capacity alerting before disk reaches 85% (service improvement plan)

## Related Runbook

[runbooks/database-down.md](../runbooks/database-down.md)

## Related Problem Record

[problem-records/PRB-001-recurring-database-timeout.md](../problem-records/PRB-001-recurring-database-timeout.md)

## Related Change Record

None for immediate restore. Follow-up: CHG-002 (monitoring threshold tuning).
