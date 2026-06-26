CREATE TABLE support_tickets (
    id              BIGSERIAL PRIMARY KEY,
    external_id     VARCHAR(64)  NOT NULL UNIQUE,
    customer_name   VARCHAR(255) NOT NULL,
    service_name    VARCHAR(255) NOT NULL,
    priority        VARCHAR(8)   NOT NULL,
    status          VARCHAR(32)  NOT NULL,
    title           VARCHAR(500) NOT NULL,
    description     TEXT         NOT NULL,
    created_at      TIMESTAMP    NOT NULL,
    updated_at      TIMESTAMP    NOT NULL
);

CREATE INDEX idx_support_tickets_status ON support_tickets (status);
CREATE INDEX idx_support_tickets_priority ON support_tickets (priority);
