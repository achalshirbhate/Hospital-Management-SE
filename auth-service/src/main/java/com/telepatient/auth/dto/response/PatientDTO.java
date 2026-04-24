package com.telepatient.auth.dto.response;

import java.time.LocalDateTime;

public class PatientDTO {
    private Long id; private String fullName, historySummary, specialty;
    private Integer age; private LocalDateTime lastConsultation;

    public PatientDTO() {}

    public static Builder builder() { return new Builder(); }

    public static class Builder {
        private Long id; private String fullName, historySummary, specialty;
        private Integer age; private LocalDateTime lastConsultation;

        public Builder id(Long id) { this.id = id; return this; }
        public Builder fullName(String n) { this.fullName = n; return this; }
        public Builder historySummary(String h) { this.historySummary = h; return this; }
        public Builder specialty(String s) { this.specialty = s; return this; }
        public Builder age(Integer a) { this.age = a; return this; }
        public Builder lastConsultation(LocalDateTime d) { this.lastConsultation = d; return this; }
        public PatientDTO build() {
            PatientDTO p = new PatientDTO();
            p.id = id; p.fullName = fullName; p.historySummary = historySummary;
            p.specialty = specialty; p.age = age; p.lastConsultation = lastConsultation;
            return p;
        }
    }

    public Long getId() { return id; }
    public String getFullName() { return fullName; }
    public String getHistorySummary() { return historySummary; }
    public String getSpecialty() { return specialty; }
    public Integer getAge() { return age; }
    public LocalDateTime getLastConsultation() { return lastConsultation; }
}
