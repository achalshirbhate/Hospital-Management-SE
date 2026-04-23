package com.telepatient.auth.controller;

import com.fasterxml.jackson.databind.ObjectMapper;
import com.telepatient.auth.config.TestSecurityConfig;
import com.telepatient.auth.dto.request.LoginRequest;
import com.telepatient.auth.dto.request.RegisterRequest;
import com.telepatient.auth.dto.response.AuthResponse;
import com.telepatient.auth.service.AuthService;
import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Nested;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.autoconfigure.web.servlet.WebMvcTest;
import org.springframework.boot.test.mock.mockito.MockBean;
import org.springframework.context.annotation.Import;
import org.springframework.http.MediaType;
import org.springframework.test.web.servlet.MockMvc;

import static org.mockito.ArgumentMatchers.any;
import static org.mockito.Mockito.*;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.post;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.*;

/**
 * Slice test for AuthController.
 * Uses TestSecurityConfig to bypass JWT filter — auth endpoints are public anyway.
 */
@WebMvcTest(AuthController.class)
@Import(TestSecurityConfig.class)
@DisplayName("AuthController API")
class AuthControllerTest {

    @Autowired private MockMvc      mockMvc;
    @Autowired private ObjectMapper objectMapper;

    @MockBean private AuthService authService;

    // =========================================================================
    // POST /api/auth/register
    // =========================================================================

    @Nested
    @DisplayName("POST /api/auth/register")
    class Register {

        @Test
        @DisplayName("201 Created with valid payload")
        void register_validPayload_returns201() throws Exception {
            RegisterRequest req = RegisterRequest.builder()
                    .fullName("Jane Doe")
                    .email("jane@example.com")
                    .password("secret123")
                    .build();

            AuthResponse resp = AuthResponse.builder()
                    .message("User registered successfully")
                    .userId(1L).fullName("Jane Doe")
                    .email("jane@example.com").role("PATIENT")
                    .build();

            when(authService.register(any())).thenReturn(resp);

            mockMvc.perform(post("/api/auth/register")
                            .contentType(MediaType.APPLICATION_JSON)
                            .content(objectMapper.writeValueAsString(req)))
                    .andExpect(status().isCreated())
                    .andExpect(jsonPath("$.message").value("User registered successfully"))
                    .andExpect(jsonPath("$.role").value("PATIENT"))
                    .andExpect(jsonPath("$.token").doesNotExist());
        }

        @Test
        @DisplayName("400 Bad Request when email is blank")
        void register_blankEmail_returns400() throws Exception {
            RegisterRequest req = RegisterRequest.builder()
                    .fullName("Jane Doe").email("").password("secret123").build();

            mockMvc.perform(post("/api/auth/register")
                            .contentType(MediaType.APPLICATION_JSON)
                            .content(objectMapper.writeValueAsString(req)))
                    .andExpect(status().isBadRequest());

            verify(authService, never()).register(any());
        }

        @Test
        @DisplayName("400 Bad Request when password is too short")
        void register_shortPassword_returns400() throws Exception {
            RegisterRequest req = RegisterRequest.builder()
                    .fullName("Jane Doe").email("jane@example.com").password("abc").build();

            mockMvc.perform(post("/api/auth/register")
                            .contentType(MediaType.APPLICATION_JSON)
                            .content(objectMapper.writeValueAsString(req)))
                    .andExpect(status().isBadRequest());
        }

        @Test
        @DisplayName("400 Bad Request when email already exists")
        void register_duplicateEmail_returns400() throws Exception {
            RegisterRequest req = RegisterRequest.builder()
                    .fullName("Jane Doe").email("jane@example.com").password("secret123").build();

            when(authService.register(any()))
                    .thenThrow(new IllegalArgumentException("Email already exists"));

            mockMvc.perform(post("/api/auth/register")
                            .contentType(MediaType.APPLICATION_JSON)
                            .content(objectMapper.writeValueAsString(req)))
                    .andExpect(status().isBadRequest())
                    .andExpect(jsonPath("$.error").value("Email already exists"));
        }
    }

    // =========================================================================
    // POST /api/auth/login
    // =========================================================================

