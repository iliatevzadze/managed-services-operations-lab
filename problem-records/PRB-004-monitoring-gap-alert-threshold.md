# PRB-004 — Monitoring Gap: Alert Threshold

## Problem ID

PRB-004

## Title

CPU alert threshold too sensitive — alert fatigue and missed real incidents

## Related Incidents

- INC-012 (planned) — false-positive CPU pages during scheduled batch window
- INC-013 (planned) — real CPU issue delayed due to alert silencing after noise

## Business Impact

- On-call engineers silenced repeated false alerts → slower response to genuine P2
- Team confidence in monitoring degraded
- Risk of SLA breach if real high-CPU incident not acted on promptly

## Technical Symptoms

- `HighCPUUsage` fires at 70% sustained 5 min during normal batch processing
- CPU returns to baseline without intervention — not actionable
- Same alert threshold across all environments (dev/staging/prod)
- No business-hours vs. batch-window exception

## Root Cause Analysis

**Root cause:** Alert rule `HighCPUUsage` set at 70% for 5 minutes without baseline analysis. Legitimate batch jobs at 02:00 and 14:00 UTC routinely reach 65–75% CPU — indistinguishable from incident-level load from alerting perspective.

**Contributing factors:**

- No alert review cadence after initial setup
- Missing dashboard annotation for expected batch windows
- No severity differentiation (warning vs. critical)

## Permanent Fix

Implement [CHG-002](../changes/CHG-002-adjust-monitoring-threshold.md):

- Raise warning threshold to 80% for 10 min
- Critical threshold at 90% for 5 min
- Add `unless on(batch_window)` inhibition or separate recording rule
- Document expected batch CPU profile in monitoring guide

## Prevention

- Quarterly alert review: false positive rate per rule
- Require 7-day baseline before setting production thresholds
- Test alert rules in staging with load simulation

## Monitoring Improvement

- Track `ALERTS{alertstate="firing"}` count per rule per week
- Add composite alert: high CPU **and** elevated latency **and** error rate
- Runbook link in all Alertmanager annotations

## Related Change Record

[changes/CHG-002-adjust-monitoring-threshold.md](../changes/CHG-002-adjust-monitoring-threshold.md)
