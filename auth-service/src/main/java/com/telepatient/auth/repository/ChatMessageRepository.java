package com.telepatient.auth.repository;

import com.telepatient.auth.entity.ChatMessage;
import com.telepatient.auth.entity.CommunicationToken;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;
import java.util.List;

@Repository
public interface ChatMessageRepository extends JpaRepository<ChatMessage, Long> {
    List<ChatMessage> findByTokenOrderBySentAtAsc(CommunicationToken token);
}
