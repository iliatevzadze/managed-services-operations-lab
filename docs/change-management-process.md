# Change Management Process

## Purpose

Ensure production changes are planned, risk-assessed, reversible, and validated — protecting service stability during fixes and improvements.

## Change types

| Type | Description | Approval |
|---|---|---|
| **Standard** | Pre-approved, low-risk, documented procedure | Auto-approved |
| **Normal** | Planned change with risk review | Team lead / change manager |
| **Emergency** | Required during active incident | Verbal approval + post-implementation review |

## Lifecycle

```
Request → Assess risk → Approve → Implement → Validate → Document → Close
                                      ↓ (if failed)
                                  Rollback
```

## Change record requirements

- Change ID, title, type
- Reason and linked incident/problem
- Risk and impact assessment
- Implementation plan (steps, window, owner)
- Rollback plan (explicit, tested where possible)
- Validation plan (metrics, tests, observation period)
- Approval notes and result

Examples: [../changes/](../changes/)

## Risk assessment factors

- Customer visibility and blast radius
- Reversibility
- Data migration or schema change
- Dependency on other teams
- Time of implementation (business hours vs. maintenance window)

## Rollback principle

> When customer impact is ongoing and root cause of a change is uncertain, **rollback first**, investigate second.

See CHG-003 for a documented rollback scenario.

## Validation checklist

- [ ] Health endpoints green
- [ ] Error rate within baseline
- [ ] Key business transaction smoke test passed
- [ ] Monitoring dashboards normal for observation period
- [ ] No new alerts fired

## Related documents

- [incident-management-process.md](incident-management-process.md)
- [problem-management-process.md](problem-management-process.md)
- [../runbooks/failed-deployment.md](../runbooks/failed-deployment.md)
