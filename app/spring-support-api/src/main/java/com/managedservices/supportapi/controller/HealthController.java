package com.managedservices.supportapi.controller;

import com.managedservices.supportapi.dto.HealthResponse;
import com.managedservices.supportapi.service.HealthService;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RestController;

@RestController
public class HealthController {

    private final HealthService healthService;

    public HealthController(HealthService healthService) {
        this.healthService = healthService;
    }

    @GetMapping("/health")
    public HealthResponse health() {
        return healthService.checkHealth();
    }
}
