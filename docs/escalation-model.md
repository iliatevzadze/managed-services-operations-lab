# Escalation Model

## Purpose

Define when 2nd-level support escalates, to whom, and with what information — minimizing delay and duplicate work.

## Escalation paths

```
1st Level → 2nd Level (Support Operations) → 3rd Level (Development / DBA / Platform)
                ↓
         Service Owner / Management (P1 prolonged or customer-facing)
```

## When to escalate

| Condition | Escalate to | Timeframe |
|---|---|---|
| Root cause requires code change | 3rd level Development | As soon as identified |
| Database corruption or data loss risk | 3rd level DBA + Management | Immediately |
| Infrastructure / cloud provider issue | Cloud platform team | After initial triage |
| Security incident suspected | Security team + Management | Immediately |
| No resolution path in runbook | 3rd level + Team lead | Within SLA window |
| P1 unresolved past 30 minutes | Team lead + Service owner | At 30 min mark |

## What to include in escalation

1. **Incident ID** and current priority
2. **Customer impact** — who is affected and how
3. **Timeline** — detection time, actions taken
4. **Evidence** — logs, metrics screenshots, error messages
5. **Hypothesis** — current best theory and what was ruled out
6. **Risk of next steps** — especially for changes in production

## Escalation anti-patterns

- Escalating without checking recent changes or monitoring
- Escalating without attempting runbook steps
- Escalating without a clear ask ("need dev to investigate thread dump")
- Holding P1 while waiting for perfect information

## De-escalation

- Service restored and validated
- Monitoring confirms stable state (typically 15–30 min)
- Incident record updated with resolution summary
- Customer communication sent if P1/P2

## Related documents

- [sla-priority-matrix.md](sla-priority-matrix.md)
- [incident-management-process.md](incident-management-process.md)
- [change-management-process.md](change-management-process.md)
