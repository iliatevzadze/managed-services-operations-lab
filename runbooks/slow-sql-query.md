# Runbook: Slow SQL Query

## Overview

| Field | Value |
|---|---|
| **Symptom** | API latency elevated; database query duration high |
| **Typical alerts** | `SupportApiHighErrorRate`, elevated P95 latency, customer ticket |
| **Priority** | P2 |
| **Estimated time** | 45–120 min |
| **Lab investigation** | `./scripts/sql/run-slow-query-investigation.sh` |

## Detection

- Customer report: "ticket history search is slow"
- Grafana API latency panel elevated; database CPU moderate
- Application logs: slow request warnings, connection pool wait
- Prometheus: latency or error rate increase without app crash

## Impact check

```bash
# API health and latency context
curl -s http://localhost:18081/health | jq .
curl -s http://localhost:18080/actuator/prometheus | grep http_server_requests

# Active long-running queries
docker compose exec -T postgres psql -U supportuser -d supportdb -c "
  SELECT pid, now() - query_start AS duration, left(query, 80) AS query
  FROM pg_stat_activity
  WHERE state = 'active' AND query NOT LIKE '%pg_stat_activity%'
  ORDER BY duration DESC LIMIT 10;"
```

Assess: which customer/query pattern? How many concurrent users affected?

## Investigation steps

1. **Confirm API latency** — Which endpoints and customers affected?
2. **Identify slow query** — Application logs, `pg_stat_activity`, customer report details
3. **Run EXPLAIN ANALYZE** — Capture plan before any change (evidence)
4. **Check for sequential scan** — Missing index on filter columns?
5. **Review data volume** — Row count on target table
6. **Check locks** — Blocking queries delaying execution?
7. **Assess mitigation** — Index fix vs. kill long query (with DBA approval)

## SQL investigation commands

```bash
# Full lab workflow (Milestone 6)
./scripts/sql/run-slow-query-investigation.sh

# Manual EXPLAIN on running postgres
docker compose exec -T postgres psql -U supportuser -d supportdb \
  < database/sql-troubleshooting/02-before-index-explain.sql

# Row count on demo/production table
docker compose exec -T postgres psql -U supportuser -d supportdb \
  -c "SELECT COUNT(*) FROM support_ticket_events;"

# Host PostgreSQL access
psql -h localhost -p 15434 -U supportuser -d supportdb
```

## EXPLAIN ANALYZE steps

1. Reproduce slow query with representative filters (customer, date range, event type)
2. Run `EXPLAIN (ANALYZE, BUFFERS, FORMAT TEXT) <query>`
3. Save output to `database/sql-troubleshooting/evidence/before-index-explain.txt`
4. Look for: `Seq Scan`, high `rows`/`loops`, execution time in ms
5. Apply index per CHG-001
6. Re-run EXPLAIN; save to `after-index-explain.txt`
7. Confirm: `Index Scan` or `Bitmap Index Scan` on new index

## Index validation

```bash
# After applying index
docker compose exec -T postgres psql -U supportuser -d supportdb \
  < database/sql-troubleshooting/04-after-index-explain.sql

# Verify index exists
docker compose exec -T postgres psql -U supportuser -d supportdb -c "\d support_ticket_events"
```

- [ ] Plan uses `idx_support_ticket_events_customer_event_created`
- [ ] Execution time lower than before evidence
- [ ] API P95 latency returned to baseline

## Resolution paths

| Root cause | Action |
|---|---|
| Missing index | Apply CHG-001; validate with EXPLAIN evidence |
| Lock contention | Identify blocker; coordinate kill with DBA |
| Stale statistics | `ANALYZE table` (document in change record) |
| N+1 query pattern | Escalate to development |
| Connection pool wait | Tune pool; check database-down symptoms |

## Rollback notes

```sql
DROP INDEX CONCURRENTLY IF EXISTS idx_support_ticket_events_customer_event_created;
```

Re-run EXPLAIN to confirm return to prior plan. Document rollback in change record if production index is removed.

## Validation

```bash
curl -s http://localhost:18081/tickets | jq 'length'
# Compare evidence files
diff <(grep 'Execution Time' database/sql-troubleshooting/evidence/before-index-explain.txt) \
     <(grep 'Execution Time' database/sql-troubleshooting/evidence/after-index-explain.txt) || true
```

- [ ] P95 latency returned to baseline
- [ ] Query plan shows index usage
- [ ] No new slow-query alerts for 24 hours
- [ ] PRB-001 and CHG-001 updated with evidence paths

## Escalation

Escalate to DBA / 3rd level if: index does not improve plan, table rewrite required, or query pattern needs application change.

## Prevention

- Quarterly `pg_stat_statements` review
- Index change checklist before production deploy
- Keep EXPLAIN evidence in `database/sql-troubleshooting/evidence/`
- Load test search endpoints before releases

## Related records

- Problem: [../problem-records/PRB-001-recurring-database-timeout.md](../problem-records/PRB-001-recurring-database-timeout.md)
- Change: [../changes/CHG-001-add-sql-index.md](../changes/CHG-001-add-sql-index.md)
- Script: [../scripts/sql/run-slow-query-investigation.sh](../scripts/sql/run-slow-query-investigation.sh)
