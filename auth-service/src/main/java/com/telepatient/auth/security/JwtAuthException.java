package com.telepatient.auth.security;

/**
 * Thrown when a JWT token fails validation (expired, malformed, bad signature).
 * Caught by the filter and translated to HTTP 401.
 */
public class JwtAuthException extends RuntimeException {
    public JwtAuthException(String message) {
        super(message);
    }
}
