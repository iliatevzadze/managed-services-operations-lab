# Architecture Overview

## High-level design

The lab simulates a typical managed services stack: containerized application, relational database, reverse proxy, and observability layer.

```
Clients → Nginx → spring-support-api → PostgreSQL
                      ↓
              Prometheus / Grafana / Alertmanager
```

## Docker Compose architecture (Milestone 2)

The local stack runs as three containers on a shared `msol-net` network. This mirrors a real customer application: a reverse proxy in front, an application tier, and a database with persistent storage.

```
                Host (localhost)
  :18081 ──────────────┐        :18080 ──────────────┐
                       ▼                              ▼
              ┌─────────────────┐           (direct API access
              │   msol-nginx    │            for troubleshooting)
              │  nginx:1.27     │                     │
              └────────┬────────┘                     │
                       │ proxy_pass                    │
                       ▼                               ▼
              ┌──────────────────────────────────────────┐
              │           msol-support-api               │
              │     Spring Boot 3.5 (Java 21) :8080      │
              │     health check: GET /health            │
              └────────────────────┬─────────────────────┘
                                   │ JDBC
                                   ▼
              ┌──────────────────────────────────────────┐
              │              msol-postgres               │
              │     postgres:16-alpine :5432             │
              │     health check: pg_isready             │
              │     volume: msol-postgres-data           │
              │     host access: localhost:15434         │
              └──────────────────────────────────────────┘
```

Host port mappings: Nginx `localhost:18081` → `80`, API `localhost:18080` → `8080`, PostgreSQL `localhost:15434` → `5432`. Container-internal ports are unchanged.

**Request flow:** A client calls Nginx on `localhost:18081`. Nginx proxies to `spring-support-api:8080`, adding `Host`, `X-Real-IP`, `X-Forwarded-For`, and `X-Forwarded-Proto` headers. The API serves the request, querying PostgreSQL over JDBC at `postgres:5432`.

**Operational notes (Managed Services relevance):**

- **Startup ordering:** the API `depends_on` PostgreSQL passing its `pg_isready` health check, preventing connection-refused errors on boot.
- **Direct vs. proxied access:** host port `18080` exposes the API directly for 2nd-level troubleshooting; host port `18081` represents the customer-facing path through Nginx. Comparing the two isolates whether a fault is in the app or the proxy.
- **Persistence:** the named volume `msol-postgres-data` survives `docker compose down`, so data is retained between restarts unless explicitly removed with `-v`.
- **Health checks:** each tier reports health, supporting the detect → investigate workflow.

## Monitoring architecture (Milestone 3)

A local monitoring stack provides **proactive customer application visibility** plus host and container metrics, so 2nd-level support can investigate before issues become outages.

```
   ┌──────────────┐   ┌───────────────┐   ┌──────────────┐
   │ spring-      │   │ node-exporter │   │   cadvisor   │
   │ support-api  │   │ (host metrics)│   │ (container   │
   │ /actuator/   │   │   :9100       │   │  metrics)    │
   │ prometheus   │   │               │   │   :8080      │
   └──────┬───────┘   └───────┬───────┘   └──────┬───────┘
          │ scrape            │ scrape           │ scrape
          └───────────────────┼──────────────────┘
                              ▼
                    ┌───────────────────┐
                    │    msol-prometheus │  stores time series
                    │       :9090        │  (volume: msol-prometheus-data)
                    └─────────┬─────────-┘
              query           │            alerts (M4)
        ┌───────────────────-─┤                 │
        ▼                     │                 ▼
┌───────────────┐            │        ┌────────────────────┐
│  msol-grafana │            │        │ msol-alertmanager  │
│    :3000      │◄───────────┘        │      :9093         │
│ (dashboards   │  visualizes         │ placeholder        │
│   in M4)      │  Prometheus data    │ receiver (M4 rules)│
└───────────────┘                     └────────────────────┘
```

**Monitoring flow:**

- **Prometheus scrapes** the customer application (`spring-support-api:8080/actuator/prometheus`), the host via **Node Exporter** (`node-exporter:9100`), and containers via **cAdvisor** (`cadvisor:8080`), plus itself.
- **Grafana visualizes** Prometheus data (dashboards delivered in Milestone 4).
- **Alertmanager** is wired as a Prometheus target and **will receive future alerts**; in Milestone 3 it runs a local placeholder receiver with no alert rules yet.

**Why this matters for Managed Services:** separating application, host, and container signals lets the engineer quickly tell whether a customer-impacting symptom comes from the app, the machine, or a specific container — the foundation of reliable service operation. Host monitoring port mappings: Prometheus `19090→9090`, Grafana `13003→3000`, Alertmanager `19093→9093`, cAdvisor `18084→8080`, Node Exporter `19100→9100`. Container-internal ports are unchanged.

## Components

### spring-support-api

- **Role:** Primary application under support — customer support ticket API for incident simulation
- **Location:** `app/spring-support-api/`
- **Runtime:** Java 21, Spring Boot 3.5.15, Maven
- **Persistence:** Spring Data JPA + Flyway migrations on PostgreSQL
- **API surface:** `GET /health`, `GET /tickets`, `GET /tickets/{id}`, `POST /tickets`
- **Observability hooks:** Spring Actuator, Micrometer Prometheus registry, scraped by Prometheus at `/actuator/prometheus` (Milestone 3)
- **Failure domains:** Application errors, memory pressure, misconfiguration, bad deployments, database connectivity

### PostgreSQL

- **Role:** System of record for support portal data
- **Failure domains:** Connection exhaustion, disk full, slow queries, backup failures

### Nginx

- **Role:** Reverse proxy and customer entry point; routing, proxy headers, upstream timeouts
- **Config:** `docker/nginx/default.conf` — proxies `/` to `spring-support-api:8080`
- **Local ports:** `localhost:18081` → container port `80`
- **Failure domains:** Misconfigured upstream, certificate expiry, timeout mismatches

### Observability stack

| Component | Function |
|---|---|
| Prometheus | Metrics scrape and storage |
| Grafana | Dashboards and visualization |
| Alertmanager | Alert routing, grouping, silencing |

## Data flow

1. Client request hits Nginx on port 443 (or 18081 locally).
2. Nginx forwards to healthy application instances.
3. Application executes business logic and queries PostgreSQL.
4. Application exposes `/health` (operations) and `/actuator/prometheus` (metrics).
5. Prometheus scrapes metrics (Milestone 3); Alertmanager fires on threshold breach once rules are added (Milestone 4).

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
