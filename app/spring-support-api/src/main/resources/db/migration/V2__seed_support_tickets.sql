INSERT INTO support_tickets (
    external_id, customer_name, service_name, priority, status, title, description, created_at, updated_at
) VALUES
(
    'TKT-1001',
    'Northwind Logistics',
    'Support Portal API',
    'P1',
    'INVESTIGATING',
    'PostgreSQL database unreachable',
    'Customer reports complete API outage. Monitoring shows PostgresDown alert. Application logs contain Connection refused to jdbc:postgresql://postgres:5432/supportdb. Nginx returning 503. Aligns with INC-001 database-down scenario.',
    TIMESTAMP '2026-06-26 07:00:00',
    TIMESTAMP '2026-06-26 09:30:00'
),
(
    'TKT-1002',
    'Helios Retail Group',
    'Support Portal API',
    'P2',
    'OPEN',
    'Elevated HTTP 500 errors on case search',
    'Since release v1.4.2, approximately 35% of GET /api/v1/search requests return HTTP 500. Stack traces show NullPointerException when optional status filter is omitted. Correlates with INC-002 application-500-errors scenario.',
    TIMESTAMP '2026-06-26 05:00:00',
    TIMESTAMP '2026-06-26 08:00:00'
),
(
    'TKT-1003',
    'Summit Financial',
    'Support Portal API',
    'P3',
    'INVESTIGATING',
    'Slow API response on ticket list endpoint',
    'P95 latency on GET /tickets exceeded 8 seconds during peak hours. Database shows long-running sequential scan on support_tickets. Connection pool wait times elevated. Aligns with slow-sql-query runbook and PRB-001.',
    TIMESTAMP '2026-06-26 03:00:00',
    TIMESTAMP '2026-06-26 08:15:00'
),
(
    'TKT-1004',
    'BluePeak Manufacturing',
    'PostgreSQL Backup Service',
    'P2',
    'OPEN',
    'Nightly database backup job failed',
    'Backup job backup-supportdb-20250625 exited with code 1. Disk quota exceeded on backup volume. No successful backup in last 26 hours. Maintenance window at risk. Aligns with backup-and-restore runbook.',
    TIMESTAMP '2026-06-26 01:00:00',
    TIMESTAMP '2026-06-26 07:00:00'
);
