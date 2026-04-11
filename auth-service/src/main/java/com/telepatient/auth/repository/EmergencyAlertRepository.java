package com.telepatient.auth.repository;

import com.telepatient.auth.entity.EmergencyAlert;
import org.springframework.data.jpa.repository.JpaRepository;
import java.util.List;

public interface EmergencyAlertRepository extends JpaRepository<EmergencyAlert, Long> {
    List<EmergencyAlert> findByAcknowledgedFalseOrderByAlertTimeDesc();
}
