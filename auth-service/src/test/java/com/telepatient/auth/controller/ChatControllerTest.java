package com.telepatient.auth.controller;

import com.telepatient.auth.config.TestSecurityConfig;
import com.telepatient.auth.entity.*;
import com.telepatient.auth.repository.ChatMessageRepository;
import com.telepatient.auth.repository.CommunicationTokenRepository;
import com.telepatient.auth.repository.UserRepository;
import com.telepatient.auth.security.JwtPrincipal;
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
import java.util.Optional;

import static org.mockito.ArgumentMatchers.*;
import static org.mockito.Mockito.*;
import static org.springframework.security.test.web.servlet.request.SecurityMockMvcRequestPostProcessors.authentication;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.*;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.*;

@WebMvcTest(ChatController.class)
@Import(TestSecurityConfig.class)
@DisplayName("ChatController API")
class ChatControllerTest {

    @Autowired private MockMvc mockMvc;

    @MockBean private ChatMessageRepository        chatRepo;
    @MockBean private CommunicationTokenRepository tokenRepo;
    // UserRepository mock is provided by TestSecurityConfig (shared across all controller tests)
    @Autowired private UserRepository              userRepo;

    private UsernamePasswordAuthenticationToken patientAuth(Long userId) {
        JwtPrincipal principal = new JwtPrincipal(userId, "jane@example.com", "PATIENT");
        return new UsernamePasswordAuthenticationToken(
                principal, null,
                List.of(new SimpleGrantedAuthority("ROLE_PATIENT")));
    }

    private User patient() {
        return User.builder().id(1L).fullName("Jane Doe")
                .email("jane@example.com").role(Role.PATIENT).build();
    }

    private User doctor() {
        return User.builder().id(2L).fullName("Dr. Smith")
                .email("doctor@123").role(Role.DOCTOR).build();
    }

    private CommunicationToken activeToken(User p, User md) {
        return CommunicationToken.builder()
                .id(10L).patient(p).mainDoctor(md)
                .type(TokenType.CHAT).status(TokenStatus.APPROVED)
                .isFrozen(false).build();
    }

    // =========================================================================
    // GET /api/chat/{tokenId}
    // =========================================================================

    @Nested
    @DisplayName("GET /api/chat/{tokenId}")
    class GetChatHistory {

        @Test
        @DisplayName("200 OK with messages and isTerminated=false for APPROVED token")
        void getChatHistory_approvedToken_returnsMessages() throws Exception {
            User p = patient();
            User d = doctor();
            CommunicationToken token = activeToken(p, d);

            ChatMessage msg = ChatMessage.builder()
                    .id(1L).token(token).sender(d)
                    .message("Hello, how are you?")
                    .sentAt(LocalDateTime.of(2025, 1, 15, 10, 0))
                    .build();

            when(tokenRepo.findById(10L)).thenReturn(Optional.of(token));
            when(chatRepo.findByTokenPatientOrderBySentAtAsc(p)).thenReturn(List.of(msg));

            mockMvc.perform(get("/api/chat/10")
                            .with(authentication(patientAuth(1L))))
                    .andExpect(status().isOk())
                    .andExpect(jsonPath("$.terminated").value(false))
                    .andExpect(jsonPath("$.messages").isArray())
                    .andExpect(jsonPath("$.messages[0].message").value("Hello, how are you?"))
                    .andExpect(jsonPath("$.messages[0].senderName").value("Dr. Smith"));
        }

        @Test
        @DisplayName("200 OK with isTerminated=true for COMPLETED token")
        void getChatHistory_completedToken_isTerminatedTrue() throws Exception {
            User p = patient();
            User d = doctor();
            CommunicationToken token = CommunicationToken.builder()
                    .id(10L).patient(p).mainDoctor(d)
                    .type(TokenType.CHAT).status(TokenStatus.COMPLETED)
                    .isFrozen(true).build();

            when(tokenRepo.findById(10L)).thenReturn(Optional.of(token));
            when(chatRepo.findByTokenPatientOrderBySentAtAsc(p)).thenReturn(List.of());

            mockMvc.perform(get("/api/chat/10")
                            .with(authentication(patientAuth(1L))))
                    .andExpect(status().isOk())
                    .andExpect(jsonPath("$.terminated").value(true))
                    .andExpect(jsonPath("$.messages").isEmpty());
        }
    }

    // =========================================================================
    // POST /api/chat/{tokenId}
    // =========================================================================

    @Nested
    @DisplayName("POST /api/chat/{tokenId}")
    class SendMessage {

        @Test
        @DisplayName("200 OK when token is active and not frozen")
        void sendMessage_activeToken_returns200() throws Exception {
            User p = patient();
            User d = doctor();
            CommunicationToken token = activeToken(p, d);

            when(tokenRepo.findById(10L)).thenReturn(Optional.of(token));
            when(userRepo.findById(1L)).thenReturn(Optional.of(p));

            mockMvc.perform(post("/api/chat/10")
                            .param("senderId", "1")
                            .contentType(MediaType.TEXT_PLAIN)
                            .content("Hello doctor!")
                            .with(authentication(patientAuth(1L))))
                    .andExpect(status().isOk())
                    .andExpect(content().string("Sent"));

            verify(chatRepo).save(argThat(m ->
                    m.getMessage().equals("Hello doctor!") &&
                    m.getSender().equals(p)));
        }

        @Test
        @DisplayName("400 Bad Request when token is frozen")
        void sendMessage_frozenToken_returns400() throws Exception {
            User p = patient();
            User d = doctor();
            CommunicationToken frozenToken = CommunicationToken.builder()
                    .id(10L).patient(p).mainDoctor(d)
                    .type(TokenType.CHAT).status(TokenStatus.APPROVED)
                    .isFrozen(true).build();

            when(tokenRepo.findById(10L)).thenReturn(Optional.of(frozenToken));
            when(userRepo.findById(1L)).thenReturn(Optional.of(p));

            mockMvc.perform(post("/api/chat/10")
                            .param("senderId", "1")
                            .contentType(MediaType.TEXT_PLAIN)
                            .content("Hello?")
                            .with(authentication(patientAuth(1L))))
                    .andExpect(status().isBadRequest())
                    .andExpect(jsonPath("$.error")
                            .value("Chat is currently frozen by Admin MD."));

            verify(chatRepo, never()).save(any());
        }
    }
}
