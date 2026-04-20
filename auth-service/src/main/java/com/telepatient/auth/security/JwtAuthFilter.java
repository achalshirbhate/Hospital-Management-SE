package com.telepatient.auth.security;

import com.fasterxml.jackson.databind.ObjectMapper;
import jakarta.servlet.FilterChain;
import jakarta.servlet.ServletException;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import lombok.RequiredArgsConstructor;
import org.springframework.http.HttpStatus;
import org.springframework.http.MediaType;
import org.springframework.security.authentication.UsernamePasswordAuthenticationToken;
import org.springframework.security.core.authority.SimpleGrantedAuthority;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.security.web.authentication.WebAuthenticationDetailsSource;
import org.springframework.stereotype.Component;
import org.springframework.util.StringUtils;
import org.springframework.web.filter.OncePerRequestFilter;

import java.io.IOException;
import java.util.List;
import java.util.Map;

/**
 * Intercepts every HTTP request, extracts the Bearer token from the
 * Authorization header, validates it, and populates the SecurityContext.
 *
 * If the token is missing the filter simply passes through — Spring Security
 * will then reject the request if the endpoint requires authentication.
 *
 * If the token is present but invalid a 401 JSON response is returned
 * immediately without reaching the controller.
 */
@Component
@RequiredArgsConstructor
public class JwtAuthFilter extends OncePerRequestFilter {

    private final JwtUtils jwtUtils;
    private final ObjectMapper objectMapper;

    @Override
    protected void doFilterInternal(HttpServletRequest request,
                                    HttpServletResponse response,
                                    FilterChain filterChain)
            throws ServletException, IOException {

        String token = extractToken(request);

        if (token == null) {
            // No token — let the request through; security rules decide access
            filterChain.doFilter(request, response);
            return;
        }

        try {
            jwtUtils.validateToken(token);

            String email  = jwtUtils.extractEmail(token);
            Long   userId = jwtUtils.extractUserId(token);
            String role   = jwtUtils.extractRole(token);

            // Build a principal that carries userId and email for use in controllers
            JwtPrincipal principal = new JwtPrincipal(userId, email, role);

            // Grant authority as "ROLE_<ROLE_NAME>" so Spring's hasRole() works
            List<SimpleGrantedAuthority> authorities =
                    List.of(new SimpleGrantedAuthority("ROLE_" + role));

            UsernamePasswordAuthenticationToken auth =
                    new UsernamePasswordAuthenticationToken(principal, null, authorities);
            auth.setDetails(new WebAuthenticationDetailsSource().buildDetails(request));

            SecurityContextHolder.getContext().setAuthentication(auth);

        } catch (JwtAuthException ex) {
            // Token present but invalid — return 401 immediately
            sendError(response, HttpStatus.UNAUTHORIZED, ex.getMessage());
            return;
        }

        filterChain.doFilter(request, response);
    }

    // ─── Helpers ──────────────────────────────────────────────────────────────

    /** Extract the raw token from "Authorization: Bearer <token>" header. */
    private String extractToken(HttpServletRequest request) {
        String header = request.getHeader("Authorization");
        if (StringUtils.hasText(header) && header.startsWith("Bearer ")) {
            return header.substring(7);
        }
        return null;
    }

    /** Write a JSON error body and set the HTTP status. */
    private void sendError(HttpServletResponse response, HttpStatus status, String message)
            throws IOException {
        response.setStatus(status.value());
        response.setContentType(MediaType.APPLICATION_JSON_VALUE);
        objectMapper.writeValue(response.getWriter(),
                Map.of("error", message, "status", status.value()));
    }
}
