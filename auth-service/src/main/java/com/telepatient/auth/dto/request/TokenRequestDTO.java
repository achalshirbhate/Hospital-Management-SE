package com.telepatient.auth.dto.request;

import com.telepatient.auth.entity.TokenType;
import lombok.Data;

@Data
public class TokenRequestDTO {
    private Long patientId;
    private Long mdId;
    private TokenType type;
}
