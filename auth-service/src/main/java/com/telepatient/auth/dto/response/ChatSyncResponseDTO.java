package com.telepatient.auth.dto.response;

import java.util.List;

public class ChatSyncResponseDTO {
    private boolean isTerminated;
    private List<ChatMessageDTO> messages;

    public ChatSyncResponseDTO() {}

    public static Builder builder() { return new Builder(); }

    public static class Builder {
        private boolean isTerminated; private List<ChatMessageDTO> messages;

        public Builder isTerminated(boolean t) { this.isTerminated = t; return this; }
        public Builder messages(List<ChatMessageDTO> m) { this.messages = m; return this; }
        public ChatSyncResponseDTO build() {
            ChatSyncResponseDTO c = new ChatSyncResponseDTO();
            c.isTerminated = isTerminated; c.messages = messages;
            return c;
        }
    }

    public boolean isTerminated() { return isTerminated; }
    public List<ChatMessageDTO> getMessages() { return messages; }
    public void setTerminated(boolean t) { this.isTerminated = t; }
    public void setMessages(List<ChatMessageDTO> m) { this.messages = m; }
}
