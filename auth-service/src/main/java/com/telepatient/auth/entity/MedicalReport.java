package com.telepatient.auth.entity;

import jakarta.persistence.*;
import java.time.LocalDateTime;

@Entity
@Table(name = "medical_reports")
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
    private String reportType;

    @Column(columnDefinition = "TEXT")
    private String fileUrl;

    @Column(columnDefinition = "TEXT")
    private String notes;

    private LocalDateTime uploadedAt;

    public MedicalReport() {}

    public static Builder builder() { return new Builder(); }

    public static class Builder {
        private Long id; private User patient, doctor;
        private String reportName, reportType, fileUrl, notes;
        private LocalDateTime uploadedAt;

        public Builder id(Long id) { this.id = id; return this; }
        public Builder patient(User p) { this.patient = p; return this; }
        public Builder doctor(User d) { this.doctor = d; return this; }
        public Builder reportName(String n) { this.reportName = n; return this; }
        public Builder reportType(String t) { this.reportType = t; return this; }
        public Builder fileUrl(String f) { this.fileUrl = f; return this; }
        public Builder notes(String n) { this.notes = n; return this; }
        public Builder uploadedAt(LocalDateTime d) { this.uploadedAt = d; return this; }
        public MedicalReport build() {
            MedicalReport m = new MedicalReport();
            m.id = id; m.patient = patient; m.doctor = doctor; m.reportName = reportName;
            m.reportType = reportType; m.fileUrl = fileUrl; m.notes = notes; m.uploadedAt = uploadedAt;
            return m;
        }
    }

    public Long getId() { return id; }
    public User getPatient() { return patient; }
    public User getDoctor() { return doctor; }
    public String getReportName() { return reportName; }
    public String getReportType() { return reportType; }
    public String getFileUrl() { return fileUrl; }
    public String getNotes() { return notes; }
    public LocalDateTime getUploadedAt() { return uploadedAt; }

    public void setId(Long id) { this.id = id; }
    public void setPatient(User p) { this.patient = p; }
    public void setDoctor(User d) { this.doctor = d; }
    public void setReportName(String n) { this.reportName = n; }
    public void setReportType(String t) { this.reportType = t; }
    public void setFileUrl(String f) { this.fileUrl = f; }
    public void setNotes(String n) { this.notes = n; }
    public void setUploadedAt(LocalDateTime d) { this.uploadedAt = d; }
}
