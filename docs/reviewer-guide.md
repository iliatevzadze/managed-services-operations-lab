# Reviewer Guide — Practical Walkthrough

A quick reviewer path for hiring managers and technical reviewers evaluating this portfolio for **Managed Services / Support Operations** roles.

## What this project demonstrates

Local **2nd-level Managed Services operations** across:

- Application support (Spring Boot API, health checks, incident drills)
- Monitoring-driven response (Prometheus, Grafana, alert rules)
- Database troubleshooting (EXPLAIN ANALYZE, index fix with before/after evidence)
- ITSM discipline (incidents, problems, changes, runbooks, SLA/escalation)
- Kubernetes basics (kind deploy, rollout rollback)
- CI/CD validation (Java tests, Docker build/config, offline manifest schema check)

Everything runs **locally** — no cloud account, no paid services, no secrets.

## Validation path

### 1. Read the README

Start at [../README.md](../README.md) — project summary, architecture, ports, reviewer path.

### 2. Run Docker Compose

```bash
docker compose up -d --build
docker compose ps
curl -s http://localhost:18081/health | jq .
```

Expected: `status: UP`, `database: UP`.

### 3. Check monitoring

| Check | URL / command |
|---|---|
| Prometheus targets | http://localhost:19090/targets — all jobs UP |
| Firing alerts | http://localhost:19090/alerts — none when healthy |
| Grafana dashboard | http://localhost:13003 — **Managed Services Operations Overview** (`admin` / `admin`) |

```bash
curl -s 'http://localhost:19090/api/v1/query?query=support_api_database_up' | jq .
```

### 4. Run one incident simulation

```bash
./scripts/incidents/simulate-database-down.sh
# Confirm alert at http://localhost:19090/alerts
./scripts/incidents/restore-database-down.sh
```

Read the matching record: [INC-001](../incidents/INC-001-database-down.md).

### 5. Review ITSM artifacts

Open [itsm-artifact-map.md](itsm-artifact-map.md) — one-page map of incidents, problems, changes, runbooks, and tool mappings.

### 6. Skim CI workflows

[`.github/workflows/`](../.github/workflows/) — Java CI, Docker Compose CI, Kubernetes Manifests CI (kubeconform, offline).

Optional local equivalent:

```bash
./scripts/ci/local-ci-check.sh
```

## Where to look for evidence

| Topic | Location |
|---|---|
| Incident response | [incidents/](../incidents/), [runbooks/](../runbooks/) |
| Root cause + permanent fix | [problem-records/](../problem-records/) → [changes/](../changes/) |
| SQL performance proof | `database/sql-troubleshooting/evidence/before-index-explain.txt` (Seq Scan ~7 ms) → `after-index-explain.txt` (Bitmap Index Scan ~0.6 ms) |
| Monitoring + alerts | `monitoring/prometheus/rules/managed-services-alerts.yml`, Grafana dashboard JSON |
| Kubernetes deploy/rollback | [k8s/README.md](../k8s/README.md), [runbooks/kubernetes-rollback.md](../runbooks/kubernetes-rollback.md) |
| Process maturity | [incident-management-process.md](incident-management-process.md), [sla-priority-matrix.md](sla-priority-matrix.md) |
| Resume bullets | [resume-bullets.md](resume-bullets.md) |
| Full validation checklist | [final-validation-checklist.md](final-validation-checklist.md) |

## What this demonstrates for Managed Services / Support Operations roles

| Capability | Evidence in this repo |
|---|---|
| Application support | Spring Boot API, health checks, application logs |
| Database troubleshooting | EXPLAIN ANALYZE workflow, index fix, before/after evidence (PRB-001, CHG-001) |
| Monitoring and alerting | Prometheus rules, Grafana dashboard, `support_api_database_up` metric |
| Incident response | INC-001–003 drills, runbooks, investigation commands |
| ITSM process | Incident, problem, change records, SLA matrix, escalation model |
| Container operations | Docker Compose stack, Nginx proxy, restart runbooks |
| Kubernetes basics | kind manifests, deploy/rollback scripts, health probes |
| CI/CD validation | GitHub Actions workflows, local CI script |
| Documentation discipline | Runbooks, artifact map, cross-linked records |

## What is intentionally local-only

| Item | Why |
|---|---|
| Docker Compose lab | Full stack + monitoring without cloud cost |
| kind Kubernetes | Deployment/rollback pattern without EKS/AKS account |
| `emptyDir` Postgres in K8s | Disposable lab storage — not production persistence |
| Lab-defined SLA targets | Portfolio demonstration — not an official customer SLA |
| CI validation only | No registry push, no cloud deploy, no secrets |
| Simulation endpoints | Gated by `SUPPORT_SIMULATION_ENABLED=true` for controlled drills |

## Related documents

- [final-validation-checklist.md](final-validation-checklist.md)
- [itsm-artifact-map.md](itsm-artifact-map.md)
- [resume-bullets.md](resume-bullets.md)
- [cicd-guide.md](cicd-guide.md)
