package com.managedservices.supportapi.exception;

public class SimulationDisabledException extends RuntimeException {

    public SimulationDisabledException() {
        super("Simulation endpoints are disabled. Set support.simulation.enabled=true for local incident drills.");
    }
}
