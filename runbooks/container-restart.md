# Runbook: Container Restart

## Overview

| Field | Value |
|---|---|
| **Symptom** | Container or pod repeatedly restarting (CrashLoopBackOff) |
| **Typical alerts** | `PodRestarting`, `ContainerOOMKilled`, `LivenessProbeFailed` |
| **Priority** | P2 (P1 if no healthy replicas) |
| **Estimated time** | 20–60 min |

## Investigation steps

1. **Count restarts** — `RESTARTS` column or pod events
2. **Read exit reason** — OOMKilled, Error, Completed?
3. **Check last logs before crash** — Stack trace, config error
4. **Review resource limits** — CPU/memory requests and limits
5. **Probe configuration** — Liveness killing slow-starting app?
6. **Recent image or config change** — Correlate timeline

## Commands

```bash
# Docker
docker compose ps
docker inspect spring-support-api --format '{{.State.ExitCode}} {{.State.OOMKilled}}'
docker compose logs --tail=50 spring-support-api

# Kubernetes
kubectl get pods -l app=spring-support-api
kubectl describe pod <pod-name>
kubectl logs <pod-name> --previous
kubectl get events --sort-by='.lastTimestamp'
```

## Resolution paths

| Root cause | Action |
|---|---|
| OOMKilled | Increase memory limit or fix leak; restart |
| Liveness too aggressive | Adjust probe (CHG-005) |
| Bad startup config | Fix env var (CHG-004) or rollback image |
| Dependency not ready | Fix init order / readiness probe |
| Application bug on boot | Rollback deployment |

## Validation

- [ ] Pod/container `Running` with 0 restarts for 30 min
- [ ] Readiness probe passing
- [ ] Traffic served normally

## Related records

- Incident: [../incidents/INC-003-container-restart-loop.md](../incidents/INC-003-container-restart-loop.md)
- Problem: [../problem-records/PRB-002-repeated-container-restarts.md](../problem-records/PRB-002-repeated-container-restarts.md)
- Change: [../changes/CHG-005-improve-health-check.md](../changes/CHG-005-improve-health-check.md)
