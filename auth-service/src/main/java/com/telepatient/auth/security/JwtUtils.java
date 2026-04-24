package com.telepatient.auth.security;

import io.jsonwebtoken.*;
import io.jsonwebtoken.io.Decoders;
import io.jsonwebtoken.security.Keys;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Component;

import javax.crypto.SecretKey;
import java.util.Date;

/**
 * Utility for generating, parsing, and validating JWT tokens.
 *
 * Claims stored in the token:
 *   sub  → user email (standard subject)
 *   id   → user database ID  (Long)
 *   role → Role enum name (e.g. "PATIENT", "DOCTOR", "MAIN_DOCTOR")
 */
@Component
public class JwtUtils {

    @Value("${jwt.secret}")
    private String jwtSecret;

    @Value("${jwt.expiration-ms:86400000}")
    private long jwtExpirationMs;

    // ─── Key ─────────────────────────────────────────────────────────────────

    private SecretKey signingKey() {
        // Derive a 256-bit HMAC-SHA key from the configured secret string.
        // Using UTF-8 bytes directly (no Base64 encoding needed for plain strings).
        byte[] keyBytes = jwtSecret.getBytes(java.nio.charset.StandardCharsets.UTF_8);
        // Pad or truncate to exactly 32 bytes for HS256
        byte[] key32 = new byte[32];
        System.arraycopy(keyBytes, 0, key32, 0, Math.min(keyBytes.length, 32));
        return Keys.hmacShaKeyFor(key32);
    }

    // ─── Generate ─────────────────────────────────────────────────────────────

    /**
     * Build a signed JWT for the given user.
     *
     * @param email  user's email (becomes the subject)
     * @param userId user's database PK
     * @param role   user's role name
     * @return compact JWT string
     */
    public String generateToken(String email, Long userId, String role) {
        return Jwts.builder()
                .subject(email)
                .claim("id", userId)
                .claim("role", role)
                .issuedAt(new Date())
                .expiration(new Date(System.currentTimeMillis() + jwtExpirationMs))
                .signWith(signingKey())
                .compact();
    }

    // ─── Parse ────────────────────────────────────────────────────────────────

    private Claims parseClaims(String token) {
        return Jwts.parser()
                .verifyWith(signingKey())
                .build()
                .parseSignedClaims(token)
                .getPayload();
    }

    public String extractEmail(String token) {
        return parseClaims(token).getSubject();
    }

    public Long extractUserId(String token) {
        Object id = parseClaims(token).get("id");
        if (id instanceof Integer) return ((Integer) id).longValue();
        if (id instanceof Long)    return (Long) id;
        return Long.parseLong(id.toString());
    }

    public String extractRole(String token) {
        return parseClaims(token).get("role", String.class);
    }

    // ─── Validate ─────────────────────────────────────────────────────────────

    /**
     * Returns true if the token is structurally valid, signed correctly,
     * and not expired.
     */
    public boolean validateToken(String token) {
        try {
            parseClaims(token);
            return true;
        } catch (ExpiredJwtException e) {
            throw new JwtAuthException("JWT token has expired");
        } catch (UnsupportedJwtException e) {
            throw new JwtAuthException("JWT token is unsupported");
        } catch (MalformedJwtException e) {
            throw new JwtAuthException("JWT token is malformed");
        } catch (io.jsonwebtoken.security.SignatureException e) {
            throw new JwtAuthException("JWT signature is invalid");
        } catch (SecurityException e) {
            throw new JwtAuthException("JWT signature is invalid");
        } catch (IllegalArgumentException e) {
            throw new JwtAuthException("JWT claims string is empty");
        }
    }
}
