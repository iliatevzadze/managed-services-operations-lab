# INC-002 — Application HTTP 500 Errors

## Incident ID

INC-002

## Title

Elevated HTTP 500 errors on Support Portal API

## Priority

P2 — High

## Affected Service

Support Portal API — simulated error endpoint and customer-facing paths via Nginx

## Alert Source

Prometheus alert: `SupportApiHighErrorRate` (warning)  
Grafana dashboard: Managed Services Operations Overview — HTTP 5xx Error Rate panel  
Lab trigger: `./scripts/incidents/simulate-http-500.sh`

## Impact

- Repeated HTTP 500 responses on `/simulate/http-500` (lab) or production endpoints (real scenario)
- Customer agents see errors when loading support workflows
- `http_server_requests_seconds_count{status="500"}` increases
- No data loss; degraded experience until errors stop or rollback completes
- SLA error budget consumption if sustained

## Symptoms

- Prometheus: `sum(rate(http_server_requests_seconds_count{job="spring-support-api",status=~"5.."}[2m])) > 0`
- Application logs: `Incident simulation HTTP 500` or stack traces for real defects
- `curl -s -o /dev/null -w "%{http_code}" http://localhost:18081/simulate/http-500` → `500`
- JSON error body: `{"error":"SIMULATION_ERROR","message":"Simulated HTTP 500..."}`
- Grafana 5xx panel shows spike

## Investigation Steps

1. Confirmed `SupportApiHighErrorRate` pending/firing at http://localhost:19090/alerts
2. Quantified 5xx rate in Prometheus expression browser
3. Checked Grafana HTTP 5xx Error Rate panel at http://localhost:13003
4. Reviewed application logs: `docker compose logs --tail=100 spring-support-api | grep -i error`
5. Tested customer path vs direct API:
   - `curl -s http://localhost:18081/simulate/http-500`
   - `curl -s http://localhost:18080/simulate/http-500`
6. Checked recent deployments and change records for correlation
7. Ruled out database issue: `support_api_database_up == 1`

## Commands Used

```bash
docker compose logs --tail=100 spring-support-api | grep -i error
curl -s -o /dev/null -w "%{http_code}\n" http://localhost:18081/simulate/http-500
curl -s 'http://localhost:19090/api/v1/query?query=sum(rate(http_server_requests_seconds_count{job="spring-support-api",status=~"5.."}[2m]))' | jq .
curl -s http://localhost:19090/alerts | grep SupportApiHighErrorRate
curl -s http://localhost:18081/health | jq .
```

## Root Cause

**Lab drill:** Controlled requests to `GET /simulate/http-500` with `SUPPORT_SIMULATION_ENABLED=true` deliberately return HTTP 500 for incident training.

**Production analogue:** Application regression (e.g. release v1.4.2 NPE on optional query parameter) causing unhandled exceptions on customer endpoints.

## Resolution

1. **Lab:** Stop sending simulation requests; 5xx rate returns to zero within 2–5 minutes
2. **Production analogue:** Rollback bad release (CHG-003) or hotfix with dev approval
3. Validated 5xx rate below threshold: Prometheus query returns `0`
4. Confirmed alert inactive at http://localhost:19090/alerts
5. Smoke-tested critical endpoints: `curl -s http://localhost:18081/tickets | jq 'length'`
6. Updated incident record and notified stakeholders (P2)

## Prevention

- Strengthen pre-production smoke tests for all API endpoints
- Gate releases on staging error-rate soak (PRB-003)
- Keep simulation endpoints disabled in production (`support.simulation.enabled=false`)
- Document rollback path in change management process

## Related Runbook

[runbooks/application-500-errors.md](../runbooks/application-500-errors.md)

## Related Problem Record

[problem-records/PRB-003-repeated-http-500-errors.md](../problem-records/PRB-003-repeated-http-500-errors.md)

## Related Change Record

[changes/CHG-003-rollback-bad-release.md](../changes/CHG-003-rollback-bad-release.md)
