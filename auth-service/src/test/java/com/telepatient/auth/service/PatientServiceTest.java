package com.telepatient.auth.service;

import com.telepatient.auth.dto.request.TokenRequestDTO;
import com.telepatient.auth.dto.response.HistoryDTO;
import com.telepatient.auth.entity.*;
import com.telepatient.auth.repository.*;
import com.telepatient.auth.service.impl.PatientServiceImpl;
import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Nested;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.ArgumentCaptor;
import org.mockito.InjectMocks;
import org.mockito.Mock;
import org.mockito.junit.jupiter.MockitoExtension;

import java.time.LocalDateTime;
import java.util.List;
import java.util.Optional;

import static org.assertj.core.api.Assertions.*;
import static org.mockito.ArgumentMatchers.*;
import static org.mockito.Mockito.*;

@ExtendWith(MockitoExtension.class)
class PatientServiceTest {

    @Mock private ConsultationRepository       consultationRepo;
    @Mock private CommunicationTokenRepository tokenRepo;
    @Mock private UserRepository               userRepo;
    @Mock private EmergencyAlertRepository     emergencyRepo;
    @Mock private NotificationRepository       notifRepo;

    @InjectMocks
    private PatientServiceImpl patientService;

    // ─── Fixtures ─────────────────────────────────────────────────────────────

    private User patient() {
        return User.builder().id(1L).fullName("Jane Doe")
                .email("jane@example.com").role(Role.PATIENT).build();
    }

    private User md() {
        return User.builder().id(99L).fullName("Dr. Admin")
                .email("admin@123").role(Role.MAIN_DOCTOR).build();
    }

    private User doctor() {
        return User.builder().id(2L).fullName("Dr. Smith")
                .email("doctor@123").role(Role.DOCTOR).build();
    }

    // =========================================================================
    // GET PATIENT HISTORY
    // =========================================================================

    @Nested
    @DisplayName("getPatientHistory()")
    class GetHistory {

        @Test
        @DisplayName("should return mapped HistoryDTOs for all consultations")
        void getHistory_returnsMappedDTOs() {
            User p = patient();
            User d = doctor();

            Consultation c = Consultation.builder()
                    .id(10L).doctor(d).patient(p)
                    .notes("Routine checkup").prescription("Paracetamol")
                    .reportsUrl("https://reports/1")
                    .consultationDate(LocalDateTime.of(2025, 1, 15, 10, 0))
                    .build();

            when(userRepo.findById(1L)).thenReturn(Optional.of(p));
            when(consultationRepo.findByPatient(p)).thenReturn(List.of(c));

            List<HistoryDTO> result = patientService.getPatientHistory(1L);

            assertThat(result).hasSize(1);
            assertThat(result.get(0).getDoctorName()).isEqualTo("Dr. Smith");
            assertThat(result.get(0).getNotes()).isEqualTo("Routine checkup");
            assertThat(result.get(0).getPrescription()).isEqualTo("Paracetamol");
            assertThat(result.get(0).getReportsUrl()).isEqualTo("https://reports/1");
        }

        @Test
        @DisplayName("should return empty list when patient has no consultations")
        void getHistory_noConsultations_returnsEmpty() {
            User p = patient();
            when(userRepo.findById(1L)).thenReturn(Optional.of(p));
            when(consultationRepo.findByPatient(p)).thenReturn(List.of());

            List<HistoryDTO> result = patientService.getPatientHistory(1L);

            assertThat(result).isEmpty();
        }

        @Test
        @DisplayName("should throw when patient not found")
        void getHistory_unknownPatient_throws() {
            when(userRepo.findById(999L)).thenReturn(Optional.empty());

            assertThatThrownBy(() -> patientService.getPatientHistory(999L))
                    .isInstanceOf(java.util.NoSuchElementException.class);
        }
    }

    // =========================================================================
    // REQUEST COMMUNICATION TOKEN
    // =========================================================================

    @Nested
    @DisplayName("requestCommunicationToken()")
    class RequestToken {

