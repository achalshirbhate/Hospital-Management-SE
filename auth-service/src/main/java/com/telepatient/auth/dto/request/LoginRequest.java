package com.telepatient.auth.dto.request;

import jakarta.validation.constraints.NotBlank;

public class LoginRequest {

    @NotBlank(message = "Email is required")
    private String email;

    @NotBlank(message = "Password is required")
    private String password;

    public LoginRequest() {}
    public LoginRequest(String email, String password) { this.email = email; this.password = password; }

    public String getEmail() { return email; }
    public String getPassword() { return password; }
    public void setEmail(String e) { this.email = e; }
    public void setPassword(String p) { this.password = p; }
}
