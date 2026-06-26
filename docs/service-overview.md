# Service Overview

## Service name

**Support Portal API** (`spring-support-api`) — internal B2B API backing customer support workflows and managed services incident simulation.

## Business context

The Support Portal API is a managed service component operated under contract SLA. Downtime or severe degradation directly affects customer support teams and end-user case resolution times.

## Deployment context (Milestone 2)

The service now runs as a **containerized customer application** via Docker Compose: an Nginx reverse proxy fronts the Spring Boot API, which depends on a PostgreSQL database backed by a persistent volume. This is the environment 2nd-level support operates against:

- **Customer entry point:** Nginx at `http://localhost:8081`
- **Direct API access (troubleshooting):** `http://localhost:8080`
- **Database dependency:** PostgreSQL (`msol-postgres`) with `pg_isready` health checks
- **Operational verification:** `/health` reports application status and live database connectivity
- **Safe backup/restore:** `database/backup.sh` and `database/restore.sh` (see [backup-restore-guide.md](backup-restore-guide.md))

See [architecture-overview.md](architecture-overview.md) for the container topology and request flow.

## Service owner

- **Business owner:** Customer Success / Platform Product
- **Technical owner:** Managed Services Platform Team
- **On-call:** 2nd-level Support Operations (this lab's operational focus)

## API overview (Milestone 1)

Base path: `http://localhost:8080` (default)

| Method | Endpoint | Purpose |
|---|---|---|
| GET | `/health` | Service health with live database check (`SELECT 1`), ticket count, and status |
| GET | `/tickets` | List all support tickets |
| GET | `/tickets/{id}` | Get one ticket by ID (404 if missing) |
| POST | `/tickets` | Create a new support ticket (validated) |

**Health response fields:** `status` (UP or DEGRADED), `service`, `database` (UP/DOWN), `ticketCount`, `timestamp`.

**Ticket fields:** `id`, `externalId`, `customerName`, `serviceName`, `priority` (P1–P4), `status`, `title`, `description`, `createdAt`, `updatedAt`.

**Seeded scenarios** (Flyway V2) mirror common Managed Services incidents:

1. PostgreSQL database unreachable (P1)
2. Elevated HTTP 500 errors (P2)
3. Slow API response / query performance (P3)
4. Failed nightly backup job (P2)

Actuator endpoints (`/actuator/health`, `/actuator/prometheus`) are available for future monitoring integration.

## Users and dependencies

| Consumer | Dependency type |
|---|---|
| Support agents (web UI) | Synchronous API calls |
| Reporting batch jobs | Scheduled read queries |
| Integration middleware | Webhook and REST endpoints |

**Upstream dependencies:** Nginx reverse proxy (planned), container runtime, Kubernetes (higher environments).

**Downstream dependencies:** PostgreSQL, external identity provider (future milestone).

## Availability target

| Metric | Target |
|---|---|
| Monthly availability | 99.5% |
| P1 response | 15 minutes |
| P2 response | 1 hour |

See [sla-priority-matrix.md](sla-priority-matrix.md) for priority definitions.

## Support tiers

| Tier | Responsibility |
|---|---|
| 1st level | Triage, initial data collection, known-issue routing |
| **2nd level** | Investigation, troubleshooting, safe resolution, documentation |
| 3rd level | Application development, architecture, complex RCA |

## Key operational artifacts

- Application: [../app/spring-support-api/](../app/spring-support-api/)
- Runbooks: [../runbooks/](../runbooks/)
- Incidents: [../incidents/](../incidents/)
- Problem records: [../problem-records/](../problem-records/)
- Change records: [../changes/](../changes/)
