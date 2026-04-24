package com.telepatient.auth.dto.request;

public class LaunchpadDTO {
    private Long submitterId;
    private String ideaTitle, description, domain, contactInfo;

    public LaunchpadDTO() {}

    public Long getSubmitterId() { return submitterId; }
    public String getIdeaTitle() { return ideaTitle; }
    public String getDescription() { return description; }
    public String getDomain() { return domain; }
    public String getContactInfo() { return contactInfo; }
    public void setSubmitterId(Long id) { this.submitterId = id; }
    public void setIdeaTitle(String t) { this.ideaTitle = t; }
    public void setDescription(String d) { this.description = d; }
    public void setDomain(String d) { this.domain = d; }
    public void setContactInfo(String c) { this.contactInfo = c; }
}
