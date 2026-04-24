package com.telepatient.auth.dto.request;

import jakarta.validation.constraints.Email;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.Size;

public class RegisterRequest {

    @NotBlank(message = "Full name is required")
    private String fullName;

    @NotBlank(message = "Email is required")
    @Email(message = "Email format is not valid")
    private String email;

    @NotBlank(message = "Password is required")
    @Size(min = 5, message = "Password must be at least 5 characters")
    private String password;

    public RegisterRequest() {}
    public RegisterRequest(String fullName, String email, String password) {
        this.fullName = fullName; this.email = email; this.password = password;
    }

    public String getFullName() { return fullName; }
    public String getEmail() { return email; }
    public String getPassword() { return password; }
    public void setFullName(String n) { this.fullName = n; }
    public void setEmail(String e) { this.email = e; }
    public void setPassword(String p) { this.password = p; }
}
