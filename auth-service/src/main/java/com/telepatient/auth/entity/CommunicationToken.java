package com.telepatient.auth.entity;

import jakarta.persistence.*;
import java.time.LocalDateTime;

@Entity
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

    public CommunicationToken() {}

    public CommunicationToken(Long id, User patient, User mainDoctor, TokenType type,
            TokenStatus status, LocalDateTime requestedAt, LocalDateTime approvedAt,
            LocalDateTime expiresAt, String scheduledTime, boolean isFrozen) {
        this.id = id; this.patient = patient; this.mainDoctor = mainDoctor;
        this.type = type; this.status = status; this.requestedAt = requestedAt;
        this.approvedAt = approvedAt; this.expiresAt = expiresAt;
        this.scheduledTime = scheduledTime; this.isFrozen = isFrozen;
    }

    public static Builder builder() { return new Builder(); }

    public static class Builder {
        private Long id; private User patient; private User mainDoctor;
        private TokenType type; private TokenStatus status;
        private LocalDateTime requestedAt, approvedAt, expiresAt;
        private String scheduledTime; private boolean isFrozen;

        public Builder id(Long id) { this.id = id; return this; }
        public Builder patient(User p) { this.patient = p; return this; }
        public Builder mainDoctor(User m) { this.mainDoctor = m; return this; }
        public Builder type(TokenType t) { this.type = t; return this; }
        public Builder status(TokenStatus s) { this.status = s; return this; }
        public Builder requestedAt(LocalDateTime d) { this.requestedAt = d; return this; }
        public Builder approvedAt(LocalDateTime d) { this.approvedAt = d; return this; }
        public Builder expiresAt(LocalDateTime d) { this.expiresAt = d; return this; }
        public Builder scheduledTime(String s) { this.scheduledTime = s; return this; }
        public Builder isFrozen(boolean f) { this.isFrozen = f; return this; }
        public CommunicationToken build() {
            return new CommunicationToken(id, patient, mainDoctor, type, status,
                    requestedAt, approvedAt, expiresAt, scheduledTime, isFrozen);
        }
    }

    public Long getId() { return id; }
    public User getPatient() { return patient; }
    public User getMainDoctor() { return mainDoctor; }
    public TokenType getType() { return type; }
    public TokenStatus getStatus() { return status; }
    public LocalDateTime getRequestedAt() { return requestedAt; }
    public LocalDateTime getApprovedAt() { return approvedAt; }
    public LocalDateTime getExpiresAt() { return expiresAt; }
    public String getScheduledTime() { return scheduledTime; }
    public boolean isFrozen() { return isFrozen; }

    public void setId(Long id) { this.id = id; }
    public void setPatient(User p) { this.patient = p; }
    public void setMainDoctor(User m) { this.mainDoctor = m; }
    public void setType(TokenType t) { this.type = t; }
    public void setStatus(TokenStatus s) { this.status = s; }
    public void setRequestedAt(LocalDateTime d) { this.requestedAt = d; }
    public void setApprovedAt(LocalDateTime d) { this.approvedAt = d; }
    public void setExpiresAt(LocalDateTime d) { this.expiresAt = d; }
    public void setScheduledTime(String s) { this.scheduledTime = s; }
    public void setFrozen(boolean f) { this.isFrozen = f; }
}
