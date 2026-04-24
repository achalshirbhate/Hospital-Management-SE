package com.telepatient.auth.dto.response;

import java.time.LocalDateTime;

public class HistoryDTO {
    private String doctorName, notes, prescription, reportsUrl, referralInfo;
    private LocalDateTime date;

    public HistoryDTO() {}

    public static Builder builder() { return new Builder(); }

    public static class Builder {
        private String doctorName, notes, prescription, reportsUrl, referralInfo;
        private LocalDateTime date;

        public Builder doctorName(String d) { this.doctorName = d; return this; }
        public Builder date(LocalDateTime d) { this.date = d; return this; }
        public Builder notes(String n) { this.notes = n; return this; }
        public Builder prescription(String p) { this.prescription = p; return this; }
        public Builder reportsUrl(String r) { this.reportsUrl = r; return this; }
        public Builder referralInfo(String r) { this.referralInfo = r; return this; }
        public HistoryDTO build() {
            HistoryDTO h = new HistoryDTO();
            h.doctorName = doctorName; h.date = date; h.notes = notes;
            h.prescription = prescription; h.reportsUrl = reportsUrl; h.referralInfo = referralInfo;
            return h;
        }
    }

    public String getDoctorName() { return doctorName; }
    public LocalDateTime getDate() { return date; }
    public String getNotes() { return notes; }
    public String getPrescription() { return prescription; }
    public String getReportsUrl() { return reportsUrl; }
    public String getReferralInfo() { return referralInfo; }
}
