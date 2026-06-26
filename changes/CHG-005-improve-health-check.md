# CHG-005 — Improve Health Check

## Change ID

CHG-005

## Title

Separate readiness and liveness probes; extend startup grace period

## Change Type

Normal — Kubernetes deployment manifest change

## Reason

Permanent fix component for [PRB-002](../problem-records/PRB-002-repeated-container-restarts.md). Current liveness probe kills pods during legitimate slow starts (JVM warm-up, post-OOM recovery) and does not verify database readiness before receiving traffic.

Related incident: [INC-003](../incidents/INC-003-container-restart-loop.md)

## Risk

| Factor | Assessment |
|---|---|
| Probe misconfiguration | Medium — incorrect values could hide unhealthy pods |
| Traffic routing | Low — readiness gates load balancer inclusion |
| Rollback | Low — revert deployment manifest |

**Overall risk:** Low-Medium

## Impact

- Pods not killed during JVM warm-up (up to 90s `startupProbe`)
- Traffic only routed when app AND database ready
- Reduced false restart cycles
- Brief rolling update during deployment (~3 min per replica)

## Implementation Plan

1. Update `k8s/deployment.yaml` (Milestone 5+):

   ```yaml
   startupProbe:
     httpGet:
       path: /actuator/health/liveness
       port: 8080
     failureThreshold: 18
     periodSeconds: 5        # 90s max startup

   readinessProbe:
     httpGet:
       path: /actuator/health/readiness
       port: 8080
     periodSeconds: 10
     failureThreshold: 3

   livenessProbe:
     httpGet:
       path: /actuator/health/liveness
       port: 8080
     periodSeconds: 15
     failureThreshold: 3
     initialDelaySeconds: 0  # startupProbe handles warm-up
   ```

2. Ensure Spring Boot actuator exposes separate readiness (includes DB check)
3. Deploy to staging; simulate slow start and DB unavailable
4. Production deploy during maintenance window
5. Monitor restart count for 48 hours

## Rollback Plan

1. `kubectl rollout undo deployment/spring-support-api`
2. Or revert manifest to previous probe configuration from Git
3. Confirm pods healthy on previous probe settings

## Validation Plan

- [ ] Pod survives JVM warm-up without restart
- [ ] Pod removed from service endpoints when DB down (readiness fails)
- [ ] Pod restarted only on true liveness failure (simulated hang)
- [ ] Zero OOM-related restart loops for 48 hours
- [ ] PRB-002 closure criteria met

## Approval Notes

- Approved by: Team Lead + Platform Engineer
- Staging validation required before production
- Linked problem: PRB-002
- Complements memory review process from CHG-004 lessons

## Result

*Pending implementation — Milestone 5+*

Planned outcome: Restart rate due to probe misconfiguration reduced to zero; improved traffic safety during partial failures.
