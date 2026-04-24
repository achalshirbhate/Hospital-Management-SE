package com.telepatient.auth.entity;

import jakarta.persistence.*;
import java.time.LocalDateTime;

@Entity
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

    public ReferralRequest() {}

    public ReferralRequest(Long id, User fromDoctor, User assignedDoctor, User patient,
            String reason, String requestedSpecialty, String urgency,
            ReferralStatus status, LocalDateTime requestDate, LocalDateTime resolutionDate) {
        this.id = id; this.fromDoctor = fromDoctor; this.assignedDoctor = assignedDoctor;
        this.patient = patient; this.reason = reason;
        this.requestedSpecialty = requestedSpecialty; this.urgency = urgency;
        this.status = status; this.requestDate = requestDate; this.resolutionDate = resolutionDate;
    }

    public static Builder builder() { return new Builder(); }

    public static class Builder {
        private Long id; private User fromDoctor, assignedDoctor, patient;
        private String reason, requestedSpecialty, urgency;
        private ReferralStatus status;
        private LocalDateTime requestDate, resolutionDate;

        public Builder id(Long id) { this.id = id; return this; }
        public Builder fromDoctor(User d) { this.fromDoctor = d; return this; }
        public Builder assignedDoctor(User d) { this.assignedDoctor = d; return this; }
        public Builder patient(User p) { this.patient = p; return this; }
        public Builder reason(String r) { this.reason = r; return this; }
        public Builder requestedSpecialty(String s) { this.requestedSpecialty = s; return this; }
        public Builder urgency(String u) { this.urgency = u; return this; }
        public Builder status(ReferralStatus s) { this.status = s; return this; }
        public Builder requestDate(LocalDateTime d) { this.requestDate = d; return this; }
        public Builder resolutionDate(LocalDateTime d) { this.resolutionDate = d; return this; }
        public ReferralRequest build() {
            return new ReferralRequest(id, fromDoctor, assignedDoctor, patient,
                    reason, requestedSpecialty, urgency, status, requestDate, resolutionDate);
        }
    }

    public Long getId() { return id; }
    public User getFromDoctor() { return fromDoctor; }
    public User getAssignedDoctor() { return assignedDoctor; }
    public User getPatient() { return patient; }
    public String getReason() { return reason; }
    public String getRequestedSpecialty() { return requestedSpecialty; }
    public String getUrgency() { return urgency; }
    public ReferralStatus getStatus() { return status; }
    public LocalDateTime getRequestDate() { return requestDate; }
    public LocalDateTime getResolutionDate() { return resolutionDate; }

    public void setId(Long id) { this.id = id; }
    public void setFromDoctor(User d) { this.fromDoctor = d; }
    public void setAssignedDoctor(User d) { this.assignedDoctor = d; }
    public void setPatient(User p) { this.patient = p; }
    public void setReason(String r) { this.reason = r; }
    public void setRequestedSpecialty(String s) { this.requestedSpecialty = s; }
    public void setUrgency(String u) { this.urgency = u; }
    public void setStatus(ReferralStatus s) { this.status = s; }
    public void setRequestDate(LocalDateTime d) { this.requestDate = d; }
    public void setResolutionDate(LocalDateTime d) { this.resolutionDate = d; }
}
