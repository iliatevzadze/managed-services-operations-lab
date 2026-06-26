package com.managedservices.supportapi;

import static org.hamcrest.Matchers.hasSize;
import static org.junit.jupiter.api.Assertions.assertEquals;
import static org.junit.jupiter.api.Assertions.assertNotNull;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.get;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.jsonPath;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.status;

import io.micrometer.core.instrument.MeterRegistry;

import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.autoconfigure.web.servlet.AutoConfigureMockMvc;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.test.context.ActiveProfiles;
import org.springframework.test.web.servlet.MockMvc;

@SpringBootTest
@AutoConfigureMockMvc
@ActiveProfiles("test")
class SupportApiApplicationTests {

    @Autowired
    private MockMvc mockMvc;

    @Autowired
    private MeterRegistry meterRegistry;

    @Test
    void contextLoads() {
    }

    @Test
    void healthReturnsUpWhenDatabaseIsAvailable() throws Exception {
        mockMvc.perform(get("/health"))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.status").value("UP"))
                .andExpect(jsonPath("$.service").value("spring-support-api"))
                .andExpect(jsonPath("$.database").value("UP"))
                .andExpect(jsonPath("$.ticketCount").value(4))
                .andExpect(jsonPath("$.timestamp").exists());
    }

    @Test
    void databaseHealthMetricReportsUpWhenDatabaseIsAvailable() throws Exception {
        mockMvc.perform(get("/health")).andExpect(status().isOk());

        var gauge = meterRegistry.find("support_api_database_up").gauge();
        assertNotNull(gauge);
        assertEquals(1.0, gauge.value());
    }

    @Test
    void ticketsReturnsSeededTickets() throws Exception {
        mockMvc.perform(get("/tickets"))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$", hasSize(4)))
                .andExpect(jsonPath("$[0].externalId").exists())
                .andExpect(jsonPath("$[0].title").exists());
    }

    @Test
    void ticketByIdReturns404WhenMissing() throws Exception {
        mockMvc.perform(get("/tickets/99999"))
                .andExpect(status().isNotFound())
                .andExpect(jsonPath("$.error").value("NOT_FOUND"))
                .andExpect(jsonPath("$.message").value("Support ticket not found: id=99999"))
                .andExpect(jsonPath("$.timestamp").exists());
    }
}
