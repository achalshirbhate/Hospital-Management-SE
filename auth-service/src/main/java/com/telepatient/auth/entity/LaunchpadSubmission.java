package com.telepatient.auth.entity;

import jakarta.persistence.*;
import java.time.LocalDateTime;

@Entity
public class LaunchpadSubmission {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @ManyToOne
    @JoinColumn(name = "submitter_id", nullable = false)
    private User submitter;

    private String ideaTitle;

    @Column(columnDefinition = "TEXT")
    private String description;

    private String domain;
    private String contactInfo;
    private String response;
    private LocalDateTime submittedAt;

    public LaunchpadSubmission() {}

    public static Builder builder() { return new Builder(); }

    public static class Builder {
        private Long id; private User submitter; private String ideaTitle, description, domain, contactInfo, response;
        private LocalDateTime submittedAt;

        public Builder id(Long id) { this.id = id; return this; }
        public Builder submitter(User s) { this.submitter = s; return this; }
        public Builder ideaTitle(String t) { this.ideaTitle = t; return this; }
        public Builder description(String d) { this.description = d; return this; }
        public Builder domain(String d) { this.domain = d; return this; }
        public Builder contactInfo(String c) { this.contactInfo = c; return this; }
        public Builder response(String r) { this.response = r; return this; }
        public Builder submittedAt(LocalDateTime d) { this.submittedAt = d; return this; }
        public LaunchpadSubmission build() {
            LaunchpadSubmission l = new LaunchpadSubmission();
            l.id = id; l.submitter = submitter; l.ideaTitle = ideaTitle;
            l.description = description; l.domain = domain; l.contactInfo = contactInfo;
            l.response = response; l.submittedAt = submittedAt;
            return l;
        }
    }

    public Long getId() { return id; }
    public User getSubmitter() { return submitter; }
    public String getIdeaTitle() { return ideaTitle; }
    public String getDescription() { return description; }
    public String getDomain() { return domain; }
    public String getContactInfo() { return contactInfo; }
    public String getResponse() { return response; }
    public LocalDateTime getSubmittedAt() { return submittedAt; }

    public void setId(Long id) { this.id = id; }
    public void setSubmitter(User s) { this.submitter = s; }
    public void setIdeaTitle(String t) { this.ideaTitle = t; }
    public void setDescription(String d) { this.description = d; }
    public void setDomain(String d) { this.domain = d; }
    public void setContactInfo(String c) { this.contactInfo = c; }
    public void setResponse(String r) { this.response = r; }
    public void setSubmittedAt(LocalDateTime d) { this.submittedAt = d; }
}
