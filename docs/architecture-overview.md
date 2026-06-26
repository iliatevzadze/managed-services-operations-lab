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

- **Role:** Primary application under support
- **Runtime:** JVM / Spring Boot (Milestone 1+)
- **Failure domains:** Application errors, memory pressure, misconfiguration, bad deployments

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
4. Application exposes `/actuator/prometheus` for metrics (planned).
5. Prometheus scrapes metrics; Alertmanager fires on threshold breach.

## Environment model

| Environment | Purpose |
|---|---|
| Local (Docker Compose) | Development and incident drill |
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
