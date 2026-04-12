package com.telepatient.auth.service;

import lombok.RequiredArgsConstructor;
import org.springframework.mail.SimpleMailMessage;
import org.springframework.mail.javamail.JavaMailSender;
import org.springframework.stereotype.Service;

@Service
@RequiredArgsConstructor
public class EmailService {

    private final JavaMailSender mailSender;

    public void sendOtpEmail(String toEmail, String otp) {
        SimpleMailMessage message = new SimpleMailMessage();
        message.setTo(toEmail);
        message.setSubject("Tele Patient System — Password Reset OTP");
        message.setText(
            "Hello,\n\n" +
            "Your OTP for password reset is:\n\n" +
            "  " + otp + "\n\n" +
            "This OTP is valid for 5 minutes.\n" +
            "Do not share this OTP with anyone.\n\n" +
            "If you did not request this, please ignore this email.\n\n" +
            "— Tele Patient System"
        );
        mailSender.send(message);
    }
}
