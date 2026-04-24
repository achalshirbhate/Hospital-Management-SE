package com.telepatient.auth.entity;

import jakarta.persistence.*;
import java.time.LocalDateTime;

@Entity
@Table(name = "emergency_alerts")
public class EmergencyAlert {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @ManyToOne
    @JoinColumn(name = "patient_id")
    private User patient;

    private String level;
    private LocalDateTime alertTime;
    private boolean acknowledged;

    public EmergencyAlert() {}

    public static Builder builder() { return new Builder(); }

    public static class Builder {
        private Long id; private User patient; private String level;
        private LocalDateTime alertTime; private boolean acknowledged;

        public Builder id(Long id) { this.id = id; return this; }
        public Builder patient(User p) { this.patient = p; return this; }
        public Builder level(String l) { this.level = l; return this; }
        public Builder alertTime(LocalDateTime d) { this.alertTime = d; return this; }
        public Builder acknowledged(boolean a) { this.acknowledged = a; return this; }
        public EmergencyAlert build() {
            EmergencyAlert e = new EmergencyAlert();
            e.id = id; e.patient = patient; e.level = level;
            e.alertTime = alertTime; e.acknowledged = acknowledged;
            return e;
        }
    }

    public Long getId() { return id; }
    public User getPatient() { return patient; }
    public String getLevel() { return level; }
    public LocalDateTime getAlertTime() { return alertTime; }
    public boolean isAcknowledged() { return acknowledged; }

    public void setId(Long id) { this.id = id; }
    public void setPatient(User p) { this.patient = p; }
    public void setLevel(String l) { this.level = l; }
    public void setAlertTime(LocalDateTime d) { this.alertTime = d; }
    public void setAcknowledged(boolean a) { this.acknowledged = a; }
}
