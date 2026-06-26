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
