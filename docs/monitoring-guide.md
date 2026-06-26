# Monitoring Guide

## Objectives

Monitoring in this lab supports **2nd-level support operations**: fast detection, enough context to investigate, and alerts that reduce noise without hiding real outages.

## Stack overview

| Tool | Role |
|---|---|
| Prometheus | Metrics collection and rule evaluation |
| Grafana | Dashboards for application, database, and infrastructure |
| Alertmanager | Route, group, deduplicate, and notify |

Configuration files will live under `monitoring/` (Milestone 2+).

## Key metrics (planned)

### Application

- `http_server_requests_seconds` — latency and error rate
- JVM heap and GC metrics
- Thread pool saturation

### Database

- Connection pool active/idle
- Query duration (application-side)
- PostgreSQL exporter: connections, locks, replication lag

### Infrastructure

- Container CPU and memory
- Pod restart count (Kubernetes)
- Nginx upstream health and 5xx rate

## Alerting principles

1. **Alert on symptoms that matter to users** — availability, error rate, latency SLO breach
2. **Include runbook links** in alert annotations
3. **Avoid alert storms** — grouping and inhibition in Alertmanager
4. **Tune thresholds with evidence** — see PRB-004 and CHG-002

## Dashboard structure (planned)

| Dashboard | Audience | Focus |
|---|---|---|
| Service Overview | On-call | Golden signals, SLA indicators |
| Application Deep Dive | 2nd level | JVM, endpoints, errors |
| Database | 2nd level | Connections, slow queries |
| Infrastructure | 2nd level | CPU, memory, restarts |

## Investigation workflow

1. Confirm alert in Alertmanager / Grafana
2. Check Service Overview dashboard for scope
3. Correlate with recent deployments and changes
4. Follow linked runbook
5. Document findings in incident record

## Known gaps (documented)

- Threshold too sensitive on CPU (PRB-004) — addressed via CHG-002
- Missing synthetic uptime check — in service improvement backlog

## Related documents

- [sla-priority-matrix.md](sla-priority-matrix.md)
- [escalation-model.md](escalation-model.md)
- [../runbooks/high-cpu.md](../runbooks/high-cpu.md)
