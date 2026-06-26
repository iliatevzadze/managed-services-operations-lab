package com.managedservices.supportapi.service;

import com.managedservices.supportapi.domain.SupportTicket;
import com.managedservices.supportapi.dto.CreateTicketRequest;
import com.managedservices.supportapi.dto.TicketResponse;
import com.managedservices.supportapi.exception.TicketNotFoundException;
import com.managedservices.supportapi.repository.SupportTicketRepository;
import java.util.List;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

@Service
public class TicketService {

    private static final Logger log = LoggerFactory.getLogger(TicketService.class);

    private final SupportTicketRepository ticketRepository;

    public TicketService(SupportTicketRepository ticketRepository) {
        this.ticketRepository = ticketRepository;
    }

    @Transactional(readOnly = true)
    public List<TicketResponse> findAll() {
        List<TicketResponse> tickets = ticketRepository.findAll().stream()
                .map(TicketResponse::from)
                .toList();
        log.info("Listed support tickets: count={}", tickets.size());
        return tickets;
    }

    @Transactional(readOnly = true)
    public TicketResponse findById(Long id) {
        return ticketRepository.findById(id)
                .map(TicketResponse::from)
                .orElseThrow(() -> {
                    log.warn("Support ticket not found: id={}", id);
                    return new TicketNotFoundException(id);
                });
    }

    @Transactional
    public TicketResponse create(CreateTicketRequest request) {
        SupportTicket ticket = new SupportTicket();
        ticket.setExternalId(request.externalId());
        ticket.setCustomerName(request.customerName());
        ticket.setServiceName(request.serviceName());
        ticket.setPriority(request.priority());
        ticket.setStatus(request.status());
        ticket.setTitle(request.title());
        ticket.setDescription(request.description());

        SupportTicket saved = ticketRepository.save(ticket);
        log.info("Created support ticket: id={}, externalId={}, priority={}",
                saved.getId(), saved.getExternalId(), saved.getPriority());
        return TicketResponse.from(saved);
    }
}
