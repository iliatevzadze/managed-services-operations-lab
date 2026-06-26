package com.managedservices.supportapi;

import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.get;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.jsonPath;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.status;

import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.autoconfigure.web.servlet.AutoConfigureMockMvc;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.test.context.ActiveProfiles;
import org.springframework.test.context.TestPropertySource;
import org.springframework.test.web.servlet.MockMvc;

@SpringBootTest
@AutoConfigureMockMvc
@ActiveProfiles("test")
@TestPropertySource(properties = "support.simulation.enabled=true")
class SimulationControllerTest {

    @Autowired
    private MockMvc mockMvc;

    @Test
    void simulateHttp500Returns500WhenEnabled() throws Exception {
        mockMvc.perform(get("/simulate/http-500"))
                .andExpect(status().isInternalServerError())
                .andExpect(jsonPath("$.error").value("SIMULATION_ERROR"))
                .andExpect(jsonPath("$.message").value("Simulated HTTP 500 for Managed Services incident drill"))
                .andExpect(jsonPath("$.timestamp").exists());
    }
}
