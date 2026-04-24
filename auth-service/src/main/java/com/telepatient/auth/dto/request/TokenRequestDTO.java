package com.telepatient.auth.dto.request;

import com.telepatient.auth.entity.TokenType;

public class TokenRequestDTO {
    private Long patientId, mdId;
    private TokenType type;

    public TokenRequestDTO() {}

    public Long getPatientId() { return patientId; }
    public Long getMdId() { return mdId; }
    public TokenType getType() { return type; }
    public void setPatientId(Long id) { this.patientId = id; }
    public void setMdId(Long id) { this.mdId = id; }
    public void setType(TokenType t) { this.type = t; }
}
