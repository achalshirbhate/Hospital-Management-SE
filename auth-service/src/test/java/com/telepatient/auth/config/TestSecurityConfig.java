package com.telepatient.auth.config;

import com.telepatient.auth.repository.UserRepository;
import com.telepatient.auth.security.JwtUtils;
import org.springframework.boot.test.context.TestConfiguration;
import org.springframework.boot.test.mock.mockito.MockBean;
import org.springframework.context.annotation.Bean;
import org.springframework.security.config.annotation.method.configuration.EnableMethodSecurity;
import org.springframework.security.config.annotation.web.builders.HttpSecurity;
import org.springframework.security.crypto.bcrypt.BCryptPasswordEncoder;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.security.web.SecurityFilterChain;

/**
 * Shared test configuration imported by all @WebMvcTest controller tests.
 *
 * Provides:
 *  1. A permissive SecurityFilterChain (all HTTP requests allowed).
 *  2. @EnableMethodSecurity so @PreAuthorize on controllers is still enforced.
 *  3. Mocks for beans @WebMvcTest cannot auto-create:
 *     - JwtUtils       → required by JwtAuthFilter (@Component)
 *     - UserRepository → required by AuthServiceApplication.initData()
 *  4. A real PasswordEncoder (required by initData, cheap to create).
 */
@TestConfiguration
@EnableMethodSecurity
public class TestSecurityConfig {

    /** Satisfies JwtAuthFilter constructor dependency. */
    @MockBean
    JwtUtils jwtUtils;

    /**
     * Satisfies AuthServiceApplication.initData() which is a @Bean
     * on the main application class — picked up even in @WebMvcTest slices.
     */
    @MockBean
    UserRepository userRepository;

    /** initData also needs a PasswordEncoder — provide a real one (no DB needed). */
    @Bean
    public PasswordEncoder passwordEncoder() {
        return new BCryptPasswordEncoder();
    }

    @Bean
    public SecurityFilterChain testFilterChain(HttpSecurity http) throws Exception {
        http
            .csrf(csrf -> csrf.disable())
            // Permit all at HTTP level — role enforcement is done via @PreAuthorize
            .authorizeHttpRequests(auth -> auth.anyRequest().permitAll());
        return http.build();
    }
}
