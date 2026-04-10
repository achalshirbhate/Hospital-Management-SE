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
public class LaunchpadSubmission {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @ManyToOne
    @JoinColumn(name = "submitter_id", nullable = false)
    private User submitter;

    private String ideaTitle;

    @Column(columnDefinition = "TEXT")
    private String description;

    private String domain;
    private String contactInfo;
    private String response;

    private LocalDateTime submittedAt;
}
