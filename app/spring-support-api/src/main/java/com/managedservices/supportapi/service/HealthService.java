package com.managedservices.supportapi.service;

import com.managedservices.supportapi.dto.HealthResponse;
import com.managedservices.supportapi.repository.SupportTicketRepository;
import java.time.Instant;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.dao.DataAccessException;
import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.stereotype.Service;

@Service
public class HealthService {

    private static final Logger log = LoggerFactory.getLogger(HealthService.class);

    private final JdbcTemplate jdbcTemplate;
    private final SupportTicketRepository ticketRepository;
    private final String serviceName;

    public HealthService(
            JdbcTemplate jdbcTemplate,
            SupportTicketRepository ticketRepository,
            @Value("${spring.application.name}") String serviceName) {
        this.jdbcTemplate = jdbcTemplate;
        this.ticketRepository = ticketRepository;
        this.serviceName = serviceName;
    }

    public HealthResponse checkHealth() {
        log.info("Running health check for service={}", serviceName);

        boolean databaseUp = isDatabaseUp();
        String databaseStatus = databaseUp ? "UP" : "DOWN";
        String overallStatus = databaseUp ? "UP" : "DEGRADED";
        long ticketCount = databaseUp ? ticketRepository.count() : 0;

        log.info("Health check result: status={}, database={}, ticketCount={}",
                overallStatus, databaseStatus, ticketCount);

        return new HealthResponse(
                overallStatus,
                serviceName,
                databaseStatus,
                ticketCount,
                Instant.now()
        );
    }

    private boolean isDatabaseUp() {
        try {
            Integer result = jdbcTemplate.queryForObject("SELECT 1", Integer.class);
            return result != null && result == 1;
        } catch (DataAccessException ex) {
            log.warn("Database health check failed: {}", ex.getMessage());
            return false;
        }
    }
}
