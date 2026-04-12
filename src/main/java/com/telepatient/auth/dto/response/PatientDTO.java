package com.telepatient.auth.dto.response;

import lombok.Builder;
import lombok.Data;
import java.time.LocalDateTime;

@Data
@Builder
public class PatientDTO {
    private Long id;
    private String fullName;
    private String historySummary;
    private String specialty;
    private Integer age;
    private LocalDateTime lastConsultation;
}
