package com.telepatient.auth.entity;

import jakarta.persistence.*;
import java.time.LocalDateTime;

@Entity
public class ChatMessage {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @ManyToOne
    @JoinColumn(name = "token_id", nullable = false)
    private CommunicationToken token;

    @ManyToOne
    @JoinColumn(name = "sender_id", nullable = false)
    private User sender;

    @Column(columnDefinition = "TEXT", nullable = false)
    private String message;

    private LocalDateTime sentAt;

    public ChatMessage() {}

    public static Builder builder() { return new Builder(); }

    public static class Builder {
        private Long id; private CommunicationToken token; private User sender;
        private String message; private LocalDateTime sentAt;

        public Builder id(Long id) { this.id = id; return this; }
        public Builder token(CommunicationToken t) { this.token = t; return this; }
        public Builder sender(User s) { this.sender = s; return this; }
        public Builder message(String m) { this.message = m; return this; }
        public Builder sentAt(LocalDateTime d) { this.sentAt = d; return this; }
        public ChatMessage build() {
            ChatMessage c = new ChatMessage();
            c.id = id; c.token = token; c.sender = sender;
            c.message = message; c.sentAt = sentAt;
            return c;
        }
    }

    public Long getId() { return id; }
    public CommunicationToken getToken() { return token; }
    public User getSender() { return sender; }
    public String getMessage() { return message; }
    public LocalDateTime getSentAt() { return sentAt; }

    public void setId(Long id) { this.id = id; }
    public void setToken(CommunicationToken t) { this.token = t; }
    public void setSender(User s) { this.sender = s; }
    public void setMessage(String m) { this.message = m; }
    public void setSentAt(LocalDateTime d) { this.sentAt = d; }
}
