# Service Improvement Plan

## Purpose

Track proactive improvements that reduce incident volume, improve detection, and raise service quality beyond reactive support.

## Continuous Service Improvement Backlog

Proactive items that reduce incident volume, tighten detection, and raise operational maturity. Reviewed monthly; sourced from incidents, problems, and post-incident reviews.

| Theme | Backlog items | Status |
|---|---|---|
| **Monitoring threshold tuning** | SI-002 — tune CPU alert (PRB-004, CHG-002) | Planned |
| **Better health checks** | SI-003 — readiness vs liveness (PRB-002, CHG-005) | Planned |
| **SQL index improvement** | SI-001 — composite index validated (PRB-001, CHG-001, M6) | **Done (lab)** |
| **Backup validation** | SI-005 — automated backup verification | Backlog |
| **Incident script hardening** | SI-008 env checklist, SI-009 disable simulation in prod, SI-010 alert drill cadence | **Added (M5)** |
| **Safe deployment & rollback** | SI-014 kubectl rollback runbook + script; SI-015 local kind rehearsal environment (M8) | **Added (M8)** |
| **Future CI/CD health gates** | Pre-deploy smoke tests, datasource validation (SI-011), staging soak before promote | Planned (M9) |

Supporting detail in the table below.

## Current backlog

| ID | Improvement | Driver | Priority | Status |
|---|---|---|---|---|
| SI-001 | Add composite index on ticket history search | PRB-001, CHG-001 | High | **Validated (M6 lab)** |
| SI-002 | Tune CPU alert threshold | PRB-004, CHG-002 | Medium | Planned |
| SI-003 | Strengthen readiness probe vs. liveness | PRB-002, CHG-005 | High | Planned |
| SI-004 | Synthetic uptime monitoring | Monitoring gap | Medium | Backlog |
| SI-005 | Automated backup verification | Backup guide | Medium | Backlog |
| SI-006 | Runbook link in all alert annotations | Alert rules M4 | Low | Partial (M4 rules include runbook labels) |
| SI-007 | Post-incident review template | Process maturity | Low | Backlog |
| SI-008 | Env var change checklist before deploy | INC-003, CHG-004 | High | **Added (M5)** |
| SI-009 | Disable simulation endpoints in production | INC-002 drill | High | **Added (M5)** |
| SI-010 | Database dependency dashboard + alert drill cadence | INC-001 drill | Medium | **Added (M5)** |
| SI-011 | Pre-deploy datasource validation in staging | INC-003, PRB-002 | High | **Added (M5)** |
| SI-012 | Quarterly EXPLAIN ANALYZE review for top queries | PRB-001, M6 | High | **Added (M6)** |
| SI-013 | Commit before/after SQL evidence for index changes | CHG-001, M6 | Medium | **Added (M6)** |
| SI-014 | Kubernetes rollback runbook + script for failed deployments | CHG-003, PRB-002, M8 | High | **Added (M8)** |
| SI-015 | Local kind environment for deployment/rollback rehearsal | failed-deployment, M8 | Medium | **Added (M8)** |
| SI-016 | Replace emptyDir with PVC when persistence is in scope | M8 storage note | Low | Backlog |

## Lessons from Milestone 6 SQL investigation

| Finding | Improvement |
|---|---|
| Sequential scan on 100k rows without composite index | Index `(customer_name, event_type, created_at DESC)` — validated in lab |
| No EXPLAIN evidence before past index debates | Require before/after files in change records |
| Connection pool timeouts correlate with slow scans | Monitor `pg_stat_activity` duration + pool pending count |

## Lessons from Milestone 5 incident drills

| Incident | Finding | Improvement |
|---|---|---|
| INC-001 Database down | `support_api_database_up` detects outage within one health check cycle | Schedule quarterly restore drill; monitor disk |
| INC-002 HTTP 500 | `SupportApiHighErrorRate` fires after 2m sustained 5xx | Strengthen staging smoke tests; disable `/simulate/*` in prod |
| INC-003 Bad env config | Wrong `SPRING_DATASOURCE_URL` causes immediate health failure | Mandatory env change checklist; staging soak before promote |

## Improvement sources

- Recurring incidents and problem records
- Post-incident reviews
- Monitoring gap analysis
- Customer feedback and SLA trends
- Shift handover themes

## Success metrics

| Metric | Current (simulated) | Target |
|---|---|---|
| P1 incidents / month | — | < 1 |
| Repeat incidents (same root cause) | — | 0 within 90 days of fix |
| Mean time to detect (MTTD) | — | < 5 min for critical paths |
| Runbook coverage for top alert types | Partial | 100% |

## Review cadence

- **Monthly:** Review backlog with team lead
- **Quarterly:** Align with service owner on SLA and capacity
- **After P1/P2:** Capture items within 5 business days

## Related documents

- [problem-management-process.md](problem-management-process.md)
- [monitoring-guide.md](monitoring-guide.md)
- [../problem-records/](../problem-records/)
