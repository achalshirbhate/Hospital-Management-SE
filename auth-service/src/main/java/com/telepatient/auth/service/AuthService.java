package com.telepatient.auth.service;

import com.telepatient.auth.dto.request.LoginRequest;
import com.telepatient.auth.dto.request.RegisterRequest;
import com.telepatient.auth.dto.response.AuthResponse;

public interface AuthService {
    AuthResponse register(RegisterRequest request);
    AuthResponse login(LoginRequest request);
    void generateResetOtp(String email);
    void resetPasswordWithOtp(String email, String otp, String newPassword);
    void resetPasswordWithTemp(String email, String currentPassword, String newPassword);
}
