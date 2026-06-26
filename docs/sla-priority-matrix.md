# SLA and Priority Matrix

Priority definitions and response targets for the Support Portal API lab. These are **lab-defined targets** for portfolio demonstration — **not Exxeta's official SLA**.

## Priority matrix

| | P1 Critical | P2 High | P3 Medium | P4 Low |
|---|---|---|---|---|
| **Definition** | Complete or severe outage; major business stop | Significant degradation; core function impaired | Limited impact; workaround available | Minor issue; cosmetic or low-user-impact |
| **Customer impact** | All or most users cannot use service | Many users affected; degraded performance | Subset of users or non-critical function | Few users; no SLA risk |
| **Example (this project)** | [INC-001](../incidents/INC-001-database-down.md) — database down, API unavailable | [INC-002](../incidents/INC-002-application-500-errors.md) — sustained 5xx; [INC-003](../incidents/INC-003-container-restart-loop.md) — restart loop | Slow ticket search before index (INC-005 pattern) | Alert annotation typo; doc update |
| **Target response** | 15 minutes | 1 hour | 4 hours | Next business day |
| **Target workaround / restoration** | 1 hour | 4 hours | 1 business day | Next scheduled change window |
| **Update cadence** | Every 30 minutes | Every 2 hours | Daily | As needed |
| **Escalation expectation** | Incident commander at open; L3 + management if no progress in 30 min | L3 if no progress in 2 hours or recurring in 7 days | Problem record if recurring | Batch to improvement backlog |

## Impact vs. urgency

Use when priority is unclear:

|  | **High urgency** | **Medium urgency** | **Low urgency** |
|---|---|---|---|
| **High impact** | P1 | P1–P2 | P2 |
| **Medium impact** | P2 | P3 | P3 |
| **Low impact** | P3 | P4 | P4 |

Re-assess priority as investigation reveals true scope.

## Service availability targets (lab)

| Service | Monthly target | Measurement |
|---|---|---|
| Support Portal API | 99.5% | Synthetic + error-rate composite |
| PostgreSQL (managed) | 99.9% | Connection health + provider SLA |

## Escalation triggers by priority

| Priority | Escalate when |
|---|---|
| P1 | No progress within 30 min, or root cause requires code/DBA change |
| P2 | No progress within 2 hours, or same incident type within 7 days |
| P3 | Problem record opened; permanent fix needed |
| P4 | Batch into change window or [service-improvement-plan.md](service-improvement-plan.md) |

## Communication expectations

- **P1/P2:** Status updates to service owner and customer liaison
- **All:** Incident record updated before handover or shift end
- **Post-resolution:** Link incident → problem (if recurring) → change (if fix deployed)

## Lab incident priority reference

| Incident | Priority | Rationale |
|---|---|---|
| INC-001 Database down | P1 | Full API unavailable; no workaround |
| INC-002 HTTP 500 errors | P2 | Degraded; partial paths may work |
| INC-003 Restart loop | P2 | Intermittent availability; unhealthy container |
| INC-005 Slow SQL | P3 | Degraded search; service partially usable |

## Related documents

- [escalation-model.md](escalation-model.md)
- [incident-management-process.md](incident-management-process.md)
- [itsm-artifact-map.md](itsm-artifact-map.md)
