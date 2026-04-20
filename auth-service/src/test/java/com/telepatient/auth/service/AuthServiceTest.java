package com.telepatient.auth.service;

import com.telepatient.auth.dto.request.LoginRequest;
import com.telepatient.auth.dto.request.RegisterRequest;
import com.telepatient.auth.dto.response.AuthResponse;
import com.telepatient.auth.entity.Role;
import com.telepatient.auth.entity.User;
import com.telepatient.auth.repository.UserRepository;
import com.telepatient.auth.security.JwtUtils;
import com.telepatient.auth.service.impl.AuthServiceImpl;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Nested;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.InjectMocks;
import org.mockito.Mock;
import org.mockito.junit.jupiter.MockitoExtension;
import org.springframework.security.crypto.password.PasswordEncoder;

import java.time.LocalDateTime;
import java.util.Optional;

import static org.assertj.core.api.Assertions.*;
import static org.mockito.ArgumentMatchers.*;
import static org.mockito.Mockito.*;

/**
 * Pure unit tests for AuthServiceImpl.
 * No Spring context — all dependencies are mocked with Mockito.
 */
@ExtendWith(MockitoExtension.class)
class AuthServiceTest {

    @Mock private UserRepository  userRepository;
    @Mock private PasswordEncoder passwordEncoder;
    @Mock private EmailService    emailService;
    @Mock private JwtUtils        jwtUtils;

    @InjectMocks
    private AuthServiceImpl authService;

    // ─── Shared fixtures ──────────────────────────────────────────────────────

    private User patientUser() {
        return User.builder()
                .id(1L)
                .fullName("Jane Doe")
                .email("jane@example.com")
                .password("$2a$10$hashedPassword")
                .role(Role.PATIENT)
                .build();
    }

    // =========================================================================
    // REGISTER
    // =========================================================================

    @Nested
    @DisplayName("register()")
    class Register {

        @Test
        @DisplayName("should create a PATIENT user and return response without token")
        void register_success() {
            // Arrange
            RegisterRequest req = RegisterRequest.builder()
                    .fullName("Jane Doe")
                    .email("jane@example.com")
                    .password("secret123")
                    .build();

            when(userRepository.existsByEmail("jane@example.com")).thenReturn(false);
            when(passwordEncoder.encode("secret123")).thenReturn("$2a$10$hashed");

            User saved = patientUser();
            when(userRepository.save(any(User.class))).thenReturn(saved);

            // Act
            AuthResponse response = authService.register(req);

            // Assert
            assertThat(response.getMessage()).isEqualTo("User registered successfully");
            assertThat(response.getEmail()).isEqualTo("jane@example.com");
            assertThat(response.getRole()).isEqualTo("PATIENT");
            assertThat(response.getToken()).isNull(); // no token on register
            assertThat(response.getUserId()).isEqualTo(1L);

            verify(userRepository).save(argThat(u ->
                    u.getRole() == Role.PATIENT &&
                    u.getEmail().equals("jane@example.com")));
        }

        @Test
        @DisplayName("should throw when email already exists")
        void register_duplicateEmail_throws() {
            RegisterRequest req = RegisterRequest.builder()
                    .fullName("Jane Doe")
                    .email("jane@example.com")
                    .password("secret123")
                    .build();

            when(userRepository.existsByEmail("jane@example.com")).thenReturn(true);

            assertThatThrownBy(() -> authService.register(req))
                    .isInstanceOf(IllegalArgumentException.class)
                    .hasMessage("Email already exists");

            verify(userRepository, never()).save(any());
        }
    }

    // =========================================================================
    // LOGIN
    // =========================================================================

    @Nested
    @DisplayName("login()")
    class Login {

