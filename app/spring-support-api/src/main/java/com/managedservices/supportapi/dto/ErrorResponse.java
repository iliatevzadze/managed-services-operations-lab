package com.managedservices.supportapi.dto;

import java.time.Instant;
import java.util.List;

public record ErrorResponse(
        String error,
        String message,
        Instant timestamp,
        List<String> details
) {

    public static ErrorResponse of(String error, String message) {
        return new ErrorResponse(error, message, Instant.now(), List.of());
    }

    public static ErrorResponse of(String error, String message, List<String> details) {
        return new ErrorResponse(error, message, Instant.now(), details);
    }
}
