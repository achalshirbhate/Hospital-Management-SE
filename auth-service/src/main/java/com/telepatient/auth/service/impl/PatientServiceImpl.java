package com.telepatient.auth.service.impl;

import com.telepatient.auth.dto.request.TokenRequestDTO;
import com.telepatient.auth.dto.response.HistoryDTO;
import com.telepatient.auth.entity.*;
import com.telepatient.auth.repository.*;
import com.telepatient.auth.entity.EmergencyAlert;
import com.telepatient.auth.repository.EmergencyAlertRepository;
import com.telepatient.auth.service.PatientService;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import java.time.LocalDateTime;
import java.util.List;
import java.util.stream.Collectors;

@Service
@RequiredArgsConstructor
public class PatientServiceImpl implements PatientService {

    private final ConsultationRepository consultationRepo;
    private final CommunicationTokenRepository tokenRepo;
    private final UserRepository userRepo;
    private final EmergencyAlertRepository emergencyRepo;

    @Override
    public List<HistoryDTO> getPatientHistory(Long patientId) {
        User patient = userRepo.findById(patientId).orElseThrow();
        
        return consultationRepo.findByPatient(patient).stream()
            .map(c -> HistoryDTO.builder()
                .doctorName(c.getDoctor().getFullName())
                .date(c.getConsultationDate())
                .notes(c.getNotes())
                .prescription(c.getPrescription())
                .reportsUrl(c.getReportsUrl())
                .referralInfo("Assigned directly or approved by MD")
                .build())
            .collect(Collectors.toList());
    }

    @Override
    public void requestCommunicationToken(TokenRequestDTO request) {
        User patient = userRepo.findById(request.getPatientId()).orElseThrow();
        User md = userRepo.findById(request.getMdId()).orElseThrow();

        CommunicationToken token = CommunicationToken.builder()
                .patient(patient)
                .mainDoctor(md)
                .type(request.getType())
                .status(TokenStatus.REQUESTED)
                .requestedAt(LocalDateTime.now())
                .isFrozen(false) // Wait to be approved by MD
                .build();
                
        tokenRepo.save(token);
    }

    @Override
    public List<CommunicationToken> getPatientTokens(Long patientId) {
        User patient = userRepo.findById(patientId).orElseThrow();
        return tokenRepo.findByPatient(patient);
    }

    @Override
    public String triggerEmergencyAlert(Long patientId, String level) {
        User patient = userRepo.findById(patientId).orElseThrow();
        EmergencyAlert alert = EmergencyAlert.builder()
                .patient(patient)
                .level(level)
                .alertTime(LocalDateTime.now())
                .acknowledged(false)
                .build();
        emergencyRepo.save(alert);
        System.out.println("\n========================================");
        System.out.println("🚨 [" + level + "] EMERGENCY from: " + patient.getFullName() + " at " + alert.getAlertTime());
        System.out.println("========================================\n");
        return "Emergency alert sent. Hospital counter has been notified!";
    }
}
