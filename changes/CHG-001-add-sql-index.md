# CHG-001 — Add SQL Index

## Change ID

CHG-001

## Title

Add composite index on `support_ticket_events` for ticket history search

## Change Type

Normal — planned database change

## Reason

Permanent fix for [PRB-001](../problem-records/PRB-001-recurring-database-timeout.md).

Customer **Summit Financial** reported slow ticket history search. SQL investigation (Milestone 6) confirmed sequential scan on `support_ticket_events` when filtering by `customer_name`, `event_type`, and `created_at`. Missing composite index is the root cause.

## Risk

| Factor | Assessment |
|---|---|
| Schema change | Low — index only, no data mutation |
| Lock impact | Low in lab; Medium in production — use `CONCURRENTLY` |
| Rollback | Low — drop index if performance regresses |
| Blast radius | Read workloads on `support_ticket_events` and related search endpoints |

**Overall risk:** Low (lab) / Medium-Low (production with CONCURRENTLY)

## Impact

- Expected: query execution time reduction from sequential scan to index scan
- Brief increased I/O during index build
- No application downtime if `CONCURRENTLY` used in production
- Connection pool pressure should decrease post-deployment

## Implementation Plan

1. **Pre-check:** Run lab investigation script; capture before evidence
   ```bash
   ./scripts/sql/run-slow-query-investigation.sh
   ```
2. **Lab validation:** Apply index via `database/sql-troubleshooting/03-add-index.sql`
3. **Production window:** Tuesday 03:00–04:00 UTC (low traffic)
4. **Production execute:**
   ```sql
   CREATE INDEX CONCURRENTLY idx_support_ticket_events_customer_event_created
       ON support_ticket_events (customer_name, event_type, created_at DESC);
   ```
5. **Post-check:** `EXPLAIN ANALYZE` confirms index scan
6. **Monitor:** 24-hour observation on connection pool and API P95 latency

## Rollback Plan

```sql
DROP INDEX CONCURRENTLY IF EXISTS idx_support_ticket_events_customer_event_created;
```

Lab cleanup (optional):

```bash
docker compose exec -T postgres psql -U supportuser -d supportdb \
  < database/sql-troubleshooting/05-cleanup-slow-query-demo.sql
```

Revert to pre-change query plan. No application redeploy required.

## Validation Plan

- [ ] Before evidence captured: `database/sql-troubleshooting/evidence/before-index-explain.txt`
- [ ] `EXPLAIN ANALYZE` shows **Index Scan** (not Seq Scan) after index
- [ ] After evidence captured: `database/sql-troubleshooting/evidence/after-index-explain.txt`
- [ ] Execution time improved in after vs before comparison
- [ ] API P95 search latency < 1s under load test
- [ ] `hikari_connections_pending` = 0 under peak simulation
- [ ] PRB-001 status updated to closed

## Before / After Evidence

| Phase | Location |
|---|---|
| Before index | [database/sql-troubleshooting/evidence/before-index-explain.txt](../database/sql-troubleshooting/evidence/before-index-explain.txt) |
| After index | [database/sql-troubleshooting/evidence/after-index-explain.txt](../database/sql-troubleshooting/evidence/after-index-explain.txt) |

SQL scripts: [database/sql-troubleshooting/](../database/sql-troubleshooting/)

## Approval Notes

- Approved by: Team Lead (Managed Services)
- DBA review: Recommended `CREATE INDEX CONCURRENTLY` for production
- Maintenance window communicated to service owner
- Linked problem: PRB-001

## Result

**Lab: successful (Milestone 6).** Index `idx_support_ticket_events_customer_event_created` applied. Before evidence shows sequential scan; after evidence shows index scan with improved execution time. Evidence files committed for portfolio review.

**Production:** Scheduled per maintenance window.
