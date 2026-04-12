package com.telepatient.auth.entity;

import jakarta.persistence.*;
import lombok.*;
import java.time.LocalDateTime;

@Entity
@Table(name = "emergency_alerts")
@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class EmergencyAlert {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @ManyToOne
    @JoinColumn(name = "patient_id")
    private User patient;

    private String level; // CRITICAL, URGENT, NORMAL

    private LocalDateTime alertTime;

    private boolean acknowledged;
}
