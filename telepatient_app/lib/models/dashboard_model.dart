class DashboardModel {
  final double totalRevenue;
  final double totalExpenses;
  final double profitLoss;
  final int patientCount;
  final int activeDoctors;
  final int pendingReferrals;
  final int pendingTokenRequests;
  final int totalAppointments;
  final Map<String, int> doctorActivity;

  DashboardModel({
    required this.totalRevenue,
    required this.totalExpenses,
    required this.profitLoss,
    required this.patientCount,
    required this.activeDoctors,
    required this.pendingReferrals,
    required this.pendingTokenRequests,
    required this.totalAppointments,
    required this.doctorActivity,
  });

  factory DashboardModel.fromJson(Map<String, dynamic> json) => DashboardModel(
        totalRevenue: (json['totalRevenue'] ?? 0).toDouble(),
        totalExpenses: (json['totalExpenses'] ?? 0).toDouble(),
        profitLoss: (json['profitLoss'] ?? 0).toDouble(),
        patientCount: json['patientCount'] ?? 0,
        activeDoctors: json['activeDoctors'] ?? 0,
        pendingReferrals: json['pendingReferrals'] ?? 0,
        pendingTokenRequests: json['pendingTokenRequests'] ?? 0,
        totalAppointments: json['totalAppointments'] ?? 0,
        doctorActivity: Map<String, int>.from(
          (json['doctorActivity'] as Map? ?? {}).map(
            (k, v) => MapEntry(k.toString(), (v as num).toInt()),
          ),
        ),
      );
}
