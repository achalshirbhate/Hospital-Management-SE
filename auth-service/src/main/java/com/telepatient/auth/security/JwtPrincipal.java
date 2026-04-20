package com.telepatient.auth.security;

import lombok.AllArgsConstructor;
import lombok.Getter;

/**
 * Stored as the principal in the SecurityContext after JWT validation.
 * Controllers can retrieve it via SecurityContextHolder or @AuthenticationPrincipal.
 */
@Getter
@AllArgsConstructor
public class JwtPrincipal {
    private final Long   userId;
    private final String email;
    private final String role;
}
