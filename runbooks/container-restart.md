# Runbook: Container Restart

## Overview

| Field | Value |
|---|---|
| **Symptom** | Container unhealthy or repeatedly restarting |
| **Typical alerts** | `SupportApiDown`, `SupportApiDatabaseDown`, `ContainerMemoryHigh` |
| **Priority** | P2 (P1 if no healthy instances) |
| **Estimated time** | 20–60 min |
| **Lab simulation** | `./scripts/incidents/simulate-bad-env-restart-loop.sh` |

## Detection

- `docker compose ps` shows `unhealthy` or increasing restarts
- Prometheus `up{job="spring-support-api"} == 0` or database metric `0`
- Nginx returns 502/503 intermittently
- Grafana panels show API down or database unhealthy

## Impact check

```bash
docker compose ps
curl -s http://localhost:18081/health | jq .
curl -s 'http://localhost:19090/api/v1/query?query=up{job="spring-support-api"}' | jq .
```

## Investigation steps

1. **Count restarts** — `docker compose ps`, `docker inspect msol-support-api`
2. **Read exit reason** — OOMKilled, Error, health check failure?
3. **Check last logs** — `docker compose logs --tail=50 spring-support-api`
4. **Review environment** — Recent config change? Wrong datasource URL?
5. **Probe configuration** — Health check failing on slow start?
6. **Resource limits** — Memory/CPU pressure from cAdvisor metrics

## Commands

```bash
docker compose ps
docker inspect msol-support-api --format '{{.State.Status}} {{.State.Health.Status}}'
docker compose logs --tail=50 spring-support-api
docker compose exec spring-support-api env | grep SPRING_DATASOURCE
curl -s 'http://localhost:19090/api/v1/query?query=container_memory_usage_bytes{name=~".*msol-support-api.*"}' | jq .
```

## Safe restore

| Root cause | Action |
|---|---|
| Bad env config | `./scripts/incidents/restore-bad-env-restart-loop.sh` |
| OOMKilled | Fix leak or increase limit; recreate container |
| Liveness too aggressive | Apply CHG-005 health check fix |
| Dependency not ready | Ensure postgres healthy first |
| Application bug on boot | Rollback image/config |

```bash
# Restore normal config after bad-env drill
docker compose -f docker-compose.yml up -d --force-recreate spring-support-api
```

## Validation

```bash
docker compose ps                              # healthy, 0 restarts
curl -s http://localhost:18081/health | jq .  # UP / UP
curl -s 'http://localhost:19090/api/v1/query?query=support_api_database_up' | jq .
```

- [ ] Container healthy for 30 min
- [ ] Customer path serves traffic normally
- [ ] Incident record updated

## Escalation

Escalate if: multiple replicas failing, data loss risk, or no progress in 2 hours (P2).

## Prevention

- Env var change checklist with memory/datasource review (PRB-002, CHG-004)
- Separate readiness from liveness (CHG-005)
- Monitor container memory on Grafana dashboard
- Staging validation before production config changes

## Related records

- Incident: [../incidents/INC-003-container-restart-loop.md](../incidents/INC-003-container-restart-loop.md)
- Problem: [../problem-records/PRB-002-repeated-container-restarts.md](../problem-records/PRB-002-repeated-container-restarts.md)
- Restore: [../scripts/incidents/restore-bad-env-restart-loop.sh](../scripts/incidents/restore-bad-env-restart-loop.sh)
