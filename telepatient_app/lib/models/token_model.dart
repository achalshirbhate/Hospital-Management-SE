class TokenModel {
  final int id;
  final String type;
  final String status;
  final String? scheduledTime;
  final String? requestedAt;
  final String? approvedAt;
  final String? expiresAt;
  final bool isFrozen;
  final int? patientId;
  final String? patientName;
  final int? mdId;

  TokenModel({
    required this.id,
    required this.type,
    required this.status,
    this.scheduledTime,
    this.requestedAt,
    this.approvedAt,
    this.expiresAt,
    this.isFrozen = false,
    this.patientId,
    this.patientName,
    this.mdId,
  });

  factory TokenModel.fromJson(Map<String, dynamic> json) => TokenModel(
        id: json['id'] ?? 0,
        type: json['type'] ?? '',
        status: json['status'] ?? '',
        scheduledTime: json['scheduledTime'],
        requestedAt: json['requestedAt']?.toString(),
        approvedAt: json['approvedAt']?.toString(),
        expiresAt: json['expiresAt']?.toString(),
        isFrozen: json['frozen'] ?? json['isFrozen'] ?? false,
        patientId: json['patient']?['id'],
        patientName: json['patient']?['fullName'],
        mdId: json['mainDoctor']?['id'],
      );

  bool get isApproved  => status == 'APPROVED';
  bool get isCompleted => status == 'COMPLETED';
  bool get isRejected  => status == 'REJECTED';
}
