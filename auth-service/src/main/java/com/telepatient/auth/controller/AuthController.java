package com.telepatient.auth.controller;

import com.telepatient.auth.dto.request.LoginRequest;
import com.telepatient.auth.dto.request.RegisterRequest;
import com.telepatient.auth.dto.response.AuthResponse;
import com.telepatient.auth.service.AuthService;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/api/auth")
@RequiredArgsConstructor
public class AuthController {

    private final AuthService authService;

    @PostMapping("/register")
    public ResponseEntity<AuthResponse> register(@Valid @RequestBody RegisterRequest request) {
        return new ResponseEntity<>(authService.register(request), HttpStatus.CREATED);
    }

    @PostMapping("/login")
    public ResponseEntity<AuthResponse> login(@Valid @RequestBody LoginRequest request) {
        return ResponseEntity.ok(authService.login(request));
    }

    @PostMapping("/forgot-password")
    public ResponseEntity<String> forgotPassword(@RequestParam String email) {
        authService.generateResetOtp(email);
        return ResponseEntity.ok("OTP sent securely to registered email.");
    }

    @PostMapping("/reset-password-otp")
    public ResponseEntity<String> resetPasswordOtp(@RequestParam String email, 
                                                   @RequestParam String otp, 
                                                   @RequestParam String newPassword) {
        authService.resetPasswordWithOtp(email, otp, newPassword);
        return ResponseEntity.ok("Password updated successfully.");
    }

    @PostMapping("/reset-password-temp")
    public ResponseEntity<String> resetPasswordTemp(@RequestParam String email, 
                                                    @RequestParam String currentPassword, 
                                                    @RequestParam String newPassword) {
        authService.resetPasswordWithTemp(email, currentPassword, newPassword);
        return ResponseEntity.ok("Temporary password permanently overwritten.");
    }
}
