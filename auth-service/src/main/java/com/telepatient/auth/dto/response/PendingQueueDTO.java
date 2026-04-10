package com.telepatient.auth.dto.response;

import lombok.Builder;
import lombok.Data;
import java.util.List;

@Data
@Builder
public class PendingQueueDTO {
    private List<ReferralItem> referrals;
    private List<TokenItem> tokens;
    
    @Data @Builder public static class ReferralItem {
        private Long id;
        private String patientName;
        private String fromDoctor;
        private String requestedSpecialty;
        private String urgency;
        private String reason;
    }
    
    @Data @Builder public static class TokenItem {
        private Long id;
        private String patientName;
        private String type;
        private String scheduledTime;
    }
}
