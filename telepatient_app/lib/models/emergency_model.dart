class EmergencyModel {
  final int id;
  final String patientName;
  final String level;
  final String? alertTime;

  EmergencyModel({
    required this.id,
    required this.patientName,
    required this.level,
    this.alertTime,
  });

  factory EmergencyModel.fromJson(Map<String, dynamic> json) => EmergencyModel(
        id: json['id'] ?? 0,
        patientName: json['patientName'] ?? '',
        level: json['level'] ?? 'NORMAL',
        alertTime: json['alertTime']?.toString(),
      );
}
