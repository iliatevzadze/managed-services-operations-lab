# CHG-004 — Update Environment Variable

## Change ID

CHG-004

## Title

Increase `BATCH_CONCURRENCY` from 2 to 8 for faster report generation

## Change Type

Normal — application configuration change

## Reason

Business request to reduce nightly report generation time from ~45 min to ~15 min. Configuration change applied via Kubernetes ConfigMap without accompanying resource limit review.

**Unintended consequence:** Triggered [INC-003](../incidents/INC-003-container-restart-loop.md) — OOMKilled restart loop.

## Risk

| Factor | Assessment (at approval time) |
|---|---|
| Config only | Assessed Low — **underestimated** |
| Memory impact | **Not assessed** — gap in process |
| Rollback | Low — revert ConfigMap value |

**Overall risk:** Reassessed as Medium-High after incident. Process gap identified.

## Impact

- **Intended:** Faster batch report completion
- **Actual:** Pod OOMKilled; 33% capacity loss; intermittent 502/503
- Incident INC-003 opened; emergency revert during incident
- Led to problem record PRB-002 and health check improvement CHG-005

## Implementation Plan

1. Update ConfigMap `spring-support-api-config`:
   ```yaml
   BATCH_CONCURRENCY: "8"
   ```
2. Rolling restart via `kubectl rollout restart deployment/spring-support-api`
3. Monitor batch job completion time
4. Validate report output integrity

**Revised plan (post-incident):**

1. Revert `BATCH_CONCURRENCY` to `"2"` immediately
2. Increase memory limit to 768Mi before any re-attempt
3. Staging load test required before re-applying concurrency increase
4. Pair with CHG-005 health check improvements

## Rollback Plan

```bash
kubectl patch configmap spring-support-api-config \
  --patch '{"data":{"BATCH_CONCURRENCY":"2"}}'
kubectl rollout restart deployment/spring-support-api
```

Executed during INC-003 — successful.

## Validation Plan

- [ ] Batch job completes within target duration
- [ ] Pod memory stays below 80% of limit during batch
- [ ] Zero restarts for 1 hour post-change
- [ ] Report output row counts match baseline

**Post-incident validation (revert):**

- [x] All replicas stable — 0 restarts for 45 min
- [x] Memory usage below 70% at peak
- [ ] Re-attempt deferred pending PRB-002 closure

## Approval Notes

- Originally approved: Team Lead (Normal change)
- **Lesson learned:** Resource-affecting env vars require memory review checklist
- Process update: add to change management template
- Linked incident: INC-003, problem: PRB-002

## Result

**Reverted.** Original change caused INC-003. `BATCH_CONCURRENCY` restored to 2. Concurrency increase on hold until memory limits and health checks updated per PRB-002 / CHG-005.
