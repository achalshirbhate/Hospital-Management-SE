package com.telepatient.auth.repository;

import com.telepatient.auth.entity.Consultation;
import com.telepatient.auth.entity.User;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;
import java.util.List;

@Repository
public interface ConsultationRepository extends JpaRepository<Consultation, Long> {
    List<Consultation> findByDoctor(User doctor);
    List<Consultation> findByPatient(User patient);
}
