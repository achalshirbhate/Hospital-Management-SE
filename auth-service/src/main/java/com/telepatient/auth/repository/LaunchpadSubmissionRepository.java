package com.telepatient.auth.repository;

import com.telepatient.auth.entity.LaunchpadSubmission;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

@Repository
public interface LaunchpadSubmissionRepository extends JpaRepository<LaunchpadSubmission, Long> {
}