        @Test
        @DisplayName("should return JWT token on valid credentials")
        void login_success_returnsToken() {
            LoginRequest req = LoginRequest.builder()
                    .email("jane@example.com")
                    .password("secret123")
                    .build();

            User user = patientUser();
            when(userRepository.findByEmail("jane@example.com"))
                    .thenReturn(Optional.of(user));
            when(passwordEncoder.matches("secret123", user.getPassword()))
                    .thenReturn(true);
            when(jwtUtils.generateToken("jane@example.com", 1L, "PATIENT"))
                    .thenReturn("eyJhbGciOiJIUzI1NiJ9.test.token");

            AuthResponse response = authService.login(req);

            assertThat(response.getMessage()).isEqualTo("Login successful");
            assertThat(response.getToken()).isEqualTo("eyJhbGciOiJIUzI1NiJ9.test.token");
            assertThat(response.getRole()).isEqualTo("PATIENT");
            assertThat(response.isRequirePasswordReset()).isFalse();
        }

        @Test
        @DisplayName("should set requirePasswordReset=true when password is temp@123")
        void login_tempPassword_setsResetFlag() {
            LoginRequest req = LoginRequest.builder()
                    .email("jane@example.com")
                    .password("temp@123")
                    .build();

            User user = patientUser();
            when(userRepository.findByEmail("jane@example.com"))
                    .thenReturn(Optional.of(user));
            when(passwordEncoder.matches("temp@123", user.getPassword()))
                    .thenReturn(true);
            when(jwtUtils.generateToken(any(), any(), any()))
                    .thenReturn("some.jwt.token");

            AuthResponse response = authService.login(req);

            assertThat(response.isRequirePasswordReset()).isTrue();
        }

        @Test
        @DisplayName("should throw when email not found")
        void login_unknownEmail_throws() {
            LoginRequest req = LoginRequest.builder()
                    .email("nobody@example.com")
                    .password("secret123")
                    .build();

            when(userRepository.findByEmail("nobody@example.com"))
                    .thenReturn(Optional.empty());

            assertThatThrownBy(() -> authService.login(req))
                    .isInstanceOf(IllegalArgumentException.class)
                    .hasMessage("Invalid email or password");
        }

        @Test
        @DisplayName("should throw when password is wrong")
        void login_wrongPassword_throws() {
            LoginRequest req = LoginRequest.builder()
                    .email("jane@example.com")
                    .password("wrongpassword")
                    .build();

            User user = patientUser();
            when(userRepository.findByEmail("jane@example.com"))
                    .thenReturn(Optional.of(user));
            when(passwordEncoder.matches("wrongpassword", user.getPassword()))
                    .thenReturn(false);

            assertThatThrownBy(() -> authService.login(req))
                    .isInstanceOf(IllegalArgumentException.class)
                    .hasMessage("Invalid email or password");

            // JWT must never be generated for failed logins
            verify(jwtUtils, never()).generateToken(any(), any(), any());
        }
    }

    // =========================================================================
    // FORGOT PASSWORD / OTP
    // =========================================================================

    @Nested
    @DisplayName("generateResetOtp()")
    class ForgotPassword {

        @Test
        @DisplayName("should save OTP and expiry on the user")
        void generateOtp_savesOtpToUser() throws Exception {
            User user = patientUser();
            when(userRepository.findByEmail("jane@example.com"))
                    .thenReturn(Optional.of(user));
            when(userRepository.save(any(User.class))).thenReturn(user);
            // Email service throws — should be silently caught
            doThrow(new RuntimeException("SMTP unavailable"))
                    .when(emailService).sendOtpEmail(any(), any());

            authService.generateResetOtp("jane@example.com");

            verify(userRepository).save(argThat(u ->
                    u.getResetOtp() != null &&
                    u.getResetOtp().length() == 6 &&
                    u.getOtpExpiry() != null &&
                    u.getOtpExpiry().isAfter(LocalDateTime.now())));
        }

