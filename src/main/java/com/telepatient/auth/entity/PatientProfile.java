package com.telepatient.auth.entity;

import jakarta.persistence.*;
import lombok.*;

@Entity
@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class PatientProfile {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @OneToOne
    @JoinColumn(name = "user_id", nullable = false)
    private User user;

    private Integer age;
    private String logoUrl;
    
    @Column(columnDefinition = "TEXT")
    private String medicalHistory;
    
    @ManyToOne
    @JoinColumn(name = "current_doctor_id")
    private User currentDoctor;
}
