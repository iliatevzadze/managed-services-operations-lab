# Runbook: Failed Deployment

## Overview

| Field | Value |
|---|---|
| **Symptom** | Deployment fails or new revision unhealthy after release |
| **Typical alerts** | `DeploymentFailed`, `RolloutStuck`, post-deploy error spike |
| **Priority** | P1–P2 |
| **Estimated time** | 15–45 min |

## Investigation steps

1. **Identify deployment time** — Correlate with incident start
2. **Check rollout status** — Progressing? Replica failures?
3. **Compare old vs. new pods** — Only new revision failing?
4. **Review CI/CD output** — Tests passed? Image tag correct?
5. **Check application logs on new pods** — Startup errors?
6. **Decide: fix forward vs. rollback** — Default to rollback under customer impact

## Commands

```bash
# Kubernetes rollout
kubectl rollout status deployment/spring-support-api
kubectl get rs -l app=spring-support-api
kubectl describe deployment spring-support-api

# Docker Compose (local)
docker compose pull spring-support-api
docker compose up -d spring-support-api
docker compose logs -f spring-support-api
```

## Resolution paths

| Situation | Action |
|---|---|
| Customer impact ongoing | **Rollback immediately** (CHG-003, kubernetes-rollback) |
| Stuck rollout, no traffic on bad revision | Pause rollout; investigate |
| Config-only failure | Revert ConfigMap/secret change |
| Image pull failure | Fix registry auth or tag; redeploy previous |

## Validation

- [ ] Rollout complete on known-good revision
- [ ] Health checks passing on all replicas
- [ ] Error rate and latency at baseline
- [ ] Change record updated with result

## Related records

- Change: [../changes/CHG-003-rollback-bad-release.md](../changes/CHG-003-rollback-bad-release.md)
- Runbook: [kubernetes-rollback.md](kubernetes-rollback.md)
- Incident: [../incidents/INC-002-application-500-errors.md](../incidents/INC-002-application-500-errors.md)
