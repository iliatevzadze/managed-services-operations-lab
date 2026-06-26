# PRB-003 — Repeated HTTP 500 Errors

## Problem ID

PRB-003

## Title

Recurring HTTP 500 errors after releases — insufficient pre-production validation

## Related Incidents

- [INC-002](../incidents/INC-002-application-500-errors.md) — NPE in search after v1.4.2
- INC-011 (planned) — 500 on webhook callback null handling

## Business Impact

- Customer-visible errors erode trust in platform stability
- Repeated rollbacks consume change windows and engineering time
- Support ticket volume spikes 2–3x during error events

## Technical Symptoms

- Elevated `status=500` rate correlated with deployment events
- Stack traces showing unhandled nulls, validation gaps, or API contract breaks
- Errors isolated to new revision replicas
- Database and infrastructure metrics typically normal

## Root Cause Analysis

**Trend analysis (90 days):**

| Release | Defect type | Could have been caught in staging? |
|---|---|---|
| v1.4.2 | NPE on optional param | Yes — missing API test |
| v1.3.8 | Wrong default config | Yes — config diff review |
| v1.3.1 | Serialization error | Partial — integration test gap |

**Root cause:** Release pipeline lacks mandatory API contract and optional-parameter test coverage for high-traffic endpoints. Staging smoke tests cover happy path only.

## Permanent Fix

1. Add integration test suite for `/api/v1/search` and `/api/v1/cases` including edge cases
2. Gate production deploy on staging error-rate soak (15 min, < 0.1% 5xx)
3. Require developer sign-off on rollback plan in change record for Normal changes
4. Document release validation in change management process

## Prevention

- Blameless post-incident review within 5 days of P2+ release incidents
- Track "defect escape rate" per release
- Pair 2nd level with dev on first deploy of new major features

## Monitoring Improvement

- Canary analysis: compare 5xx rate new vs. old revision during rollout
- Alert annotation linking to application-500-errors runbook
- SLO burn rate alert for error budget consumption

## Related Change Record

[changes/CHG-003-rollback-bad-release.md](../changes/CHG-003-rollback-bad-release.md)
