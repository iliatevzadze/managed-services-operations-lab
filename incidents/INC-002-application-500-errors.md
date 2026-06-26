# INC-002 — Application HTTP 500 Errors

## Incident ID

INC-002

## Title

Elevated HTTP 500 errors after application release v1.4.2

## Priority

P2 — High

## Affected Service

Support Portal API — `/api/v1/cases` and `/api/v1/search` endpoints

## Alert Source

Prometheus alert: `HighErrorRate` (5xx > 5% for 5 min)  
Internal monitoring: Grafana — HTTP Error Rate panel  
Ticket: #4588 — intermittent errors loading case list

## Impact

- ~35% of case list requests returning 500
- Search functionality degraded; create/update still working
- No data loss; customer workaround: retry or refresh
- Approx. 40 support agents affected

## Symptoms

- Spike in `http_server_requests_seconds_count{status="500"}` after 14:02 UTC deploy
- Logs: `NullPointerException` in `CaseSearchService.buildFilter()` line 87
- Database metrics normal — ruled out DB as primary cause
- Only pods on revision `spring-support-api-7d8f9c` affected

## Investigation Steps

1. Correlated error spike start with deployment timestamp (14:02 UTC)
2. Compared error rate between old and new replicas — new revision only
3. Pulled stack traces from application logs — NPE in search filter builder
4. Reproduced with curl against new pod — confirmed on optional filter param
5. Checked change record for v1.4.2 — feature flag for advanced search enabled
6. Consulted with dev on-call — known edge case when `status` param omitted

## Commands Used

```bash
kubectl get pods -l app=spring-support-api -o wide
kubectl logs -l app=spring-support-api --tail=300 | grep -A5 NullPointerException
curl -s -o /dev/null -w "%{http_code}" "https://api.example.com/api/v1/search"
kubectl rollout history deployment/spring-support-api
```

## Root Cause

Release **v1.4.2** introduced a regression in `CaseSearchService` when the optional `status` query parameter is absent. Unhandled null dereference causes 500 on affected search requests.

## Resolution

1. Decision: rollback preferred over hotfix due to active customer impact
2. Executed `kubectl rollout undo deployment/spring-support-api`
3. Confirmed rollout complete on revision v1.4.1
4. Validated 5xx rate below 0.1% within 10 minutes
5. Customer comms sent — issue resolved, retry recommended during incident

## Prevention

- Add integration test for search without optional parameters
- Strengthen staging smoke tests before production promote
- Open problem record PRB-003 for repeated 500 patterns
- Document rollback in CHG-003

## Related Runbook

[runbooks/application-500-errors.md](../runbooks/application-500-errors.md)

## Related Problem Record

[problem-records/PRB-003-repeated-http-500-errors.md](../problem-records/PRB-003-repeated-http-500-errors.md)

## Related Change Record

[changes/CHG-003-rollback-bad-release.md](../changes/CHG-003-rollback-bad-release.md)
