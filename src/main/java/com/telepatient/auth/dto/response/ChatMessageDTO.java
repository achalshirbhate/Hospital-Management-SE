package com.telepatient.auth.dto.response;

import lombok.Builder;
import lombok.Data;
import java.time.LocalDateTime;

@Data
@Builder
public class ChatMessageDTO {
    private Long id;
    private Long senderId;
    private String senderName;
    private String message;
    private LocalDateTime sentAt;
}
