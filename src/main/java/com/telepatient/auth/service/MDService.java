package com.telepatient.auth.service;

import com.telepatient.auth.dto.response.DashboardDTO;
import com.telepatient.auth.dto.response.LaunchpadResponseDTO;
import com.telepatient.auth.dto.response.PendingQueueDTO;
import java.util.List;

public interface MDService {
    DashboardDTO getDashboardAnalytics();

    void approveReferral(Long referralId, boolean approve, Long assignedDoctorId);

    List<com.telepatient.auth.dto.response.PatientDTO> getActiveDoctors();

    List<com.telepatient.auth.dto.response.PatientDTO> getAllPatients();

    void directAssignPatient(Long patientId, Long doctorId);

    void approveToken(Long tokenId, boolean approve, String scheduledTime);

    void freezeToken(Long tokenId);

    void createSocialPost(Long mdId, String title, String content, String mediaUrl);

    List<LaunchpadResponseDTO> getLaunchpadIdeas();

    List<LaunchpadResponseDTO> getLaunchpadSubmissions();

    void respondToLaunchpadSubmission(Long submissionId, String response);

    PendingQueueDTO getPendingQueues();

    List<PendingQueueDTO.TokenItem> getActiveAppointments();

    void terminateToken(Long tokenId);

    void promoteUser(String email, String name, String roleName);

    Long getAdminUserId();

    void addFinancialRecord(String type, double amount, String description);
}
