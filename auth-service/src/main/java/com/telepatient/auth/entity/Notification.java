package com.telepatient.auth.entity;

import jakarta.persistence.*;
import lombok.*;
import java.time.LocalDateTime;

@Entity
@Table(name = "notifications")
@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class Notification {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @ManyToOne
    @JoinColumn(name = "user_id", nullable = false)
    private User user;

    private String message;
    private String type;      // REPORT, PRESCRIPTION, APPOINTMENT, CHAT, EMERGENCY, GENERAL
    private String priority;  // HIGH, MEDIUM, LOW
    private boolean isRead;
    private LocalDateTime createdAt;
}
