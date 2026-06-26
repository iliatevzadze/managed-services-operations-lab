# Runbook: Application 500 Errors

## Overview

| Field | Value |
|---|---|
| **Symptom** | Elevated HTTP 5xx responses from spring-support-api |
| **Typical alerts** | `SupportApiHighErrorRate` |
| **Priority** | P2 (P1 if complete outage) |
| **Estimated time** | 20–60 min |
| **Lab simulation** | `./scripts/incidents/simulate-http-500.sh` |

## Detection

- Prometheus alert `SupportApiHighErrorRate` fires (5xx rate > 0 for 2m)
- Grafana **HTTP 5xx Error Rate** panel shows spike
- Customer reports intermittent errors
- Logs show exceptions or simulation messages

## Impact check

```bash
curl -s 'http://localhost:19090/api/v1/query?query=sum(rate(http_server_requests_seconds_count{job="spring-support-api",status=~"5.."}[2m]))' | jq .
curl -s http://localhost:18081/health | jq .
docker compose logs --tail=50 spring-support-api | grep -i error
```

Determine: which endpoints? What percentage of requests? Database up?

## Investigation steps

1. **Quantify impact** — Error rate, affected endpoints, user reports
2. **Check recent deployments** — Release in last 2 hours?
3. **Review application logs** — Stack traces, SQLException, NPE patterns
4. **Check dependencies** — `support_api_database_up`, external APIs
5. **Compare metrics** — Latency spike correlating with errors?
6. **Reproduce safely** — `curl` against known failing endpoint

## Commands

```bash
docker compose logs --tail=200 spring-support-api | grep -i error
curl -s -o /dev/null -w "%{http_code}\n" http://localhost:18081/simulate/http-500
curl -s 'http://localhost:19090/api/v1/query?query=sum(rate(http_server_requests_seconds_count{job="spring-support-api",status=~"5.."}[2m]))' | jq .
curl -s http://localhost:18080/health | jq .
curl -s http://localhost:19090/alerts | grep SupportApiHighErrorRate
```

## Safe restore

| Root cause | Action |
|---|---|
| Bad release | Rollback deployment (see failed-deployment, CHG-003) |
| Database errors | Follow database-down runbook |
| Misconfiguration | Revert env var (CHG-004); `./scripts/incidents/restore-bad-env-restart-loop.sh` |
| Lab simulation active | Stop simulation requests; wait for rate to decay |
| Unhandled defect | Escalate to dev; mitigate if known workaround exists |

## Validation

```bash
curl -s 'http://localhost:19090/api/v1/query?query=sum(rate(http_server_requests_seconds_count{job="spring-support-api",status=~"5.."}[2m]))' | jq .
curl -s http://localhost:18081/tickets | jq 'length'
```

- [ ] 5xx rate at `0` for 15 min
- [ ] Alert inactive
- [ ] Smoke tests pass on critical endpoints
- [ ] Incident record updated

## Escalation

Escalate to 3rd level development if: root cause requires code fix, no rollback path, or P2 unresolved in 2 hours.

## Prevention

- Pre-production smoke tests for all endpoints (PRB-003)
- Disable simulation endpoints in production
- Staging error-rate gate before promote
- Blameless post-incident review within 5 days

## Related records

- Incident: [../incidents/INC-002-application-500-errors.md](../incidents/INC-002-application-500-errors.md)
- Problem: [../problem-records/PRB-003-repeated-http-500-errors.md](../problem-records/PRB-003-repeated-http-500-errors.md)
- Change: [../changes/CHG-003-rollback-bad-release.md](../changes/CHG-003-rollback-bad-release.md)
