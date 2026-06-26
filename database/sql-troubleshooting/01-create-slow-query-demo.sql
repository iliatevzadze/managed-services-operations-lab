-- Milestone 6: slow query demo — create table and seed data
-- Scenario: customer reports slow ticket history search

DROP TABLE IF EXISTS support_ticket_events;

CREATE TABLE support_ticket_events (
    id                BIGSERIAL PRIMARY KEY,
    ticket_external_id VARCHAR(50)  NOT NULL,
    customer_name     VARCHAR(150) NOT NULL,
    event_type        VARCHAR(50)  NOT NULL,
    event_message     TEXT         NOT NULL,
    created_at        TIMESTAMP    NOT NULL
);

INSERT INTO support_ticket_events (
    ticket_external_id, customer_name, event_type, event_message, created_at
)
SELECT
    'TKT-' || LPAD(g::text, 6, '0'),
    CASE WHEN g % 400 = 0 THEN 'Summit Financial'
         ELSE 'Customer-' || (g % 300)::text
    END,
    CASE (g % 4)
        WHEN 0 THEN 'STATUS_CHANGE'
        WHEN 1 THEN 'COMMENT'
        WHEN 2 THEN 'ASSIGNMENT'
        ELSE 'ESCALATION'
    END,
    'Ticket event ' || g || ' — status update recorded in support portal',
    NOW() - ((g % 90) || ' days')::interval - ((g % 3600) || ' seconds')::interval
FROM generate_series(1, 100000) AS g;

ANALYZE support_ticket_events;

SELECT COUNT(*) AS total_rows FROM support_ticket_events;
