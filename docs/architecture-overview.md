# Architecture Overview

## High-level design

The lab simulates a typical managed services stack: containerized application, relational database, reverse proxy, and observability layer.

```
Clients → Nginx → spring-support-api → PostgreSQL
                      ↓
              Prometheus / Grafana / Alertmanager
```

## Components

### spring-support-api

- **Role:** Primary application under support — customer support ticket API for incident simulation
- **Location:** `app/spring-support-api/`
- **Runtime:** Java 21, Spring Boot 3.5.15, Maven
- **Persistence:** Spring Data JPA + Flyway migrations on PostgreSQL
- **API surface:** `GET /health`, `GET /tickets`, `GET /tickets/{id}`, `POST /tickets`
- **Observability hooks:** Spring Actuator, Micrometer Prometheus registry (endpoints ready; scrape config in Milestone 3)
- **Failure domains:** Application errors, memory pressure, misconfiguration, bad deployments, database connectivity

### PostgreSQL

- **Role:** System of record for support portal data
- **Failure domains:** Connection exhaustion, disk full, slow queries, backup failures

### Nginx

- **Role:** TLS termination, routing, upstream health checks
- **Failure domains:** Misconfigured upstream, certificate expiry, timeout mismatches

### Observability stack

| Component | Function |
|---|---|
| Prometheus | Metrics scrape and storage |
| Grafana | Dashboards and visualization |
| Alertmanager | Alert routing, grouping, silencing |

## Data flow

1. Client request hits Nginx on port 443 (or 8080 locally).
2. Nginx forwards to healthy application instances.
3. Application executes business logic and queries PostgreSQL.
4. Application exposes `/health` (operations) and `/actuator/prometheus` (metrics).
5. Prometheus scrapes metrics; Alertmanager fires on threshold breach (Milestone 3+).

## Environment model

| Environment | Purpose |
|---|---|
| Local (Maven + PostgreSQL) | API development and testing (Milestone 1) |
| Local (Docker Compose) | Full stack incident drill (Milestone 2+) |
| Staging (Kubernetes) | Pre-production validation |
| Production (Kubernetes) | Customer-facing (simulated) |

## Failure domain summary

| Domain | Typical symptoms | Primary runbooks |
|---|---|---|
| Database | Connection errors, timeouts | database-down, slow-sql-query, backup-and-restore |
| Application | HTTP 5xx, elevated latency | application-500-errors, high-cpu |
| Container/platform | CrashLoopBackOff, OOMKilled | container-restart, kubernetes-rollback |
| Deployment | Post-release errors | failed-deployment, kubernetes-rollback |
| Monitoring | Missed or noisy alerts | monitoring-guide, PRB-004 |

## Related documents

- [local-setup-guide.md](local-setup-guide.md)
- [monitoring-guide.md](monitoring-guide.md)
- [aws-azure-mapping.md](aws-azure-mapping.md)
