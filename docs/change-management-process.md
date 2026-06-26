# Change Management Process

## Purpose

Ensure production changes are planned, risk-assessed, reversible, and validated — protecting service stability during fixes and improvements. L2 engineers propose and execute changes with clear rollback paths.

## Change types

| Type | Description | Approval | Lab examples |
|---|---|---|---|
| **Standard** | Pre-approved, low-risk, documented procedure | Auto-approved | Routine backup, log rotation |
| **Normal** | Planned change with risk review | Team lead / change manager | CHG-001 index, CHG-002 threshold, CHG-004 env var |
| **Emergency** | Required during active incident | Verbal approval + post-implementation review | CHG-003 rollback bad release |

## Risk levels

| Level | Criteria | Typical approval |
|---|---|---|
| **Low** | Reversible in minutes; no schema change; limited blast radius | L2 + peer review |
| **Medium** | Schema or config change; brief customer impact possible | Team lead |
| **High** | Data migration; extended outage risk; multi-service | Change manager + service owner |

## Lifecycle

```
Request → Assess risk → Approve → Implement → Validate → Document → Close
                                      ↓ (if failed)
                                  Rollback
```

## Implementation plan

Every change record must include:

1. **Objective** — what and why
2. **Linked incident/problem** — traceability
3. **Steps** — ordered, with owner and timing
4. **Maintenance window** — if customer-visible
5. **Communication** — who to notify

## Rollback plan

> When customer impact is ongoing and root cause of a change is uncertain, **rollback first**, investigate second.

| Requirement | Detail |
|---|---|
| Explicit steps | Reverse migration, restore image tag, revert env var |
| Time estimate | How long rollback takes |
| Validation after rollback | Health, metrics, smoke test |
| Tested where possible | Rehearse in lab before production |

See [CHG-003](../changes/CHG-003-rollback-bad-release.md) for rollback scenario.

## Validation plan

- [ ] Health endpoints green (`/health` via Nginx and direct)
- [ ] Error rate within baseline (Prometheus)
- [ ] Key transaction smoke test (`GET /tickets`)
- [ ] Monitoring dashboards normal for observation period (15–60 min)
- [ ] No new alerts fired
- [ ] SQL: EXPLAIN shows expected plan (for index changes)

## Approval notes

| Change type | Approval pattern |
|---|---|
| Standard | Documented in runbook; no separate ticket |
| Normal | Written approval in change record before implement |
| Emergency | Verbal from incident commander; document within 24 hours |

## Change records in this project

| ID | Title | Type | Risk | Linked problem |
|---|---|---|---|---|
| [CHG-001](../changes/CHG-001-add-sql-index.md) | Add SQL composite index | Normal | Medium | PRB-001 |
| [CHG-002](../changes/CHG-002-adjust-monitoring-threshold.md) | Adjust monitoring threshold | Normal | Low | PRB-004 |
| [CHG-003](../changes/CHG-003-rollback-bad-release.md) | Rollback bad release | Emergency | Medium | PRB-002 |
| [CHG-004](../changes/CHG-004-update-environment-variable.md) | Update environment variable | Normal | Medium | PRB-002 |
| [CHG-005](../changes/CHG-005-improve-health-check.md) | Improve health check | Normal | Low | PRB-002 |

## Change examples in this project

### Add SQL index (CHG-001)

- **Driver:** Slow ticket history search (PRB-001, INC-005)
- **Evidence:** Before/after EXPLAIN in `database/sql-troubleshooting/evidence/`
- **Rollback:** `DROP INDEX` if regression detected
- **Validation:** Query latency < 100 ms; Index Scan in EXPLAIN

### Adjust monitoring threshold (CHG-002)

- **Driver:** Alert fired too late (PRB-004)
- **Change:** Tune CPU alert in `managed-services-alerts.yml`
- **Rollback:** Revert rule file; reload Prometheus
- **Validation:** Alert fires in drill without false positives

### Rollback bad release (CHG-003)

- **Driver:** Unhealthy container after deploy (INC-003 pattern)
- **Change:** Revert to previous image tag / compose config
- **Rollback:** N/A — rollback *is* the change
- **Validation:** Container stable; health UP 30+ min

### Update environment variable (CHG-004)

- **Driver:** Wrong `SPRING_DATASOURCE_URL` caused restart loop
- **Change:** Correct datasource URL in compose or secrets
- **Rollback:** Restore previous env file
- **Validation:** JDBC connects; no restart loop

### Improve health check (CHG-005)

- **Driver:** Liveness passed while DB was down
- **Change:** Readiness includes database check
- **Rollback:** Revert probe config
- **Validation:** Unhealthy when DB stopped; healthy when restored

## ServiceNow mapping

| ServiceNow field | Lab equivalent |
|---|---|
| Change Request | `changes/CHG-xxx-*.md` |
| Risk | Low / Medium / High in record |
| Implementation plan | Steps section |
| Backout plan | Rollback section |
| Close code | Successful / Rolled back |
| Related incident/problem | INC / PRB links |

## Related documents

- [itsm-artifact-map.md](itsm-artifact-map.md)
- [incident-management-process.md](incident-management-process.md)
- [problem-management-process.md](problem-management-process.md)
- [../runbooks/failed-deployment.md](../runbooks/failed-deployment.md)
