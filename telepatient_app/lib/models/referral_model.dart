class ReferralModel {
  final int id;
  final String patientName;
  final String fromDoctor;
  final String requestedSpecialty;
  final String urgency;
  final String reason;

  ReferralModel({
    required this.id,
    required this.patientName,
    required this.fromDoctor,
    required this.requestedSpecialty,
    required this.urgency,
    required this.reason,
  });

  factory ReferralModel.fromJson(Map<String, dynamic> json) => ReferralModel(
        id: json['id'] ?? 0,
        patientName: json['patientName'] ?? '',
        fromDoctor: json['fromDoctor'] ?? '',
        requestedSpecialty: json['requestedSpecialty'] ?? '',
        urgency: json['urgency'] ?? '',
        reason: json['reason'] ?? '',
      );
}
