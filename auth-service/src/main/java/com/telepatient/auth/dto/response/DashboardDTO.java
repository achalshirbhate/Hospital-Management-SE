package com.telepatient.auth.dto.response;

import java.util.Map;

public class DashboardDTO {
    private Double totalRevenue, totalExpenses, profitLoss;
    private Long patientCount, activeDoctors, pendingReferrals, pendingTokenRequests, totalAppointments;
    private Map<String, Long> doctorActivity;

    public DashboardDTO() {}

    public static Builder builder() { return new Builder(); }

    public static class Builder {
        private Double totalRevenue, totalExpenses, profitLoss;
        private Long patientCount, activeDoctors, pendingReferrals, pendingTokenRequests, totalAppointments;
        private Map<String, Long> doctorActivity;

        public Builder totalRevenue(Double v) { this.totalRevenue = v; return this; }
        public Builder totalExpenses(Double v) { this.totalExpenses = v; return this; }
        public Builder profitLoss(Double v) { this.profitLoss = v; return this; }
        public Builder patientCount(Long v) { this.patientCount = v; return this; }
        public Builder activeDoctors(Long v) { this.activeDoctors = v; return this; }
        public Builder pendingReferrals(Long v) { this.pendingReferrals = v; return this; }
        public Builder pendingTokenRequests(Long v) { this.pendingTokenRequests = v; return this; }
        public Builder totalAppointments(Long v) { this.totalAppointments = v; return this; }
        public Builder doctorActivity(Map<String, Long> m) { this.doctorActivity = m; return this; }
        public DashboardDTO build() {
            DashboardDTO d = new DashboardDTO();
            d.totalRevenue = totalRevenue; d.totalExpenses = totalExpenses; d.profitLoss = profitLoss;
            d.patientCount = patientCount; d.activeDoctors = activeDoctors;
            d.pendingReferrals = pendingReferrals; d.pendingTokenRequests = pendingTokenRequests;
            d.totalAppointments = totalAppointments; d.doctorActivity = doctorActivity;
            return d;
        }
    }

    public Double getTotalRevenue() { return totalRevenue; }
    public Double getTotalExpenses() { return totalExpenses; }
    public Double getProfitLoss() { return profitLoss; }
    public Long getPatientCount() { return patientCount; }
    public Long getActiveDoctors() { return activeDoctors; }
    public Long getPendingReferrals() { return pendingReferrals; }
    public Long getPendingTokenRequests() { return pendingTokenRequests; }
    public Long getTotalAppointments() { return totalAppointments; }
    public Map<String, Long> getDoctorActivity() { return doctorActivity; }
}
