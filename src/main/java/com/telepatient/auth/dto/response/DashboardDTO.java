package com.telepatient.auth.dto.response;

import lombok.Builder;
import lombok.Data;
import java.util.Map;

@Data
@Builder
public class DashboardDTO {
    private Double totalRevenue;
    private Double totalExpenses;
    private Double profitLoss;
    private Long patientCount;
    private Long activeDoctors;
    private Long pendingReferrals;
    private Long pendingTokenRequests;
    private Long totalAppointments;
    private Map<String, Long> doctorActivity;
}
