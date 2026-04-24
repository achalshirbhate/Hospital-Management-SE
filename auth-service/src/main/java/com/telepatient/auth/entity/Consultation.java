package com.telepatient.auth.entity;

import jakarta.persistence.*;
import java.time.LocalDateTime;

@Entity
public class Consultation {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @ManyToOne
    @JoinColumn(name = "doctor_id", nullable = false)
    private User doctor;

    @ManyToOne
    @JoinColumn(name = "patient_id", nullable = false)
    private User patient;

    @Column(columnDefinition = "TEXT")
    private String notes;

    @Column(columnDefinition = "TEXT")
    private String prescription;

    @Column(columnDefinition = "TEXT")
    private String reportsUrl;

    private LocalDateTime consultationDate;

    public Consultation() {}

    public static Builder builder() { return new Builder(); }

    public static class Builder {
        private Long id; private User doctor, patient;
        private String notes, prescription, reportsUrl;
        private LocalDateTime consultationDate;

        public Builder id(Long id) { this.id = id; return this; }
        public Builder doctor(User d) { this.doctor = d; return this; }
        public Builder patient(User p) { this.patient = p; return this; }
        public Builder notes(String n) { this.notes = n; return this; }
        public Builder prescription(String p) { this.prescription = p; return this; }
        public Builder reportsUrl(String r) { this.reportsUrl = r; return this; }
        public Builder consultationDate(LocalDateTime d) { this.consultationDate = d; return this; }
        public Consultation build() {
            Consultation c = new Consultation();
            c.id = id; c.doctor = doctor; c.patient = patient; c.notes = notes;
            c.prescription = prescription; c.reportsUrl = reportsUrl; c.consultationDate = consultationDate;
            return c;
        }
    }

    public Long getId() { return id; }
    public User getDoctor() { return doctor; }
    public User getPatient() { return patient; }
    public String getNotes() { return notes; }
    public String getPrescription() { return prescription; }
    public String getReportsUrl() { return reportsUrl; }
    public LocalDateTime getConsultationDate() { return consultationDate; }

    public void setId(Long id) { this.id = id; }
    public void setDoctor(User d) { this.doctor = d; }
    public void setPatient(User p) { this.patient = p; }
    public void setNotes(String n) { this.notes = n; }
    public void setPrescription(String p) { this.prescription = p; }
    public void setReportsUrl(String r) { this.reportsUrl = r; }
    public void setConsultationDate(LocalDateTime d) { this.consultationDate = d; }
}
