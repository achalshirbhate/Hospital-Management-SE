package com.telepatient.auth.dto.response;

public class AuthResponse {
    private String message;
    private Long userId;
    private String fullName;
    private String email;
    private String role;
    private String token;
    private boolean requirePasswordReset;

    public AuthResponse() {}

    public static Builder builder() { return new Builder(); }

    public static class Builder {
        private String message, fullName, email, role, token;
        private Long userId; private boolean requirePasswordReset;

        public Builder message(String m) { this.message = m; return this; }
        public Builder userId(Long id) { this.userId = id; return this; }
        public Builder fullName(String n) { this.fullName = n; return this; }
        public Builder email(String e) { this.email = e; return this; }
        public Builder role(String r) { this.role = r; return this; }
        public Builder token(String t) { this.token = t; return this; }
        public Builder requirePasswordReset(boolean r) { this.requirePasswordReset = r; return this; }
        public AuthResponse build() {
            AuthResponse a = new AuthResponse();
            a.message = message; a.userId = userId; a.fullName = fullName;
            a.email = email; a.role = role; a.token = token;
            a.requirePasswordReset = requirePasswordReset;
            return a;
        }
    }

    public String getMessage() { return message; }
    public Long getUserId() { return userId; }
    public String getFullName() { return fullName; }
    public String getEmail() { return email; }
    public String getRole() { return role; }
    public String getToken() { return token; }
    public boolean isRequirePasswordReset() { return requirePasswordReset; }

    public void setMessage(String m) { this.message = m; }
    public void setUserId(Long id) { this.userId = id; }
    public void setFullName(String n) { this.fullName = n; }
    public void setEmail(String e) { this.email = e; }
    public void setRole(String r) { this.role = r; }
    public void setToken(String t) { this.token = t; }
    public void setRequirePasswordReset(boolean r) { this.requirePasswordReset = r; }
}
