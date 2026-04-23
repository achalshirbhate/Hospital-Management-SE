package com.telepatient.auth.controller;

import com.telepatient.auth.dto.request.TokenRequestDTO;
import com.telepatient.auth.dto.response.HistoryDTO;
import com.telepatient.auth.entity.CommunicationToken;
import com.telepatient.auth.security.JwtPrincipal;
import com.telepatient.auth.service.PatientService;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.security.access.AccessDeniedException;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/api/patient")
@RequiredArgsConstructor
@PreAuthorize("hasRole('PATIENT')")   // all endpoints require PATIENT role
public class PatientController {

    private final PatientService patientService;

    /**
     * Get consultation history for the authenticated patient.
     * Path variable is validated against JWT to prevent IDOR.
     */
    @GetMapping("/{patientId}/history")
    public ResponseEntity<List<HistoryDTO>> getHistory(
            @PathVariable Long patientId,
            @AuthenticationPrincipal JwtPrincipal principal) {

        validateOwnership(principal.getUserId(), patientId);
        return ResponseEntity.ok(patientService.getPatientHistory(patientId));
    }

    /**
     * Request a communication token (CHAT or VIDEO).
     * patientId in the request body is overridden with the JWT userId
     * so the frontend cannot spoof another patient's ID.
     */
    @PostMapping("/tokens")
    public ResponseEntity<String> requestToken(
            @RequestBody TokenRequestDTO request,
            @AuthenticationPrincipal JwtPrincipal principal) {

        // Override patientId from JWT — never trust the request body for identity
        request.setPatientId(principal.getUserId());
        patientService.requestCommunicationToken(request);
        return ResponseEntity.ok("Token requested successfully");
    }

    @GetMapping("/{patientId}/tokens")
    public ResponseEntity<List<CommunicationToken>> viewMyTokens(
            @PathVariable Long patientId,
            @AuthenticationPrincipal JwtPrincipal principal) {

        validateOwnership(principal.getUserId(), patientId);
        return ResponseEntity.ok(patientService.getPatientTokens(patientId));
    }

    @PostMapping("/{patientId}/emergency")
    public ResponseEntity<String> triggerEmergency(
            @PathVariable Long patientId,
            @RequestParam(defaultValue = "CRITICAL") String level,
            @AuthenticationPrincipal JwtPrincipal principal) {

        validateOwnership(principal.getUserId(), patientId);
        return ResponseEntity.ok(patientService.triggerEmergencyAlert(patientId, level));
    }

    // ─── Helper ───────────────────────────────────────────────────────────────

    private void validateOwnership(Long jwtUserId, Long pathUserId) {
        if (!jwtUserId.equals(pathUserId)) {
            throw new AccessDeniedException("You can only access your own resources.");
        }
    }
}
