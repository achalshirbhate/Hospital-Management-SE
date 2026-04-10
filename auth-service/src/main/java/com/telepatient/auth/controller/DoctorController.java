package com.telepatient.auth.controller;

import com.telepatient.auth.dto.request.ReferralRequestDTO;
import com.telepatient.auth.dto.request.RegisterRequest;
import com.telepatient.auth.dto.response.AuthResponse;
import com.telepatient.auth.dto.response.PatientDTO;
import com.telepatient.auth.service.AuthService;
import com.telepatient.auth.service.DoctorService;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;
import java.util.List;

@RestController
@RequestMapping("/api/doctor")
@RequiredArgsConstructor
public class DoctorController {

    private final DoctorService doctorService;
    private final AuthService authService;

    @PostMapping("/add-patient")
    public ResponseEntity<AuthResponse> addPatient(@RequestBody RegisterRequest request, @RequestParam Long doctorId,
            @RequestParam(required = false) Integer age) {
        AuthResponse response = authService.register(request);
        doctorService.assignPatientToDoctor(response.getUserId(), doctorId, age);
        return ResponseEntity.ok(response);
    }

    @GetMapping("/{doctorId}/patients")
    public ResponseEntity<List<PatientDTO>> getPatients(@PathVariable Long doctorId) {
        return ResponseEntity.ok(doctorService.getAssignedPatients(doctorId));
    }

    @PostMapping("/{doctorId}/consultations")
    public ResponseEntity<String> addConsultation(@PathVariable Long doctorId,
            @RequestParam Long patientId,
            @RequestParam String notes,
            @RequestParam(required = false) String prescription,
            @RequestParam(required = false) String reportsUrl) {
        doctorService.addConsultation(doctorId, patientId, notes, prescription, reportsUrl);
        return ResponseEntity.ok("Consultation record added successfully");
    }

    @PostMapping("/{doctorId}/referrals")
    public ResponseEntity<String> requestReferral(@PathVariable Long doctorId,
            @RequestBody ReferralRequestDTO request) {
        doctorService.requestReferral(doctorId, request);
        return ResponseEntity.ok("Referral requested forwarded to Main Doctor for approval");
    }
}
