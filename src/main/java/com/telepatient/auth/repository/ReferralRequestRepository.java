package com.telepatient.auth.repository;

import com.telepatient.auth.entity.ReferralRequest;
import com.telepatient.auth.entity.ReferralStatus;
import com.telepatient.auth.entity.User;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;
import java.util.List;

@Repository
public interface ReferralRequestRepository extends JpaRepository<ReferralRequest, Long> {
    List<ReferralRequest> findByStatus(ReferralStatus status);
    List<ReferralRequest> findByPatient(User patient);
    List<ReferralRequest> findByAssignedDoctorAndStatus(User assignedDoctor, ReferralStatus status);
    List<ReferralRequest> findByAssignedDoctor(User doctor);
}