        @Test
        @DisplayName("should save REQUESTED token and send notification")
        void requestToken_savesTokenAndNotification() {
            User p  = patient();
            User m  = md();

            TokenRequestDTO req = new TokenRequestDTO();
            req.setPatientId(1L);
            req.setMdId(99L);
            req.setType(TokenType.CHAT);

            when(userRepo.findById(1L)).thenReturn(Optional.of(p));
            when(userRepo.findById(99L)).thenReturn(Optional.of(m));

            patientService.requestCommunicationToken(req);

            // Verify token saved with correct status
            ArgumentCaptor<CommunicationToken> tokenCaptor =
                    ArgumentCaptor.forClass(CommunicationToken.class);
            verify(tokenRepo).save(tokenCaptor.capture());

            CommunicationToken saved = tokenCaptor.getValue();
            assertThat(saved.getStatus()).isEqualTo(TokenStatus.REQUESTED);
            assertThat(saved.getType()).isEqualTo(TokenType.CHAT);
            assertThat(saved.getPatient()).isEqualTo(p);
            assertThat(saved.getMainDoctor()).isEqualTo(m);
            assertThat(saved.isFrozen()).isFalse();
            assertThat(saved.getRequestedAt()).isNotNull();

            // Verify notification sent to patient
            ArgumentCaptor<Notification> notifCaptor =
                    ArgumentCaptor.forClass(Notification.class);
            verify(notifRepo).save(notifCaptor.capture());

            Notification notif = notifCaptor.getValue();
            assertThat(notif.getUser()).isEqualTo(p);
            assertThat(notif.getType()).isEqualTo("APPOINTMENT");
            assertThat(notif.getPriority()).isEqualTo("MEDIUM");
            assertThat(notif.isRead()).isFalse();
        }

        @Test
        @DisplayName("should work for VIDEO token type")
        void requestToken_videoType_savesCorrectly() {
            User p = patient();
            User m = md();

            TokenRequestDTO req = new TokenRequestDTO();
            req.setPatientId(1L);
            req.setMdId(99L);
            req.setType(TokenType.VIDEO);

            when(userRepo.findById(1L)).thenReturn(Optional.of(p));
            when(userRepo.findById(99L)).thenReturn(Optional.of(m));

            patientService.requestCommunicationToken(req);

            verify(tokenRepo).save(argThat(t -> t.getType() == TokenType.VIDEO));
        }
    }

    // =========================================================================
    // GET PATIENT TOKENS
    // =========================================================================

    @Nested
    @DisplayName("getPatientTokens()")
    class GetTokens {

        @Test
        @DisplayName("should return all tokens for the patient")
        void getTokens_returnsAll() {
            User p = patient();
            User m = md();

            CommunicationToken t1 = CommunicationToken.builder()
                    .id(1L).patient(p).mainDoctor(m)
                    .type(TokenType.CHAT).status(TokenStatus.APPROVED).build();
            CommunicationToken t2 = CommunicationToken.builder()
                    .id(2L).patient(p).mainDoctor(m)
                    .type(TokenType.VIDEO).status(TokenStatus.REQUESTED).build();

            when(userRepo.findById(1L)).thenReturn(Optional.of(p));
            when(tokenRepo.findByPatient(p)).thenReturn(List.of(t1, t2));

            List<CommunicationToken> result = patientService.getPatientTokens(1L);

            assertThat(result).hasSize(2);
            assertThat(result).extracting(CommunicationToken::getStatus)
                    .containsExactlyInAnyOrder(TokenStatus.APPROVED, TokenStatus.REQUESTED);
        }
    }

    // =========================================================================
    // EMERGENCY ALERT
    // =========================================================================

    @Nested
    @DisplayName("triggerEmergencyAlert()")
    class EmergencyAlert {

        @Test
        @DisplayName("should save alert and send HIGH priority notification")
        void triggerEmergency_savesAlertAndNotification() {
            User p = patient();
            when(userRepo.findById(1L)).thenReturn(Optional.of(p));

            String result = patientService.triggerEmergencyAlert(1L, "CRITICAL");

            assertThat(result).contains("Emergency alert sent");

            // Verify alert saved
            ArgumentCaptor<com.telepatient.auth.entity.EmergencyAlert> alertCaptor =
                    ArgumentCaptor.forClass(com.telepatient.auth.entity.EmergencyAlert.class);
            verify(emergencyRepo).save(alertCaptor.capture());

            com.telepatient.auth.entity.EmergencyAlert alert = alertCaptor.getValue();
            assertThat(alert.getLevel()).isEqualTo("CRITICAL");
            assertThat(alert.isAcknowledged()).isFalse();
            assertThat(alert.getAlertTime()).isNotNull();
            assertThat(alert.getPatient()).isEqualTo(p);

            // Verify HIGH priority notification
            verify(notifRepo).save(argThat(n ->
                    n.getPriority().equals("HIGH") &&
                    n.getType().equals("EMERGENCY")));
        }

        @Test
        @DisplayName("should handle URGENT level correctly")
        void triggerEmergency_urgentLevel() {
            User p = patient();
            when(userRepo.findById(1L)).thenReturn(Optional.of(p));

            patientService.triggerEmergencyAlert(1L, "URGENT");

            verify(emergencyRepo).save(argThat(a -> a.getLevel().equals("URGENT")));
        }
    }
}
