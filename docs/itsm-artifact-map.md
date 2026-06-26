# ITSM Artifact Map

A fast reference for employers reviewing this portfolio. Every artifact below demonstrates how a **2nd-level Managed Services Support Operations Engineer** detects issues, investigates with evidence, resolves safely, documents clearly, and prevents recurrence.

> Targets in this lab are **lab-defined** for portfolio demonstration — not Exxeta's official SLA.

---

## Incident records

| | |
|---|---|
| **Represents** | A single service disruption: what broke, who was affected, how it was fixed |
| **Location** | [incidents/](../incidents/) |
| **Examples** | [INC-001](../incidents/INC-001-database-down.md), [INC-002](../incidents/INC-002-application-500-errors.md), [INC-003](../incidents/INC-003-container-restart-loop.md) |
| **L2 usage** | Open on alert or customer report; follow runbook; log commands and timeline; link to problem/change; close when validated |

**ServiceNow mapping:** Incident table — Priority, Assignment group, Work notes, Resolution notes, Related Records (Problem, Change).

---

## Problem records

| | |
|---|---|
| **Represents** | Root cause of recurring or significant incidents; permanent fix plan |
| **Location** | [problem-records/](../problem-records/) |
| **Examples** | [PRB-001](../problem-records/PRB-001-recurring-database-timeout.md) · [PRB-002](../problem-records/PRB-002-repeated-container-restarts.md) · [PRB-003](../problem-records/PRB-003-repeated-http-500-errors.md) · [PRB-004](../problem-records/PRB-004-monitoring-gap-alert-threshold.md) |
| **L2 usage** | Open when pattern repeats or RCA needed; document evidence; drive change record; close after permanent fix validated |

**Jira mapping:** Problem / Bug / Improvement — linked Incidents, Acceptance criteria, linked Changes.

---

## Change records

| | |
|---|---|
| **Represents** | Controlled production change with risk, rollback, and validation |
| **Location** | [changes/](../changes/) |
| **Examples** | [CHG-001](../changes/CHG-001-add-sql-index.md) (index) through [CHG-005](../changes/CHG-005-improve-health-check.md) (health check) |
| **L2 usage** | Request fix via change process; document rollback before implement; validate with metrics; update result |

**ServiceNow mapping:** Change Request — Risk, Implementation plan, Backout plan, Close code.

---

## Runbooks

| | |
|---|---|
| **Represents** | Repeatable operational procedure for a known failure mode |
| **Location** | [runbooks/](../runbooks/) |
| **Examples** | database-down, application-500-errors, slow-sql-query, container-restart, failed-deployment, backup-and-restore |
| **L2 usage** | First reference on alert; execute investigation and restore steps; update if gaps found |

**Confluence mapping:** Runbook page — linked from alert annotations and incident records.

---

## SLA / priority model

| | |
|---|---|
| **Represents** | How urgency and impact map to P1–P4 and response targets |
| **Location** | [sla-priority-matrix.md](sla-priority-matrix.md) |
| **L2 usage** | Assign and re-assess priority; set customer expectations; trigger escalation per matrix |

**ServiceNow mapping:** Priority field (1–4), Impact, Urgency.

---

## Escalation model

| | |
|---|---|
| **Represents** | When and how L2 escalates to L3, DBA, platform, or management |
| **Location** | [escalation-model.md](escalation-model.md) |
| **L2 usage** | Escalate with evidence package; avoid premature or late escalation |

**ServiceNow / Jira mapping:** Escalation flag, Assignment group change, linked parent ticket.

---

## Monitoring artifacts

| | |
|---|---|
| **Represents** | Proactive detection: metrics, alerts, dashboards |
| **Location** | [monitoring/](../monitoring/), [monitoring-guide.md](monitoring-guide.md) |
| **Key files** | `prometheus.yml`, `managed-services-alerts.yml`, Grafana dashboard JSON |
| **L2 usage** | Confirm alert; query Prometheus; check Grafana panel; correlate with incident timeline |

**ServiceNow mapping:** Event → Incident (alert integration). **Grafana:** operational dashboards.

---

## SQL troubleshooting evidence

| | |
|---|---|
| **Represents** | Before/after proof for database performance fixes |
| **Location** | [database/sql-troubleshooting/](../database/sql-troubleshooting/), [evidence/](../database/sql-troubleshooting/evidence/) |
| **Script** | [scripts/sql/run-slow-query-investigation.sh](../scripts/sql/run-slow-query-investigation.sh) |
| **L2 usage** | Capture EXPLAIN ANALYZE before change; attach to PRB/CHG; validate index usage after |

**Confluence mapping:** RCA attachment, change evidence folder.

---

## Process documents

| Document | Purpose |
|---|---|
| [incident-management-process.md](incident-management-process.md) | Incident lifecycle, triage, validation |
| [problem-management-process.md](problem-management-process.md) | RCA, permanent fix, known errors |
| [change-management-process.md](change-management-process.md) | Standard / Normal / Emergency changes |
| [service-improvement-plan.md](service-improvement-plan.md) | Continuous improvement backlog |

---

## Tool mapping summary

| Lab artifact | ServiceNow | Jira | Confluence |
|---|---|---|---|
| Incident record | Incident | Incident / Service request | Post-mortem page |
| Problem record | Problem | Bug / Story | Known error database |
| Change record | Change Request | Change / Release task | Change advisory |
| Runbook | Knowledge article | — | Runbook space |
| Alert rule | Event rule | — | — |
| EXPLAIN evidence | Attachment | Attachment | RCA doc |
| SLA matrix | SLA definition | Priority scheme | Ops handbook |

---

## How to read this portfolio as a hiring manager

1. **Operations thinking** — [INC-001](../incidents/INC-001-database-down.md): detect → investigate → restore → document
2. **Evidence discipline** — [PRB-001](../problem-records/PRB-001-recurring-database-timeout.md) + SQL evidence files
3. **Safe change** — [CHG-001](../changes/CHG-001-add-sql-index.md) with rollback and validation
4. **Runbook-driven** — alerts link to [runbooks/](../runbooks/)
5. **Improvement mindset** — [service-improvement-plan.md](service-improvement-plan.md)

This is the workflow a 2nd-level Managed Services engineer is expected to operate every day.
