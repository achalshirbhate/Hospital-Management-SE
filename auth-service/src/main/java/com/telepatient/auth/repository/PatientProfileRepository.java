package com.telepatient.auth.repository;

import com.telepatient.auth.entity.PatientProfile;
import com.telepatient.auth.entity.User;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;
import java.util.Optional;

@Repository
public interface PatientProfileRepository extends JpaRepository<PatientProfile, Long> {
    Optional<PatientProfile> findByUser(User user);
    java.util.List<PatientProfile> findByCurrentDoctor(User currentDoctor);
}
