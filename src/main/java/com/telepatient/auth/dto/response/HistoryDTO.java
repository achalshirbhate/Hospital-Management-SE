package com.telepatient.auth.dto.response;

import lombok.Builder;
import lombok.Data;
import java.time.LocalDateTime;

@Data
@Builder
public class HistoryDTO {
    private String doctorName;
    private LocalDateTime date;
    private String notes;
    private String prescription;
    private String reportsUrl;
    private String referralInfo;
}
