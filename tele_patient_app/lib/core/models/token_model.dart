class TokenModel {
  final int id;
  final String type;       // CHAT, VIDEO
  final String status;     // REQUESTED, APPROVED, COMPLETED
  final String patientName;
  final DateTime? scheduledTime;

  TokenModel({
    required this.id,
    required this.type,
    required this.status,
    required this.patientName,
    this.scheduledTime,
  });

  factory TokenModel.fromJson(Map<String, dynamic> j) => TokenModel(
    id:            j['id'] ?? 0,
    type:          j['type'] ?? '',
    status:        j['status'] ?? '',
    patientName:   j['patientName'] ?? '',
    scheduledTime: j['scheduledTime'] != null
        ? DateTime.parse(j['scheduledTime'])
        : null,
  );
}
