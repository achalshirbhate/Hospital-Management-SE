package com.telepatient.auth.dto.request;

public class ReferralRequestDTO {
    private String requestedSpecialty, urgency, reason;
    private Long patientId;

    public ReferralRequestDTO() {}

    public String getRequestedSpecialty() { return requestedSpecialty; }
    public String getUrgency() { return urgency; }
    public String getReason() { return reason; }
    public Long getPatientId() { return patientId; }
    public void setRequestedSpecialty(String s) { this.requestedSpecialty = s; }
    public void setUrgency(String u) { this.urgency = u; }
    public void setReason(String r) { this.reason = r; }
    public void setPatientId(Long id) { this.patientId = id; }
}
