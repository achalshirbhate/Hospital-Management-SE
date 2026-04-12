package com.telepatient.auth.service.impl;

import com.telepatient.auth.dto.request.LoginRequest;
import com.telepatient.auth.dto.request.RegisterRequest;
import com.telepatient.auth.dto.response.AuthResponse;
import com.telepatient.auth.entity.User;
import com.telepatient.auth.repository.UserRepository;
import com.telepatient.auth.service.AuthService;
import com.telepatient.auth.service.EmailService;
import lombok.RequiredArgsConstructor;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;
import java.time.LocalDateTime;

@Service
@RequiredArgsConstructor
public class AuthServiceImpl implements AuthService {

    private final UserRepository userRepository;
    private final PasswordEncoder passwordEncoder;
    private final EmailService emailService;

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
        User savedUser = userRepository.save(user);
        return AuthResponse.builder()
                .message("User registered successfully")
                .userId(savedUser.getId())
                .fullName(savedUser.getFullName())
                .email(savedUser.getEmail())
                .role(savedUser.getRole().name())
                .build();
    }

    @Override
    public AuthResponse login(LoginRequest request) {
        User user = userRepository.findByEmail(request.getEmail())
                .orElseThrow(() -> new IllegalArgumentException("Invalid email or password"));
        if (!passwordEncoder.matches(request.getPassword(), user.getPassword())) {
            throw new IllegalArgumentException("Invalid email or password");
        }
        boolean requireReset = request.getPassword().equals("temp@123");
        return AuthResponse.builder()
                .message("Login successful")
                .userId(user.getId())
                .fullName(user.getFullName())
                .email(user.getEmail())
                .role(user.getRole().name())
                .requirePasswordReset(requireReset)
                .build();
    }

    @Override
    public void generateResetOtp(String email) {
        User user = userRepository.findByEmail(email)
                .orElseThrow(() -> new IllegalArgumentException("No account found with this email address."));
        String otp = String.format("%06d", new java.util.Random().nextInt(999999));
        user.setResetOtp(otp);
        user.setOtpExpiry(LocalDateTime.now().plusMinutes(5));
        userRepository.save(user);
        // Try sending email; silently fallback to console if SMTP not configured
        try {
            emailService.sendOtpEmail(email, otp);
        } catch (Exception e) {
            System.out.println("\n=========================================================");
            System.out.println("OTP FOR: " + email + "  →  " + otp);
            System.out.println("=========================================================\n");
        }
        // Always return success — OTP is saved regardless of email delivery
    }

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

    @Override
    public void resetPasswordWithTemp(String email, String currentPassword, String newPassword) {
        User user = userRepository.findByEmail(email)
                .orElseThrow(() -> new IllegalArgumentException("Email not found"));
        if (!passwordEncoder.matches(currentPassword, user.getPassword())) {
            throw new IllegalArgumentException("Invalid current password");
        }
        if (!currentPassword.equals("temp@123")) {
            throw new IllegalArgumentException("This mechanism is strictly restricted to temporary passwords only.");
        }
        user.setPassword(passwordEncoder.encode(newPassword));
        userRepository.save(user);
    }
}
