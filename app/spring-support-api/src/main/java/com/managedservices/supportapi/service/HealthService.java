package com.managedservices.supportapi.service;

import com.managedservices.supportapi.dto.HealthResponse;
import com.managedservices.supportapi.repository.SupportTicketRepository;
import io.micrometer.core.instrument.Gauge;
import io.micrometer.core.instrument.MeterRegistry;
import java.time.Instant;
import java.util.concurrent.atomic.AtomicInteger;
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
    private final AtomicInteger databaseUpMetric = new AtomicInteger(0);

    public HealthService(
            JdbcTemplate jdbcTemplate,
            SupportTicketRepository ticketRepository,
            MeterRegistry meterRegistry,
            @Value("${spring.application.name}") String serviceName) {
        this.jdbcTemplate = jdbcTemplate;
        this.ticketRepository = ticketRepository;
        this.serviceName = serviceName;

        Gauge.builder("support_api_database_up", databaseUpMetric, AtomicInteger::get)
                .description("Support API database connectivity (1=up, 0=down)")
                .register(meterRegistry);
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
            boolean up = result != null && result == 1;
            databaseUpMetric.set(up ? 1 : 0);
            return up;
        } catch (DataAccessException ex) {
            log.warn("Database health check failed: {}", ex.getMessage());
            databaseUpMetric.set(0);
            return false;
        }
    }
}
