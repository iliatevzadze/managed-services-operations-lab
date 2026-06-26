# INC-003 — Container Restart Loop

## Incident ID

INC-003

## Title

spring-support-api pod CrashLoopBackOff — intermittent service unavailability

## Priority

P2 — High

## Affected Service

Support Portal API — reduced replica count; intermittent 502/503 from load balancer

## Alert Source

Kubernetes event: `CrashLoopBackOff`  
Prometheus alert: `PodRestarting` (> 3 restarts in 15 min)  
PagerDuty: Support Portal API replica unhealthy

## Impact

- 1 of 3 replicas in crash loop; 33% capacity reduction
- Intermittent timeouts during peak load
- No data corruption; degraded experience for ~25% of requests under load
- SLA not breached but trending toward P1 if additional replica fails

## Symptoms

- `kubectl get pods` shows `0/1 Running` with increasing `RESTARTS` count
- `kubectl describe pod` — `Last State: Terminated, Reason: OOMKilled`
- Liveness probe failures logged before each restart
- Memory usage metric spiked to limit (512Mi) before kill

## Investigation Steps

1. Identified failing pod `spring-support-api-6b4xx` via `kubectl get pods`
2. Retrieved previous container logs — GC overhead limit exceeded before OOM
3. Compared memory limits across replicas — consistent at 512Mi
4. Reviewed recent changes — CHG-004 increased batch job concurrency via env var
5. Checked traffic — batch endpoint usage elevated after config change
6. Ruled out image change — same image as healthy replicas on other nodes

## Commands Used

```bash
kubectl get pods -l app=spring-support-api
kubectl describe pod spring-support-api-6b4xx
kubectl logs spring-support-api-6b4xx --previous
kubectl top pod -l app=spring-support-api
kubectl get deployment spring-support-api -o yaml | grep -A5 resources
```

## Root Cause

Environment variable change (CHG-004) raised `BATCH_CONCURRENCY` from 2 to 8 without corresponding memory limit increase. Under load, JVM heap exhausted container memory limit, triggering OOMKill and liveness-driven restart loop.

## Resolution

1. Reverted `BATCH_CONCURRENCY` to 2 via ConfigMap patch (emergency change)
2. Deleted failing pod to force clean restart with corrected config
3. All replicas reached `Running` with 0 restarts over 45-minute observation
4. Temporarily increased memory limit to 768Mi on one replica for monitoring (documented)
5. Scheduled permanent fix via CHG-005 (health check) and problem record PRB-002

## Prevention

- Memory impact assessment required for concurrency-related env changes
- Add JVM heap vs. container limit dashboard panel
- Separate liveness from readiness for slow-start scenarios (CHG-005)
- Load test config changes in staging before production

## Related Runbook

[runbooks/container-restart.md](../runbooks/container-restart.md)

## Related Problem Record

[problem-records/PRB-002-repeated-container-restarts.md](../problem-records/PRB-002-repeated-container-restarts.md)

## Related Change Record

[changes/CHG-004-update-environment-variable.md](../changes/CHG-004-update-environment-variable.md)
