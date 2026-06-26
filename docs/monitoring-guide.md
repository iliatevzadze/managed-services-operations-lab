# Monitoring Guide

## Objectives

Monitoring in this lab supports **proactive 2nd-level support operations**: detect customer-impacting issues early, give the engineer enough context to investigate, and build toward alerts that reduce noise without hiding real outages.

Milestone 3 adds a working local monitoring stack. **Alert rules and Grafana dashboards are intentionally not included yet** — they arrive in Milestone 4.

## Stack overview (Milestone 3)

| Component | Container | Host port | Role |
|---|---|---|---|
| Prometheus | `msol-prometheus` | 19090 | Scrapes and stores metrics; evaluates rules (rules added in M4) |
| Grafana | `msol-grafana` | 13003 | Visualizes Prometheus data (dashboards added in M4) |
| Alertmanager | `msol-alertmanager` | 19093 | Receives future alerts; local placeholder receiver only |
| Node Exporter | `msol-node-exporter` | 19100 | Host metrics: CPU, memory, disk, network |
| cAdvisor | `msol-cadvisor` | 18084 | Per-container metrics: CPU, memory, restarts |

### What each component gives 2nd-level support

- **Prometheus** — single place to query the health and behavior of the customer application, host, and containers. The investigation starting point.
- **Grafana** — visual correlation across application, host, and container metrics (dashboards in M4).
- **Alertmanager** — wired now so the alerting path exists; routing and receivers are completed with the rules in M4.
- **Node Exporter** — answers "is the host itself under pressure?" (CPU saturation, memory exhaustion, disk full).
- **cAdvisor** — answers "which container is misbehaving?" (a restarting or memory-hungry container), supporting container-level investigation.

## What Prometheus scrapes

| Job | Target | Purpose |
|---|---|---|
| `prometheus` | `localhost:9090` | Self-monitoring |
| `spring-support-api` | `spring-support-api:8080/actuator/prometheus` | Customer application metrics (Micrometer) |
| `node-exporter` | `node-exporter:9100` | Host metrics |
| `cadvisor` | `cadvisor:8080` | Container metrics |

Config: [`../monitoring/prometheus/prometheus.yml`](../monitoring/prometheus/prometheus.yml)
Alertmanager config: [`../monitoring/alertmanager/alertmanager.yml`](../monitoring/alertmanager/alertmanager.yml)

## Startup checks

Start (or restart) the full stack including monitoring:

```bash
docker compose up -d
docker compose ps
```

Confirm each monitoring UI responds:

```bash
curl -s http://localhost:19090/-/ready          # Prometheus: "Prometheus Server is Ready."
curl -s http://localhost:19093/-/ready          # Alertmanager readiness
curl -s -o /dev/null -w "%{http_code}\n" http://localhost:13003/login   # Grafana: 200
curl -s http://localhost:19100/metrics | head   # Node Exporter metrics
curl -s http://localhost:18084/healthz          # cAdvisor health
```

Monitoring UIs:

- Prometheus: http://localhost:19090
- Grafana: http://localhost:13003 (login `admin` / `admin`)
- Alertmanager: http://localhost:19093

## Prometheus target check

Confirm all scrape targets are healthy:

1. Open http://localhost:19090/targets
2. Every job (`prometheus`, `spring-support-api`, `node-exporter`, `cadvisor`) should show **State = UP**.

From the command line:

```bash
# Quick check that the application metrics are being exposed
curl -s http://localhost:18080/actuator/prometheus | head

# Ask Prometheus which targets are up
curl -s 'http://localhost:19090/api/v1/query?query=up' | jq '.data.result[] | {job:.metric.job, value:.value[1]}'
```

## Useful queries

Run these in the Prometheus UI (http://localhost:19090) expression browser:

| Query | What it tells a 2nd-level engineer |
|---|---|
| `up` | Which scrape targets are reachable (1) or down (0) |
| `up{job="spring-support-api"}` | Is the customer application being scraped successfully |
| `http_server_requests_seconds_count` | Request counts per endpoint/status — traffic and error visibility |
| `process_cpu_usage` | Application process CPU usage |
| `container_memory_usage_bytes` | Per-container memory usage (cAdvisor) |
| `node_cpu_seconds_total` | Host CPU time by mode (Node Exporter) |

## Alerting principles (applied in Milestone 4)

1. **Alert on symptoms that matter to users** — availability, error rate, latency SLO breach
2. **Include runbook links** in alert annotations
3. **Avoid alert storms** — grouping and inhibition in Alertmanager
4. **Tune thresholds with evidence** — see PRB-004 and CHG-002

## Investigation workflow

1. Confirm scope in Prometheus (`up`, error-rate, resource queries)
2. Separate application vs. host vs. container symptoms (app metrics vs. Node Exporter vs. cAdvisor)
3. Correlate with recent deployments and changes
4. Follow the linked runbook
5. Document findings in the incident record

## Roadmap

| Item | Milestone |
|---|---|
| Monitoring stack (this guide) | M3 (done) |
| Alert rules + Alertmanager routing | M4 |
| Grafana dashboards | M4 |

## Known gaps (documented)

- Threshold too sensitive on CPU (PRB-004) — addressed via CHG-002
- Missing synthetic uptime check — in service improvement backlog

## Related documents

- [architecture-overview.md](architecture-overview.md)
- [sla-priority-matrix.md](sla-priority-matrix.md)
- [escalation-model.md](escalation-model.md)
- [../runbooks/high-cpu.md](../runbooks/high-cpu.md)
