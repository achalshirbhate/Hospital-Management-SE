package com.telepatient.auth.repository;

import com.telepatient.auth.entity.CommunicationToken;
import com.telepatient.auth.entity.TokenStatus;
import com.telepatient.auth.entity.User;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;
import java.util.List;

@Repository
public interface CommunicationTokenRepository extends JpaRepository<CommunicationToken, Long> {
    List<CommunicationToken> findByStatus(TokenStatus status);
    List<CommunicationToken> findByPatient(User patient);
}