    @Nested
    @DisplayName("POST /api/auth/login")
    class Login {

        @Test
        @DisplayName("200 OK with JWT token on valid credentials")
        void login_validCredentials_returns200WithToken() throws Exception {
            LoginRequest req = LoginRequest.builder()
                    .email("jane@example.com").password("secret123").build();

            AuthResponse resp = AuthResponse.builder()
                    .message("Login successful").userId(1L)
                    .fullName("Jane Doe").email("jane@example.com")
                    .role("PATIENT").token("eyJhbGciOiJIUzI1NiJ9.test.token")
                    .requirePasswordReset(false).build();

            when(authService.login(any())).thenReturn(resp);

            mockMvc.perform(post("/api/auth/login")
                            .contentType(MediaType.APPLICATION_JSON)
                            .content(objectMapper.writeValueAsString(req)))
                    .andExpect(status().isOk())
                    .andExpect(jsonPath("$.token").value("eyJhbGciOiJIUzI1NiJ9.test.token"))
                    .andExpect(jsonPath("$.role").value("PATIENT"))
                    .andExpect(jsonPath("$.requirePasswordReset").value(false));
        }

        @Test
        @DisplayName("200 OK with requirePasswordReset=true for temp password")
        void login_tempPassword_setsResetFlag() throws Exception {
            LoginRequest req = LoginRequest.builder()
                    .email("jane@example.com").password("temp@123").build();

            AuthResponse resp = AuthResponse.builder()
                    .message("Login successful").userId(1L).role("PATIENT")
                    .token("some.jwt.token").requirePasswordReset(true).build();

            when(authService.login(any())).thenReturn(resp);

            mockMvc.perform(post("/api/auth/login")
                            .contentType(MediaType.APPLICATION_JSON)
                            .content(objectMapper.writeValueAsString(req)))
                    .andExpect(status().isOk())
                    .andExpect(jsonPath("$.requirePasswordReset").value(true));
        }

        @Test
        @DisplayName("400 Bad Request on wrong credentials")
        void login_wrongCredentials_returns400() throws Exception {
            LoginRequest req = LoginRequest.builder()
                    .email("jane@example.com").password("wrongpass").build();

            when(authService.login(any()))
                    .thenThrow(new IllegalArgumentException("Invalid email or password"));

            mockMvc.perform(post("/api/auth/login")
                            .contentType(MediaType.APPLICATION_JSON)
                            .content(objectMapper.writeValueAsString(req)))
                    .andExpect(status().isBadRequest())
                    .andExpect(jsonPath("$.error").value("Invalid email or password"));
        }

        @Test
        @DisplayName("400 Bad Request when email field is blank")
        void login_blankEmail_returns400() throws Exception {
            LoginRequest req = LoginRequest.builder()
                    .email("").password("secret123").build();

            mockMvc.perform(post("/api/auth/login")
                            .contentType(MediaType.APPLICATION_JSON)
                            .content(objectMapper.writeValueAsString(req)))
                    .andExpect(status().isBadRequest());

            verify(authService, never()).login(any());
        }
    }

    // =========================================================================
    // POST /api/auth/forgot-password
    // =========================================================================

    @Nested
    @DisplayName("POST /api/auth/forgot-password")
    class ForgotPassword {

        @Test
        @DisplayName("200 OK when email exists")
        void forgotPassword_validEmail_returns200() throws Exception {
            doNothing().when(authService).generateResetOtp("jane@example.com");

            mockMvc.perform(post("/api/auth/forgot-password")
                            .param("email", "jane@example.com"))
                    .andExpect(status().isOk())
                    .andExpect(content().string("OTP sent securely to registered email."));
        }

        @Test
        @DisplayName("400 Bad Request when email not found")
        void forgotPassword_unknownEmail_returns400() throws Exception {
            doThrow(new IllegalArgumentException("No account found with this email address."))
                    .when(authService).generateResetOtp("ghost@example.com");

            mockMvc.perform(post("/api/auth/forgot-password")
                            .param("email", "ghost@example.com"))
                    .andExpect(status().isBadRequest())
                    .andExpect(jsonPath("$.error")
                            .value("No account found with this email address."));
        }
    }
}
