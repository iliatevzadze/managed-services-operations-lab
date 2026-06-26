# Problem Management Process

## Purpose

Problem management identifies and eliminates **root causes** of recurring incidents — moving beyond temporary fixes to permanent resolution and monitoring improvement. L2 engineers open problem records when incidents reveal systemic issues.

## Incident vs. problem

| Aspect | Incident | Problem |
|---|---|---|
| Goal | Restore service now | Prevent recurrence |
| Timeframe | Hours | Days to weeks |
| Output | Resolution, workaround | RCA, permanent fix, change |
| Urgency | High during outage | Planned after stabilization |

## Lifecycle

```
Identify trend → Open problem record → Root cause analysis → Permanent fix plan
       → Change record → Implement → Validate → Close problem
```

## When an incident becomes a problem

| Trigger | Example in this lab |
|---|---|
| Same incident type **3+ times in 30 days** | Repeated DB timeouts → PRB-001 |
| Root cause **unknown** at incident closure | Alert fired late → PRB-004 |
| **Workaround** in place; permanent fix needed | Simulation endpoint in prod → PRB-003 |
| **Monitoring gap** allowed undetected escalation | CPU threshold too high → PRB-004 |
| **Configuration class** of failure repeats | Bad env var pattern → PRB-002 |
| **Release validation gap** causes repeat 5xx | Insufficient staging tests → PRB-003 |

Do **not** open a problem for every single incident. Open when recurrence, unknown cause, or systemic fix is required.

## Recurring issue detection

| Signal | L2 action |
|---|---|
| Duplicate alert names in 7-day window | Compare incident records; check for shared root cause |
| Same runbook used repeatedly | Review problem backlog |
| Customer reports same symptom | Link tickets; trend analysis |
| Metric baseline drift | Grafana history; Prometheus query |

## Root cause analysis

1. Build timeline from logs, alerts, and changes — not assumptions
2. Distinguish **trigger** (what started it) from **contributing factors** (why it persisted)
3. Identify **detection gaps** (why alert or customer noticed late)
4. Propose fix that survives next deploy
5. Assign owner and target date

Methods: 5 Whys, fishbone, or chronological RCA — choose based on complexity.

## Known error documentation

For accepted risks or interim workarounds:

- Document in problem record under **Known error / workaround**
- Link from runbook if operators must apply workaround
- Set review date to remove workaround when change lands

Example: PRB-002 documents env validation gap until CHG-004 and CHG-005 complete.

## Permanent fix

| Step | Detail |
|---|---|
| Define fix | Schema index, config change, code fix, alert tuning |
| Risk assess | Via [change-management-process.md](change-management-process.md) |
| Implement | Change record with rollback |
| Validate | Metrics + functional test + observation period |
| Close problem | When recurrence risk accepted as resolved |

## Monitoring improvement

Every problem record should answer: **How do we detect this earlier next time?**

| Improvement type | Example |
|---|---|
| New alert | `SupportApiDatabaseDown` after INC-001 |
| Threshold tune | CHG-002 for PRB-004 |
| New metric | `support_api_database_up` gauge |
| Dashboard panel | SQL latency on Grafana |

## Problem records in this project

| ID | Title | Linked incidents | Linked changes |
|---|---|---|---|
| [PRB-001](../problem-records/PRB-001-recurring-database-timeout.md) | Recurring database timeout | INC-005 (slow SQL) | CHG-001 |
| [PRB-002](../problem-records/PRB-002-repeated-container-restarts.md) | Repeated container restarts | INC-003 | CHG-004, CHG-005 |
| [PRB-003](../problem-records/PRB-003-repeated-http-500-errors.md) | Repeated HTTP 500 errors | INC-002 | — |
| [PRB-004](../problem-records/PRB-004-monitoring-gap-alert-threshold.md) | Monitoring gap / alert threshold | INC-007 | CHG-002 |

## Jira mapping

| Jira concept | Lab equivalent |
|---|---|
| **Problem / Bug / Improvement** | `problem-records/PRB-xxx-*.md` |
| **Acceptance criteria** | Permanent fix validated; monitoring updated; no recurrence in 90 days |
| **Linked incidents** | INC-xxx references in problem record |
| **Linked changes** | CHG-xxx references |
| **Epic / parent** | Service improvement theme (e.g. "Database performance") |
| **Labels** | `managed-services`, `rca`, `monitoring-gap` |

## Handoff to change management

Permanent fixes that alter production require a [change record](../changes/) with:

- Risk assessment
- Rollback plan
- Validation plan
- Before/after evidence (especially for SQL — see M6)

## Closure criteria

- [ ] Root cause documented
- [ ] Permanent fix implemented and validated
- [ ] Monitoring improvements in place
- [ ] Related incidents linked
- [ ] Known error removed or formally accepted

## Related documents

- [itsm-artifact-map.md](itsm-artifact-map.md)
- [incident-management-process.md](incident-management-process.md)
- [change-management-process.md](change-management-process.md)
- [service-improvement-plan.md](service-improvement-plan.md)
