package com.telepatient.auth.service.impl;

import java.util.Set;
import java.util.HashSet;

import com.telepatient.auth.dto.request.ReferralRequestDTO;
import com.telepatient.auth.entity.Notification;
import com.telepatient.auth.repository.NotificationRepository;
import com.telepatient.auth.dto.response.PatientDTO;
import com.telepatient.auth.entity.*;
import com.telepatient.auth.repository.*;
import com.telepatient.auth.service.DoctorService;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import java.time.LocalDateTime;
import java.util.List;
import java.util.stream.Collectors;

@Service
@RequiredArgsConstructor
public class DoctorServiceImpl implements DoctorService {

    private final ConsultationRepository consultationRepo;
    private final UserRepository userRepo;
    private final ReferralRequestRepository referralRepo;
    private final PatientProfileRepository profileRepo;
    private final NotificationRepository notifRepo;

    private void notify(User user, String message, String type, String priority) {
        notifRepo.save(Notification.builder()
            .user(user).message(message).type(type)
            .priority(priority).isRead(false).createdAt(LocalDateTime.now()).build());
    }

    @Override
    public List<PatientDTO> getAssignedPatients(Long doctorId) {
        User doctor = userRepo.findById(doctorId).orElseThrow();

        return profileRepo.findByCurrentDoctor(doctor).stream()
                .map(profile -> {
                    User p = profile.getUser();
                    String history = profile.getMedicalHistory() != null ? profile.getMedicalHistory()
                            : "No history available";
                    java.time.LocalDateTime lastConsult = consultationRepo.findByPatient(p).stream()
                            .map(c -> c.getConsultationDate())
                            .max(java.util.Comparator.naturalOrder())
                            .orElse(null);
                    return PatientDTO.builder()
                            .id(p.getId())
                            .fullName(p.getFullName())
                            .historySummary(history)
                            .age(profile.getAge())
                            .lastConsultation(lastConsult)
                            .build();
                })
                .collect(Collectors.toList());
    }

    @Override
    public void addConsultation(Long doctorId, Long patientId, String notes, String prescription, String reportsUrl) {
        User doctor = userRepo.findById(doctorId).orElseThrow();
        User patient = userRepo.findById(patientId).orElseThrow();

        Consultation consultation = Consultation.builder()
                .doctor(doctor)
                .patient(patient)
                .notes(notes)
                .prescription(prescription)
                .reportsUrl(reportsUrl)
                .consultationDate(LocalDateTime.now())
                .build();

        consultationRepo.save(consultation);
        notify(patient, "📋 Dr. " + doctor.getFullName() + " updated your clinical notes.", "REPORT", "MEDIUM");
        if (prescription != null && !prescription.isBlank())
            notify(patient, "💊 New prescription added by Dr. " + doctor.getFullName(), "PRESCRIPTION", "MEDIUM");
        if (reportsUrl != null && !reportsUrl.isBlank())
            notify(patient, "📎 A new report has been uploaded by Dr. " + doctor.getFullName(), "REPORT", "MEDIUM");
    }

    @Override
    public void requestReferral(Long fromDoctorId, ReferralRequestDTO request) {
        User fromDoctor = userRepo.findById(fromDoctorId).orElseThrow();
        User patient = userRepo.findById(request.getPatientId()).orElseThrow();

        ReferralRequest referral = ReferralRequest.builder()
                .fromDoctor(fromDoctor)
                .patient(patient)
                .requestedSpecialty(request.getRequestedSpecialty())
                .urgency(request.getUrgency())
                .reason(request.getReason())
                .status(ReferralStatus.PENDING)
                .requestDate(LocalDateTime.now())
                .build();

        referralRepo.save(referral);
        notify(patient, "🔁 Dr. " + fromDoctor.getFullName() + " has requested a referral for you to " + request.getRequestedSpecialty(), "GENERAL", "MEDIUM");
    }

    @Override
    public void assignPatientToDoctor(Long patientId, Long doctorId, Integer age) {
        User patient = userRepo.findById(patientId).orElseThrow();
        User doctor = userRepo.findById(doctorId).orElseThrow();

        PatientProfile profile = profileRepo.findByUser(patient).orElse(
                PatientProfile.builder().user(patient).build());
        profile.setCurrentDoctor(doctor);
        if (age != null) profile.setAge(age);
        profileRepo.save(profile);
    }
}
