# Incident Management Process

## Scope

Incident management restores normal service operation as quickly as possible while preserving evidence for problem management.

## Lifecycle

```
Detect → Log → Triage → Investigate → Mitigate/Resolve → Validate → Document → Close
                                                              ↓
                                                    Problem record (if recurring)
```

## Roles

| Role | Responsibility |
|---|---|
| 1st level | Initial ticket, severity suggestion, attach customer reports |
| **2nd level** | Investigation, troubleshooting, resolution, incident record |
| 3rd level | Deep RCA, code fixes, architectural changes |
| Incident commander (P1) | Coordination, comms, decision authority |

## Incident record requirements

Each incident must capture:

- Unique ID, title, priority, affected service
- Alert or ticket source
- Business impact and technical symptoms
- Chronological investigation steps
- Commands and queries used (reproducible)
- Root cause (or "under investigation" until known)
- Resolution and validation
- Prevention notes
- Links to runbook, problem record, change record

Template examples: [../incidents/](../incidents/)

## Priority assignment

Follow [sla-priority-matrix.md](sla-priority-matrix.md). Re-assess priority as impact becomes clearer.

## Communication

| Priority | Channels |
|---|---|
| P1 | Bridge call, status page, customer liaison |
| P2 | Ticket updates, internal chat |
| P3/P4 | Ticket updates |

## Simulated incidents (Milestone 5)

The lab includes **controlled incident drills** for 2nd-level training. These are local-only, reversible, and do not delete volumes.

### Drill workflow

```
Alert fires (Prometheus) → Triage (Grafana/dashboard) → Investigate (runbook)
    → Mitigate (restore script) → Validate (health + metrics) → Document (incident record)
```

### Handling simulated incidents

1. **Detect** — Confirm alert at http://localhost:19090/alerts before acting
2. **Log** — Open or update incident record (INC-001, INC-002, or INC-003)
3. **Investigate** — Use runbook commands; compare Nginx (`:18081`) vs direct API (`:18080`)
4. **Mitigate** — Run matching restore script from `scripts/incidents/`
5. **Validate** — Health `UP`, `support_api_database_up = 1`, alerts inactive
6. **Document** — Complete incident record with actual commands used
7. **Close** — Open problem record if recurring pattern identified

### Drill scripts

| Script | Purpose |
|---|---|
| `scripts/incidents/simulate-database-down.sh` | Stop postgres; trigger DB alert |
| `scripts/incidents/restore-database-down.sh` | Restart postgres; validate recovery |
| `scripts/incidents/simulate-http-500.sh` | Generate 5xx via `/simulate/http-500` |
| `scripts/incidents/simulate-bad-env-restart-loop.sh` | Apply bad datasource override |
| `scripts/incidents/restore-bad-env-restart-loop.sh` | Restore normal compose config |

Simulation endpoints require `SUPPORT_SIMULATION_ENABLED=true` (set in Docker Compose only).

## Closure criteria

- [ ] Service restored and validated
- [ ] Monitoring green for agreed observation period
- [ ] Incident record complete
- [ ] Customer comms sent (if required)
- [ ] Problem record opened if recurring or unknown root cause
- [ ] Post-incident review scheduled (P1/P2)

## Related documents

- [problem-management-process.md](problem-management-process.md)
- [escalation-model.md](escalation-model.md)
- [../runbooks/](../runbooks/)
