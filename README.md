# Managed Services Operations Lab — Exxeta-Focused 2nd Level Support Simulation

A portfolio project demonstrating **2nd-level Managed Services support operations thinking**: detect issues, investigate systematically, troubleshoot with evidence, identify root cause, resolve safely, document clearly, prevent recurrence, and improve service quality.

---

## Purpose

This repository simulates the operational reality of a **Support Operations Engineer — Managed Services** role. It is not a generic DevOps showcase. It is a structured lab environment where incidents, problems, changes, monitoring, and runbooks reflect how managed services teams keep customer platforms stable under SLA pressure.

The goal is to show hiring managers and technical interviewers that I can operate production-like services with discipline, traceability, and customer impact awareness.

---

## Why this project exists

Managed Services support is judged on outcomes, not tool familiarity alone. Employers need engineers who can:

- Respond to alerts without guessing
- Separate symptoms from root cause
- Restore service quickly and safely
- Escalate at the right time with the right context
- Leave behind documentation that helps the next engineer

This project exists to make that workflow visible and repeatable in a GitHub portfolio.

---

## Exxeta role alignment

This lab is intentionally aligned with **Exxeta's Support Operations Engineer — Managed Services** role (Tbilisi, Hybrid). The project reflects responsibilities commonly expected in that position:

| Role expectation | How this project demonstrates it |
|---|---|
| 2nd-level incident handling | Documented incidents with investigation steps, commands, and resolution |
| Monitoring and alerting | Prometheus, Grafana, Alertmanager structure and monitoring guides |
| Linux and container operations | Docker Compose lab, container restart and deployment runbooks |
| SQL and database troubleshooting | Database-down and slow-query runbooks, backup/restore procedures |
| Cloud platform familiarity | AWS/Azure mapping document for hybrid managed services context |
| ITIL-aligned operations | Incident, problem, and change records with cross-references |
| Clear communication | Runbooks, escalation model, and employer-facing documentation |

---

## Managed Services scenario

**Customer context:** A B2B SaaS platform ("Support Portal API") runs on containers behind a reverse proxy, backed by PostgreSQL, monitored by Prometheus/Grafana, and deployed to Kubernetes in higher environments.

