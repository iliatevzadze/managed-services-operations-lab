# Runbook: Slow SQL Query

## Overview

| Field | Value |
|---|---|
| **Symptom** | API latency elevated; database query duration high |
| **Typical alerts** | `HighLatency`, `SlowQueryDetected`, `DatabaseQueryDuration` |
| **Priority** | P2 |
| **Estimated time** | 45–120 min |

## Investigation steps

1. **Confirm API latency** — Which endpoints affected?
2. **Identify slow queries** — Application logs, pg_stat_statements, APM
3. **Check execution plan** — Missing index? Seq scan on large table?
4. **Review data volume** — Recent bulk load or migration?
5. **Check locks** — Blocking queries?
6. **Assess quick mitigation** — Kill long-running query if safe

## Commands

```bash
# Active queries (PostgreSQL)
psql -h <host> -U <user> -d <db> -c "
  SELECT pid, now() - query_start AS duration, query, state
  FROM pg_stat_activity
  WHERE state != 'idle'
  ORDER BY duration DESC
  LIMIT 10;"

# Explain plan (non-production or with care)
psql -c "EXPLAIN ANALYZE SELECT ..."

# Application slow query logs
docker compose logs spring-support-api | grep -i "slow\|query"
```

## Resolution paths

| Root cause | Action |
|---|---|
| Missing index | Schedule CHG-001; verify in staging first |
| Lock contention | Identify blocker; coordinate kill with DBA |
| Stale statistics | `ANALYZE` table (change record if production) |
| N+1 query pattern | Escalate to development |
| Connection pool wait | Tune pool; check database-down symptoms |

## Validation

- [ ] P95 latency returned to baseline
- [ ] Query plan shows index usage (post-fix)
- [ ] No new slow-query alerts for 24 hours

## Related records

- Problem: [../problem-records/PRB-001-recurring-database-timeout.md](../problem-records/PRB-001-recurring-database-timeout.md)
- Change: [../changes/CHG-001-add-sql-index.md](../changes/CHG-001-add-sql-index.md)
