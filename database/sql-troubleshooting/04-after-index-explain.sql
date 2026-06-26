-- Milestone 6: AFTER index — EXPLAIN ANALYZE (validate index usage)

EXPLAIN (ANALYZE, BUFFERS, FORMAT TEXT)
SELECT
    id,
    ticket_external_id,
    customer_name,
    event_type,
    event_message,
    created_at
FROM support_ticket_events
WHERE customer_name = 'Summit Financial'
  AND event_type = 'STATUS_CHANGE'
  AND created_at >= NOW() - INTERVAL '30 days'
ORDER BY created_at DESC;
