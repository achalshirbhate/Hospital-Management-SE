package com.telepatient.auth.dto.response;

import java.time.LocalDateTime;

public class EmergencyAlertDTO {
    private Long id;
    private String patientName, level;
    private LocalDateTime alertTime;

    public EmergencyAlertDTO() {}

    public static Builder builder() { return new Builder(); }

    public static class Builder {
        private Long id; private String patientName, level; private LocalDateTime alertTime;

        public Builder id(Long id) { this.id = id; return this; }
        public Builder patientName(String n) { this.patientName = n; return this; }
        public Builder level(String l) { this.level = l; return this; }
        public Builder alertTime(LocalDateTime d) { this.alertTime = d; return this; }
        public EmergencyAlertDTO build() {
            EmergencyAlertDTO e = new EmergencyAlertDTO();
            e.id = id; e.patientName = patientName; e.level = level; e.alertTime = alertTime;
            return e;
        }
    }

    public Long getId() { return id; }
    public String getPatientName() { return patientName; }
    public String getLevel() { return level; }
    public LocalDateTime getAlertTime() { return alertTime; }
}
