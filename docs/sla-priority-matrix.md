# SLA and Priority Matrix

## Priority definitions

| Priority | Label | Description | Initial response | Update cadence |
|---|---|---|---|---|
| **P1** | Critical | Complete or severe service outage; major SLA breach risk | 15 min | Every 30 min |
| **P2** | High | Significant degradation; workaround may exist | 1 hour | Every 2 hours |
| **P3** | Medium | Limited impact; non-critical function affected | 4 hours | Daily |
| **P4** | Low | Minor issue; cosmetic or low-user-impact | Next business day | As needed |

## Impact vs. urgency matrix

|  | **High urgency** | **Medium urgency** | **Low urgency** |
|---|---|---|---|
| **High impact** | P1 | P1–P2 | P2 |
| **Medium impact** | P2 | P3 | P3 |
| **Low impact** | P3 | P4 | P4 |

## Service availability targets

| Service | Monthly target | Measurement |
|---|---|---|
| Support Portal API | 99.5% | Synthetic + error-rate composite |
| PostgreSQL (managed) | 99.9% | Provider SLA + connection health |

## Escalation triggers by priority

| Priority | Escalate to 3rd level when |
|---|---|
| P1 | No progress within 30 min, or root cause requires code change |
| P2 | No progress within 2 hours, or recurring within 7 days |
| P3 | Problem record opened; permanent fix needed |
| P4 | Batch into change window or improvement backlog |

## Communication expectations

- **P1/P2:** Status updates to service owner and customer liaison
- **All:** Incident record updated before handover or shift end
- **Post-resolution:** Link incident → problem (if recurring) → change (if fix deployed)

## Examples in this lab

| Incident | Priority | Rationale |
|---|---|---|
| INC-001 Database down | P1 | Full API unavailable |
| INC-002 HTTP 500 errors | P2 | Degraded; partial function may work |
| INC-003 Restart loop | P2 | Service unstable; intermittent availability |

## Related documents

- [escalation-model.md](escalation-model.md)
- [incident-management-process.md](incident-management-process.md)
