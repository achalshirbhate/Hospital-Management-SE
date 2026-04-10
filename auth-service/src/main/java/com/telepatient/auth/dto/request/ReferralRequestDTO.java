package com.telepatient.auth.dto.request;

import lombok.Data;

@Data
public class ReferralRequestDTO {
    private String requestedSpecialty;
    private String urgency;
    private Long patientId;
    private String reason;
}
