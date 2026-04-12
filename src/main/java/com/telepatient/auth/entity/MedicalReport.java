package com.telepatient.auth.entity;

import jakarta.persistence.*;
import lombok.*;
import java.time.LocalDateTime;

@Entity
@Table(name = "medical_reports")
@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class MedicalReport {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @ManyToOne
    @JoinColumn(name = "patient_id", nullable = false)
    private User patient;

    @ManyToOne
    @JoinColumn(name = "doctor_id", nullable = false)
    private User doctor;

    private String reportName;

    // PDF, IMAGE, TEXT
    private String reportType;

    @Column(columnDefinition = "TEXT")
    private String fileUrl;

    @Column(columnDefinition = "TEXT")
    private String notes;

    private LocalDateTime uploadedAt;
}
