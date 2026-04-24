package com.telepatient.auth.dto.response;

import java.time.LocalDateTime;

public class ChatMessageDTO {
    private Long id, senderId;
    private String senderName, message;
    private LocalDateTime sentAt;

    public ChatMessageDTO() {}

    public static Builder builder() { return new Builder(); }

    public static class Builder {
        private Long id, senderId; private String senderName, message; private LocalDateTime sentAt;

        public Builder id(Long id) { this.id = id; return this; }
        public Builder senderId(Long s) { this.senderId = s; return this; }
        public Builder senderName(String n) { this.senderName = n; return this; }
        public Builder message(String m) { this.message = m; return this; }
        public Builder sentAt(LocalDateTime d) { this.sentAt = d; return this; }
        public ChatMessageDTO build() {
            ChatMessageDTO c = new ChatMessageDTO();
            c.id = id; c.senderId = senderId; c.senderName = senderName;
            c.message = message; c.sentAt = sentAt;
            return c;
        }
    }

    public Long getId() { return id; }
    public Long getSenderId() { return senderId; }
    public String getSenderName() { return senderName; }
    public String getMessage() { return message; }
    public LocalDateTime getSentAt() { return sentAt; }
}
