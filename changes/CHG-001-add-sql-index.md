# CHG-001 — Add SQL Index

## Change ID

CHG-001

## Title

Add composite index on `cases(status, updated_at)` to resolve search timeouts

## Change Type

Normal — planned database change

## Reason

Permanent fix for [PRB-001](../problem-records/PRB-001-recurring-database-timeout.md). Recurring connection timeouts and slow search caused by sequential scans on high-traffic query pattern.

## Risk

| Factor | Assessment |
|---|---|
| Schema change | Low — index only, no data mutation |
| Lock impact | Medium — mitigated with `CONCURRENTLY` |
| Rollback | Low — drop index if performance regresses |
| Blast radius | Search and read workloads on `cases` table |

**Overall risk:** Medium-Low

## Impact

- Expected: P95 search latency reduction from ~8s to < 500ms
- Brief increased I/O during index build
- No application downtime if `CONCURRENTLY` used correctly
- Connection pool pressure should decrease post-deployment

## Implementation Plan

1. **Pre-check:** Capture baseline query plan and P95 latency in Grafana
2. **Staging:** Apply index in staging; run load test for 30 min
3. **Production window:** Tuesday 03:00–04:00 UTC (low traffic)
4. **Execute:**
   ```sql
   CREATE INDEX CONCURRENTLY idx_cases_status_updated_at
   ON cases(status, updated_at);
   ```
5. **Post-check:** Verify index usage via `EXPLAIN ANALYZE` on representative query
6. **Monitor:** 24-hour observation on connection pool and latency metrics

## Rollback Plan

```sql
DROP INDEX CONCURRENTLY IF EXISTS idx_cases_status_updated_at;
```

Revert to pre-change query plan. No application redeploy required.

## Validation Plan

- [ ] `EXPLAIN` shows index scan on search query
- [ ] P95 `/api/v1/search` latency < 1s
- [ ] `hikari_connections_pending` = 0 under peak simulation
- [ ] No new database alerts for 24 hours
- [ ] Update PRB-001 status to closed

## Approval Notes

- Approved by: Team Lead (Managed Services)
- DBA review: Recommended for production `CONCURRENTLY` syntax
- Maintenance window communicated to service owner
- Linked problem: PRB-001

## Result

*Pending implementation — Milestone 4+*

Planned outcome: Index deployed successfully; search timeouts eliminated; PRB-001 closed.
