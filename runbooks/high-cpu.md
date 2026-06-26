# Runbook: High CPU

## Overview

| Field | Value |
|---|---|
| **Symptom** | Sustained high CPU on application container/pod |
| **Typical alerts** | `HighCPUUsage`, `ContainerCPUThrottling` |
| **Priority** | P2 (P1 if causing outage) |
| **Estimated time** | 30–90 min |

## Investigation steps

1. **Confirm alert validity** — Sustained vs. brief spike during deploy?
2. **Identify process** — Application JVM vs. sidecar
3. **Correlate with traffic** — Legitimate load vs. anomaly
4. **Check GC logs** — Memory pressure causing CPU burn?
5. **Review slow queries** — DB wait driving thread buildup?
6. **Inspect thread dump** — Hot loops, blocked threads (escalate to dev if needed)

## Commands

```bash
# Container CPU (Docker)
docker stats --no-stream spring-support-api

# Pod CPU (Kubernetes)
kubectl top pod -l app=spring-support-api

# JVM metrics (if actuator exposed)
curl -s http://localhost:8080/actuator/metrics/jvm.cpu.usage

# Recent traffic
# Prometheus: rate(http_server_requests_seconds_count[5m])
```

## Resolution paths

| Root cause | Action |
|---|---|
| Traffic spike | Scale horizontally; confirm HPA limits |
| Inefficient query | Identify and schedule index change (CHG-001) |
| Memory leak / GC storm | Restart as mitigation; open problem record |
| Wrong alert threshold | Tune monitoring (CHG-002, PRB-004) |
| Infinite loop in new code | Rollback release |

## Validation

- [ ] CPU below threshold for 30 min
- [ ] Latency and error rate normal
- [ ] No OOM or restart events

## Related records

- Problem: [../problem-records/PRB-004-monitoring-gap-alert-threshold.md](../problem-records/PRB-004-monitoring-gap-alert-threshold.md)
- Change: [../changes/CHG-002-adjust-monitoring-threshold.md](../changes/CHG-002-adjust-monitoring-threshold.md)
