package com.telepatient.auth.controller;

import com.telepatient.auth.dto.response.ChatMessageDTO;
import com.telepatient.auth.dto.response.ChatSyncResponseDTO;
import com.telepatient.auth.entity.ChatMessage;
import com.telepatient.auth.entity.CommunicationToken;
import com.telepatient.auth.entity.TokenStatus;
import com.telepatient.auth.entity.User;
import com.telepatient.auth.repository.ChatMessageRepository;
import com.telepatient.auth.repository.CommunicationTokenRepository;
import com.telepatient.auth.repository.UserRepository;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.time.LocalDateTime;
import java.util.List;
import java.util.stream.Collectors;

@RestController
@RequestMapping("/api/chat")
public class ChatController {

    private final ChatMessageRepository chatRepo;
    private final CommunicationTokenRepository tokenRepo;
    private final UserRepository userRepo;

    public ChatController(ChatMessageRepository chatRepo,
                          CommunicationTokenRepository tokenRepo,
                          UserRepository userRepo) {
        this.chatRepo = chatRepo;
        this.tokenRepo = tokenRepo;
        this.userRepo = userRepo;
    }

    @GetMapping("/{tokenId}")
    public ResponseEntity<ChatSyncResponseDTO> getChatHistory(@PathVariable Long tokenId) {
        CommunicationToken token = tokenRepo.findById(tokenId).orElseThrow();

        List<ChatMessageDTO> messages = chatRepo.findByTokenOrderBySentAtAsc(token).stream()
                .map(m -> ChatMessageDTO.builder()
                        .id(m.getId())
                        .senderId(m.getSender().getId())
                        .senderName(m.getSender().getFullName())
                        .message(m.getMessage())
                        .sentAt(m.getSentAt())
                        .build())
                .collect(Collectors.toList());

        return ResponseEntity.ok(ChatSyncResponseDTO.builder()
                .isTerminated(token.getStatus() == TokenStatus.COMPLETED)
                .messages(messages)
                .build());
    }

    @PostMapping("/{tokenId}")
    public ResponseEntity<String> sendMessage(@PathVariable Long tokenId,
                                              @RequestParam Long senderId,
                                              @RequestBody String message) {
        CommunicationToken token = tokenRepo.findById(tokenId).orElseThrow();
        User sender = userRepo.findById(senderId).orElseThrow();

        if (token.isFrozen()) {
            throw new IllegalArgumentException("Chat is currently frozen by Admin MD.");
        }

        chatRepo.save(ChatMessage.builder()
                .token(token).sender(sender)
                .message(message).sentAt(LocalDateTime.now())
                .build());

        return ResponseEntity.ok("Sent");
    }
}
