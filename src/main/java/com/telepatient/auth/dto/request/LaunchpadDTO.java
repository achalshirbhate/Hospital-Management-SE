package com.telepatient.auth.dto.request;

import lombok.Data;

@Data
public class LaunchpadDTO {
    private Long submitterId;
    private String ideaTitle;
    private String description;
    private String domain;
    private String contactInfo;
}
