package com.telepatient.auth.controller;

import com.fasterxml.jackson.databind.ObjectMapper;
import com.telepatient.auth.config.TestSecurityConfig;
import com.telepatient.auth.dto.request.TokenRequestDTO;
import com.telepatient.auth.dto.response.HistoryDTO;
import com.telepatient.auth.entity.TokenType;
import com.telepatient.auth.security.JwtPrincipal;
import com.telepatient.auth.service.PatientService;
import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Nested;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.autoconfigure.web.servlet.WebMvcTest;
import org.springframework.boot.test.mock.mockito.MockBean;
import org.springframework.context.annotation.Import;
import org.springframework.http.MediaType;
import org.springframework.security.authentication.UsernamePasswordAuthenticationToken;
import org.springframework.security.core.authority.SimpleGrantedAuthority;
import org.springframework.test.web.servlet.MockMvc;

import java.time.LocalDateTime;
import java.util.List;

import static org.mockito.ArgumentMatchers.*;
import static org.mockito.Mockito.*;
import static org.springframework.security.test.web.servlet.request.SecurityMockMvcRequestPostProcessors.authentication;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.*;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.*;

@WebMvcTest(PatientController.class)
@Import(TestSecurityConfig.class)
@DisplayName("PatientController API")
class PatientControllerTest {

    @Autowired private MockMvc      mockMvc;
    @Autowired private ObjectMapper objectMapper;

    @MockBean private PatientService patientService;

    // ─── Auth helpers ─────────────────────────────────────────────────────────

    private UsernamePasswordAuthenticationToken patientAuth(Long userId) {
        JwtPrincipal principal = new JwtPrincipal(userId, "jane@example.com", "PATIENT");
        return new UsernamePasswordAuthenticationToken(
                principal, null,
                List.of(new SimpleGrantedAuthority("ROLE_PATIENT")));
    }

    private UsernamePasswordAuthenticationToken doctorAuth(Long userId) {
        JwtPrincipal principal = new JwtPrincipal(userId, "doc@example.com", "DOCTOR");
        return new UsernamePasswordAuthenticationToken(
                principal, null,
                List.of(new SimpleGrantedAuthority("ROLE_DOCTOR")));
    }

    // =========================================================================
    // GET /api/patient/{patientId}/history
    // =========================================================================

    @Nested
    @DisplayName("GET /api/patient/{patientId}/history")
    class GetHistory {

        @Test
        @DisplayName("200 OK when patient accesses own history")
        void getHistory_ownId_returns200() throws Exception {
            HistoryDTO dto = HistoryDTO.builder()
                    .doctorName("Dr. Smith")
                    .date(LocalDateTime.of(2025, 1, 15, 10, 0))
                    .notes("Routine checkup")
                    .prescription("Paracetamol 500mg")
                    .build();

            when(patientService.getPatientHistory(1L)).thenReturn(List.of(dto));

            mockMvc.perform(get("/api/patient/1/history")
                            .with(authentication(patientAuth(1L))))
                    .andExpect(status().isOk())
                    .andExpect(jsonPath("$[0].doctorName").value("Dr. Smith"))
                    .andExpect(jsonPath("$[0].notes").value("Routine checkup"))
                    .andExpect(jsonPath("$[0].prescription").value("Paracetamol 500mg"));
        }

        @Test
        @DisplayName("403 Forbidden when patient accesses another patient's history (IDOR)")
        void getHistory_differentId_returns403() throws Exception {
            // Patient 1 tries to access patient 2's history — controller throws AccessDeniedException
            mockMvc.perform(get("/api/patient/2/history")
                            .with(authentication(patientAuth(1L))))
                    .andExpect(status().isForbidden());

            verify(patientService, never()).getPatientHistory(any());
        }

        @Test
        @DisplayName("403 Forbidden when a DOCTOR tries to access patient history endpoint")
        void getHistory_wrongRole_returns403() throws Exception {
            // @PreAuthorize("hasRole('PATIENT')") on the class blocks DOCTOR role.
            // TestSecurityConfig uses permitAll() at the HTTP level, but
            // @EnableMethodSecurity (active via @WebMvcTest) still enforces @PreAuthorize.
            mockMvc.perform(get("/api/patient/1/history")
                            .with(authentication(doctorAuth(1L))))
                    .andExpect(status().isForbidden());
        }

        @Test
        @DisplayName("Service never called when no authentication provided")
        void getHistory_noAuth_serviceNotCalled() throws Exception {
            // With TestSecurityConfig (permitAll at HTTP level), unauthenticated requests
            // reach the controller but @PreAuthorize fails because principal is null.
            // We only assert the service is never called.
            mockMvc.perform(get("/api/patient/1/history"));
            verify(patientService, never()).getPatientHistory(any());
        }
    }

    // =========================================================================
    // POST /api/patient/tokens
    // =========================================================================

    @Nested
    @DisplayName("POST /api/patient/tokens")
    class RequestToken {

        @Test
        @DisplayName("200 OK and patientId overridden from JWT")
        void requestToken_overridesPatientIdFromJwt() throws Exception {
            TokenRequestDTO req = new TokenRequestDTO();
            req.setPatientId(999L); // attacker tries to spoof another patient's ID
            req.setMdId(99L);
            req.setType(TokenType.CHAT);

            doNothing().when(patientService).requestCommunicationToken(any());

            mockMvc.perform(post("/api/patient/tokens")
                            .contentType(MediaType.APPLICATION_JSON)
                            .content(objectMapper.writeValueAsString(req))
                            .with(authentication(patientAuth(1L)))) // JWT says userId=1
                    .andExpect(status().isOk())
                    .andExpect(content().string("Token requested successfully"));

            // Verify the patientId was overridden to 1 (from JWT), not 999 (from body)
            verify(patientService).requestCommunicationToken(argThat(r ->
                    r.getPatientId().equals(1L)));
        }
    }

    // =========================================================================
    // POST /api/patient/{patientId}/emergency
    // =========================================================================

    @Nested
    @DisplayName("POST /api/patient/{patientId}/emergency")
    class TriggerEmergency {

        @Test
        @DisplayName("200 OK with CRITICAL level")
        void triggerEmergency_critical_returns200() throws Exception {
            when(patientService.triggerEmergencyAlert(1L, "CRITICAL"))
                    .thenReturn("Emergency alert sent. Hospital counter has been notified!");

            mockMvc.perform(post("/api/patient/1/emergency")
                            .param("level", "CRITICAL")
                            .with(authentication(patientAuth(1L))))
                    .andExpect(status().isOk())
                    .andExpect(content().string(
                            "Emergency alert sent. Hospital counter has been notified!"));
        }

        @Test
        @DisplayName("200 OK with default CRITICAL level when level param omitted")
        void triggerEmergency_defaultLevel_usesCritical() throws Exception {
            when(patientService.triggerEmergencyAlert(1L, "CRITICAL"))
                    .thenReturn("Emergency alert sent. Hospital counter has been notified!");

            mockMvc.perform(post("/api/patient/1/emergency")
                            .with(authentication(patientAuth(1L))))
                    .andExpect(status().isOk());

            verify(patientService).triggerEmergencyAlert(1L, "CRITICAL");
        }

        @Test
        @DisplayName("403 Forbidden when patient triggers emergency for another patient")
        void triggerEmergency_differentPatient_returns403() throws Exception {
            mockMvc.perform(post("/api/patient/2/emergency")
                            .param("level", "CRITICAL")
                            .with(authentication(patientAuth(1L))))
                    .andExpect(status().isForbidden());

            verify(patientService, never()).triggerEmergencyAlert(any(), any());
        }
    }
}
