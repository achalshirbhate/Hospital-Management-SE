package com.telepatient.auth.entity;

import jakarta.persistence.*;
import java.time.LocalDateTime;

@Entity
public class SocialPost {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @ManyToOne
    @JoinColumn(name = "author_id", nullable = false)
    private User author;

    private String title;

    @Column(columnDefinition = "TEXT")
    private String content;

    private String mediaUrl;
    private LocalDateTime postedAt;

    public SocialPost() {}

    public static Builder builder() { return new Builder(); }

    public static class Builder {
        private Long id; private User author; private String title, content, mediaUrl;
        private LocalDateTime postedAt;

        public Builder id(Long id) { this.id = id; return this; }
        public Builder author(User a) { this.author = a; return this; }
        public Builder title(String t) { this.title = t; return this; }
        public Builder content(String c) { this.content = c; return this; }
        public Builder mediaUrl(String m) { this.mediaUrl = m; return this; }
        public Builder postedAt(LocalDateTime d) { this.postedAt = d; return this; }
        public SocialPost build() {
            SocialPost s = new SocialPost();
            s.id = id; s.author = author; s.title = title;
            s.content = content; s.mediaUrl = mediaUrl; s.postedAt = postedAt;
            return s;
        }
    }

    public Long getId() { return id; }
    public User getAuthor() { return author; }
    public String getTitle() { return title; }
    public String getContent() { return content; }
    public String getMediaUrl() { return mediaUrl; }
    public LocalDateTime getPostedAt() { return postedAt; }

    public void setId(Long id) { this.id = id; }
    public void setAuthor(User a) { this.author = a; }
    public void setTitle(String t) { this.title = t; }
    public void setContent(String c) { this.content = c; }
    public void setMediaUrl(String m) { this.mediaUrl = m; }
    public void setPostedAt(LocalDateTime d) { this.postedAt = d; }
}
