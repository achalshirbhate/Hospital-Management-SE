package com.telepatient.auth.service.impl;

import com.itextpdf.text.*;
import com.itextpdf.text.pdf.*;
import com.telepatient.auth.entity.*;
import com.telepatient.auth.repository.*;
import com.telepatient.auth.service.DashboardService;
import lombok.RequiredArgsConstructor;
import org.apache.poi.ss.usermodel.*;
import org.apache.poi.ss.usermodel.Font;
import org.apache.poi.xssf.usermodel.XSSFWorkbook;
import org.springframework.stereotype.Service;

import java.io.ByteArrayOutputStream;
import java.time.LocalDateTime;
import java.time.format.DateTimeFormatter;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.stream.Collectors;

@Service
@RequiredArgsConstructor
public class DashboardServiceImpl implements DashboardService {

  private final UserRepository userRepository;
  private final FinancialTransactionRepository financialTransactionRepository;
  private final ConsultationRepository consultationRepository;
  private final ReferralRequestRepository referralRequestRepository;
  private final CommunicationTokenRepository communicationTokenRepository;

  @Override
  public Map<String, Object> getAnalytics() {
    Map<String, Object> analytics = new HashMap<>();
    double totalRevenue = financialTransactionRepository.findAll().stream()
        .filter(t -> t.getType() == TransactionType.REVENUE)
        .mapToDouble(FinancialTransaction::getAmount).sum();
    double totalExpenses = financialTransactionRepository.findAll().stream()
        .filter(t -> t.getType() == TransactionType.EXPENDITURE)
        .mapToDouble(FinancialTransaction::getAmount).sum();
    analytics.put("totalRevenue", totalRevenue);
    analytics.put("totalExpenses", totalExpenses);
    analytics.put("profitLoss", totalRevenue - totalExpenses);
    analytics.put("patientCount", userRepository.findAll().stream().filter(u -> u.getRole() == Role.PATIENT).count());
    analytics.put("doctorActivity", consultationRepository.findAll().stream()
        .collect(Collectors.groupingBy(c -> c.getDoctor().getId(), Collectors.counting())));
    analytics.put("appointments", consultationRepository.count());
    analytics.put("pendingReferrals", referralRequestRepository.findAll().stream()
        .filter(r -> r.getStatus() == ReferralStatus.PENDING).count());
    analytics.put("pendingRequests", communicationTokenRepository.findAll().stream()
        .filter(t -> t.getStatus() == TokenStatus.REQUESTED).count());
    return analytics;
  }

  @Override
  public byte[] generateRevenueReport() {
    List<FinancialTransaction> records = financialTransactionRepository.findAll().stream()
        .filter(t -> t.getType() == TransactionType.REVENUE).collect(Collectors.toList());
    double total = records.stream().mapToDouble(FinancialTransaction::getAmount).sum();
    return buildExcel("Revenue Report", new String[]{"#", "Description", "Amount (Rs.)", "Date"},
        records.stream().map(t -> new String[]{
            String.valueOf(t.getId()), t.getDescription(), String.valueOf(t.getAmount()),
            t.getTransactionDate() != null ? t.getTransactionDate().format(DateTimeFormatter.ofPattern("yyyy-MM-dd HH:mm")) : "-"
        }).collect(Collectors.toList()), "Total Revenue", total);
  }

  @Override
  public byte[] generateExpenseReport() {
    List<FinancialTransaction> records = financialTransactionRepository.findAll().stream()
        .filter(t -> t.getType() == TransactionType.EXPENDITURE).collect(Collectors.toList());
    double total = records.stream().mapToDouble(FinancialTransaction::getAmount).sum();
    return buildExcel("Expense Report", new String[]{"#", "Description", "Amount (Rs.)", "Date"},
        records.stream().map(t -> new String[]{
            String.valueOf(t.getId()), t.getDescription(), String.valueOf(t.getAmount()),
            t.getTransactionDate() != null ? t.getTransactionDate().format(DateTimeFormatter.ofPattern("yyyy-MM-dd HH:mm")) : "-"
        }).collect(Collectors.toList()), "Total Expenses", total);
  }

  @Override
  public byte[] generateDoctorStatsReport() {
    List<String[]> rows = userRepository.findByRole(Role.DOCTOR).stream().map(doctor -> {
      long patients = consultationRepository.findAll().stream()
          .filter(c -> c.getDoctor().getId().equals(doctor.getId()))
          .map(c -> c.getPatient().getId()).distinct().count();
      long consultations = consultationRepository.findAll().stream()
          .filter(c -> c.getDoctor().getId().equals(doctor.getId())).count();
      return new String[]{doctor.getFullName(), doctor.getSpecialty() != null ? doctor.getSpecialty() : "General",
          String.valueOf(patients), String.valueOf(consultations)};
    }).collect(Collectors.toList());
    return buildExcel("Doctor Stats Report", new String[]{"Doctor Name", "Specialty", "Patients", "Consultations"},
        rows, null, 0);
  }

  public byte[] generateRevenuePdf() {
    List<FinancialTransaction> records = financialTransactionRepository.findAll().stream()
        .filter(t -> t.getType() == TransactionType.REVENUE).collect(Collectors.toList());
    double total = records.stream().mapToDouble(FinancialTransaction::getAmount).sum();
    return buildPdf("Monthly Revenue Report", new String[]{"#", "Description", "Amount (Rs.)", "Date"},
        records.stream().map(t -> new String[]{
            String.valueOf(t.getId()), t.getDescription(), String.valueOf(t.getAmount()),
            t.getTransactionDate() != null ? t.getTransactionDate().format(DateTimeFormatter.ofPattern("yyyy-MM-dd HH:mm")) : "-"
        }).collect(Collectors.toList()), "Total Revenue: Rs." + total);
  }

