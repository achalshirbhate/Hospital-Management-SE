class ReportModel {
  final int id;
  final String reportName;
  final String reportType;
  final String fileUrl;
  final String? notes;
  final String doctorName;
  final int patientId;
  final String? uploadedAt;

  ReportModel({
    required this.id,
    required this.reportName,
    required this.reportType,
    required this.fileUrl,
    this.notes,
    required this.doctorName,
    required this.patientId,
    this.uploadedAt,
  });

  factory ReportModel.fromJson(Map<String, dynamic> json) => ReportModel(
        id: json['id'] ?? 0,
        reportName: json['reportName'] ?? '',
        reportType: json['reportType'] ?? 'PDF',
        fileUrl: json['fileUrl'] ?? '',
        notes: json['notes'],
        doctorName: json['doctorName'] ?? '',
        patientId: json['patientId'] ?? 0,
        uploadedAt: json['uploadedAt']?.toString(),
      );
}
