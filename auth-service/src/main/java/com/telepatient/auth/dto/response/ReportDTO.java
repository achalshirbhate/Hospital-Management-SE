package com.telepatient.auth.dto.response;

import lombok.Builder;
import lombok.Data;
import java.time.LocalDateTime;

@Data
@Builder
public class ReportDTO {
    private Long id;
    private String reportName;
    private String reportType;
    private String fileUrl;
    private String notes;
    private String doctorName;
    private Long patientId;
    private LocalDateTime uploadedAt;
}