  public byte[] generateExpensePdf() {
    List<FinancialTransaction> records = financialTransactionRepository.findAll().stream()
        .filter(t -> t.getType() == TransactionType.EXPENDITURE).collect(Collectors.toList());
    double total = records.stream().mapToDouble(FinancialTransaction::getAmount).sum();
    return buildPdf("Expense Breakdown Report", new String[]{"#", "Description", "Amount (Rs.)", "Date"},
        records.stream().map(t -> new String[]{
            String.valueOf(t.getId()), t.getDescription(), String.valueOf(t.getAmount()),
            t.getTransactionDate() != null ? t.getTransactionDate().format(DateTimeFormatter.ofPattern("yyyy-MM-dd HH:mm")) : "-"
        }).collect(Collectors.toList()), "Total Expenses: Rs." + total);
  }

  public byte[] generateDoctorStatsPdf() {
    List<String[]> rows = userRepository.findByRole(Role.DOCTOR).stream().map(doctor -> {
      long patients = consultationRepository.findAll().stream()
          .filter(c -> c.getDoctor().getId().equals(doctor.getId()))
          .map(c -> c.getPatient().getId()).distinct().count();
      long consultations = consultationRepository.findAll().stream()
          .filter(c -> c.getDoctor().getId().equals(doctor.getId())).count();
      return new String[]{doctor.getFullName(), doctor.getSpecialty() != null ? doctor.getSpecialty() : "General",
          String.valueOf(patients), String.valueOf(consultations)};
    }).collect(Collectors.toList());
    return buildPdf("Doctor Stats Report", new String[]{"Doctor Name", "Specialty", "Patients", "Consultations"}, rows, null);
  }

  private byte[] buildExcel(String sheetName, String[] headers, List<String[]> rows, String totalLabel, double total) {
    try (XSSFWorkbook wb = new XSSFWorkbook(); ByteArrayOutputStream out = new ByteArrayOutputStream()) {
      Sheet sheet = wb.createSheet(sheetName);
      CellStyle headerStyle = wb.createCellStyle();
      Font hFont = wb.createFont(); hFont.setBold(true); headerStyle.setFont(hFont);
      headerStyle.setFillForegroundColor(IndexedColors.LIGHT_BLUE.getIndex());
      headerStyle.setFillPattern(FillPatternType.SOLID_FOREGROUND);
      Row titleRow = sheet.createRow(0);
      titleRow.createCell(0).setCellValue(sheetName + " - Generated: " + LocalDateTime.now().format(DateTimeFormatter.ofPattern("yyyy-MM-dd HH:mm")));
      Row headerRow = sheet.createRow(1);
      for (int i = 0; i < headers.length; i++) {
        Cell c = headerRow.createCell(i); c.setCellValue(headers[i]); c.setCellStyle(headerStyle);
      }
      int rowNum = 2;
      for (String[] row : rows) {
        Row r = sheet.createRow(rowNum++);
        for (int i = 0; i < row.length; i++) r.createCell(i).setCellValue(row[i] != null ? row[i] : "-");
      }
      if (totalLabel != null) {
        Row totalRow = sheet.createRow(rowNum + 1);
        Cell lbl = totalRow.createCell(0); lbl.setCellValue(totalLabel); lbl.setCellStyle(headerStyle);
        totalRow.createCell(1).setCellValue("Rs." + total);
      }
      for (int i = 0; i < headers.length; i++) sheet.autoSizeColumn(i);
      wb.write(out);
      return out.toByteArray();
    } catch (Exception e) { throw new RuntimeException("Excel generation failed", e); }
  }

  private byte[] buildPdf(String title, String[] headers, List<String[]> rows, String footer) {
    try (ByteArrayOutputStream out = new ByteArrayOutputStream()) {
      Document doc = new Document(PageSize.A4);
      PdfWriter.getInstance(doc, out);
      doc.open();
      com.itextpdf.text.Font titleFont = new com.itextpdf.text.Font(com.itextpdf.text.Font.FontFamily.HELVETICA, 16, com.itextpdf.text.Font.BOLD);
      com.itextpdf.text.Font headerFont = new com.itextpdf.text.Font(com.itextpdf.text.Font.FontFamily.HELVETICA, 10, com.itextpdf.text.Font.BOLD, BaseColor.WHITE);
      com.itextpdf.text.Font cellFont = new com.itextpdf.text.Font(com.itextpdf.text.Font.FontFamily.HELVETICA, 9);
      doc.add(new Paragraph(title, titleFont));
      doc.add(new Paragraph("Generated: " + LocalDateTime.now().format(DateTimeFormatter.ofPattern("yyyy-MM-dd HH:mm"))));
      doc.add(Chunk.NEWLINE);
      PdfPTable table = new PdfPTable(headers.length);
      table.setWidthPercentage(100);
      for (String h : headers) {
        PdfPCell cell = new PdfPCell(new Phrase(h, headerFont));
        cell.setBackgroundColor(new BaseColor(41, 128, 185));
        cell.setPadding(6); table.addCell(cell);
      }
      for (String[] row : rows)
        for (String val : row) { PdfPCell c = new PdfPCell(new Phrase(val != null ? val : "-", cellFont)); c.setPadding(5); table.addCell(c); }
      doc.add(table);
      if (footer != null) { doc.add(Chunk.NEWLINE); doc.add(new Paragraph(footer, titleFont)); }
      doc.close();
      return out.toByteArray();
    } catch (Exception e) { throw new RuntimeException("PDF generation failed", e); }
  }
}
