package com.telepatient.auth.service;

import java.util.Map;

public interface DashboardService {
    Map<String, Object> getAnalytics();

    byte[] generateRevenueReport();
    byte[] generateExpenseReport();
    byte[] generateDoctorStatsReport();

    byte[] generateRevenuePdf();
    byte[] generateExpensePdf();
    byte[] generateDoctorStatsPdf();
}
