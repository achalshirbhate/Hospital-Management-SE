package com.telepatient.auth.entity;

import jakarta.persistence.*;
import java.time.LocalDateTime;

@Entity
@Table(name = "users")
public class User {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @Column(nullable = false)
    private String fullName;

    @Column(nullable = false, unique = true)
    private String email;

    @Column(nullable = false)
    private String password;

    @Enumerated(EnumType.STRING)
    @Column(nullable = false)
    private Role role;

    private String specialty;
    private String resetOtp;
    private LocalDateTime otpExpiry;

    public User() {}

    public User(Long id, String fullName, String email, String password, Role role,
                String specialty, String resetOtp, LocalDateTime otpExpiry) {
        this.id = id; this.fullName = fullName; this.email = email;
        this.password = password; this.role = role; this.specialty = specialty;
        this.resetOtp = resetOtp; this.otpExpiry = otpExpiry;
    }

    public static Builder builder() { return new Builder(); }

    public static class Builder {
        private Long id; private String fullName, email, password, specialty, resetOtp;
        private Role role; private LocalDateTime otpExpiry;

        public Builder id(Long id) { this.id = id; return this; }
        public Builder fullName(String n) { this.fullName = n; return this; }
        public Builder email(String e) { this.email = e; return this; }
        public Builder password(String p) { this.password = p; return this; }
        public Builder role(Role r) { this.role = r; return this; }
        public Builder specialty(String s) { this.specialty = s; return this; }
        public Builder resetOtp(String o) { this.resetOtp = o; return this; }
        public Builder otpExpiry(LocalDateTime d) { this.otpExpiry = d; return this; }
        public User build() {
            return new User(id, fullName, email, password, role, specialty, resetOtp, otpExpiry);
        }
    }

    public Long getId() { return id; }
    public String getFullName() { return fullName; }
    public String getEmail() { return email; }
    public String getPassword() { return password; }
    public Role getRole() { return role; }
    public String getSpecialty() { return specialty; }
    public String getResetOtp() { return resetOtp; }
    public LocalDateTime getOtpExpiry() { return otpExpiry; }

    public void setId(Long id) { this.id = id; }
    public void setFullName(String n) { this.fullName = n; }
    public void setEmail(String e) { this.email = e; }
    public void setPassword(String p) { this.password = p; }
    public void setRole(Role r) { this.role = r; }
    public void setSpecialty(String s) { this.specialty = s; }
    public void setResetOtp(String o) { this.resetOtp = o; }
    public void setOtpExpiry(LocalDateTime d) { this.otpExpiry = d; }
}
