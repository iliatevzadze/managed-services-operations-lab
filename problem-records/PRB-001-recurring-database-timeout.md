# PRB-001 — Recurring Database Timeout

## Problem ID

PRB-001

## Title

Recurring database connection timeouts on case search under peak load

## Related Incidents

- [INC-001](../incidents/INC-001-database-down.md) — full outage (disk); exposed timeout sensitivity
- INC-006 (planned) — slow search during peak hours
- INC-009 (planned) — connection pool exhaustion

## Business Impact

- Intermittent 5–15 second delays on case search
- Support agent productivity loss estimated 10–15 min per agent per shift during peaks
- Customer satisfaction risk if delays persist
- Contributes to SLA latency budget consumption

## Technical Symptoms

- Application logs: `HikariPool - Connection is not available, request timed out after 30000ms`
- PostgreSQL: elevated `pg_stat_activity` count during peak
- Slow query on `cases` table — sequential scan on `status + updated_at` filter
- CPU on database moderate; not primary bottleneck — query plan is

## Root Cause Analysis

**Timeline:**

1. Case volume grew 40% over 6 months without index review
2. Search endpoint uses composite filter without supporting index
3. Under concurrent load, long-running queries hold connections
4. Connection pool (size 10) exhausted → timeouts propagate to API

**Root cause:** Missing composite index on `cases(status, updated_at)` combined with fixed connection pool size inadequate for peak concurrency.

**Contributing factors:** No query performance monitoring alert; staging load test not representative of production peak.

## Permanent Fix

Add composite index via [CHG-001](../changes/CHG-001-add-sql-index.md):

```sql
CREATE INDEX CONCURRENTLY idx_cases_status_updated_at ON cases(status, updated_at);
```

Review and tune HikariCP `maximum-pool-size` after index deployment based on metrics.

## Prevention

- Quarterly slow-query review from `pg_stat_statements`
- Load test search endpoints before major releases
- Index change checklist in change management process
- Document query patterns in architecture overview

## Monitoring Improvement

- Alert on `hikari_connections_pending` > 0 for 5 minutes
- Dashboard panel: P95 query duration for search endpoints
- Weekly report: top 10 slow queries from PostgreSQL exporter

## Related Change Record

[changes/CHG-001-add-sql-index.md](../changes/CHG-001-add-sql-index.md)
