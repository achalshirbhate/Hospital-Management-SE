package com.telepatient.auth.service.impl;

import com.telepatient.auth.dto.response.DashboardDTO;
import com.telepatient.auth.dto.response.LaunchpadResponseDTO;
import com.telepatient.auth.dto.response.PendingQueueDTO;
import com.telepatient.auth.entity.*;
import com.telepatient.auth.repository.*;
import com.telepatient.auth.service.MDService;
import lombok.RequiredArgsConstructor;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;
import java.time.LocalDateTime;
import java.util.List;
import java.util.stream.Collectors;

@Service
@RequiredArgsConstructor
public class MDServiceImpl implements MDService {

    private final FinancialTransactionRepository financeRepo;
    private final UserRepository userRepo;
    private final ReferralRequestRepository referralRepo;
    private final CommunicationTokenRepository tokenRepo;
    private final SocialPostRepository socialRepo;
    private final LaunchpadSubmissionRepository launchpadRepo;
    private final PasswordEncoder passwordEncoder;
    private final PatientProfileRepository profileRepo;
    private final ConsultationRepository consultationRepo;

    @Override
    public DashboardDTO getDashboardAnalytics() {
        double revenue = financeRepo.findAll().stream()
                .filter(t -> t.getType() == TransactionType.REVENUE)
                .mapToDouble(FinancialTransaction::getAmount).sum();

        double expenses = financeRepo.findAll().stream()
                .filter(t -> t.getType() == TransactionType.EXPENDITURE)
                .mapToDouble(FinancialTransaction::getAmount).sum();

        long patients = userRepo.findAll().stream().filter(u -> u.getRole() == Role.PATIENT).count();
        long doctors = userRepo.findAll().stream().filter(u -> u.getRole() == Role.DOCTOR).count();
        long pendingRefs = referralRepo.findByStatus(ReferralStatus.PENDING).size();
        long pendingTokens = tokenRepo.findByStatus(TokenStatus.REQUESTED).size();
        long totalAppointments = consultationRepo.count();

        java.util.Map<String, Long> doctorActivity = consultationRepo.findAll().stream()
                .collect(java.util.stream.Collectors.groupingBy(
                        c -> c.getDoctor().getFullName(),
                        java.util.stream.Collectors.counting()));

        return DashboardDTO.builder()
                .totalRevenue(revenue)
                .totalExpenses(expenses)
                .profitLoss(revenue - expenses)
                .patientCount(patients)
                .activeDoctors(doctors)
                .pendingReferrals(pendingRefs)
                .pendingTokenRequests(pendingTokens)
                .totalAppointments(totalAppointments)
                .doctorActivity(doctorActivity)
                .build();
    }

    @Override
    public List<com.telepatient.auth.dto.response.PatientDTO> getActiveDoctors() {
        return userRepo.findByRole(Role.DOCTOR).stream()
                .map(d -> com.telepatient.auth.dto.response.PatientDTO.builder()
                        .id(d.getId())
                        .fullName(d.getFullName())
                        .specialty(d.getSpecialty() != null ? d.getSpecialty() : "General Practice")
                        .historySummary(d.getSpecialty() != null ? d.getSpecialty() : "General Practice")
                        .build())
                .collect(Collectors.toList());
    }

    @Override
    public List<com.telepatient.auth.dto.response.PatientDTO> getAllPatients() {
        return userRepo.findByRole(Role.PATIENT).stream()
                .map(p -> {
                    PatientProfile profile = profileRepo.findByUser(p).orElse(null);
                    String currentDoc = (profile != null && profile.getCurrentDoctor() != null)
                            ? "Assigned to Dr. " + profile.getCurrentDoctor().getFullName()
                            : "UNASSIGNED";
                    Integer age = (profile != null) ? profile.getAge() : null;
                    return com.telepatient.auth.dto.response.PatientDTO.builder()
                            .id(p.getId())
                            .fullName(p.getFullName())
                            .historySummary(currentDoc)
                            .age(age)
                            .build();
                })
                .collect(Collectors.toList());
    }

