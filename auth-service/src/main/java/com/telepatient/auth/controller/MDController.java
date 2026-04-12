package com.telepatient.auth.controller;

import com.telepatient.auth.service.DashboardService;
import com.telepatient.auth.dto.response.EmergencyAlertDTO;
import com.telepatient.auth.repository.EmergencyAlertRepository;
import com.telepatient.auth.entity.EmergencyAlert;
import com.telepatient.auth.dto.response.DashboardDTO;
import com.telepatient.auth.dto.response.LaunchpadResponseDTO;
import com.telepatient.auth.dto.response.PendingQueueDTO;
import com.telepatient.auth.dto.response.HistoryDTO;
import com.telepatient.auth.dto.response.PatientDTO;
import com.telepatient.auth.service.DoctorService;
import com.telepatient.auth.service.PatientService;
import com.telepatient.auth.service.MDService;
import lombok.RequiredArgsConstructor;
import org.springframework.http.HttpHeaders;
import org.springframework.http.MediaType;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;
import java.util.List;

@RestController
@RequestMapping("/api/md")
@RequiredArgsConstructor
public class MDController {

    private final MDService mdService;
    private final DoctorService doctorService;
    private final PatientService patientService;
    private final DashboardService dashboardService;
    private final EmergencyAlertRepository emergencyRepo;

    @GetMapping("/admin-id")
    public ResponseEntity<Long> getAdminId() {
        return ResponseEntity.ok(mdService.getAdminUserId());
    }

    @GetMapping("/dashboard")
    public ResponseEntity<DashboardDTO> getDashboard() {
        return ResponseEntity.ok(mdService.getDashboardAnalytics());
    }

    @GetMapping("/queues")
    public ResponseEntity<PendingQueueDTO> getPendingQueues() {
        return ResponseEntity.ok(mdService.getPendingQueues());
    }

    @GetMapping("/appointments")
    public ResponseEntity<java.util.List<PendingQueueDTO.TokenItem>> getAppointments() {
        return ResponseEntity.ok(mdService.getActiveAppointments());
    }

    @PutMapping("/referrals/{id}/assign")
    public ResponseEntity<String> processReferral(@PathVariable Long id,
            @RequestParam boolean approve,
            @RequestParam(required = false) Long assignedDoctorId) {
        mdService.approveReferral(id, approve, assignedDoctorId);
        return ResponseEntity.ok("Referral processed");
    }

    @GetMapping("/doctors")
    public ResponseEntity<List<PatientDTO>> getActiveDoctors() {
        return ResponseEntity.ok(mdService.getActiveDoctors());
    }

    @GetMapping("/doctors/{doctorId}/patients")
    public ResponseEntity<List<PatientDTO>> getDoctorPatients(@PathVariable Long doctorId) {
        return ResponseEntity.ok(doctorService.getAssignedPatients(doctorId));
    }

    @GetMapping("/patients/{patientId}/history")
    public ResponseEntity<List<HistoryDTO>> getPatientHistory(@PathVariable Long patientId) {
        return ResponseEntity.ok(patientService.getPatientHistory(patientId));
    }

    @GetMapping("/patients")
    public ResponseEntity<List<PatientDTO>> getAllPatients() {
        return ResponseEntity.ok(mdService.getAllPatients());
    }

    @PutMapping("/patients/{patientId}/assign")
    public ResponseEntity<String> directAssignPatient(@PathVariable Long patientId, @RequestParam Long doctorId) {
        mdService.directAssignPatient(patientId, doctorId);
        return ResponseEntity.ok("Patient forcibly assigned to Doctor.");
    }

    @PutMapping("/tokens/{id}")
    public ResponseEntity<String> processToken(@PathVariable Long id,
            @RequestParam boolean approve,
            @RequestParam(required = false) String scheduledTime) {
        mdService.approveToken(id, approve, scheduledTime);
        return ResponseEntity.ok("Token processed");
    }

    @PutMapping("/tokens/{id}/terminate")
    public ResponseEntity<String> terminateToken(@PathVariable Long id) {
        mdService.terminateToken(id);
        return ResponseEntity.ok("Session permanently closed");
    }

    @PutMapping("/tokens/{id}/freeze")
    public ResponseEntity<String> freezeToken(@PathVariable Long id) {
        mdService.freezeToken(id);
        return ResponseEntity.ok("Token frozen");
    }

    @PostMapping("/social")
    public ResponseEntity<String> createPost(@RequestParam Long mdId,
            @RequestParam String title,
            @RequestParam String content,
            @RequestParam(required = false) String mediaUrl) {
        mdService.createSocialPost(mdId, title, content, mediaUrl);
        return ResponseEntity.ok("Post published successfully");
    }

