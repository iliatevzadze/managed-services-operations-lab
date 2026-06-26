# Local Setup Guide

## Milestone status

| Milestone | Setup scope | Status |
|---|---|---|
| M0 | Clone repo, review documentation | **Available now** |
| M1 | Docker Compose full stack | Planned |
| M2 | Monitoring stack integration | Planned |
| M3+ | Failure injection and K8s scenarios | Planned |

## Prerequisites

Install before Milestone 1:

- **Git** — version control and clone
- **Docker** (24+) and **Docker Compose** (v2)
- **Java 17+** and **Maven** (or Gradle)
- **curl** and **jq** — API and JSON inspection
- **kubectl** (optional) — Kubernetes scenarios in later milestones

## Milestone 0 — current steps

```bash
git clone <repository-url>
cd managed-services-operations-lab
tree -L 2   # optional: review structure
```

No application or containers are started at this milestone. Review:

- [README.md](../README.md) — project purpose and roadmap
- [service-overview.md](service-overview.md) — service context
- [incidents/](../incidents/) — example incident records

## Milestone 1 — planned local stack (preview)

```bash
# Not yet available — placeholder for upcoming milestone
docker compose up -d
docker compose ps
curl -s http://localhost:8080/actuator/health
```

Expected services: `spring-support-api`, `postgres`, `nginx`.

## Milestone 2 — monitoring (preview)

```bash
# Not yet available
# Grafana:    http://localhost:3000
# Prometheus: http://localhost:9090
```

## Verification checklist (M1+)

- [ ] All containers healthy (`docker compose ps`)
- [ ] Application health endpoint returns `UP`
- [ ] Database accepts connections
- [ ] Prometheus targets show `UP`
- [ ] Grafana dashboards load without errors

## Troubleshooting setup issues

| Issue | Check |
|---|---|
| Port conflict | `ss -tlnp \| grep -E '8080\|5432\|9090'` |
| Container won't start | `docker compose logs <service>` |
| Database not ready | Wait for healthcheck; review `database/init.sql` logs |

## Related documents

- [architecture-overview.md](architecture-overview.md)
- [monitoring-guide.md](monitoring-guide.md)
- [backup-restore-guide.md](backup-restore-guide.md)
