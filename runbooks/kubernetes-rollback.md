# Runbook: Kubernetes Rollback

## Overview

| Field | Value |
|---|---|
| **Symptom** | Need to revert deployment to previous known-good revision |
| **Typical triggers** | Failed deployment, post-release 5xx spike, crash loop after release |
| **Priority** | P1–P2 during active incident |
| **Estimated time** | 5–20 min |
| **Environment** | Local kind lab (`managed-services-lab` namespace) — see [k8s/README.md](../k8s/README.md) |

## When to rollback

- Customer impact confirmed after a deployment
- New revision unhealthy and root cause not immediately clear
- Incident commander or 2nd level determines fix-forward risk too high

> **Principle:** Rollback first, root-cause second when users are affected.

> **Prerequisite:** Rollback only works once **at least two deployment revisions
> exist** — i.e. after at least one newer deployment on top of the original.
> The **first deployment has no previous revision**, so there is nothing to roll
> back to. The rollback script detects this and exits safely with the message
> `No previous revision available. Rollback requires at least two deployment revisions.`

## 1. Deployment status checks

```bash
NS=managed-services-lab

# Pods, restarts, readiness
kubectl -n $NS get pods -o wide

# Deployment and replica status
kubectl -n $NS get deployment spring-support-api

# Watch rollout in progress
kubectl -n $NS rollout status deployment/spring-support-api
```

Look for: `READY 0/1`, `CrashLoopBackOff`, repeated `RESTARTS`, or a rollout
stuck below the desired replica count.

## 2. Logs

```bash
# Application logs (follow)
kubectl -n $NS logs -f deployment/spring-support-api

# Previous container instance (after a crash/restart)
kubectl -n $NS logs deployment/spring-support-api --previous

# Database logs if connectivity is suspected
kubectl -n $NS logs deployment/postgres
```

## 3. Describe pod

```bash
kubectl -n $NS describe pod -l app=spring-support-api
```

Check the **Events** section for: failed readiness/liveness probes, `ImagePullBackOff`,
`OOMKilled`, or scheduling problems. This is the primary evidence source before escalation.

## 4. Rollout history

```bash
# List revisions
kubectl -n $NS rollout history deployment/spring-support-api

# Inspect a specific revision
kubectl -n $NS rollout history deployment/spring-support-api --revision=<N>
```

Identify the last known-good revision from history and/or the change record.
If only **one** revision is listed, there is no previous revision to roll back
to — the deployment has not been updated since it was first created.

## 5. Rollback command

```bash
# Roll back to the previous revision
kubectl -n $NS rollout undo deployment/spring-support-api

# Or roll back to a specific revision
kubectl -n $NS rollout undo deployment/spring-support-api --to-revision=<N>

# Wait for completion
kubectl -n $NS rollout status deployment/spring-support-api --timeout=180s
```

Script shortcut: [`scripts/k8s/rollback-support-api.sh`](../scripts/k8s/rollback-support-api.sh)

## 6. Validation through /health

```bash
# Via the kind port mapping (host)
curl -s http://localhost:18082/health
curl -s http://localhost:18082/tickets

# Or from inside the pod
kubectl -n $NS exec deployment/spring-support-api -- \
  wget -q -O - http://localhost:8080/health
```

Confirm `status: UP` and `database: UP`, pods `READY 1/1`, and no new restarts
for the observation period.

## Post-rollback

- [ ] Hold new deployments until RCA complete
- [ ] Open problem record if defect in release
- [ ] Coordinate with dev on fix and re-release plan
- [ ] Update failed-deployment runbook if new learnings

## Related records

- Change: [../changes/CHG-003-rollback-bad-release.md](../changes/CHG-003-rollback-bad-release.md)
- Runbook: [failed-deployment.md](failed-deployment.md)
- Kubernetes lab: [../k8s/README.md](../k8s/README.md)