    @GetMapping("/launchpad/submissions")
    public ResponseEntity<List<LaunchpadResponseDTO>> getLaunchpadSubmissions() {
        return ResponseEntity.ok(mdService.getLaunchpadSubmissions());
    }

    @PutMapping("/launchpad/{id}/respond")
    public ResponseEntity<String> respondToSubmission(@PathVariable Long id, @RequestParam String response) {
        mdService.respondToLaunchpadSubmission(id, response);
        return ResponseEntity.ok("Response sent to submitter");
    }

    @GetMapping("/launchpad")
    public ResponseEntity<List<LaunchpadResponseDTO>> viewIdeas() {
        return ResponseEntity.ok(mdService.getLaunchpadIdeas());
    }

    @PostMapping("/finance")
    public ResponseEntity<String> addFinancialRecord(@RequestBody java.util.Map<String, Object> body) {
        String type = (String) body.get("type");
        double amount = ((Number) body.get("amount")).doubleValue();
        String description = (String) body.get("description");
        mdService.addFinancialRecord(type, amount, description);
        return ResponseEntity.ok("Financial record saved.");
    }

    @PostMapping("/promote")
    public ResponseEntity<String> promoteUser(@RequestParam String email,
            @RequestParam String name,
            @RequestParam String role) {
        mdService.promoteUser(email, name, role);
        return ResponseEntity.ok("User promoted/registered successfully.");
    }

    @GetMapping("/reports/revenue/excel")
    public ResponseEntity<byte[]> revenueExcel() {
        return ResponseEntity.ok()
            .header(HttpHeaders.CONTENT_DISPOSITION, "attachment; filename=revenue_report.xlsx")
            .contentType(MediaType.parseMediaType("application/vnd.openxmlformats-officedocument.spreadsheetml.sheet"))
            .body(dashboardService.generateRevenueReport());
    }

    @GetMapping("/reports/expenses/excel")
    public ResponseEntity<byte[]> expensesExcel() {
        return ResponseEntity.ok()
            .header(HttpHeaders.CONTENT_DISPOSITION, "attachment; filename=expense_report.xlsx")
            .contentType(MediaType.parseMediaType("application/vnd.openxmlformats-officedocument.spreadsheetml.sheet"))
            .body(dashboardService.generateExpenseReport());
    }

    @GetMapping("/reports/doctors/excel")
    public ResponseEntity<byte[]> doctorsExcel() {
        return ResponseEntity.ok()
            .header(HttpHeaders.CONTENT_DISPOSITION, "attachment; filename=doctor_stats.xlsx")
            .contentType(MediaType.parseMediaType("application/vnd.openxmlformats-officedocument.spreadsheetml.sheet"))
            .body(dashboardService.generateDoctorStatsReport());
    }

    @GetMapping("/reports/revenue/pdf")
    public ResponseEntity<byte[]> revenuePdf() {
        return ResponseEntity.ok()
            .header(HttpHeaders.CONTENT_DISPOSITION, "attachment; filename=revenue_report.pdf")
            .contentType(MediaType.APPLICATION_PDF)
            .body(dashboardService.generateRevenuePdf());
    }

    @GetMapping("/reports/expenses/pdf")
    public ResponseEntity<byte[]> expensesPdf() {
        return ResponseEntity.ok()
            .header(HttpHeaders.CONTENT_DISPOSITION, "attachment; filename=expense_report.pdf")
            .contentType(MediaType.APPLICATION_PDF)
            .body(dashboardService.generateExpensePdf());
    }

    @GetMapping("/reports/doctors/pdf")
    public ResponseEntity<byte[]> doctorsPdf() {
        return ResponseEntity.ok()
            .header(HttpHeaders.CONTENT_DISPOSITION, "attachment; filename=doctor_stats.pdf")
            .contentType(MediaType.APPLICATION_PDF)
            .body(dashboardService.generateDoctorStatsPdf());
    }

    @GetMapping("/emergencies")
    public ResponseEntity<List<EmergencyAlertDTO>> getEmergencies() {
        List<EmergencyAlertDTO> list = emergencyRepo.findByAcknowledgedFalseOrderByAlertTimeDesc()
            .stream().map(e -> EmergencyAlertDTO.builder()
                .id(e.getId())
                .patientName(e.getPatient().getFullName())
                .level(e.getLevel())
                .alertTime(e.getAlertTime())
                .build())
            .collect(java.util.stream.Collectors.toList());
        return ResponseEntity.ok(list);
    }

    @PutMapping("/emergencies/{id}/acknowledge")
    public ResponseEntity<String> acknowledgeEmergency(@PathVariable Long id) {
        emergencyRepo.findById(id).ifPresent(e -> {
            e.setAcknowledged(true);
            emergencyRepo.save(e);
        });
        return ResponseEntity.ok("Acknowledged");
    }
}
