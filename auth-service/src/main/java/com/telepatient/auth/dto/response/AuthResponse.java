package com.telepatient.auth.dto.response;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@Builder
@AllArgsConstructor
@NoArgsConstructor
public class AuthResponse {
    private String  message;
    private Long    userId;
    private String  fullName;
    private String  email;
    private String  role;
    private boolean requirePasswordReset;

    /** JWT Bearer token — present only on successful login. */
    private String  token;
}