**Support model:** 1st level triages and gathers initial data. **2nd level** (this project's focus) investigates, troubleshoots, implements safe fixes or coordinates changes, validates recovery, and drives problem/change follow-up.

**Operating principles:**

1. **Detect** — Alert or ticket indicates abnormal behavior
2. **Investigate** — Gather logs, metrics, and recent changes
3. **Troubleshoot** — Narrow scope with evidence, not assumptions
4. **Identify root cause** — Distinguish trigger from underlying failure
5. **Resolve safely** — Minimize blast radius; prefer rollback when uncertain
6. **Document clearly** — Incident record, runbook updates, handover notes
7. **Prevent recurrence** — Problem record, permanent fix, monitoring improvement
8. **Improve service quality** — Change management and service improvement plan

---

## Architecture overview

```
                    ┌─────────────┐
                    │   Clients   │
                    └──────┬──────┘
                           │
                    ┌──────▼──────┐
                    │    Nginx    │  Reverse proxy / TLS
                    └──────┬──────┘
                           │
              ┌────────────▼────────────┐
              │   spring-support-api    │  Spring Boot 3.5 — ticket API (M1)
              └────────────┬────────────┘
                           │
              ┌────────────▼────────────┐
              │      PostgreSQL         │  Primary datastore
              └─────────────────────────┘

   ┌──────────────────────────────────────────────────┐
   │  Observability: Prometheus → Grafana             │
   │                 Alertmanager → on-call / ticket  │
   └──────────────────────────────────────────────────┘
```

Local lab runs via Docker Compose. Kubernetes manifests support staging/production-style scenarios in later milestones.

See [docs/architecture-overview.md](docs/architecture-overview.md) for detail.

---

## Technology stack

| Layer | Technology | Role in lab |
|---|---|---|
| Application | Java, Spring Boot | Simulated customer API with realistic failure modes |
| Database | PostgreSQL | Persistence, query performance scenarios |
| Proxy | Nginx | Routing, health checks, upstream failures |
| Containers | Docker, Docker Compose | Local multi-service environment |
| Orchestration | Kubernetes | Deployment, rollback, and pod restart scenarios |
| Monitoring | Prometheus, Grafana, Alertmanager | Metrics, dashboards, alert routing |
| Operations | Bash, SQL, Git | Investigation commands and versioned ops artifacts |
| Cloud mapping | AWS / Azure concepts | Hybrid managed services context |

---

## What this project demonstrates

- **Incident management** — Structured records with priority, impact, investigation, and resolution
- **Problem management** — Root cause analysis and permanent fixes for recurring issues
- **Change management** — Risk-assessed changes with rollback and validation plans
- **Runbook-driven response** — Repeatable procedures for common failure modes
- **Monitoring literacy** — Alert thresholds, dashboards, and gap identification
- **Database operations** — Backup, restore, and query troubleshooting
- **Safe operational judgment** — Rollback over risky fixes; evidence before action
- **Documentation discipline** — Cross-linked incidents, problems, changes, and runbooks

---

## Local setup

> **Milestone 2:** The full stack (Nginx → Spring Boot API → PostgreSQL) runs locally via Docker Compose.

**Prerequisites:** Docker + Docker Compose (full stack), or Java 21 + Maven 3.9+ (API tests only).

### Run the stack (Docker Compose)

```bash
docker compose up -d --build
docker compose ps
```

**Service URLs:**

| Target | URL |
|---|---|
| API direct (troubleshooting) | http://localhost:18080/health |
| Nginx proxy (customer entry point) | http://localhost:18081/health |
| Tickets via proxy | http://localhost:18081/tickets |
| PostgreSQL host access | localhost:15434 |

**Monitoring URLs (Milestone 3–4):**

| Target | URL | Notes |
|---|---|---|
| Prometheus | http://localhost:19090 | Targets (`/targets`), alerts (`/alerts`), rules |
| Grafana | http://localhost:13003 | Login `admin` / `admin`; dashboard in **Managed Services** folder |
| Alertmanager | http://localhost:19093 | Receives alerts from Prometheus |
| Node Exporter | http://localhost:19100/metrics | Host metrics |
| cAdvisor | http://localhost:18084 | Container metrics |
| App metrics endpoint | http://localhost:18080/actuator/prometheus | Includes `support_api_database_up` |

**Grafana dashboard:** Managed Services Operations Overview — http://localhost:13003 (Dashboards → Managed Services)

**Alert rules (summary):**

| Alert | Severity | Trigger |
|---|---|---|
| SupportApiDown | critical | Application scrape target down |
| SupportApiDatabaseDown | critical | `support_api_database_up == 0` |
| SupportApiHighErrorRate | warning | HTTP 5xx rate > 0 |
| SupportApiHighCpuUsage | warning | CPU > 80% |
| ContainerMemoryHigh | warning | API container memory > 500 MB |
| NodeExporterDown / CadvisorDown | warning | Metrics collector unavailable |

**Verify monitoring (Milestone 4):**

```bash
docker compose up -d --build
docker compose ps
curl -s http://localhost:19090/-/ready
curl -s http://localhost:19090/api/v1/rules | jq '.data.groups[].name'    # managed-services-alerts
curl -s 'http://localhost:19090/api/v1/query?query=support_api_database_up' | jq .
docker compose exec prometheus promtool check rules /etc/prometheus/rules/managed-services-alerts.yml
# Open http://localhost:19090/targets — all jobs UP
# Open http://localhost:13003 — Managed Services Operations Overview dashboard
```

**Stop the stack:**

```bash
docker compose down       # keep data volumes
docker compose down -v    # remove data volumes (postgres, prometheus, grafana)
```

### Validate the API without Docker (Milestone 1)

```bash
cd app/spring-support-api
mvn test
```

`mvn test` uses H2 in PostgreSQL compatibility mode (`application-test.properties`) and does **not** require Docker or PostgreSQL.

See [docs/local-setup-guide.md](docs/local-setup-guide.md) for details.

---

## Simulated incidents (Milestone 5)

Controlled drills demonstrate **alert-driven 2nd-level incident response**: detect via Prometheus, investigate with runbooks, restore safely, document in incident records.

**Prerequisites:** full stack running (`docker compose up -d --build`)

| Drill | Simulate | Restore | Expected alert |
|---|---|---|---|
| Database down | `./scripts/incidents/simulate-database-down.sh` | `./scripts/incidents/restore-database-down.sh` | `SupportApiDatabaseDown` |
| HTTP 500 errors | `./scripts/incidents/simulate-http-500.sh` | Stop requests; wait for rate decay | `SupportApiHighErrorRate` |
| Bad env / restart loop | `./scripts/incidents/simulate-bad-env-restart-loop.sh` | `./scripts/incidents/restore-bad-env-restart-loop.sh` | `SupportApiDatabaseDown`, unhealthy container |

Documented incidents: [incidents/INC-001-database-down.md](incidents/INC-001-database-down.md), [INC-002](incidents/INC-002-application-500-errors.md), [INC-003](incidents/INC-003-container-restart-loop.md)

Verify alerts during drill: http://localhost:19090/alerts

---

## SQL troubleshooting (Milestone 6)

2nd-level support workflow for **slow ticket history search** — investigate with evidence, apply index fix, validate improvement.

```bash
docker compose up -d
./scripts/sql/run-slow-query-investigation.sh
```

**Evidence files (portfolio):**

| Phase | File |
|---|---|
| Before index | `database/sql-troubleshooting/evidence/before-index-explain.txt` |
| After index | `database/sql-troubleshooting/evidence/after-index-explain.txt` |

Related: [PRB-001](problem-records/PRB-001-recurring-database-timeout.md), [CHG-001](changes/CHG-001-add-sql-index.md), [runbooks/slow-sql-query.md](runbooks/slow-sql-query.md)

---

## Planned incident simulations

| ID | Scenario | Status |
|---|---|---|
| INC-001 | Database unavailable | **Drill available (M5)** |
| INC-002 | Application HTTP 500 errors | **Drill available (M5)** |
| INC-003 | Container restart loop / bad config | **Drill available (M5)** |
| INC-004 | High CPU on application pod | Planned (M6+) |
| INC-005 | Slow SQL query degrading API | **Investigation available (M6)** |
| INC-006 | Failed deployment | Partially covered by INC-003 drill |
| INC-007 | Monitoring alert threshold gap | Documented (PRB-004) |
| INC-008 | Backup failure before maintenance | Documented |

Example incident records: [incidents/](incidents/)

---

## Documentation map

| Document | Description |
|---|---|
| [docs/service-overview.md](docs/service-overview.md) | Service context, stakeholders, and SLA framing |
| [docs/architecture-overview.md](docs/architecture-overview.md) | Components, data flow, and failure domains |
| [docs/local-setup-guide.md](docs/local-setup-guide.md) | Environment setup by milestone |
| [docs/monitoring-guide.md](docs/monitoring-guide.md) | Metrics, dashboards, and alerting approach |
| [docs/sla-priority-matrix.md](docs/sla-priority-matrix.md) | Priority definitions and response expectations |
| [docs/escalation-model.md](docs/escalation-model.md) | When and how to escalate |
| [docs/incident-management-process.md](docs/incident-management-process.md) | Incident lifecycle |
| [docs/problem-management-process.md](docs/problem-management-process.md) | Problem lifecycle and RCA |
| [docs/change-management-process.md](docs/change-management-process.md) | Change types, approval, and validation |
| [docs/backup-restore-guide.md](docs/backup-restore-guide.md) | Backup strategy and restore procedure |
| [docs/service-improvement-plan.md](docs/service-improvement-plan.md) | Continuous improvement backlog |
| [docs/aws-azure-mapping.md](docs/aws-azure-mapping.md) | Cloud service mapping for hybrid MS context |

**Runbooks:** [runbooks/](runbooks/) — Operational procedures for common incidents.

**Records:**

- [incidents/](incidents/) — Incident examples and templates
- [problem-records/](problem-records/) — Root cause and permanent fix tracking
- [changes/](changes/) — Change records with rollback plans

---

## Milestone roadmap

| Milestone | Scope | Status |
|---|---|---|
| M0 | Repository foundation, README, documentation and record skeletons | Completed |
| M1 | Spring Boot support API, Flyway schema, seeded tickets, tests | Completed |
| M2 | Docker Compose stack: Nginx → API → PostgreSQL, health checks, backup/restore | Completed |
| **M3** | Monitoring stack: Prometheus, Grafana, Alertmanager, Node Exporter, cAdvisor | Completed |
| **M4** | Prometheus alert rules, Grafana dashboard, `support_api_database_up` metric | Completed |
| **M5** | Controlled incident simulations, drill scripts, documented INC-001–003 | Completed |
| **M6** | SQL troubleshooting: EXPLAIN ANALYZE, index fix, evidence files | **Completed** |
| M7 | Kubernetes manifests, deployment and rollback scenarios | Planned |
| M8 | CI/CD workflows, automated validation | Planned |

---

## Future improvements

- Automated incident scenario injection for repeatable drills
- Synthetic monitoring and SLO-based alerting
- Integration with ticketing workflow (Jira/ServiceNow-style fields)
- On-call rotation simulation and escalation timing metrics
- Expanded cloud-specific runbooks (EKS/AKS, RDS/Azure Database)
- Post-incident review templates and blameless RCA format

---

## Resume positioning

**Suggested title:** Managed Services Operations Lab — 2nd Level Support Simulation

**One-liner for resume or LinkedIn:**

> Built a production-style operations lab simulating 2nd-level Managed Services support: incident/problem/change management, monitoring-driven troubleshooting, database and container operations, and ITIL-aligned documentation — aligned with enterprise support engineering roles.

**Talking points for interviews:**

- Walk through INC-001 or INC-002: how you detected, investigated, and resolved
- Explain the difference between incident fix and problem permanent fix (PRB-001 → CHG-001)
- Describe when you would rollback vs. hotfix (CHG-003)
- Show how monitoring gaps become problem records (PRB-004 → CHG-002)
- Connect local Docker lab concepts to AWS/Azure managed services (see aws-azure-mapping.md)

---

*This project is a learning and portfolio artifact. It is not affiliated with or endorsed by Exxeta.*
