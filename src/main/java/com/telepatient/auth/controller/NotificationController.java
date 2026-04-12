package com.telepatient.auth.controller;

import com.telepatient.auth.entity.Notification;
import com.telepatient.auth.entity.User;
import com.telepatient.auth.repository.NotificationRepository;
import com.telepatient.auth.repository.UserRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.time.LocalDateTime;
import java.util.List;
import java.util.Map;

@RestController
@RequestMapping("/api/notifications")
@RequiredArgsConstructor
public class NotificationController {

    private final NotificationRepository notifRepo;
    private final UserRepository userRepo;

    @GetMapping("/{userId}")
    public ResponseEntity<List<Notification>> getNotifications(@PathVariable Long userId) {
        User user = userRepo.findById(userId).orElseThrow();
        return ResponseEntity.ok(notifRepo.findByUserOrderByCreatedAtDesc(user));
    }

    @GetMapping("/{userId}/unread-count")
    public ResponseEntity<Long> getUnreadCount(@PathVariable Long userId) {
        User user = userRepo.findById(userId).orElseThrow();
        return ResponseEntity.ok(notifRepo.countByUserAndIsReadFalse(user));
    }

    @PostMapping
    public ResponseEntity<String> createNotification(@RequestBody Map<String, Object> body) {
        Long userId  = Long.valueOf(body.get("userId").toString());
        String msg   = (String) body.get("message");
        String type  = (String) body.getOrDefault("type", "GENERAL");
        String prio  = (String) body.getOrDefault("priority", "LOW");
        User user = userRepo.findById(userId).orElseThrow();
        notifRepo.save(Notification.builder()
            .user(user).message(msg).type(type).priority(prio)
            .isRead(false).createdAt(LocalDateTime.now()).build());
        return ResponseEntity.ok("Notification created");
    }

    @PutMapping("/{id}/read")
    public ResponseEntity<String> markRead(@PathVariable Long id) {
        notifRepo.findById(id).ifPresent(n -> { n.setRead(true); notifRepo.save(n); });
        return ResponseEntity.ok("Marked as read");
    }

    @PutMapping("/{userId}/read-all")
    public ResponseEntity<String> markAllRead(@PathVariable Long userId) {
        User user = userRepo.findById(userId).orElseThrow();
        notifRepo.findByUserOrderByCreatedAtDesc(user).forEach(n -> { n.setRead(true); notifRepo.save(n); });
        return ResponseEntity.ok("All marked as read");
    }

    @DeleteMapping("/{id}")
    public ResponseEntity<String> deleteNotification(@PathVariable Long id) {
        notifRepo.deleteById(id);
        return ResponseEntity.ok("Deleted");
    }
}
