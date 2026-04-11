package com.telepatient.auth.repository;

import com.telepatient.auth.entity.MedicalReport;
import com.telepatient.auth.entity.User;
import org.springframework.data.jpa.repository.JpaRepository;
import java.util.List;

public interface MedicalReportRepository extends JpaRepository<MedicalReport, Long> {
    List<MedicalReport> findByPatientOrderByUploadedAtDesc(User patient);
}
