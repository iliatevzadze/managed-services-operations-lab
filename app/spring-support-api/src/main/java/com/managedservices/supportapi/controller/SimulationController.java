package com.managedservices.supportapi.controller;

import com.managedservices.supportapi.exception.SimulationDisabledException;
import com.managedservices.supportapi.exception.SimulationHttp500Exception;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequestMapping("/simulate")
public class SimulationController {

    private static final Logger log = LoggerFactory.getLogger(SimulationController.class);

    private final boolean simulationEnabled;

    public SimulationController(@Value("${support.simulation.enabled:false}") boolean simulationEnabled) {
        this.simulationEnabled = simulationEnabled;
    }

    @GetMapping("/http-500")
    public void simulateHttp500() {
        if (!simulationEnabled) {
            throw new SimulationDisabledException();
        }

        log.warn("Incident simulation: deliberate HTTP 500 triggered via GET /simulate/http-500");
        throw new SimulationHttp500Exception("Simulated HTTP 500 for Managed Services incident drill");
    }
}
