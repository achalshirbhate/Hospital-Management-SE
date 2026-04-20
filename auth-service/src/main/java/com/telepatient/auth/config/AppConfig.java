package com.telepatient.auth.config;

import com.fasterxml.jackson.databind.ObjectMapper;
import com.fasterxml.jackson.databind.SerializationFeature;
import com.fasterxml.jackson.datatype.jsr310.JavaTimeModule;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.security.crypto.bcrypt.BCryptPasswordEncoder;
import org.springframework.security.crypto.password.PasswordEncoder;

/**
 * General application beans.
 *
 * CORS is configured exclusively in SecurityConfig to avoid conflicts.
 * The WebMvcConfigurer.addCorsMappings approach was removed because
 * Spring Security's CorsConfigurationSource takes precedence and having
 * both causes duplicate/conflicting headers in production.
 */
@Configuration
public class AppConfig {

    @Bean
    public PasswordEncoder passwordEncoder() {
        return new BCryptPasswordEncoder();
    }

    /**
     * ObjectMapper with Java 8 time support.
     * Ensures LocalDateTime fields serialize as ISO-8601 strings, not arrays.
     */
    @Bean
    public ObjectMapper objectMapper() {
        return new ObjectMapper()
                .registerModule(new JavaTimeModule())
                .disable(SerializationFeature.WRITE_DATES_AS_TIMESTAMPS);
    }
}
