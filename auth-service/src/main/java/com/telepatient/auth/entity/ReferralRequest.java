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
public class ReferralRequest {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @ManyToOne
    @JoinColumn(name = "from_doctor_id", nullable = false)
    private User fromDoctor;

    @ManyToOne
    @JoinColumn(name = "assigned_doctor_id")
    private User assignedDoctor;

    @ManyToOne
    @JoinColumn(name = "patient_id", nullable = false)
    private User patient;

    @Column(columnDefinition = "TEXT")
    private String reason;

    private String requestedSpecialty;
    private String urgency;

    @Enumerated(EnumType.STRING)
    private ReferralStatus status;

    private LocalDateTime requestDate;
    private LocalDateTime resolutionDate;
}
