package com.telepatient.auth.dto.response;

import java.time.LocalDateTime;

public class LaunchpadResponseDTO {
    private Long id, submitterId;
    private String submitterEmail, ideaTitle, description, domain, contactInfo;
    private LocalDateTime submittedAt;

    public LaunchpadResponseDTO() {}

    public static Builder builder() { return new Builder(); }

    public static class Builder {
        private Long id, submitterId;
        private String submitterEmail, ideaTitle, description, domain, contactInfo;
        private LocalDateTime submittedAt;

        public Builder id(Long id) { this.id = id; return this; }
        public Builder submitterId(Long s) { this.submitterId = s; return this; }
        public Builder submitterEmail(String e) { this.submitterEmail = e; return this; }
        public Builder ideaTitle(String t) { this.ideaTitle = t; return this; }
        public Builder description(String d) { this.description = d; return this; }
        public Builder domain(String d) { this.domain = d; return this; }
        public Builder contactInfo(String c) { this.contactInfo = c; return this; }
        public Builder submittedAt(LocalDateTime d) { this.submittedAt = d; return this; }
        public LaunchpadResponseDTO build() {
            LaunchpadResponseDTO l = new LaunchpadResponseDTO();
            l.id = id; l.submitterId = submitterId; l.submitterEmail = submitterEmail;
            l.ideaTitle = ideaTitle; l.description = description; l.domain = domain;
            l.contactInfo = contactInfo; l.submittedAt = submittedAt;
            return l;
        }
    }

    public Long getId() { return id; }
    public Long getSubmitterId() { return submitterId; }
    public String getSubmitterEmail() { return submitterEmail; }
    public String getIdeaTitle() { return ideaTitle; }
    public String getDescription() { return description; }
    public String getDomain() { return domain; }
    public String getContactInfo() { return contactInfo; }
    public LocalDateTime getSubmittedAt() { return submittedAt; }
}
