# Escalation Model

## Purpose

Define when 2nd-level support escalates, to whom, and with what information — minimizing delay and duplicate work. This model reflects Managed Services operations for the Support Portal API lab.

## Escalation paths

```
Customer → L1 → L2 (Support Operations) → L3 (Development / DBA / Platform)
                ↓
         Service Owner / Management (P1 prolonged or customer-facing)
```

## L1 responsibilities

- Log ticket with customer description and affected workflow
- Suggest initial priority; attach screenshots or error messages
- Perform basic checks if runbook allows (e.g. status page)
- Escalate to L2 when beyond script or within 15 min for suspected P1

## L2 responsibilities

- Own incident investigation and resolution within SLA
- Execute runbooks; document work notes with timestamps
- Assign/re-assess priority; coordinate customer updates (P1/P2)
- Open problem/change records when appropriate
- Escalate to L3 with complete evidence package
- Validate restoration before close

## L3 / engineering responsibilities

- Code fixes, thread dumps, application architecture
- Database administration (corruption, migration, index design review)
- Platform/infrastructure (cloud provider, K8s, network)
- Permanent fix implementation via change process

## Customer communication path

```
Customer → L1 (ticket) → L2 (technical updates) → Customer liaison (P1/P2 external comms)
```

L2 provides technical facts; customer liaison formats external messaging. For P1, agree update cadence upfront (every 30 min per [sla-priority-matrix.md](sla-priority-matrix.md)).

## When to escalate

| Condition | Escalate to | Timeframe |
|---|---|---|
| Root cause requires code change | L3 Development | As soon as identified |
| Database corruption or data loss risk | L3 DBA + Management | Immediately |
| Infrastructure / cloud provider issue | Platform team | After initial triage (15 min) |
| Security incident suspected | Security + Management | Immediately |
| No resolution path in runbook | L3 + Team lead | Within SLA response window |
| P1 unresolved past 30 minutes | Team lead + Service owner | At 30 min mark |
| Change risk exceeds L2 authority | Change manager | Before implement |

## Evidence L2 should collect before escalation

1. **Incident ID** and current priority
2. **Customer impact** — who, how many, which workflow
3. **Timeline** — detection, first action, current state
4. **Monitoring** — alert name, Grafana panel, Prometheus query result
5. **Logs** — relevant excerpts (not full dumps unless requested)
6. **Recent changes** — CHG-xxx, deploy time, config diff
7. **Hypothesis** — best theory and what was ruled out
8. **Clear ask** — e.g. "Need DBA to verify index bloat on `support_ticket_events`"
9. **Risk of next steps** — especially for production changes

## Escalation anti-patterns

- Escalating without checking recent changes or monitoring
- Escalating without attempting runbook steps
- Escalating without a clear ask
- Holding P1 while waiting for perfect information
- Escalating to management before L3 when technical fix is needed

## Examples from project incidents

### INC-001 — Database down (P1)

| Phase | L2 action |
|---|---|
| Triage | Confirm `SupportApiDatabaseDown`; postgres stopped |
| Investigate | Runbook `database-down`; check `docker compose ps` |
| Resolve | `restore-database-down.sh`; validate health |
| Escalate? | Only if postgres will not start (disk, corruption) → DBA |

### INC-002 — HTTP 500 errors (P2)

| Phase | L2 action |
|---|---|
| Triage | `SupportApiHighErrorRate`; compare Nginx vs direct API |
| Investigate | Logs; check simulation endpoint; recent deploy |
| Resolve | Disable simulation; rollback if bad release |
| Escalate? | If 500 persists after rollback → L3 for stack trace analysis |

### INC-003 — Container restart loop (P2)

| Phase | L2 action |
|---|---|
| Triage | Unhealthy `msol-support-api`; JDBC errors in logs |
| Investigate | Env vars; `SPRING_DATASOURCE_URL`; recent CHG-004 class change |
| Resolve | `restore-bad-env-restart-loop.sh` |
| Escalate? | If config correct but still failing → L3 platform / image issue |

### INC-005 — Slow SQL (P3 → problem)

| Phase | L2 action |
|---|---|
| Triage | Customer "search slow"; elevated API latency |
| Investigate | EXPLAIN ANALYZE; `run-slow-query-investigation.sh` |
| Resolve | CHG-001 index via change process |
| Escalate? | If index does not help → DBA for query plan review |

## De-escalation

- Service restored and validated
- Monitoring stable 15–30 min (P1/P2)
- Incident record updated with resolution summary
- Customer communication sent if P1/P2
- Hand back to L1 for ticket closure if appropriate

## Related documents

- [sla-priority-matrix.md](sla-priority-matrix.md)
- [incident-management-process.md](incident-management-process.md)
- [change-management-process.md](change-management-process.md)
- [itsm-artifact-map.md](itsm-artifact-map.md)
