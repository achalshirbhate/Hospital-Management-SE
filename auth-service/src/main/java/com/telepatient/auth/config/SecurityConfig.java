package com.telepatient.auth.config;

import com.telepatient.auth.security.JwtAccessDeniedHandler;
import com.telepatient.auth.security.JwtAuthEntryPoint;
import com.telepatient.auth.security.JwtAuthFilter;
import lombok.RequiredArgsConstructor;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.security.config.annotation.method.configuration.EnableMethodSecurity;
import org.springframework.security.config.annotation.web.builders.HttpSecurity;
import org.springframework.security.config.annotation.web.configuration.EnableWebSecurity;
import org.springframework.security.config.http.SessionCreationPolicy;
import org.springframework.security.web.SecurityFilterChain;
import org.springframework.security.web.authentication.UsernamePasswordAuthenticationFilter;
import org.springframework.web.cors.CorsConfiguration;
import org.springframework.web.cors.CorsConfigurationSource;
import org.springframework.web.cors.UrlBasedCorsConfigurationSource;

import java.util.Arrays;
import java.util.List;

@Configuration
@EnableWebSecurity
@EnableMethodSecurity
@RequiredArgsConstructor
public class SecurityConfig {

    private final JwtAuthFilter          jwtAuthFilter;
    private final JwtAuthEntryPoint      authEntryPoint;
    private final JwtAccessDeniedHandler accessDeniedHandler;

    /**
     * Comma-separated list of allowed CORS origins from application.properties.
     * Defaults to "*" which is correct for native mobile apps (Flutter does not
     * send an Origin header, so wildcard is safe and required).
     *
     * For web frontends, set CORS_ALLOWED_ORIGINS=https://yourapp.com
     */
    @Value("${cors.allowed-origins:*}")
    private String allowedOriginsRaw;

    @Bean
    public SecurityFilterChain filterChain(HttpSecurity http) throws Exception {
        http
            .cors(cors -> cors.configurationSource(corsConfigurationSource()))
            .csrf(csrf -> csrf.disable())
            .sessionManagement(sm ->
                sm.sessionCreationPolicy(SessionCreationPolicy.STATELESS))
            .exceptionHandling(ex -> ex
                .authenticationEntryPoint(authEntryPoint)
                .accessDeniedHandler(accessDeniedHandler))
            .authorizeHttpRequests(authz -> authz
                // ── Public ────────────────────────────────────────────────
                .requestMatchers("/api/auth/**").permitAll()
                // WebSocket upgrade handshake must be permitted
                .requestMatchers("/ws/**").permitAll()
                // Actuator health check (used by Render/Railway)
                .requestMatchers("/actuator/health").permitAll()

                // ── Authenticated (any role) ───────────────────────────────
                .requestMatchers("/api/shared/**").authenticated()
                .requestMatchers("/api/notifications/**").authenticated()
                .requestMatchers("/api/chat/**").authenticated()
                .requestMatchers("/api/reports/**").authenticated()

                // ── Role-scoped ────────────────────────────────────────────
                .requestMatchers("/api/patient/**").hasRole("PATIENT")
                .requestMatchers("/api/doctor/**").hasRole("DOCTOR")
                .requestMatchers("/api/md/**").hasRole("MAIN_DOCTOR")

                .anyRequest().authenticated()
            )
            .addFilterBefore(jwtAuthFilter, UsernamePasswordAuthenticationFilter.class);

        return http.build();
    }

    @Bean
    public CorsConfigurationSource corsConfigurationSource() {
        CorsConfiguration config = new CorsConfiguration();

        // Parse the comma-separated origins from config
        List<String> origins = Arrays.stream(allowedOriginsRaw.split(","))
                .map(String::trim)
                .filter(s -> !s.isEmpty())
                .toList();

        if (origins.contains("*")) {
            // Wildcard — required for native mobile apps (no Origin header)
            // Note: allowCredentials must be false when using wildcard
            config.setAllowedOriginPatterns(List.of("*"));
            config.setAllowCredentials(false);
        } else {
            // Specific origins — credentials can be allowed
            config.setAllowedOrigins(origins);
            config.setAllowCredentials(true);
        }

        config.setAllowedMethods(List.of("GET", "POST", "PUT", "DELETE", "OPTIONS", "PATCH"));
        config.setAllowedHeaders(List.of("*"));
        config.setExposedHeaders(List.of("Authorization"));
        // Cache preflight for 1 hour
        config.setMaxAge(3600L);

        UrlBasedCorsConfigurationSource source = new UrlBasedCorsConfigurationSource();
        source.registerCorsConfiguration("/**", config);
        return source;
    }
}
