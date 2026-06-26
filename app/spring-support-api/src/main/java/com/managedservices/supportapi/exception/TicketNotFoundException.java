package com.managedservices.supportapi.exception;

public class TicketNotFoundException extends RuntimeException {

    public TicketNotFoundException(Long id) {
        super("Support ticket not found: id=" + id);
    }
}
