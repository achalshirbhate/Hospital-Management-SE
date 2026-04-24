package com.telepatient.auth.entity;

import jakarta.persistence.*;
import java.time.LocalDateTime;

@Entity
@Table(name = "notifications")
public class Notification {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @ManyToOne
    @JoinColumn(name = "user_id", nullable = false)
    private User user;

    private String message;
    private String type;
    private String priority;
    private boolean isRead;
    private LocalDateTime createdAt;

    public Notification() {}

    public static Builder builder() { return new Builder(); }

    public static class Builder {
        private Long id; private User user; private String message, type, priority;
        private boolean isRead; private LocalDateTime createdAt;

        public Builder id(Long id) { this.id = id; return this; }
        public Builder user(User u) { this.user = u; return this; }
        public Builder message(String m) { this.message = m; return this; }
        public Builder type(String t) { this.type = t; return this; }
        public Builder priority(String p) { this.priority = p; return this; }
        public Builder isRead(boolean r) { this.isRead = r; return this; }
        public Builder createdAt(LocalDateTime d) { this.createdAt = d; return this; }
        public Notification build() {
            Notification n = new Notification();
            n.id = id; n.user = user; n.message = message; n.type = type;
            n.priority = priority; n.isRead = isRead; n.createdAt = createdAt;
            return n;
        }
    }

    public Long getId() { return id; }
    public User getUser() { return user; }
    public String getMessage() { return message; }
    public String getType() { return type; }
    public String getPriority() { return priority; }
    public boolean isRead() { return isRead; }
    public LocalDateTime getCreatedAt() { return createdAt; }

    public void setId(Long id) { this.id = id; }
    public void setUser(User u) { this.user = u; }
    public void setMessage(String m) { this.message = m; }
    public void setType(String t) { this.type = t; }
    public void setPriority(String p) { this.priority = p; }
    public void setRead(boolean r) { this.isRead = r; }
    public void setCreatedAt(LocalDateTime d) { this.createdAt = d; }
}
