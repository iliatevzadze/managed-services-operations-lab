# Monitoring Guide

## Objectives

Monitoring in this lab supports **proactive 2nd-level support operations**: detect customer-impacting issues early, give the engineer enough context to investigate, and respond to alerts with runbook discipline.

Milestone 4 adds **Prometheus alert rules** and the first **Grafana dashboard** for alert-driven incident response and service reliability visibility.

## Stack overview

| Component | Container | Host port | Role |
|---|---|---|---|
| Prometheus | `msol-prometheus` | 19090 | Scrapes metrics, evaluates alert rules, sends alerts to Alertmanager |
| Grafana | `msol-grafana` | 13003 | Visualizes Prometheus data; provisioned dashboard |
| Alertmanager | `msol-alertmanager` | 19093 | Receives alerts from Prometheus (local placeholder receiver) |
| Node Exporter | `msol-node-exporter` | 19100 | Host metrics: CPU, memory, disk, network |
| cAdvisor | `msol-cadvisor` | 18084 | Per-container metrics: CPU, memory, restarts |

### What each component gives 2nd-level support

- **Prometheus** — single place to query customer application, host, and container health; evaluates alert rules for proactive detection.
- **Grafana** — operational overview dashboard correlating availability, database health, errors, and resource pressure.
- **Alertmanager** — receives firing alerts from Prometheus; routing to external channels is deferred (no paid integrations).
- **Node Exporter** — answers "is the host itself under pressure?"
- **cAdvisor** — answers "which container is misbehaving?"

## What Prometheus scrapes

| Job | Target | Purpose |
|---|---|---|
| `prometheus` | `localhost:9090` | Self-monitoring |
| `spring-support-api` | `spring-support-api:8080/actuator/prometheus` | Customer application metrics (Micrometer) |
| `node-exporter` | `node-exporter:9100` | Host metrics |
| `cadvisor` | `cadvisor:8080` | Container metrics |

Config: [`../monitoring/prometheus/prometheus.yml`](../monitoring/prometheus/prometheus.yml)  
Alert rules: [`../monitoring/prometheus/rules/managed-services-alerts.yml`](../monitoring/prometheus/rules/managed-services-alerts.yml)  
Alertmanager: [`../monitoring/alertmanager/alertmanager.yml`](../monitoring/alertmanager/alertmanager.yml)

## Custom application metric

| Metric | Values | Purpose |
|---|---|---|
| `support_api_database_up` | `1` = database reachable, `0` = down | Drives `SupportApiDatabaseDown` alert; updated on each `/health` check |

## Grafana dashboard (Milestone 4)

**Title:** Managed Services Operations Overview  
**URL:** http://localhost:13003 → Dashboards → Managed Services folder  
**File:** [`../monitoring/grafana/dashboards/managed-services-overview.json`](../monitoring/grafana/dashboards/managed-services-overview.json)

| Panel | Query | Support value |
|---|---|---|
| Support API Availability | `up{job="spring-support-api"}` | Is the customer app being scraped |
| Database Health | `support_api_database_up` | Database dependency status |
| HTTP Request Count | `sum(rate(http_server_requests_seconds_count{job="spring-support-api"}[2m]))` | Traffic level |
| HTTP 5xx Error Rate | `sum(rate(...,status=~"5.."}[2m]))` | Customer-impacting errors |
| API CPU Usage | `process_cpu_usage{job="spring-support-api"}` | Application CPU pressure |
| API Container Memory | `container_memory_usage_bytes{name=~".*msol-support-api.*"}` | OOM risk |
| Host CPU Usage | `100 - (avg(rate(node_cpu_seconds_total{mode="idle"}[5m])) * 100)` | Host saturation |
| Container Count / Visibility | `count(container_last_seen)` | Container visibility |

### Grafana provisioning

Grafana loads configuration automatically on startup:

- **Datasource:** `monitoring/grafana/provisioning/datasources/prometheus.yml` — Prometheus at `http://prometheus:9090` (default datasource)
- **Dashboards:** `monitoring/grafana/provisioning/dashboards/dashboards.yml` — loads JSON from `/var/lib/grafana/dashboards`

