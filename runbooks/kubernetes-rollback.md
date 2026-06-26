# Runbook: Kubernetes Rollback

## Overview

| Field | Value |
|---|---|
| **Symptom** | Need to revert deployment to previous known-good revision |
| **Typical triggers** | Failed deployment, post-release 5xx spike, crash loop after release |
| **Priority** | P1–P2 during active incident |
| **Estimated time** | 5–20 min |

## When to rollback

- Customer impact confirmed after a deployment
- New revision unhealthy and root cause not immediately clear
- Incident commander or 2nd level determines fix-forward risk too high

> **Principle:** Rollback first, root-cause second when users are affected.

## Rollback steps

1. **Confirm current revision** — `kubectl rollout history`
2. **Identify last good revision** — From history or change record
3. **Execute rollback** — `kubectl rollout undo`
4. **Watch rollout** — `kubectl rollout status`
5. **Validate** — Health, metrics, smoke tests
6. **Document** — Update incident and change record (CHG-003)

## Commands

```bash
# View history
kubectl rollout history deployment/spring-support-api

# Rollback to previous revision
kubectl rollout undo deployment/spring-support-api

# Rollback to specific revision
kubectl rollout undo deployment/spring-support-api --to-revision=<N>

# Monitor
kubectl rollout status deployment/spring-support-api
kubectl get pods -l app=spring-support-api

# Verify application
curl -s https://<host>/actuator/health
```

## Post-rollback

- [ ] Hold new deployments until RCA complete
- [ ] Open problem record if defect in release
- [ ] Coordinate with dev on fix and re-release plan
- [ ] Update failed-deployment runbook if new learnings

## Related records

- Change: [../changes/CHG-003-rollback-bad-release.md](../changes/CHG-003-rollback-bad-release.md)
- Runbook: [failed-deployment.md](failed-deployment.md)
