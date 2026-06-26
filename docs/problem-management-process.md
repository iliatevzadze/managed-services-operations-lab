# Problem Management Process

## Purpose

Problem management identifies and eliminates **root causes** of recurring incidents — moving beyond temporary fixes to permanent resolution and monitoring improvement.

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

## When to open a problem record

- Same incident type occurs **3+ times in 30 days**
- Root cause unknown at incident closure
- Workaround in place but permanent fix needed
- Monitoring gap allowed incident to escalate undetected

Examples: [../problem-records/](../problem-records/)

## Problem record requirements

- Problem ID and descriptive title
- Related incident IDs
- Business and technical impact summary
- Root cause analysis (5 Whys, fishbone, or timeline — as appropriate)
- Permanent fix description
- Prevention measures
- Monitoring improvements
- Linked change record(s)

## RCA guidelines

1. Start from timeline, not assumptions
2. Distinguish **trigger** from **contributing factors**
3. Identify detection gaps
4. Propose fix that survives the next deploy
5. Assign owner and target date

## Handoff to change management

Permanent fixes that alter production require a [change record](../changes/) with risk assessment, rollback plan, and validation plan.

## Related documents

- [incident-management-process.md](incident-management-process.md)
- [change-management-process.md](change-management-process.md)
- [service-improvement-plan.md](service-improvement-plan.md)
