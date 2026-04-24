package com.telepatient.auth.dto.response;

import java.time.LocalDateTime;

public class ReportDTO {
    private Long id, patientId;
    private String reportName, reportType, fileUrl, notes, doctorName;
    private LocalDateTime uploadedAt;

    public ReportDTO() {}

    public static Builder builder() { return new Builder(); }

    public static class Builder {
        private Long id, patientId;
        private String reportName, reportType, fileUrl, notes, doctorName;
        private LocalDateTime uploadedAt;

        public Builder id(Long id) { this.id = id; return this; }
        public Builder patientId(Long p) { this.patientId = p; return this; }
        public Builder reportName(String n) { this.reportName = n; return this; }
        public Builder reportType(String t) { this.reportType = t; return this; }
        public Builder fileUrl(String f) { this.fileUrl = f; return this; }
        public Builder notes(String n) { this.notes = n; return this; }
        public Builder doctorName(String d) { this.doctorName = d; return this; }
        public Builder uploadedAt(LocalDateTime d) { this.uploadedAt = d; return this; }
        public ReportDTO build() {
            ReportDTO r = new ReportDTO();
            r.id = id; r.patientId = patientId; r.reportName = reportName;
            r.reportType = reportType; r.fileUrl = fileUrl; r.notes = notes;
            r.doctorName = doctorName; r.uploadedAt = uploadedAt;
            return r;
        }
    }

    public Long getId() { return id; }
    public Long getPatientId() { return patientId; }
    public String getReportName() { return reportName; }
    public String getReportType() { return reportType; }
    public String getFileUrl() { return fileUrl; }
    public String getNotes() { return notes; }
    public String getDoctorName() { return doctorName; }
    public LocalDateTime getUploadedAt() { return uploadedAt; }
}
