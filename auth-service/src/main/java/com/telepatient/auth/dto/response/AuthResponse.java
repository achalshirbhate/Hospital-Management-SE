package com.telepatient.auth.dto.response;

import lombok.*;

@Data
@Builder
@AllArgsConstructor
@NoArgsConstructor
public class AuthResponse {
    private String message;
    private Long userId;
    private String fullName;
    private String email;
    private String role;
    private String token;           // JWT token
    private boolean requirePasswordReset;
}
