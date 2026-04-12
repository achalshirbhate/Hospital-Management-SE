package com.telepatient.auth.entity;

import jakarta.persistence.*;
import lombok.*;
import java.time.LocalDateTime;

@Entity
@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class CommunicationToken {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @ManyToOne
    @JoinColumn(name = "patient_id", nullable = false)
    private User patient;

    @ManyToOne
    @JoinColumn(name = "md_id", nullable = false)
    private User mainDoctor;

    @Enumerated(EnumType.STRING)
    private TokenType type;

    @Enumerated(EnumType.STRING)
    private TokenStatus status;

    private LocalDateTime requestedAt;
    private LocalDateTime approvedAt;
    private LocalDateTime expiresAt;
    
    private String scheduledTime;
    
    private boolean isFrozen;
}
