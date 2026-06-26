# CHG-002 — Adjust Monitoring Threshold

## Change ID

CHG-002

## Title

Tune CPU alert thresholds and add batch-window inhibition for HighCPUUsage

## Change Type

Normal — monitoring configuration change

## Reason

Permanent fix for [PRB-004](../problem-records/PRB-004-monitoring-gap-alert-threshold.md). Current 70% threshold causes false positives during scheduled batch jobs, leading to alert fatigue.

## Risk

| Factor | Assessment |
|---|---|
| Config change only | Low |
| Missed real incident | Medium — mitigated by composite critical alert |
| Rollback | Low — revert Prometheus rule file |

**Overall risk:** Low

## Impact

- Reduced false-positive pages during batch windows
- On-call may need brief orientation on new threshold levels
- Critical incidents still caught at 90% + correlation rules
- No customer-facing service impact

## Implementation Plan

1. Export 30-day CPU baseline per environment from Prometheus
2. Update `monitoring/prometheus/alerts.yml` (Milestone 2+):
   - Warning: `cpu_usage > 80%` for 10m
   - Critical: `cpu_usage > 90%` for 5m AND `http_latency_p95 > 2s`
3. Add inhibition rule for known batch cron windows
4. Apply via `promtool check rules` validation
5. Reload Prometheus configuration
6. Observe for 7 days — track false positive count

## Rollback Plan

1. Restore previous `alerts.yml` from Git revision
2. Reload Prometheus: `curl -X POST http://localhost:9090/-/reload`
3. Confirm previous `HighCPUUsage` rule active

## Validation Plan

- [ ] `promtool check rules` passes
- [ ] Synthetic high-CPU test fires critical alert in staging
- [ ] Batch window at 02:00 UTC does not page on-call (warning only or suppressed)
- [ ] Alertmanager routes warning vs. critical to correct channels
- [ ] Update PRB-004 and monitoring guide

## Approval Notes

- Approved by: Team Lead
- On-call team notified of threshold change before go-live
- Linked problem: PRB-004

## Result

*Pending implementation — Milestone 2+*

Planned outcome: False positive rate reduced by > 80%; on-call confidence restored.
