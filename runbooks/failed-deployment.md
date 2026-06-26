# Runbook: Failed Deployment

## Overview

| Field | Value |
|---|---|
| **Symptom** | Deployment fails or new revision unhealthy after release |
| **Typical alerts** | `SupportApiDown`, `SupportApiDatabaseDown`, post-deploy error spike |
| **Priority** | P1–P2 |
| **Estimated time** | 15–45 min |
| **Lab simulation** | `./scripts/incidents/simulate-bad-env-restart-loop.sh` (bad config deploy) |

## Detection

- Container unhealthy immediately after `docker compose up` or config change
- Alerts fire within minutes of deployment
- Customer-facing health degrades
- Logs show startup failures (Flyway, JDBC, missing database)

## Impact check

```bash
docker compose ps
docker compose logs --tail=30 spring-support-api
curl -s http://localhost:18081/health | jq .
curl -s http://localhost:19090/alerts
```

Correlate incident start time with deployment/change timestamp.

## Investigation steps

1. **Identify deployment time** — When was container last recreated?
2. **Check container status** — Healthy? Restarting?
3. **Compare config** — `docker compose exec spring-support-api env`
4. **Review logs** — Startup errors, Flyway, datasource
5. **Check dependencies** — Is postgres healthy?
6. **Decide: fix forward vs. rollback** — Default to rollback under customer impact

## Commands

```bash
docker compose ps
docker compose logs --tail=100 spring-support-api
docker compose exec spring-support-api env | grep -E 'SPRING_|SUPPORT_'
curl -s http://localhost:18080/health | jq .

# Lab: apply bad config (incident drill only)
docker compose -f docker-compose.yml -f docker-compose.incident-bad-env.yml up -d --force-recreate spring-support-api
```

## Safe restore

| Situation | Action |
|---|---|
| Customer impact ongoing | **Rollback immediately** — recreate with base compose file |
| Bad env var only | `./scripts/incidents/restore-bad-env-restart-loop.sh` |
| Bad image tag | Redeploy previous image digest |
| Config-only failure | Remove override file; force-recreate |

```bash
# Rollback to known-good configuration
docker compose -f docker-compose.yml up -d --force-recreate spring-support-api
```

Update change record (CHG-003) with rollback result.

## Validation

```bash
docker compose ps                              # all healthy
curl -s http://localhost:18081/health | jq .  # UP
curl -s http://localhost:18081/tickets | jq 'length'
curl -s 'http://localhost:19090/api/v1/query?query=up{job="spring-support-api"}' | jq .
```

- [ ] Health checks passing
- [ ] Error rate at baseline
- [ ] Change record updated with result

## Escalation

Escalate to development if rollback does not restore service or root cause requires code fix.

## Prevention

- Staging soak test before production promote
- Change record with rollback plan for every Normal change
- Env var impact checklist (CHG-004 lesson)
- Hold deploys after P1/P2 until RCA complete

## Related records

- Change: [../changes/CHG-003-rollback-bad-release.md](../changes/CHG-003-rollback-bad-release.md)
- Incident: [../incidents/INC-003-container-restart-loop.md](../incidents/INC-003-container-restart-loop.md)
- Runbook: [container-restart.md](container-restart.md)
