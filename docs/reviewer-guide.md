# Reviewer Guide — 10-Minute Walkthrough

A fast path for hiring managers and technical reviewers evaluating this portfolio for a **2nd-level Managed Services Support Operations Engineer** role (Exxeta-focused).

## What this project demonstrates

Local **2nd-level Managed Services operations** across:

- Application support (Spring Boot API, health checks, incident drills)
- Monitoring-driven response (Prometheus, Grafana, alert rules)
- Database troubleshooting (EXPLAIN ANALYZE, index fix with before/after evidence)
- ITSM discipline (incidents, problems, changes, runbooks, SLA/escalation)
- Kubernetes basics (kind deploy, rollout rollback)
- CI/CD validation (Java tests, Docker build/config, offline manifest schema check)

Everything runs **locally** — no cloud account, no paid services, no secrets.

## Fastest way to validate (~10 minutes)

### 1. Read the README (2 min)

Start at [../README.md](../README.md) — project summary, architecture, ports, reviewer path.

### 2. Run Docker Compose (2 min)

```bash
docker compose up -d --build
docker compose ps
curl -s http://localhost:18081/health | jq .
```

Expected: `status: UP`, `database: UP`.

### 3. Check monitoring (2 min)

| Check | URL / command |
|---|---|
| Prometheus targets | http://localhost:19090/targets — all jobs UP |
| Firing alerts | http://localhost:19090/alerts — none when healthy |
| Grafana dashboard | http://localhost:13003 — **Managed Services Operations Overview** (`admin` / `admin`) |

```bash
curl -s 'http://localhost:19090/api/v1/query?query=support_api_database_up' | jq .
```

### 4. Run one incident simulation (2 min)

```bash
./scripts/incidents/simulate-database-down.sh
# Confirm alert at http://localhost:19090/alerts
./scripts/incidents/restore-database-down.sh
```

Read the matching record: [INC-001](../incidents/INC-001-database-down.md).

### 5. Review ITSM artifacts (1 min)

Open [itsm-artifact-map.md](itsm-artifact-map.md) — one-page map of incidents, problems, changes, runbooks, and tool mappings.

### 6. Skim CI workflows (1 min)

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

## What maps to Exxeta requirements

| Exxeta expectation | Evidence in this repo |
|---|---|
| 2nd-level incident handling | INC-001–003 drills, runbooks, investigation commands |
| Monitoring and alerting | Prometheus rules, Grafana dashboard, `support_api_database_up` metric |
| Linux / container operations | Docker Compose stack, container restart runbooks |
| SQL / database troubleshooting | M6 workflow, EXPLAIN evidence, PRB-001, CHG-001 |
| Kubernetes familiarity | kind manifests, deploy/rollback scripts |
| ITIL-aligned operations | ITSM process docs, artifact map, cross-linked records |
| Clear documentation | Runbooks, escalation model, this reviewer guide |

## What is intentionally local-only

| Item | Why |
|---|---|
| Docker Compose lab | Full stack + monitoring without cloud cost |
| kind Kubernetes | Deployment/rollback pattern without EKS/AKS account |
| `emptyDir` Postgres in K8s | Disposable lab storage — not production persistence |
| Lab-defined SLA targets | Portfolio demonstration — not Exxeta's official SLA |
| CI validation only | No registry push, no cloud deploy, no secrets |
| Simulation endpoints | Gated by `SUPPORT_SIMULATION_ENABLED=true` for controlled drills |

## Related documents

- [final-validation-checklist.md](final-validation-checklist.md)
- [itsm-artifact-map.md](itsm-artifact-map.md)
- [resume-bullets.md](resume-bullets.md)
- [cicd-guide.md](cicd-guide.md)
