-- Milestone 6: permanent fix — composite index for ticket history search
-- Related change: CHG-001

CREATE INDEX idx_support_ticket_events_customer_event_created
    ON support_ticket_events (customer_name, event_type, created_at DESC);

ANALYZE support_ticket_events;