    @Override
    public void directAssignPatient(Long patientId, Long doctorId) {
        User patient = userRepo.findById(patientId).orElseThrow(() -> new IllegalArgumentException("Patient missing"));
        User doctor = userRepo.findById(doctorId).orElseThrow(() -> new IllegalArgumentException("Doctor missing"));

        PatientProfile profile = profileRepo.findByUser(patient).orElseGet(() -> {
            PatientProfile p = new PatientProfile();
            p.setUser(patient);
            return p;
        });
        profile.setCurrentDoctor(doctor);
        profileRepo.save(profile);

        Consultation consultation = Consultation.builder()
                .doctor(doctor)
                .patient(patient)
                .notes("Automatically generated log: Patient forcibly routed to jurisdiction by Medical Director via Direct Assignment.")
                .consultationDate(LocalDateTime.now())
                .build();
        consultationRepo.save(consultation);
    }

    @Override
    public void approveReferral(Long referralId, boolean approve, Long assignedDoctorId) {
        ReferralRequest req = referralRepo.findById(referralId)
                .orElseThrow(() -> new IllegalArgumentException("Referral not found"));
        req.setStatus(approve ? ReferralStatus.APPROVED : ReferralStatus.REJECTED);
        req.setResolutionDate(LocalDateTime.now());

        if (approve && assignedDoctorId != null) {
            User assignedDoctor = userRepo.findById(assignedDoctorId)
                    .orElseThrow(() -> new IllegalArgumentException("Target Doctor missing"));
            req.setAssignedDoctor(assignedDoctor);

            PatientProfile profile = profileRepo.findByUser(req.getPatient())
                    .orElseGet(() -> {
                        PatientProfile p = new PatientProfile();
                        p.setUser(req.getPatient());
                        return p;
                    });
            profile.setCurrentDoctor(assignedDoctor);
            profileRepo.save(profile);

            Consultation consultation = Consultation.builder()
                    .doctor(assignedDoctor)
                    .patient(req.getPatient())
                    .notes("Automatically generated log: Patient officially transferred into jurisdiction by Medical Director via Referral System.")
                    .consultationDate(LocalDateTime.now())
                    .build();
            consultationRepo.save(consultation);
        }
        referralRepo.save(req);
    }

    @Override
    public void approveToken(Long tokenId, boolean approve, String scheduledTime) {
        CommunicationToken token = tokenRepo.findById(tokenId)
                .orElseThrow(() -> new IllegalArgumentException("Token not found"));
        token.setStatus(approve ? TokenStatus.APPROVED : TokenStatus.REJECTED);
        if (approve) {
            token.setApprovedAt(LocalDateTime.now());
            // Standardizing token window at 60 mins from start for scheduled chat
            token.setExpiresAt(LocalDateTime.now().plusMinutes(60));
            token.setScheduledTime(scheduledTime);
            token.setFrozen(false);
        }
        tokenRepo.save(token);
    }

    @Override
    public void freezeToken(Long tokenId) {
        CommunicationToken token = tokenRepo.findById(tokenId)
                .orElseThrow(() -> new IllegalArgumentException("Token not found"));
        token.setFrozen(true);
        tokenRepo.save(token);
    }

    @Override
    public void createSocialPost(Long mdId, String title, String content, String mediaUrl) {
        User md = userRepo.findById(mdId).orElseThrow(() -> new IllegalArgumentException("MD not found"));
        SocialPost post = SocialPost.builder()
                .author(md)
                .title(title)
                .content(content)
                .mediaUrl(mediaUrl)
                .postedAt(LocalDateTime.now())
                .build();
        socialRepo.save(post);
    }

