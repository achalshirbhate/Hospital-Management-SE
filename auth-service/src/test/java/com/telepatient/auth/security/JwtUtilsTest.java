package com.telepatient.auth.security;

import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Test;
import org.springframework.test.util.ReflectionTestUtils;

import static org.assertj.core.api.Assertions.*;

/**
 * Unit tests for JwtUtils — no Spring context needed.
 * Uses ReflectionTestUtils to inject @Value fields.
 */
@DisplayName("JwtUtils")
class JwtUtilsTest {

    private JwtUtils jwtUtils;

    private static final String TEST_SECRET     = "TestSecret$ForJwtUnitTests$32Chars!";
    private static final long   TEST_EXPIRATION = 3_600_000L; // 1 hour

    @BeforeEach
    void setUp() {
        jwtUtils = new JwtUtils();
        ReflectionTestUtils.setField(jwtUtils, "jwtSecret",      TEST_SECRET);
        ReflectionTestUtils.setField(jwtUtils, "jwtExpirationMs", TEST_EXPIRATION);
    }

    @Test
    @DisplayName("generateToken() should produce a non-blank JWT string")
    void generateToken_returnsNonBlankString() {
        String token = jwtUtils.generateToken("user@example.com", 42L, "PATIENT");
        assertThat(token).isNotBlank();
        // JWT has 3 dot-separated parts
        assertThat(token.split("\\.")).hasSize(3);
    }

    @Test
    @DisplayName("extractEmail() should return the subject embedded in the token")
    void extractEmail_returnsCorrectEmail() {
        String token = jwtUtils.generateToken("user@example.com", 42L, "PATIENT");
        assertThat(jwtUtils.extractEmail(token)).isEqualTo("user@example.com");
    }

    @Test
    @DisplayName("extractUserId() should return the id claim as Long")
    void extractUserId_returnsCorrectId() {
        String token = jwtUtils.generateToken("user@example.com", 42L, "PATIENT");
        assertThat(jwtUtils.extractUserId(token)).isEqualTo(42L);
    }

    @Test
    @DisplayName("extractRole() should return the role claim")
    void extractRole_returnsCorrectRole() {
        String token = jwtUtils.generateToken("user@example.com", 42L, "MAIN_DOCTOR");
        assertThat(jwtUtils.extractRole(token)).isEqualTo("MAIN_DOCTOR");
    }

    @Test
    @DisplayName("validateToken() should return true for a freshly generated token")
    void validateToken_validToken_returnsTrue() {
        String token = jwtUtils.generateToken("user@example.com", 1L, "DOCTOR");
        assertThat(jwtUtils.validateToken(token)).isTrue();
    }

    @Test
    @DisplayName("validateToken() should throw JwtAuthException for a tampered token")
    void validateToken_tamperedToken_throwsJwtAuthException() {
        String token = jwtUtils.generateToken("user@example.com", 1L, "PATIENT");

        // Replace the payload part (middle segment) with garbage — this produces
        // a structurally valid 3-part JWT but with a mismatched signature,
        // which JJWT 0.12.x raises as SignatureException → caught → JwtAuthException.
        String[] parts = token.split("\\.");
        String tampered = parts[0] + ".dGFtcGVyZWRwYXlsb2Fk." + parts[2];

        assertThatThrownBy(() -> jwtUtils.validateToken(tampered))
                .isInstanceOf(JwtAuthException.class);
    }

    @Test
    @DisplayName("validateToken() should throw JwtAuthException for an expired token")
    void validateToken_expiredToken_throwsJwtAuthException() {
        // Create a JwtUtils instance with -1ms expiration (already expired)
        JwtUtils expiredUtils = new JwtUtils();
        ReflectionTestUtils.setField(expiredUtils, "jwtSecret",      TEST_SECRET);
        ReflectionTestUtils.setField(expiredUtils, "jwtExpirationMs", -1L);

        String expiredToken = expiredUtils.generateToken("user@example.com", 1L, "PATIENT");

        assertThatThrownBy(() -> jwtUtils.validateToken(expiredToken))
                .isInstanceOf(JwtAuthException.class)
                .hasMessageContaining("expired");
    }

    @Test
    @DisplayName("validateToken() should throw JwtAuthException for a blank token")
    void validateToken_blankToken_throwsJwtAuthException() {
        assertThatThrownBy(() -> jwtUtils.validateToken(""))
                .isInstanceOf(JwtAuthException.class);
    }

    @Test
    @DisplayName("different users should get different tokens")
    void generateToken_differentUsers_differentTokens() {
        String t1 = jwtUtils.generateToken("alice@example.com", 1L, "PATIENT");
        String t2 = jwtUtils.generateToken("bob@example.com",   2L, "DOCTOR");
        assertThat(t1).isNotEqualTo(t2);
    }
}
