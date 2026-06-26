# CHG-003 — Rollback Bad Release

## Change ID

CHG-003

## Title

Emergency rollback of spring-support-api v1.4.2 to v1.4.1

## Change Type

Emergency — during active incident [INC-002](../incidents/INC-002-application-500-errors.md)

## Reason

Release v1.4.2 caused NullPointerException on case search when optional `status` parameter omitted. Customer-facing 500 errors at 35% rate on affected endpoints. Fix-forward ETA unknown; rollback restores known-good state fastest.

## Risk

| Factor | Assessment |
|---|---|
| Rollback itself | Low — reverting to previous stable revision |
| Data loss | None — stateless API rollback |
| Missed forward fix | Low — dev patch planned post-stabilization |

**Overall risk:** Low (rollback reduces incident risk)

## Impact

- Immediate restoration of search endpoint stability
- Brief connection drain during pod replacement (< 2 min per replica)
- v1.4.2 features unavailable until fixed re-release
- Customer comms required — incident update

## Implementation Plan

1. Verbal approval from incident commander at 14:18 UTC
2. Confirm target revision: `spring-support-api-6a2bc` (v1.4.1)
3. Execute rollback:
   ```bash
   kubectl rollout undo deployment/spring-support-api
   kubectl rollout status deployment/spring-support-api --timeout=300s
   ```
4. Validate health on all replicas
5. Monitor 5xx rate for 15 minutes
6. Notify customer liaison — service restored
7. Post-implementation review within 24 hours

## Rollback Plan

*N/A — this change IS the rollback.*

If rollback fails: pin deployment to specific revision `--to-revision=12`; escalate to platform team.

## Validation Plan

- [ ] All pods on v1.4.1 image digest
- [ ] 5xx rate < 0.1% for 15 min
- [ ] `curl` smoke tests on `/api/v1/search` with and without `status` param — 200
- [ ] INC-002 updated with resolution
- [ ] PRB-003 opened for permanent prevention

## Approval Notes

- Emergency verbal approval: Incident Commander + Team Lead
- Post-implementation review scheduled: next business day
- Developer notified to prepare v1.4.3 with fix

## Result

**Successful.** Rollout completed at 14:24 UTC. Error rate normalized within 10 minutes. INC-002 closed. PRB-003 opened. v1.4.3 release planned with expanded test coverage.
