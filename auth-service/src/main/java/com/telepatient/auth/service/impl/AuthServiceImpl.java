package com.telepatient.auth.service.impl;

import com.telepatient.auth.dto.request.LoginRequest;
import com.telepatient.auth.dto.request.RegisterRequest;
import com.telepatient.auth.dto.response.AuthResponse;
import com.telepatient.auth.entity.User;
import com.telepatient.auth.repository.UserRepository;
import com.telepatient.auth.security.JwtUtil;
import com.telepatient.auth.service.AuthService;
import com.telepatient.auth.service.EmailService;
import lombok.RequiredArgsConstructor;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;

import java.time.LocalDateTime;

@Service
@RequiredArgsConstructor
public class AuthServiceImpl implements AuthService {

    private final UserRepository  userRepository;
    private final PasswordEncoder passwordEncoder;
    private final EmailService emailService;
    private final JwtUtil jwtUtil;

    // ─── Register ─────────────────────────────────────────────────────────────
    @Override
    public AuthResponse register(RegisterRequest request) {
        if (userRepository.existsByEmail(request.getEmail())) {
            throw new IllegalArgumentException("Email already registered");
        }
        User user = User.builder()
                .fullName(request.getFullName())
                .email(request.getEmail())
                .password(passwordEncoder.encode(request.getPassword()))
                .role(com.telepatient.auth.entity.Role.PATIENT)
                .build();
        User saved = userRepository.save(user);
        String token = jwtUtil.generateToken(saved.getId(), saved.getEmail(), saved.getRole().name());
        return AuthResponse.builder()
                .message("Registered successfully")
                .userId(saved.getId())
                .fullName(saved.getFullName())
                .email(saved.getEmail())
                .role(saved.getRole().name())
                .token(token)
                .build();
    }

    // ─── Login ────────────────────────────────────────────────────────────────
    @Override
    public AuthResponse login(LoginRequest request) {
        User user = userRepository.findByEmail(request.getEmail())
                .orElseThrow(() -> new IllegalArgumentException("Invalid email or password"));

        if (!passwordEncoder.matches(request.getPassword(), user.getPassword())) {
            throw new IllegalArgumentException("Invalid email or password");
        }

        boolean requireReset = request.getPassword().equals("temp@123");
        String token = jwtUtil.generateToken(user.getId(), user.getEmail(), user.getRole().name());
        return AuthResponse.builder()
                .message("Login successful")
                .userId(user.getId())
                .fullName(user.getFullName())
                .email(user.getEmail())
                .role(user.getRole().name())
                .token(token)
                .requirePasswordReset(requireReset)
                .token(token)                         // ← JWT returned here
                .build();
    }

    // ─── Forgot password ──────────────────────────────────────────────────────
    @Override
    public void generateResetOtp(String email) {
        User user = userRepository.findByEmail(email)
                .orElseThrow(() -> new IllegalArgumentException("No account found with this email"));
        String otp = String.format("%06d", new java.util.Random().nextInt(999999));
        user.setResetOtp(otp);
        user.setOtpExpiry(LocalDateTime.now().plusMinutes(10));
        userRepository.save(user);
        try {
            emailService.sendOtpEmail(email, otp);
        } catch (Exception e) {
            System.out.printf("%n=== OTP for %s: %s ===%n", email, otp);
        }
    }

    // ─── Reset via OTP ────────────────────────────────────────────────────────
    @Override
    public void resetPasswordWithOtp(String email, String otp, String newPassword) {
        User user = userRepository.findByEmail(email)
                .orElseThrow(() -> new IllegalArgumentException("Email not found"));
        if (otp == null || !otp.equals(user.getResetOtp()))
            throw new IllegalArgumentException("Invalid OTP");
        if (user.getOtpExpiry() == null || LocalDateTime.now().isAfter(user.getOtpExpiry()))
            throw new IllegalArgumentException("OTP expired. Request a new one.");
        user.setPassword(passwordEncoder.encode(newPassword));
        user.setResetOtp(null);
        user.setOtpExpiry(null);
        userRepository.save(user);
    }

    // ─── Reset temp password ──────────────────────────────────────────────────
    @Override
    public void resetPasswordWithTemp(String email, String currentPassword, String newPassword) {
        User user = userRepository.findByEmail(email)
                .orElseThrow(() -> new IllegalArgumentException("Email not found"));
        if (!passwordEncoder.matches(currentPassword, user.getPassword()))
            throw new IllegalArgumentException("Invalid current password");
        if (!currentPassword.equals("temp@123"))
            throw new IllegalArgumentException("Only temporary passwords can be reset this way");
        user.setPassword(passwordEncoder.encode(newPassword));
        userRepository.save(user);
    }
}
