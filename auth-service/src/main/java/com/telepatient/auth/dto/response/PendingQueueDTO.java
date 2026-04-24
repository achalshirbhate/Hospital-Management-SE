package com.telepatient.auth.dto.response;

import java.util.List;

public class PendingQueueDTO {
    private List<ReferralItem> referrals;
    private List<TokenItem> tokens;

    public PendingQueueDTO() {}
    public PendingQueueDTO(List<ReferralItem> r, List<TokenItem> t) { this.referrals = r; this.tokens = t; }

    public static Builder builder() { return new Builder(); }

    public static class Builder {
        private List<ReferralItem> referrals;
        private List<TokenItem> tokens;
        public Builder referrals(List<ReferralItem> r) { this.referrals = r; return this; }
        public Builder tokens(List<TokenItem> t) { this.tokens = t; return this; }
        public PendingQueueDTO build() { return new PendingQueueDTO(referrals, tokens); }
    }

    public List<ReferralItem> getReferrals() { return referrals; }
    public List<TokenItem> getTokens() { return tokens; }
    public void setReferrals(List<ReferralItem> r) { this.referrals = r; }
    public void setTokens(List<TokenItem> t) { this.tokens = t; }

    public static class ReferralItem {
        private Long id;
        private String patientName, fromDoctor, requestedSpecialty, urgency, reason;

        public ReferralItem() {}

        public static Builder builder() { return new Builder(); }

        public static class Builder {
            private Long id; private String patientName, fromDoctor, requestedSpecialty, urgency, reason;
            public Builder id(Long id) { this.id = id; return this; }
            public Builder patientName(String p) { this.patientName = p; return this; }
            public Builder fromDoctor(String f) { this.fromDoctor = f; return this; }
            public Builder requestedSpecialty(String r) { this.requestedSpecialty = r; return this; }
            public Builder urgency(String u) { this.urgency = u; return this; }
            public Builder reason(String r) { this.reason = r; return this; }
            public ReferralItem build() {
                ReferralItem i = new ReferralItem();
                i.id = id; i.patientName = patientName; i.fromDoctor = fromDoctor;
                i.requestedSpecialty = requestedSpecialty; i.urgency = urgency; i.reason = reason;
                return i;
            }
        }

        public Long getId() { return id; }
        public String getPatientName() { return patientName; }
        public String getFromDoctor() { return fromDoctor; }
        public String getRequestedSpecialty() { return requestedSpecialty; }
        public String getUrgency() { return urgency; }
        public String getReason() { return reason; }
    }

    public static class TokenItem {
        private Long id;
        private String patientName, type, scheduledTime;

        public TokenItem() {}

        public static Builder builder() { return new Builder(); }

        public static class Builder {
            private Long id; private String patientName, type, scheduledTime;
            public Builder id(Long id) { this.id = id; return this; }
            public Builder patientName(String p) { this.patientName = p; return this; }
            public Builder type(String t) { this.type = t; return this; }
            public Builder scheduledTime(String s) { this.scheduledTime = s; return this; }
            public TokenItem build() {
                TokenItem i = new TokenItem();
                i.id = id; i.patientName = patientName; i.type = type; i.scheduledTime = scheduledTime;
                return i;
            }
        }

        public Long getId() { return id; }
        public String getPatientName() { return patientName; }
        public String getType() { return type; }
        public String getScheduledTime() { return scheduledTime; }
    }
}
