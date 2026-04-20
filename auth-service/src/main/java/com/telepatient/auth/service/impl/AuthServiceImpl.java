package com.telepatient.auth.service.impl;

import com.telepatient.auth.dto.request.LoginRequest;
import com.telepatient.auth.dto.request.RegisterRequest;
import com.telepatient.auth.dto.response.AuthResponse;
import com.telepatient.auth.entity.User;
import com.telepatient.auth.repository.UserRepository;
import com.telepatient.auth.security.JwtUtils;
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
    private final EmailService    emailService;
    private final JwtUtils        jwtUtils;          // ← injected JWT utility

    // ─── Register ─────────────────────────────────────────────────────────────
    @Override
    public AuthResponse register(RegisterRequest request) {
        if (userRepository.existsByEmail(request.getEmail())) {
            throw new IllegalArgumentException("Email already exists");
        }
        User user = User.builder()
                .fullName(request.getFullName())
                .email(request.getEmail())
                .password(passwordEncoder.encode(request.getPassword()))
                .role(com.telepatient.auth.entity.Role.PATIENT)
                .build();
        User saved = userRepository.save(user);

        // Registration does NOT return a token — user must log in explicitly.
        return AuthResponse.builder()
                .message("User registered successfully")
                .userId(saved.getId())
                .fullName(saved.getFullName())
                .email(saved.getEmail())
                .role(saved.getRole().name())
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

        // Generate JWT — embed userId and role so the filter can reconstruct
        // the principal without a DB lookup on every request.
        String token = jwtUtils.generateToken(
                user.getEmail(), user.getId(), user.getRole().name());

        return AuthResponse.builder()
                .message("Login successful")
                .userId(user.getId())
                .fullName(user.getFullName())
                .email(user.getEmail())
                .role(user.getRole().name())
                .requirePasswordReset(requireReset)
                .token(token)                         // ← JWT returned here
                .build();
    }

    // ─── Forgot password ──────────────────────────────────────────────────────
    @Override
    public void generateResetOtp(String email) {
        User user = userRepository.findByEmail(email)
                .orElseThrow(() -> new IllegalArgumentException(
                        "No account found with this email address."));

        String otp = String.format("%06d", new java.util.Random().nextInt(999999));
        user.setResetOtp(otp);
        user.setOtpExpiry(LocalDateTime.now().plusMinutes(5));
        userRepository.save(user);

        try {
            emailService.sendOtpEmail(email, otp);
        } catch (Exception e) {
            System.out.println("\n=========================================================");
            System.out.println("OTP FOR: " + email + "  →  " + otp);
            System.out.println("=========================================================\n");
        }
    }

    // ─── Reset via OTP ────────────────────────────────────────────────────────
    @Override
    public void resetPasswordWithOtp(String email, String otp, String newPassword) {
        User user = userRepository.findByEmail(email)
                .orElseThrow(() -> new IllegalArgumentException("Email not found"));

        if (otp == null || !otp.equals(user.getResetOtp())) {
            throw new IllegalArgumentException("Invalid or expired OTP");
        }
        if (user.getOtpExpiry() == null || LocalDateTime.now().isAfter(user.getOtpExpiry())) {
            throw new IllegalArgumentException("OTP has expired. Please request a new one.");
        }

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

        if (!passwordEncoder.matches(currentPassword, user.getPassword())) {
            throw new IllegalArgumentException("Invalid current password");
        }
        if (!currentPassword.equals("temp@123")) {
            throw new IllegalArgumentException(
                    "This mechanism is strictly restricted to temporary passwords only.");
        }

        user.setPassword(passwordEncoder.encode(newPassword));
        userRepository.save(user);
    }
}
