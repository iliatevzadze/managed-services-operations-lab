package com.managedservices.supportapi.dto;

import com.managedservices.supportapi.domain.Priority;
import com.managedservices.supportapi.domain.TicketStatus;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;
import jakarta.validation.constraints.Size;

public record CreateTicketRequest(
        @NotBlank @Size(max = 64) String externalId,
        @NotBlank @Size(max = 255) String customerName,
        @NotBlank @Size(max = 255) String serviceName,
        @NotNull Priority priority,
        @NotNull TicketStatus status,
        @NotBlank @Size(max = 500) String title,
        @NotBlank String description
) {
}
