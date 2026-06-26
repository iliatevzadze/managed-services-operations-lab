# PRB-001 — Recurring Database Timeout

## Problem ID

PRB-001

## Title

Recurring database connection timeouts on ticket history search under peak load

## Related Incidents

- [INC-001](../incidents/INC-001-database-down.md) — full outage (disk); exposed timeout sensitivity
- INC-005 (planned) — slow ticket history search degrading API
- INC-009 (planned) — connection pool exhaustion

## Business Impact

- Intermittent 5–15 second delays on ticket history search
- Support agent productivity loss estimated 10–15 min per agent per shift during peaks
- Customer **Summit Financial** reported slow status-change history lookup
- Customer satisfaction risk if delays persist
- Contributes to SLA latency budget consumption

## Technical Symptoms

- Application logs: `HikariPool - Connection is not available, request timed out after 30000ms`
- PostgreSQL: elevated `pg_stat_activity` count during peak
- Slow query filtering `customer_name`, `event_type`, `created_at` — sequential scan
- API P95 latency spike on search endpoints; database CPU moderate — query plan is the bottleneck

## Root Cause Analysis

**Timeline:**

1. Ticket event volume grew without index review on `support_ticket_events`
2. Search query filters on `customer_name`, `event_type`, and `created_at` without supporting index
3. Under concurrent load, long-running sequential scans hold connections
4. Connection pool (size 10) exhausted → timeouts propagate to API

**Root cause:** Missing composite index on `(customer_name, event_type, created_at)` causing sequential scan on ~100k+ rows.

**Contributing factors:** No query performance monitoring alert; no EXPLAIN review before peak season.

## SQL Investigation (Milestone 6 — completed)

**Lab reproduction:** `./scripts/sql/run-slow-query-investigation.sh`

| Phase | Finding |
|---|---|
| **Before index** | `EXPLAIN ANALYZE` shows **Seq Scan** on `support_ticket_events`; execution time ~tens of ms on 100k rows (worse at production scale) |
| **Evidence** | [database/sql-troubleshooting/evidence/before-index-explain.txt](../database/sql-troubleshooting/evidence/before-index-explain.txt) |
| **After index** | **Index Scan** using `idx_support_ticket_events_customer_event_created`; execution time reduced |
| **Evidence** | [database/sql-troubleshooting/evidence/after-index-explain.txt](../database/sql-troubleshooting/evidence/after-index-explain.txt) |

**Query under investigation:**

```sql
SELECT id, ticket_external_id, customer_name, event_type, event_message, created_at
FROM support_ticket_events
WHERE customer_name = 'Summit Financial'
  AND event_type = 'STATUS_CHANGE'
  AND created_at >= NOW() - INTERVAL '30 days'
ORDER BY created_at DESC;
```

## Permanent Fix

Add composite index via [CHG-001](../changes/CHG-001-add-sql-index.md):

```sql
CREATE INDEX idx_support_ticket_events_customer_event_created
    ON support_ticket_events (customer_name, event_type, created_at DESC);
```

Production analogue: apply same pattern to high-traffic tables (e.g. `cases(status, updated_at)`). Review HikariCP `maximum-pool-size` after deployment.

## Prevention

- Quarterly slow-query review from `pg_stat_statements`
- Capture `EXPLAIN ANALYZE` evidence before and after index changes
- Load test search endpoints before major releases
- Index change checklist in change management process
- Run `./scripts/sql/run-slow-query-investigation.sh` as onboarding drill

## Monitoring Improvement

- Alert on `hikari_connections_pending` > 0 for 5 minutes
- Dashboard panel: P95 query duration for search endpoints
- Weekly report: top 10 slow queries from PostgreSQL
- Compare before/after evidence files in `database/sql-troubleshooting/evidence/`

## Related Change Record

[changes/CHG-001-add-sql-index.md](../changes/CHG-001-add-sql-index.md)

**Status:** Lab validated (M6). Production deployment per change window.
