package com.telepatient.auth.controller;

import com.telepatient.auth.dto.response.ReportDTO;
import com.telepatient.auth.entity.*;
import com.telepatient.auth.repository.*;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.time.LocalDateTime;
import java.util.List;
import java.util.Map;
import java.util.stream.Collectors;

@RestController
@RequestMapping("/api/reports")
@RequiredArgsConstructor
public class ReportController {

    private final MedicalReportRepository reportRepo;
    private final UserRepository userRepo;
    private final ChatMessageRepository chatRepo;
    private final CommunicationTokenRepository tokenRepo;

    // GET all reports for a patient (latest first)
    @GetMapping("/{patientId}")
    public ResponseEntity<List<ReportDTO>> getReports(@PathVariable Long patientId) {
        User patient = userRepo.findById(patientId).orElseThrow();
        List<ReportDTO> reports = reportRepo.findByPatientOrderByUploadedAtDesc(patient)
            .stream().map(r -> ReportDTO.builder()
                .id(r.getId())
                .reportName(r.getReportName())
                .reportType(r.getReportType())
                .fileUrl(r.getFileUrl())
                .notes(r.getNotes())
                .doctorName(r.getDoctor().getFullName())
                .patientId(patientId)
                .uploadedAt(r.getUploadedAt())
                .build())
            .collect(Collectors.toList());
        return ResponseEntity.ok(reports);
    }

    // POST upload/save a report
    @PostMapping("/upload")
    public ResponseEntity<ReportDTO> uploadReport(@RequestBody Map<String, Object> body) {
        Long patientId = Long.valueOf(body.get("patientId").toString());
        Long doctorId  = Long.valueOf(body.get("doctorId").toString());
        String name    = (String) body.get("reportName");
        String type    = (String) body.getOrDefault("reportType", "PDF");
        String url     = (String) body.get("fileUrl");
        String notes   = (String) body.getOrDefault("notes", "");

        User patient = userRepo.findById(patientId).orElseThrow();
        User doctor  = userRepo.findById(doctorId).orElseThrow();

        MedicalReport report = MedicalReport.builder()
            .patient(patient).doctor(doctor)
            .reportName(name).reportType(type)
            .fileUrl(url).notes(notes)
            .uploadedAt(LocalDateTime.now())
            .build();
        report = reportRepo.save(report);

        return ResponseEntity.ok(ReportDTO.builder()
            .id(report.getId())
            .reportName(report.getReportName())
            .reportType(report.getReportType())
            .fileUrl(report.getFileUrl())
            .notes(report.getNotes())
            .doctorName(doctor.getFullName())
            .patientId(patientId)
            .uploadedAt(report.getUploadedAt())
            .build());
    }

    // POST send report as chat message
    @PostMapping("/send-to-chat")
    public ResponseEntity<String> sendToChat(@RequestBody Map<String, Object> body) {
        Long reportId = Long.valueOf(body.get("reportId").toString());
        Long tokenId  = Long.valueOf(body.get("tokenId").toString());
        Long senderId = Long.valueOf(body.get("senderId").toString());

        MedicalReport report = reportRepo.findById(reportId).orElseThrow();
        CommunicationToken token = tokenRepo.findById(tokenId).orElseThrow();
        User sender = userRepo.findById(senderId).orElseThrow();

        if (token.isFrozen()) return ResponseEntity.badRequest().body("Chat is frozen.");

        String msg = "📎 Report Shared: " + report.getReportName()
            + " [" + report.getReportType() + "]"
            + "\n🔗 " + report.getFileUrl()
            + "\n📅 " + report.getUploadedAt().toLocalDate();

        ChatMessage chat = ChatMessage.builder()
            .token(token).sender(sender)
            .message(msg).sentAt(LocalDateTime.now())
            .build();
        chatRepo.save(chat);

        return ResponseEntity.ok("Report shared in chat.");
    }
}
