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

## Monitoring architecture (Milestones 3–4)

A local monitoring stack provides **proactive customer application visibility**, host and container metrics, **alert rules for alert-driven incident response**, and a **Grafana operations dashboard** for service reliability.

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
                    │  msol-prometheus  │  scrapes + evaluates rules
                    │      :9090        │  rules: managed-services-alerts.yml
                    └─────────┬─────────┘
              query           │            firing alerts
        ┌─────────────────────┤                 │
        ▼                     │                 ▼
┌───────────────┐            │        ┌────────────────────┐
│ msol-grafana  │            │        │ msol-alertmanager  │
│    :3000      │◄───────────┘        │      :9093         │
│ provisioned   │  visualizes         │ local placeholder  │
│ dashboard:    │  Prometheus data    │ receiver           │
│ MS Ops Overview│                   └────────────────────┘
└───────────────┘
```

**Monitoring flow:**

- **Prometheus scrapes** the customer application (`/actuator/prometheus` including `support_api_database_up`), Node Exporter, cAdvisor, and itself.
- **Prometheus evaluates alert rules** from `monitoring/prometheus/rules/managed-services-alerts.yml` and sends firing alerts to Alertmanager.
- **Grafana visualizes** Prometheus data via auto-provisioned datasource and the **Managed Services Operations Overview** dashboard.
- **Alertmanager** receives alerts; external routing (email/Slack/PagerDuty) is not configured — local placeholder receiver only.

**Grafana provisioning (Milestone 4):**

- Datasource: `monitoring/grafana/provisioning/datasources/prometheus.yml`
- Dashboard loader: `monitoring/grafana/provisioning/dashboards/dashboards.yml`
- Dashboard JSON: `monitoring/grafana/dashboards/managed-services-overview.json`

**Why this matters for Managed Services:** alert rules detect customer-impacting symptoms early; the dashboard gives 2nd-level support a single view of availability, database health, errors, and resource pressure — the foundation for reliable service operation and runbook-driven response.

## Local Kubernetes extension (Milestone 8)

A **local-only** Kubernetes deployment on [kind](https://kind.sigs.k8s.io/) demonstrates the **deployment and runtime support pattern** — Deployments, Services, ConfigMap/Secret, health probes, and `kubectl rollout` rollback — without any cloud account, paid service, or Helm.

> **Docker Compose remains the full monitoring stack** (Prometheus, Grafana, Alertmanager, exporters). Kubernetes does **not** replace it; it adds a focused view of how the same application is deployed, validated, and rolled back on an orchestrator. Monitoring drills stay on Docker Compose.

```
                Host (localhost)
   :18082 ─────────────────────────┐
                                   ▼
              ┌──────────────────────────────────────────┐
              │   kind node (control-plane container)     │
              │   hostPort 18082 → nodePort 30080         │
              │                                           │
              │   namespace: managed-services-lab         │
              │  ┌─────────────────────────────────────┐  │
              │  │ Service spring-support-api (NodePort)│  │
              │  │            :30080 → :8080            │  │
              │  └──────────────────┬──────────────────┘  │
              │                     ▼                      │
              │  ┌─────────────────────────────────────┐  │
              │  │ Deployment spring-support-api        │  │
              │  │  msol/spring-support-api:local       │  │
              │  │  readiness + liveness: GET /health   │  │
              │  │  env: ConfigMap (URL) + Secret (creds)│ │
              │  └──────────────────┬──────────────────┘  │
              │                     │ JDBC (Service DNS)   │
              │                     ▼                      │
              │  ┌─────────────────────────────────────┐  │
              │  │ Service postgres (ClusterIP :5432)   │  │
              │  │ Deployment postgres postgres:16-alpine│ │
              │  │  storage: emptyDir (EPHEMERAL)        │ │
              │  └─────────────────────────────────────┘  │
              └──────────────────────────────────────────┘
```

**Key design choices (Managed Services relevance):**

- **Locally built image, loaded into kind** (`imagePullPolicy: IfNotPresent`) — no registry needed; reviewers run one script.
- **ConfigMap vs. Secret split** — `SPRING_DATASOURCE_URL` is config; credentials are in a Secret, mirroring real environment separation.
- **Health probes** — readiness gates traffic until the app + database are up; liveness restarts a wedged pod, the same `/health` contract used in Docker Compose.
- **NodePort + kind port map** — deterministic host access (`localhost:18082`) without `kubectl port-forward`.
- **emptyDir storage** — intentionally **ephemeral** for a disposable lab; **not production persistence**. Production would use a PVC/StorageClass or managed database. Docker Compose holds the persistent local data.
- **Rollback-first** — `kubectl rollout undo` plus [kubernetes-rollback runbook](../runbooks/kubernetes-rollback.md) demonstrate safe recovery from a bad release.

Manifests: [`k8s/base/`](../k8s/) · Cluster config: [`k8s/kind/cluster-config.yaml`](../k8s/kind/cluster-config.yaml) · Scripts: [`scripts/k8s/`](../scripts/k8s/) · Guide: [`k8s/README.md`](../k8s/README.md)

## Components

### spring-support-api

- **Role:** Primary application under support — customer support ticket API for incident simulation
- **Location:** `app/spring-support-api/`
- **Runtime:** Java 21, Spring Boot 3.5.15, Maven
- **Persistence:** Spring Data JPA + Flyway migrations on PostgreSQL
- **API surface:** `GET /health`, `GET /tickets`, `GET /tickets/{id}`, `POST /tickets`
- **Observability hooks:** Spring Actuator, Micrometer Prometheus registry (`support_api_database_up` gauge), scraped at `/actuator/prometheus`
- **Failure domains:** Application errors, memory pressure, misconfiguration, bad deployments, database connectivity

### PostgreSQL

- **Role:** System of record for support portal data
- **Failure domains:** Connection exhaustion, disk full, slow queries, backup failures
- **Troubleshooting (M6):** `database/sql-troubleshooting/` — EXPLAIN ANALYZE workflow, index evidence, script `scripts/sql/run-slow-query-investigation.sh`
- **Host access:** `localhost:15434` | **Internal:** `postgres:5432`

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
5. Prometheus scrapes metrics and evaluates alert rules (Milestones 3–4); Alertmanager receives firing alerts.

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
