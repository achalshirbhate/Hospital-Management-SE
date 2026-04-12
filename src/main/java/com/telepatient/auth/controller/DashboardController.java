package com.telepatient.auth.controller;

import com.telepatient.auth.service.DashboardService;
import lombok.RequiredArgsConstructor;
import org.springframework.http.HttpHeaders;
import org.springframework.http.MediaType;
import org.springframework.http.ResponseEntity;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.web.bind.annotation.*;

import java.util.Map;

@RestController
@RequestMapping("/api/dashboard")
@RequiredArgsConstructor
@PreAuthorize("hasRole('MAIN_DOCTOR')")
public class DashboardController {

  private final DashboardService dashboardService;

  @GetMapping("/analytics")
  public ResponseEntity<Map<String, Object>> getAnalytics() {
    return ResponseEntity.ok(dashboardService.getAnalytics());
  }

  @GetMapping("/reports/revenue")
  public ResponseEntity<byte[]> downloadRevenueReport() {
    byte[] pdf = dashboardService.generateRevenueReport();
    return ResponseEntity.ok()
        .header(HttpHeaders.CONTENT_DISPOSITION, "attachment; filename=monthly_revenue_report.pdf")
        .contentType(MediaType.APPLICATION_PDF)
        .body(pdf);
  }

  @GetMapping("/reports/expenses")
  public ResponseEntity<byte[]> downloadExpenseReport() {
    byte[] pdf = dashboardService.generateExpenseReport();
    return ResponseEntity.ok()
        .header(HttpHeaders.CONTENT_DISPOSITION, "attachment; filename=expense_breakdown.pdf")
        .contentType(MediaType.APPLICATION_PDF)
        .body(pdf);
  }

  @GetMapping("/reports/doctor-stats")
  public ResponseEntity<byte[]> downloadDoctorStatsReport() {
    byte[] pdf = dashboardService.generateDoctorStatsReport();
    return ResponseEntity.ok()
        .header(HttpHeaders.CONTENT_DISPOSITION, "attachment; filename=doctor_patient_stats.pdf")
        .contentType(MediaType.APPLICATION_PDF)
        .body(pdf);
  }
}