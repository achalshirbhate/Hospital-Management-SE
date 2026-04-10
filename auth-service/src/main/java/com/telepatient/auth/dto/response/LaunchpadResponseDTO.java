package com.telepatient.auth.dto.response;

import lombok.Builder;
import lombok.Data;
import java.time.LocalDateTime;

@Data
@Builder
public class LaunchpadResponseDTO {
    private Long id;
    private String submitterEmail;
    private String ideaTitle;
    private String description;
    private String domain;
    private String contactInfo;
    private LocalDateTime submittedAt;
}