        @Test
        @DisplayName("should throw when email not found")
        void generateOtp_unknownEmail_throws() {
            when(userRepository.findByEmail("ghost@example.com"))
                    .thenReturn(Optional.empty());

            assertThatThrownBy(() -> authService.generateResetOtp("ghost@example.com"))
                    .isInstanceOf(IllegalArgumentException.class)
                    .hasMessage("No account found with this email address.");
        }
    }

    // =========================================================================
    // RESET PASSWORD VIA OTP
    // =========================================================================

    @Nested
    @DisplayName("resetPasswordWithOtp()")
    class ResetPasswordOtp {

        @Test
        @DisplayName("should update password when OTP is valid and not expired")
        void resetOtp_valid_updatesPassword() {
            User user = patientUser();
            user.setResetOtp("123456");
            user.setOtpExpiry(LocalDateTime.now().plusMinutes(4));

            when(userRepository.findByEmail("jane@example.com"))
                    .thenReturn(Optional.of(user));
            when(passwordEncoder.encode("newPass123")).thenReturn("$2a$10$newHash");

            authService.resetPasswordWithOtp("jane@example.com", "123456", "newPass123");

            verify(userRepository).save(argThat(u ->
                    u.getResetOtp() == null &&
                    u.getOtpExpiry() == null &&
                    u.getPassword().equals("$2a$10$newHash")));
        }

        @Test
        @DisplayName("should throw when OTP is wrong")
        void resetOtp_wrongOtp_throws() {
            User user = patientUser();
            user.setResetOtp("123456");
            user.setOtpExpiry(LocalDateTime.now().plusMinutes(4));

            when(userRepository.findByEmail("jane@example.com"))
                    .thenReturn(Optional.of(user));

            assertThatThrownBy(() ->
                    authService.resetPasswordWithOtp("jane@example.com", "999999", "newPass"))
                    .isInstanceOf(IllegalArgumentException.class)
                    .hasMessage("Invalid or expired OTP");
        }

        @Test
        @DisplayName("should throw when OTP is expired")
        void resetOtp_expiredOtp_throws() {
            User user = patientUser();
            user.setResetOtp("123456");
            user.setOtpExpiry(LocalDateTime.now().minusMinutes(1)); // already expired

            when(userRepository.findByEmail("jane@example.com"))
                    .thenReturn(Optional.of(user));

            assertThatThrownBy(() ->
                    authService.resetPasswordWithOtp("jane@example.com", "123456", "newPass"))
                    .isInstanceOf(IllegalArgumentException.class)
                    .hasMessage("OTP has expired. Please request a new one.");
        }
    }

    // =========================================================================
    // RESET TEMP PASSWORD
    // =========================================================================

    @Nested
    @DisplayName("resetPasswordWithTemp()")
    class ResetTempPassword {

        @Test
        @DisplayName("should update password when current password is temp@123")
        void resetTemp_valid_updatesPassword() {
            User user = patientUser();
            when(userRepository.findByEmail("jane@example.com"))
                    .thenReturn(Optional.of(user));
            when(passwordEncoder.matches("temp@123", user.getPassword()))
                    .thenReturn(true);
            when(passwordEncoder.encode("newSecurePass")).thenReturn("$2a$10$newHash");

            authService.resetPasswordWithTemp("jane@example.com", "temp@123", "newSecurePass");

            verify(userRepository).save(argThat(u ->
                    u.getPassword().equals("$2a$10$newHash")));
        }

        @Test
        @DisplayName("should throw when current password is not temp@123")
        void resetTemp_nonTempPassword_throws() {
            User user = patientUser();
            when(userRepository.findByEmail("jane@example.com"))
                    .thenReturn(Optional.of(user));
            when(passwordEncoder.matches("regularPass", user.getPassword()))
                    .thenReturn(true);

            assertThatThrownBy(() ->
                    authService.resetPasswordWithTemp("jane@example.com", "regularPass", "newPass"))
                    .isInstanceOf(IllegalArgumentException.class)
                    .hasMessage("This mechanism is strictly restricted to temporary passwords only.");
        }
    }
}
