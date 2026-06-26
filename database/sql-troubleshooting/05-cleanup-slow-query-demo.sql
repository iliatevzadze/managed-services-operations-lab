-- Milestone 6: cleanup slow query demo (optional lab reset)

DROP INDEX IF EXISTS idx_support_ticket_events_customer_event_created;
DROP TABLE IF EXISTS support_ticket_events;
