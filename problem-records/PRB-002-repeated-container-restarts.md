# PRB-002 — Repeated Container Restarts

## Problem ID

PRB-002

## Title

Repeated OOMKilled restarts on spring-support-api after configuration changes

## Related Incidents

- [INC-003](../incidents/INC-003-container-restart-loop.md) — OOM after BATCH_CONCURRENCY increase
- INC-010 (planned) — restart after memory limit misconfiguration

## Business Impact

- Intermittent service degradation during restart cycles
- On-call fatigue from repeated pages for same symptom class
- Risk of full outage if multiple replicas OOM simultaneously

## Technical Symptoms

- `OOMKilled` exit reason in pod describe output
- Restart count incrementing on one or more replicas
- JVM heap metrics approaching container memory limit before kill
- Liveness probe failures immediately preceding termination

## Root Cause Analysis

**Pattern:** Configuration changes affecting memory footprint (concurrency, cache size, batch settings) deployed without:

1. Memory impact assessment
2. Staging load validation
3. Alignment between JVM heap settings and container limits

**Root cause:** Operational gap — no mandatory checklist linking env var changes to resource limits and health probe behavior.

**Contributing factor:** Liveness probe does not distinguish slow start from failure (see CHG-005).

## Permanent Fix

1. Implement change checklist: env vars affecting throughput → require memory review
2. Deploy improved health checks per [CHG-005](../changes/CHG-005-improve-health-check.md)
3. Set JVM `-XX:MaxRAMPercentage` explicitly aligned to container limit
4. Document safe concurrency bounds in runbook

## Prevention

- Staging soak test (30 min under load) for resource-affecting changes
- HPA and resource limits reviewed quarterly
- Problem review in monthly ops meeting

## Monitoring Improvement

- Alert when pod memory > 85% of limit for 10 min (warning)
- Alert on restart count delta > 2 in 1 hour
- Dashboard: JVM heap vs. container memory limit overlay

## Related Change Record

- [changes/CHG-004-update-environment-variable.md](../changes/CHG-004-update-environment-variable.md)
- [changes/CHG-005-improve-health-check.md](../changes/CHG-005-improve-health-check.md)
