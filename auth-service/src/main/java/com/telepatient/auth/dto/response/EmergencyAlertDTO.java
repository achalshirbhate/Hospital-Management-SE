package com.telepatient.auth.dto.response;

import lombok.Builder;
import lombok.Data;
import java.time.LocalDateTime;

@Data
@Builder
public class EmergencyAlertDTO {
    private Long id;
    private String patientName;
    private String level;
    private LocalDateTime alertTime;
}
