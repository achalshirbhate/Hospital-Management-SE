package com.telepatient.auth.service;

import com.telepatient.auth.dto.request.ReferralRequestDTO;
import com.telepatient.auth.dto.response.PatientDTO;
import java.util.List;

public interface DoctorService {
    List<PatientDTO> getAssignedPatients(Long doctorId);

    void addConsultation(Long doctorId, Long patientId, String notes, String prescription, String reportsUrl);

    void requestReferral(Long fromDoctorId, ReferralRequestDTO request);

    void assignPatientToDoctor(Long patientId, Long doctorId, Integer age);
}