No manual datasource setup is required after `docker compose up`.

## Alert rules (Milestone 4)

Rules file: `monitoring/prometheus/rules/managed-services-alerts.yml`

| Alert | Severity | Condition | Purpose |
|---|---|---|---|
| `SupportApiDown` | critical | `up{job="spring-support-api"} == 0` | Customer application unavailable |
| `SupportApiDatabaseDown` | critical | `support_api_database_up == 0` | App running but database failing |
| `SupportApiHighErrorRate` | warning | 5xx rate > 0 for 2m | HTTP 500 errors |
| `SupportApiHighCpuUsage` | warning | `process_cpu_usage > 0.80` | Application CPU pressure |
| `ContainerMemoryHigh` | warning | API container memory > 500 MB | OOM / restart risk |
| `NodeExporterDown` | warning | `up{job="node-exporter"} == 0` | Host metrics gap |
| `CadvisorDown` | warning | `up{job="cadvisor"} == 0` | Container metrics gap |

Critical alerts include `runbook` labels linking to operational procedures (e.g. `database-down`, `application-500-errors`, `high-cpu`).

View firing alerts: http://localhost:19090/alerts  
View in Alertmanager: http://localhost:19093

## Startup checks

```bash
docker compose up -d --build
docker compose ps
```

Confirm monitoring UIs:

```bash
curl -s http://localhost:19090/-/ready
curl -s http://localhost:19093/-/ready
curl -s -o /dev/null -w "%{http_code}\n" http://localhost:13003/login
```

## Prometheus rules validation

Validate config and rules before or after startup:

```bash
# Using the running Prometheus container
docker compose exec prometheus promtool check config /etc/prometheus/prometheus.yml
docker compose exec prometheus promtool check rules /etc/prometheus/rules/managed-services-alerts.yml
```

Confirm rules are loaded:

```bash
curl -s http://localhost:19090/api/v1/rules | jq '.data.groups[].name'
# Expected: "managed-services-alerts"
```

## Prometheus target check

1. Open http://localhost:19090/targets — all jobs **UP**
2. Open http://localhost:19090/alerts — rules listed (inactive when healthy)
3. Query custom metric:

```bash
curl -s 'http://localhost:19090/api/v1/query?query=support_api_database_up' | jq .
```

## Useful queries

| Query | What it tells a 2nd-level engineer |
|---|---|
| `up` | Which scrape targets are reachable |
| `up{job="spring-support-api"}` | Customer application scrape health |
| `support_api_database_up` | Database dependency for the customer app |
| `http_server_requests_seconds_count` | Request counts per endpoint/status |
| `process_cpu_usage` | Application process CPU |
| `container_memory_usage_bytes` | Per-container memory (cAdvisor) |
| `node_cpu_seconds_total` | Host CPU time by mode |

## Investigation workflow

1. Alert fires in Prometheus / Alertmanager (or anomaly spotted on Grafana dashboard)
2. Confirm scope: app vs. database vs. host vs. container
3. Correlate with recent deployments and changes
4. Follow linked runbook (`runbook` label on critical alerts)
5. Document findings in incident record

## Troubleshooting

| Issue | Check |
|---|---|
| Rules not loaded | `docker compose logs prometheus`; run `promtool check rules` |
| `support_api_database_up` missing | Hit `/health` once; metric updates on health check |
| Grafana dashboard missing | Confirm provisioning mounts; restart `msol-grafana`; check logs |
| Alerts always firing | Open http://localhost:19090/alerts; verify expression and `for` duration |
| Dashboard panels empty | Confirm Prometheus datasource healthy; check time range (last 1h) |

## Roadmap

| Item | Milestone |
|---|---|
| Monitoring stack | M3 (done) |
| Alert rules + Grafana dashboard | M4 (done) |
| Incident simulation drills | M5 |

## Related documents

- [architecture-overview.md](architecture-overview.md)
- [sla-priority-matrix.md](sla-priority-matrix.md)
- [escalation-model.md](escalation-model.md)
- [../runbooks/high-cpu.md](../runbooks/high-cpu.md)
- [../runbooks/database-down.md](../runbooks/database-down.md)
