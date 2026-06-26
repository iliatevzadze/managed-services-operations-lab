# Service Overview

## Service name

**Support Portal API** — internal B2B API backing customer support workflows.

## Business context

The Support Portal API is a managed service component operated under contract SLA. Downtime or severe degradation directly affects customer support teams and end-user case resolution times.

## Service owner

- **Business owner:** Customer Success / Platform Product
- **Technical owner:** Managed Services Platform Team
- **On-call:** 2nd-level Support Operations (this lab's operational focus)

## Users and dependencies

| Consumer | Dependency type |
|---|---|
| Support agents (web UI) | Synchronous API calls |
| Reporting batch jobs | Scheduled read queries |
| Integration middleware | Webhook and REST endpoints |

**Upstream dependencies:** Nginx reverse proxy, container runtime, Kubernetes (higher environments).

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

- Runbooks: [../runbooks/](../runbooks/)
- Incidents: [../incidents/](../incidents/)
- Problem records: [../problem-records/](../problem-records/)
- Change records: [../changes/](../changes/)