    @Override
    public List<LaunchpadResponseDTO> getLaunchpadIdeas() {
        return launchpadRepo.findAll().stream()
                .map(idea -> LaunchpadResponseDTO.builder()
                        .id(idea.getId())
                        .submitterEmail(idea.getSubmitter().getEmail())
                        .ideaTitle(idea.getIdeaTitle())
                        .description(idea.getDescription())
                        .domain(idea.getDomain())
                        .contactInfo(idea.getContactInfo())
                        .submittedAt(idea.getSubmittedAt())
                        .build())
                .collect(Collectors.toList());
    }

    @Override
    public List<LaunchpadResponseDTO> getLaunchpadSubmissions() {
        return getLaunchpadIdeas(); // same
    }

    @Override
    public void respondToLaunchpadSubmission(Long submissionId, String response) {
        LaunchpadSubmission submission = launchpadRepo.findById(submissionId)
                .orElseThrow(() -> new IllegalArgumentException("Submission not found"));
        submission.setResponse(response);
        launchpadRepo.save(submission);
    }

    @Override
    public PendingQueueDTO getPendingQueues() {
        List<PendingQueueDTO.ReferralItem> refs = referralRepo.findByStatus(ReferralStatus.PENDING).stream()
                .map(r -> PendingQueueDTO.ReferralItem.builder()
                        .id(r.getId())
                        .patientName(r.getPatient().getFullName())
                        .fromDoctor(r.getFromDoctor().getFullName())
                        .requestedSpecialty(r.getRequestedSpecialty())
                        .urgency(r.getUrgency())
                        .reason(r.getReason())
                        .build())
                .collect(Collectors.toList());

        List<PendingQueueDTO.TokenItem> toks = tokenRepo.findByStatus(TokenStatus.REQUESTED).stream()
                .map(t -> PendingQueueDTO.TokenItem.builder()
                        .id(t.getId())
                        .patientName(t.getPatient().getFullName())
                        .type(t.getType().toString())
                        .scheduledTime(t.getScheduledTime())
                        .build())
                .collect(Collectors.toList());

        return PendingQueueDTO.builder().referrals(refs).tokens(toks).build();
    }

    @Override
    public List<PendingQueueDTO.TokenItem> getActiveAppointments() {
        return tokenRepo.findByStatus(TokenStatus.APPROVED).stream()
                .map(t -> PendingQueueDTO.TokenItem.builder()
                        .id(t.getId())
                        .patientName(t.getPatient().getFullName())
                        .type(t.getType().toString())
                        .scheduledTime(t.getScheduledTime())
                        .build())
                .collect(Collectors.toList());
    }

    @Override
    public void promoteUser(String email, String name, String roleName) {
        Role targetRole = Role.valueOf(roleName.toUpperCase());
        User user = userRepo.findByEmail(email).orElse(null);
        if (user != null) {
            user.setRole(targetRole);
            userRepo.save(user);
        } else {
            User newUser = User.builder()
                    .email(email)
                    .fullName(name)
                    .password(passwordEncoder.encode("temp@123"))
                    .role(targetRole)
                    .build();
            userRepo.save(newUser);
        }
    }

    @Override
    public void terminateToken(Long tokenId) {
        CommunicationToken token = tokenRepo.findById(tokenId)
                .orElseThrow(() -> new IllegalArgumentException("Token not found."));
        token.setStatus(TokenStatus.COMPLETED);
        token.setFrozen(true);
        token.setExpiresAt(LocalDateTime.now());
        tokenRepo.save(token);
    }

    @Override
    public void addFinancialRecord(String type, double amount, String description) {
        FinancialTransaction tx = FinancialTransaction.builder()
                .type(TransactionType.valueOf(type.toUpperCase()))
                .amount(amount)
                .description(description)
                .transactionDate(LocalDateTime.now())
                .build();
        financeRepo.save(tx);
    }

    @Override
    public Long getAdminUserId() {
        return userRepo.findByRole(Role.MAIN_DOCTOR).stream()
                .findFirst()
                .map(User::getId)
                .orElse(1L);
    }
}
