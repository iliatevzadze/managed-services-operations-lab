# Managed Services Operations Lab

[![Java CI](https://github.com/iliatevzadze/managed-services-operations-lab/actions/workflows/java-ci.yml/badge.svg)](https://github.com/iliatevzadze/managed-services-operations-lab/actions/workflows/java-ci.yml)
[![Docker Compose CI](https://github.com/iliatevzadze/managed-services-operations-lab/actions/workflows/docker-compose-ci.yml/badge.svg)](https://github.com/iliatevzadze/managed-services-operations-lab/actions/workflows/docker-compose-ci.yml)
[![Kubernetes Manifests CI](https://github.com/iliatevzadze/managed-services-operations-lab/actions/workflows/k8s-ci.yml/badge.svg)](https://github.com/iliatevzadze/managed-services-operations-lab/actions/workflows/k8s-ci.yml)

> Replace `USERNAME` in the badge URLs with your GitHub username/org after pushing.

A local portfolio lab demonstrating my ability to operate and troubleshoot a production-like Managed Services environment. The project covers containerized application support, PostgreSQL troubleshooting, monitoring with Prometheus/Grafana, incident/problem/change management, Kubernetes deployment basics and CI/CD validation — all runnable locally without cloud accounts or paid services.

**New reviewer?** Start with [docs/reviewer-guide.md](docs/reviewer-guide.md) — recommended review path.

---

## Managed Services capabilities demonstrated

| Capability | Evidence in this repo |
|---|---|
| Application support | Spring Boot support API, health checks, logs |
| Database troubleshooting | PostgreSQL, EXPLAIN ANALYZE, index improvement |
| Monitoring | Prometheus, Grafana, Alertmanager, custom metrics |
| Incident response | Controlled outage / 500 / restart-loop drills |
| ITSM process | Incident, problem, change records, SLA matrix, runbooks |
| Containers | Docker Compose, Nginx, PostgreSQL, API container |
| Kubernetes basics | kind deployment, probes, rollback script |
| CI/CD validation | GitHub Actions, Maven tests, Docker build, kubeconform |

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
| Orchestration | Kubernetes (kind) | Deploy/rollback pattern |
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

## Monitoring

Prometheus scrapes the API, exporters, and evaluates alert rules. Grafana visualizes service health, database connectivity, errors, and resource pressure.

| Target | URL |
|---|---|
| Prometheus targets | http://localhost:19090/targets |
| Firing alerts | http://localhost:19090/alerts |
| Grafana dashboard | http://localhost:13003 — **Managed Services Operations Overview** |
| App metrics | http://localhost:18080/actuator/prometheus (`support_api_database_up`) |

**Alert rules (summary):**

| Alert | Severity | Trigger |
|---|---|---|
| SupportApiDown | critical | Application scrape target down |
| SupportApiDatabaseDown | critical | `support_api_database_up == 0` |
| SupportApiHighErrorRate | warning | HTTP 5xx rate > 0 |
| SupportApiHighCpuUsage | warning | CPU > 80% |
| ContainerMemoryHigh | warning | API container memory > 500 MB |

```bash
curl -s http://localhost:19090/-/ready
curl -s 'http://localhost:19090/api/v1/query?query=support_api_database_up' | jq .
```

Detail: [docs/monitoring-guide.md](docs/monitoring-guide.md)

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

## Incident simulation

Controlled drills: detect via Prometheus → investigate with runbook → restore → document.

**Prerequisites:** `docker compose up -d --build`

| Drill | Simulate | Restore | Alert |
|---|---|---|---|
| Database down | `simulate-database-down.sh` | `restore-database-down.sh` | `SupportApiDatabaseDown` |
| HTTP 500 | `simulate-http-500.sh` | Wait for rate decay | `SupportApiHighErrorRate` |
| Bad env / restart | `simulate-bad-env-restart-loop.sh` | `restore-bad-env-restart-loop.sh` | Unhealthy container |

Scripts: [scripts/incidents/](scripts/incidents/) · Records: [INC-001](incidents/INC-001-database-down.md), [INC-002](incidents/INC-002-application-500-errors.md), [INC-003](incidents/INC-003-container-restart-loop.md)

---

## SQL troubleshooting

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

## Local Kubernetes extension

kind cluster for deploy/rollback pattern — **no cloud, no Helm**. Docker Compose remains the monitoring environment.

```bash
./scripts/k8s/deploy-kind.sh
curl -s http://localhost:18082/health
./scripts/k8s/rollback-support-api.sh   # needs ≥2 revisions
./scripts/k8s/delete-kind.sh
```

Guide: [k8s/README.md](k8s/README.md) · Rollback: [runbooks/kubernetes-rollback.md](runbooks/kubernetes-rollback.md)

---

## CI/CD validation

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

Guided review path: [docs/reviewer-guide.md](docs/reviewer-guide.md) · Resume bullets: [docs/resume-bullets.md](docs/resume-bullets.md)

---

## Documentation map

| Document | Description |
|---|---|
| [docs/reviewer-guide.md](docs/reviewer-guide.md) | Reviewer walkthrough |
| [docs/final-validation-checklist.md](docs/final-validation-checklist.md) | Pre-share validation checklist |
| [docs/resume-bullets.md](docs/resume-bullets.md) | CV/LinkedIn bullets |
| [docs/service-overview.md](docs/service-overview.md) | Service context and API |
| [docs/architecture-overview.md](docs/architecture-overview.md) | Components, data flow, CI/CD |
| [docs/local-setup-guide.md](docs/local-setup-guide.md) | Local environment setup |
| [docs/monitoring-guide.md](docs/monitoring-guide.md) | Metrics, dashboards, alerts |
| [docs/cicd-guide.md](docs/cicd-guide.md) | CI workflows and troubleshooting |
| [docs/aws-azure-mapping.md](docs/aws-azure-mapping.md) | Cloud mapping for hybrid MS |
| [k8s/README.md](k8s/README.md) | kind deploy, rollback, delete |
