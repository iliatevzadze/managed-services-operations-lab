package com.managedservices.supportapi.dto;

import java.time.Instant;

public record HealthResponse(
        String status,
        String service,
        String database,
        long ticketCount,
        Instant timestamp
) {
}
