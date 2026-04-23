package com.telepatient.auth.controller;

import com.telepatient.auth.dto.request.ReferralRequestDTO;
import com.telepatient.auth.dto.request.RegisterRequest;
import com.telepatient.auth.dto.response.AuthResponse;
import com.telepatient.auth.dto.response.PatientDTO;
import com.telepatient.auth.security.JwtPrincipal;
import com.telepatient.auth.service.AuthService;
import com.telepatient.auth.service.DoctorService;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/api/doctor")
@RequiredArgsConstructor
@PreAuthorize("hasRole('DOCTOR')")   // class-level guard — all endpoints require DOCTOR role
public class DoctorController {

    private final DoctorService doctorService;
    private final AuthService   authService;

    /**
     * Add a new patient and assign them to the authenticated doctor.
     * doctorId is taken from the JWT — not from the request body.
     */
    @PostMapping("/add-patient")
    public ResponseEntity<AuthResponse> addPatient(
            @RequestBody RegisterRequest request,
            @RequestParam(required = false) Integer age,
            @AuthenticationPrincipal JwtPrincipal principal) {

        AuthResponse response = authService.register(request);
        doctorService.assignPatientToDoctor(response.getUserId(), principal.getUserId(), age);
        return ResponseEntity.ok(response);
    }

    /**
     * Get patients assigned to the authenticated doctor.
     * The path variable {doctorId} is kept for backward compatibility but
     * is validated against the JWT to prevent horizontal privilege escalation.
     */
    @GetMapping("/{doctorId}/patients")
    public ResponseEntity<List<PatientDTO>> getPatients(
            @PathVariable Long doctorId,
            @AuthenticationPrincipal JwtPrincipal principal) {

        // Doctors can only view their own patients
        validateOwnership(principal.getUserId(), doctorId);
        return ResponseEntity.ok(doctorService.getAssignedPatients(doctorId));
    }

    @PostMapping("/{doctorId}/consultations")
    public ResponseEntity<String> addConsultation(
            @PathVariable Long doctorId,
            @RequestParam Long patientId,
            @RequestParam String notes,
            @RequestParam(required = false) String prescription,
            @RequestParam(required = false) String reportsUrl,
            @AuthenticationPrincipal JwtPrincipal principal) {

        validateOwnership(principal.getUserId(), doctorId);
        doctorService.addConsultation(doctorId, patientId, notes, prescription, reportsUrl);
        return ResponseEntity.ok("Consultation record added successfully");
    }

    @PostMapping("/{doctorId}/referrals")
    public ResponseEntity<String> requestReferral(
            @PathVariable Long doctorId,
            @RequestBody ReferralRequestDTO request,
            @AuthenticationPrincipal JwtPrincipal principal) {

        validateOwnership(principal.getUserId(), doctorId);
        doctorService.requestReferral(doctorId, request);
        return ResponseEntity.ok("Referral forwarded to Main Doctor for approval");
    }

    // ─── Helper ───────────────────────────────────────────────────────────────

    /**
     * Prevent a doctor from acting on behalf of another doctor's ID.
     * Throws 403-equivalent if the JWT userId doesn't match the path variable.
     */
    private void validateOwnership(Long jwtUserId, Long pathUserId) {
        if (!jwtUserId.equals(pathUserId)) {
            throw new org.springframework.security.access.AccessDeniedException(
                    "You can only access your own resources.");
        }
    }
}
