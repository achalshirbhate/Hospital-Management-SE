package com.telepatient.auth.controller;

import com.telepatient.auth.dto.request.TokenRequestDTO;
import com.telepatient.auth.dto.response.HistoryDTO;
import com.telepatient.auth.service.PatientService;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;
import java.util.List;

@RestController
@RequestMapping("/api/patient")
@RequiredArgsConstructor
public class PatientController {

    private final PatientService patientService;

    @GetMapping("/{patientId}/history")
    public ResponseEntity<List<HistoryDTO>> getHistory(@PathVariable Long patientId) {
        return ResponseEntity.ok(patientService.getPatientHistory(patientId));
    }

    @PostMapping("/tokens")
    public ResponseEntity<String> requestToken(@RequestBody TokenRequestDTO request) {
        patientService.requestCommunicationToken(request);
        return ResponseEntity.ok("Token requested successfully");
    }

    @GetMapping("/{patientId}/tokens")
    public ResponseEntity<List<com.telepatient.auth.entity.CommunicationToken>> viewMyTokens(@PathVariable Long patientId) {
        return ResponseEntity.ok(patientService.getPatientTokens(patientId));
    }
}
