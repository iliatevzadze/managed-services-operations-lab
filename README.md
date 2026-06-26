# Managed Services Operations Lab — Exxeta-Focused 2nd Level Support Simulation

[![Java CI](https://github.com/USERNAME/managed-services-operations-lab/actions/workflows/java-ci.yml/badge.svg)](https://github.com/USERNAME/managed-services-operations-lab/actions/workflows/java-ci.yml)
[![Docker Compose CI](https://github.com/USERNAME/managed-services-operations-lab/actions/workflows/docker-compose-ci.yml/badge.svg)](https://github.com/USERNAME/managed-services-operations-lab/actions/workflows/docker-compose-ci.yml)
[![Kubernetes Manifests CI](https://github.com/USERNAME/managed-services-operations-lab/actions/workflows/k8s-ci.yml/badge.svg)](https://github.com/USERNAME/managed-services-operations-lab/actions/workflows/k8s-ci.yml)

> Replace `USERNAME` in the badge URLs with your GitHub username/org after pushing.

A **local portfolio lab** that demonstrates 2nd-level **Managed Services support operations**: monitoring-driven incident response, PostgreSQL troubleshooting with evidence, ITSM documentation (incidents, problems, changes), Kubernetes deploy/rollback basics, and CI/CD validation — all runnable on a laptop without cloud accounts or paid services. Built to show hiring managers I can operate a production-like customer platform with discipline, traceability, and customer-impact awareness.

**New reviewer?** Start with [docs/reviewer-guide.md](docs/reviewer-guide.md) (~10 minutes).

---

## Exxeta positioning

Aligned with **Exxeta's Support Operations Engineer — Managed Services** role (Tbilisi, Hybrid). This is not a generic DevOps demo — it mirrors how a 2nd-level engineer keeps a contracted customer platform stable under SLA pressure.

| Role expectation | Evidence in this repo |
|---|---|
| 2nd-level incident handling | INC-001–003 drills, runbooks, timestamped investigation steps |
| Monitoring and alerting | Prometheus rules, Grafana dashboard, `support_api_database_up` metric |
| Linux / container operations | Docker Compose stack, restart and deployment runbooks |
| SQL / database troubleshooting | EXPLAIN ANALYZE workflow, index fix, before/after evidence |
| Kubernetes familiarity | kind manifests, deploy/rollback scripts, health probes |
| ITIL-aligned operations | [ITSM artifact map](docs/itsm-artifact-map.md), process guides (M7) |
| Change discipline | CHG-001–005 with rollback and validation plans |
| CI validation | GitHub Actions + [local CI script](scripts/ci/local-ci-check.sh) |

---

## Quick start

```bash
git clone <repo-url> && cd managed-services-operations-lab

# Full stack (app + monitoring)
docker compose up -d --build
curl -s http://localhost:18081/health | jq .

# Optional: local CI (same gates as GitHub Actions)
./scripts/ci/local-ci-check.sh
```

**Prerequisites:** Docker + Docker Compose. For Kubernetes extension: [kind](https://kind.sigs.k8s.io/) + kubectl. For tests only: Java 21 + Maven.

Full setup: [docs/local-setup-guide.md](docs/local-setup-guide.md) · Validation: [docs/final-validation-checklist.md](docs/final-validation-checklist.md)

---

## Architecture overview

```
Clients → Nginx (:18081) → spring-support-api (:8080) → PostgreSQL (:5432)
                                    ↓
              Prometheus → Grafana / Alertmanager (metrics + alerts)
```

| Layer | Technology | Purpose |
|---|---|---|
| Application | Java 21, Spring Boot 3.5 | Customer support ticket API |
| Database | PostgreSQL 16 | Persistence, slow-query scenarios |
| Proxy | Nginx | Customer entry point, fault isolation |
| Containers | Docker Compose | Full local stack + monitoring |
| Orchestration | Kubernetes (kind) | Deploy/rollback pattern (M8) |
| Observability | Prometheus, Grafana, Alertmanager | Alert-driven incident response |
| CI | GitHub Actions | Tests, image build, manifest validation |

Docker Compose is the **primary environment** (monitoring included). Kubernetes on kind is a **local extension** for deployment/runtime support. Detail: [docs/architecture-overview.md](docs/architecture-overview.md).

---

## Local ports

| Service | Host port | URL / access |
|---|---|---|
| API (direct) | 18080 | http://localhost:18080/health |
| Nginx (customer path) | 18081 | http://localhost:18081/health |
| PostgreSQL | 15434 | `localhost:15434` |
| Prometheus | 19090 | http://localhost:19090 |
| Grafana | 13003 | http://localhost:13003 (`admin` / `admin`) |
| Alertmanager | 19093 | http://localhost:19093 |
| cAdvisor | 18084 | http://localhost:18084 |
| Node Exporter | 19100 | http://localhost:19100/metrics |
| Kubernetes API (kind) | 18082 | http://localhost:18082/health |

---

## Completed milestones (M0–M10)

| Milestone | Scope | Status |
|---|---|---|
| M0 | Repository foundation, docs, record skeletons | ✅ |
| M1 | Spring Boot API, Flyway, tests | ✅ |
| M2 | Docker Compose: Nginx → API → PostgreSQL | ✅ |
| M3 | Monitoring: Prometheus, Grafana, exporters | ✅ |
| M4 | Alert rules, Grafana dashboard, DB health metric | ✅ |
| M5 | Incident simulations INC-001–003 + drill scripts | ✅ |
| M6 | SQL troubleshooting: EXPLAIN, index fix, evidence | ✅ |
| M7 | ITSM documentation: artifact map, process guides | ✅ |
| M8 | Local Kubernetes (kind): deploy, safe rollback | ✅ |
| M9 | CI/CD: Java, Docker, kubeconform manifest validation | ✅ |
| M10 | GitHub/portfolio polish: reviewer guide, resume bullets | ✅ |

---

## Screenshots (add after running locally)

> Place captured screenshots in `docs/screenshots/` and uncomment the links below.

| View | Placeholder |
|---|---|
| Grafana — Managed Services Operations Overview | `<!-- ![Grafana dashboard](docs/screenshots/grafana-overview.png) -->` |
| Prometheus — targets and alerts | `<!-- ![Prometheus targets](docs/screenshots/prometheus-targets.png) -->` |
| Health endpoint — UP / database UP | `<!-- ![Health check](docs/screenshots/health-up.png) -->` |

---

## ITSM / Managed Services documentation

Cross-linked incident, problem, and change management — employer-facing and mapped to ServiceNow/Jira/Confluence.

| Document | Description |
|---|---|
| [docs/itsm-artifact-map.md](docs/itsm-artifact-map.md) | Fast map of all ITSM artifacts |
| [docs/incident-management-process.md](docs/incident-management-process.md) | Lifecycle, triage, ServiceNow mapping |
| [docs/problem-management-process.md](docs/problem-management-process.md) | RCA, permanent fix, Jira mapping |
| [docs/change-management-process.md](docs/change-management-process.md) | Standard / Normal / Emergency changes |
| [docs/sla-priority-matrix.md](docs/sla-priority-matrix.md) | P1–P4 (lab-defined targets) |
| [docs/escalation-model.md](docs/escalation-model.md) | L1/L2/L3, evidence before escalation |

Records: [incidents/](incidents/) · [problem-records/](problem-records/) · [changes/](changes/) · [runbooks/](runbooks/)

---

## Incident simulation (Milestone 5)

Controlled drills: detect via Prometheus → investigate with runbook → restore → document.

**Prerequisites:** `docker compose up -d --build`

| Drill | Simulate | Restore | Alert |
|---|---|---|---|
| Database down | `simulate-database-down.sh` | `restore-database-down.sh` | `SupportApiDatabaseDown` |
| HTTP 500 | `simulate-http-500.sh` | Wait for rate decay | `SupportApiHighErrorRate` |
| Bad env / restart | `simulate-bad-env-restart-loop.sh` | `restore-bad-env-restart-loop.sh` | Unhealthy container |

Scripts: [scripts/incidents/](scripts/incidents/) · Records: [INC-001](incidents/INC-001-database-down.md), [INC-002](incidents/INC-002-application-500-errors.md), [INC-003](incidents/INC-003-container-restart-loop.md)

---

## SQL troubleshooting (Milestone 6)

Slow ticket history search on ~100k rows — investigate, index, validate with committed evidence.

```bash
./scripts/sql/run-slow-query-investigation.sh
```

| Phase | Plan | Execution time |
|---|---|---|
| **Before** index | Seq Scan on `support_ticket_events` | **~7 ms** |
| **After** index | Bitmap Index Scan on composite index | **~0.6 ms** |

Evidence: `database/sql-troubleshooting/evidence/before-index-explain.txt` · `after-index-explain.txt`  
Related: [PRB-001](problem-records/PRB-001-recurring-database-timeout.md) · [CHG-001](changes/CHG-001-add-sql-index.md)

---

## Local Kubernetes extension (Milestone 8)

kind cluster for deploy/rollback pattern — **no cloud, no Helm**. Docker Compose remains the monitoring environment.

```bash
./scripts/k8s/deploy-kind.sh
curl -s http://localhost:18082/health
./scripts/k8s/rollback-support-api.sh   # needs ≥2 revisions
./scripts/k8s/delete-kind.sh
```

Guide: [k8s/README.md](k8s/README.md) · Rollback: [runbooks/kubernetes-rollback.md](runbooks/kubernetes-rollback.md)

---

## CI/CD validation (Milestone 9)

Validation gates on every push/PR — no deploy, no registry push, no secrets.

| Workflow | Validates |
|---|---|
| [Java CI](.github/workflows/java-ci.yml) | `mvn test` + `mvn package` (Java 21) |
| [Docker Compose CI](.github/workflows/docker-compose-ci.yml) | `docker compose config` + image build |
| [Kubernetes Manifests CI](.github/workflows/k8s-ci.yml) | `kubeconform` offline schema check |

```bash
./scripts/ci/local-ci-check.sh
```

Detail: [docs/cicd-guide.md](docs/cicd-guide.md)

---

## Reviewer path (recommended order)

1. **Read this README** — scope, architecture, ports
2. **Run Docker Compose** — `docker compose up -d --build`
3. **Check Grafana/Prometheus** — dashboard + targets UP
4. **Run one incident simulation** — database-down drill + restore
5. **Read ITSM artifact map** — [docs/itsm-artifact-map.md](docs/itsm-artifact-map.md)
6. **Review CI workflows** — [`.github/workflows/`](.github/workflows/)

Guided walkthrough: [docs/reviewer-guide.md](docs/reviewer-guide.md) · Resume bullets: [docs/resume-bullets.md](docs/resume-bullets.md)

---

## Documentation map

| Document | Description |
|---|---|
| [docs/reviewer-guide.md](docs/reviewer-guide.md) | 10-minute reviewer walkthrough |
| [docs/final-validation-checklist.md](docs/final-validation-checklist.md) | Pre-share validation checklist |
| [docs/resume-bullets.md](docs/resume-bullets.md) | CV/LinkedIn bullets |
| [docs/service-overview.md](docs/service-overview.md) | Service context and API |
| [docs/architecture-overview.md](docs/architecture-overview.md) | Components, data flow, CI/CD |
| [docs/local-setup-guide.md](docs/local-setup-guide.md) | Setup by milestone |
| [docs/monitoring-guide.md](docs/monitoring-guide.md) | Metrics, dashboards, alerts |
| [docs/cicd-guide.md](docs/cicd-guide.md) | CI workflows and troubleshooting |
| [docs/aws-azure-mapping.md](docs/aws-azure-mapping.md) | Cloud mapping for hybrid MS |
| [k8s/README.md](k8s/README.md) | kind deploy, rollback, delete |

---

## Resume positioning

**Title:** Managed Services Operations Lab — 2nd Level Support Simulation

**Bullets:** [docs/resume-bullets.md](docs/resume-bullets.md)

**Interview talking points:**

- Walk INC-001: detect → investigate → restore → document
- Explain incident fix vs. problem permanent fix (PRB-001 → CHG-001)
- Rollback vs. hotfix decision (CHG-003)
- Monitoring gap → problem record (PRB-004 → CHG-002)
- Map local Docker concepts to AWS/Azure ([aws-azure-mapping.md](docs/aws-azure-mapping.md))

---

*Portfolio learning project. Not affiliated with or endorsed by Exxeta.*
