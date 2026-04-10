package com.telepatient.auth.dto.response;

import lombok.Builder;
import lombok.Data;
import java.util.List;

@Data
@Builder
public class ChatSyncResponseDTO {
    private boolean isTerminated;
    private List<ChatMessageDTO> messages;
}
