# INC-003 — Container Restart Loop

## Incident ID

INC-003

## Title

spring-support-api unhealthy — bad environment configuration (wrong database URL)

## Priority

P2 — High

## Affected Service

Support Portal API — container health check failing; customer traffic via Nginx degraded

## Alert Source

Prometheus alert: `SupportApiDatabaseDown` (critical), `SupportApiDown` (if scrape fails)  
Docker health check: `msol-support-api` unhealthy  
Lab trigger: `./scripts/incidents/simulate-bad-env-restart-loop.sh`

## Impact

- `msol-support-api` container reports unhealthy; may restart under `restart: unless-stopped`
- Customer-facing health at `http://localhost:18081/health` returns errors or `DEGRADED`
- `support_api_database_up = 0` — application cannot connect to `wrongdb`
- Intermittent 502/503 from Nginx when upstream is down
- No data corruption; configuration error only

## Symptoms

- `docker compose ps` → `msol-support-api` **unhealthy** or restarting
- `docker compose logs spring-support-api` → `FATAL: database "wrongdb" does not exist` or Flyway/JDBC errors
- Health endpoint: `"status":"DEGRADED","database":"DOWN"`
- Prometheus: `support_api_database_up == 0`
- Override active: `docker-compose.incident-bad-env.yml` sets `SPRING_DATASOURCE_URL=.../wrongdb`

## Investigation Steps

1. Noted alert and unhealthy container via `docker compose ps`
2. Correlated with recent config change — incident override applied
3. Inspected environment: `docker compose exec spring-support-api env | grep SPRING_DATASOURCE`
4. Reviewed startup logs: `docker compose logs --tail=50 spring-support-api`
5. Confirmed PostgreSQL itself healthy: `docker compose ps postgres` → healthy
6. Isolated fault to application config, not database outage
7. Checked Grafana Database Health panel — confirms `support_api_database_up = 0`

## Commands Used

```bash
docker compose -f docker-compose.yml -f docker-compose.incident-bad-env.yml ps
docker compose logs --tail=50 spring-support-api
docker compose ps
curl -s http://localhost:18081/health | jq .
curl -s http://localhost:18080/health | jq .
curl -s 'http://localhost:19090/api/v1/query?query=support_api_database_up' | jq .
```

## Root Cause

Misconfigured `SPRING_DATASOURCE_URL` pointing to non-existent database `wrongdb` (simulating a bad deployment or failed change). Application fails database connectivity on startup and on each `/health` check, causing container health check failure and service degradation.

**Production analogue:** CHG-004-style environment variable error deployed without validation.

## Resolution

1. Restored correct configuration: `./scripts/incidents/restore-bad-env-restart-loop.sh`
   - `docker compose -f docker-compose.yml up -d --force-recreate spring-support-api`
2. Waited 30s for healthy startup
3. Validated: `docker compose ps` → `msol-support-api` **healthy**
4. Confirmed health: `curl -s http://localhost:18081/health | jq .` → `UP` / `UP`
5. Verified `support_api_database_up = 1` in Prometheus
6. Documented as config rollback; linked to CHG-004 lessons

## Prevention

- Require change record and staging validation for all env var changes (CHG-004)
- Add pre-deploy checklist: datasource URL, credentials, database exists
- Implement CHG-005 health check improvements (readiness vs liveness)
- Memory/resource review for config changes affecting throughput (PRB-002)

## Related Runbook

[runbooks/container-restart.md](../runbooks/container-restart.md), [runbooks/failed-deployment.md](../runbooks/failed-deployment.md)

## Related Problem Record

[problem-records/PRB-002-repeated-container-restarts.md](../problem-records/PRB-002-repeated-container-restarts.md)

## Related Change Record

[changes/CHG-004-update-environment-variable.md](../changes/CHG-004-update-environment-variable.md)
