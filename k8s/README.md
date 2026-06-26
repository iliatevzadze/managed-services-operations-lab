# Local Kubernetes Extension (kind) — Milestone 8

## Purpose

A **local-only** Kubernetes deployment of the Support Portal API, running on
[kind](https://kind.sigs.k8s.io/) (Kubernetes-in-Docker). It demonstrates the
deployment, validation, and **safe rollback** workflow a 2nd-level Managed
Services engineer uses on a Kubernetes platform — without any cloud account,
paid service, or Helm.

> **Docker Compose remains the main environment** for the full monitoring stack
> (Prometheus, Grafana, Alertmanager, exporters). This Kubernetes setup is a
> focused extension showing the **deployment / runtime support pattern**:
> Deployments, Services, ConfigMap/Secret, probes, and `kubectl rollout` rollback.

## What it deploys

| Object | Name | Notes |
|---|---|---|
| Namespace | `managed-services-lab` | All objects live here |
| Secret | `postgres-secret` | DB password + datasource creds (lab only) |
| ConfigMap | `support-api-configmap` | `SPRING_DATASOURCE_URL` |
| Deployment | `postgres` | `postgres:16-alpine`, **emptyDir** (ephemeral) |
| Service | `postgres` | ClusterIP `5432` |
| Deployment | `spring-support-api` | `msol/spring-support-api:local`, readiness + liveness on `/health` |
| Service | `spring-support-api` | NodePort `30080` → host `localhost:18082` |

> **Storage note:** PostgreSQL uses an `emptyDir` volume. Data is **lost** when
> the pod is deleted or rescheduled. This is intentional for a disposable local
> lab and is **not production persistence**. Docker Compose provides the
> persistent local database via a named volume.

## Prerequisites

- **Docker** (running)
- **[kind](https://kind.sigs.k8s.io/docs/user/quick-start/#installation)**
- **kubectl**

## Deploy

```bash
./scripts/k8s/deploy-kind.sh
```

This builds the image, creates the `msol` cluster (if missing), loads the image
into kind, applies `k8s/base/`, and waits for both deployments.

## Verify

```bash
# From the host via the kind port mapping
curl -s http://localhost:18082/health
curl -s http://localhost:18082/tickets

# Cluster view
kubectl -n managed-services-lab get pods,svc
```

Expected: `/health` returns `status: UP` and `database: UP`.

## Troubleshooting (kubectl)

```bash
# Pod status and restarts
kubectl -n managed-services-lab get pods -o wide

# Describe a pod (events, probe failures, image pull issues)
kubectl -n managed-services-lab describe pod -l app=spring-support-api

# Application logs (follow)
kubectl -n managed-services-lab logs -f deployment/spring-support-api

# PostgreSQL logs
kubectl -n managed-services-lab logs deployment/postgres

# Rollout history and current revision
kubectl -n managed-services-lab rollout history deployment/spring-support-api

# Re-check readiness probe target from inside the pod
kubectl -n managed-services-lab exec deployment/spring-support-api -- \
  wget -q -O - http://localhost:8080/health
```

See [../runbooks/kubernetes-rollback.md](../runbooks/kubernetes-rollback.md) for
the full investigation and rollback procedure.

## Rollback

```bash
./scripts/k8s/rollback-support-api.sh
```

Reverts `spring-support-api` to the previous revision and waits for the rollout.

The script fails safe (exits 0) in these cases instead of erroring:

- **Cluster not reachable** (e.g. cluster was deleted) →
  `Kubernetes cluster is not reachable. Run scripts/k8s/deploy-kind.sh first.`
- **Namespace missing** →
  `Namespace managed-services-lab not found. Run scripts/k8s/deploy-kind.sh first.`
- **Only one revision** →
  `No previous revision available. Rollback requires at least two deployment revisions.`

> **Rollback needs at least two revisions.** It only works after at least one
> newer deployment exists on top of the original. The **first deployment has no
> previous revision**.

To create a second revision to roll back from (for a drill):

```bash
kubectl -n managed-services-lab set image deployment/spring-support-api \
  spring-support-api=msol/spring-support-api:local --record=false
# then apply a bad change, observe, and run the rollback script
```

## Delete the cluster

```bash
./scripts/k8s/delete-kind.sh
```

Safe to run even if the cluster does not exist.

## Why this matters for Managed Services

- **Local Kubernetes support** without paid cloud
- **Deployment validation** via rollout status and `/health` probes
- **Safe rollback** with `kubectl rollout undo` and a documented runbook
- **Troubleshooting evidence** through `describe`, `logs`, and `rollout history`
