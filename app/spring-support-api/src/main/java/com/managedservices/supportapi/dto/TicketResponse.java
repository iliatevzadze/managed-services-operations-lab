package com.managedservices.supportapi.dto;

import com.managedservices.supportapi.domain.Priority;
import com.managedservices.supportapi.domain.SupportTicket;
import com.managedservices.supportapi.domain.TicketStatus;
import java.time.Instant;

public record TicketResponse(
        Long id,
        String externalId,
        String customerName,
        String serviceName,
        Priority priority,
        TicketStatus status,
        String title,
        String description,
        Instant createdAt,
        Instant updatedAt
) {

    public static TicketResponse from(SupportTicket ticket) {
        return new TicketResponse(
                ticket.getId(),
                ticket.getExternalId(),
                ticket.getCustomerName(),
                ticket.getServiceName(),
                ticket.getPriority(),
                ticket.getStatus(),
                ticket.getTitle(),
                ticket.getDescription(),
                ticket.getCreatedAt(),
                ticket.getUpdatedAt()
        );
    }
}
