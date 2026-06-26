# Incident Management Process

## Scope

Incident management restores normal service operation as quickly as possible while preserving evidence for problem and change management. This process reflects how a **2nd-level Managed Services engineer** operates the Support Portal API lab and maps to common ITSM tooling.

## Incident lifecycle

```
Detect → Log → Triage → Investigate → Mitigate/Resolve → Validate → Document → Close
                                                              ↓
                                         Problem record (if recurring) / Change (if fix deployed)
                                                              ↓
                                                    Post-incident review (P1/P2)
```

## Roles

| Role | Responsibility |
|---|---|
| **L1** | Initial ticket, customer contact, severity suggestion, attach screenshots/logs |
| **L2** | Investigation, troubleshooting, safe resolution, incident record, escalation |
| **L3** | Code fixes, DBA actions, architecture, complex RCA |
| **Incident commander (P1)** | Coordination, customer comms, decision authority |

## Priority handling (P1–P4)

| Priority | L2 focus | Response target (lab) |
|---|---|---|
| **P1** | All hands; bridge; restore first | Acknowledge 15 min; update every 30 min |
| **P2** | Investigate runbook; customer updates | Acknowledge 1 hour; update every 2 hours |
| **P3** | Scheduled fix; document workaround | Acknowledge 4 hours |
| **P4** | Backlog; batch with changes | Next business day |

Full matrix: [sla-priority-matrix.md](sla-priority-matrix.md)

## Detection sources

| Source | What L2 checks | Lab example |
|---|---|---|
| **Prometheus** | Firing alerts at `:19090/alerts` | `SupportApiDatabaseDown`, `SupportApiHighErrorRate` |
| **Grafana** | Dashboard panels | Managed Services Operations Overview |
| **Nginx** | Customer path `:18081` vs direct API `:18080` | Isolate proxy vs application fault |
| **Spring logs** | `docker compose logs spring-support-api` | JDBC errors, simulation messages, stack traces |
| **Docker Compose** | `docker compose ps`, health status | Unhealthy `msol-support-api`, stopped postgres |
| **Customer report** | Ticket description, affected workflow | "Cannot load cases", "search is slow" |

## Triage checklist

- [ ] Confirm alert or customer report is genuine (not false positive)
- [ ] Assign priority using [sla-priority-matrix.md](sla-priority-matrix.md)
- [ ] Identify affected service and customer impact scope
- [ ] Check recent changes ([changes/](../changes/)) and deployments
- [ ] Open or link incident record (INC-xxx)
- [ ] Select runbook from [runbooks/](../runbooks/)
- [ ] Notify incident commander if P1

## Investigation checklist

- [ ] Compare Nginx (`http://localhost:18081/health`) vs API direct (`:18080/health`)
- [ ] Query Prometheus: `up`, `support_api_database_up`, error rates
- [ ] Review application logs (last 100–200 lines)
- [ ] Check container status: `docker compose ps`
- [ ] Review database connectivity if relevant
- [ ] Document commands used (reproducible for handover)
- [ ] Correlate timeline: alert time, change time, customer report time

## Communication notes

| Priority | Audience | Content |
|---|---|---|
| P1 | Customer liaison, service owner, L3 on standby | Impact, ETA unknown/known, next update time |
| P2 | Customer liaison, internal team | Degraded function, workaround if any |
| P3/P4 | Ticket update | Scope, planned resolution window |

**Work notes (ServiceNow style):** Timestamp each action. Example: `09:14 — Alert SupportApiDatabaseDown confirmed. postgres container stopped. Starting runbook database-down.`

## Resolution validation

- [ ] `curl http://localhost:18081/health` → `status: UP`, `database: UP`
- [ ] Prometheus alerts inactive for observation period (15–30 min P1/P2)
- [ ] Customer-facing smoke test (`/tickets` returns data)
- [ ] No new errors in application logs
- [ ] Grafana panels returned to baseline

## Post-incident review (P1/P2)

Within 5 business days:

1. Timeline reconstruction
2. What went well / what did not
3. Detection gap? Response gap?
4. Open problem record if recurring
5. Add items to [service-improvement-plan.md](service-improvement-plan.md)
6. Blameless; focus on process and tooling

## Incident records in this project

| ID | Scenario | Priority | Runbook |
|---|---|---|---|
| [INC-001](../incidents/INC-001-database-down.md) | Database down | P1 | database-down |
| [INC-002](../incidents/INC-002-application-500-errors.md) | HTTP 500 errors | P2 | application-500-errors |
| [INC-003](../incidents/INC-003-container-restart-loop.md) | Bad env / unhealthy container | P2 | container-restart, failed-deployment |

## ServiceNow mapping

| ServiceNow field | Lab equivalent |
|---|---|
| **Incident** | `incidents/INC-xxx-*.md` |
| **Priority** | P1–P4 in incident record |
| **Assignment group** | Managed Services Platform Team / L2 Support Operations |
| **Work notes** | Investigation steps, commands used (timestamped) |
| **Resolution notes** | Resolution + validation summary |
| **Related problem** | Link to `problem-records/PRB-xxx` |
| **Related change** | Link to `changes/CHG-xxx` |
| **Configuration item** | Support Portal API, PostgreSQL, Nginx |

## Simulated incidents (Milestone 5)

Controlled drills for L2 training. Rules:

- Run **one** simulation at a time
- Always run matching **restore script** before the next drill
- HTTP 500 drill requires baseline health `UP` / database `UP`

| Script | Incident |
|---|---|
| `scripts/incidents/simulate-database-down.sh` | INC-001 |
| `scripts/incidents/simulate-http-500.sh` | INC-002 |
| `scripts/incidents/simulate-bad-env-restart-loop.sh` | INC-003 |

## Closure criteria

- [ ] Service restored and validated
- [ ] Monitoring green for agreed observation period
- [ ] Incident record complete with evidence
- [ ] Customer comms sent (P1/P2)
- [ ] Problem record opened if recurring or unknown root cause
- [ ] Post-incident review scheduled (P1/P2)

## Related documents

- [itsm-artifact-map.md](itsm-artifact-map.md)
- [problem-management-process.md](problem-management-process.md)
- [escalation-model.md](escalation-model.md)
- [../runbooks/](../runbooks/)
