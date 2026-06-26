# Service Improvement Plan

## Purpose

Track proactive improvements that reduce incident volume, improve detection, and raise service quality beyond reactive support.

## Current backlog

| ID | Improvement | Driver | Priority | Status |
|---|---|---|---|---|
| SI-001 | Add composite index on high-traffic query | PRB-001, CHG-001 | High | Planned |
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
