# Runbook: Application 500 Errors

## Overview

| Field | Value |
|---|---|
| **Symptom** | Elevated HTTP 5xx responses from spring-support-api |
| **Typical alerts** | `HighErrorRate`, `Http5xxRatio`, `SLOBurnRate` |
| **Priority** | P2 (P1 if complete outage) |
| **Estimated time** | 20–60 min |

## Investigation steps

1. **Quantify impact** — Error rate, affected endpoints, user reports
2. **Check recent deployments** — Release in last 2 hours?
3. **Review application logs** — Stack traces, SQLException, NPE patterns
4. **Check dependencies** — Database, external APIs, config service
5. **Compare metrics** — Latency spike correlating with errors?
6. **Sample failing request** — Reproduce with curl if safe

## Commands

```bash
# Application logs
docker compose logs --tail=200 spring-support-api | grep -i error
kubectl logs -l app=spring-support-api --tail=200

# Error rate from metrics (preview)
curl -s 'http://localhost:9090/api/v1/query?query=rate(http_server_requests_seconds_count{status=~"5.."}[5m])'

# Health and readiness
curl -s http://localhost:8080/actuator/health | jq .

# Recent deployment (K8s)
kubectl rollout history deployment/spring-support-api
```

## Resolution paths

| Root cause | Action |
|---|---|
| Bad release | Rollback deployment (see failed-deployment, kubernetes-rollback) |
| Database errors | Follow database-down runbook |
| Misconfiguration | Revert env var change (CHG-004) |
| Resource exhaustion | Scale or restart; investigate high-cpu |
| Unhandled edge case | Mitigate if known; escalate to dev for fix |

## Validation

- [ ] 5xx rate below alert threshold for 15 min
- [ ] Smoke test on critical endpoints passes
- [ ] No new error spikes in logs

## Related records

- Incident: [../incidents/INC-002-application-500-errors.md](../incidents/INC-002-application-500-errors.md)
- Problem: [../problem-records/PRB-003-repeated-http-500-errors.md](../problem-records/PRB-003-repeated-http-500-errors.md)
- Change: [../changes/CHG-003-rollback-bad-release.md](../changes/CHG-003-rollback-bad-release.md)
