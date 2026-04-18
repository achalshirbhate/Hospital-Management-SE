class ReportModel {
  final int id;
  final String reportName;
  final String reportType; // PDF, IMAGE, TEXT
  final String fileUrl;
  final String? notes;
  final String doctorName;
  final DateTime uploadedAt;

  ReportModel({
    required this.id,
    required this.reportName,
    required this.reportType,
    required this.fileUrl,
    this.notes,
    required this.doctorName,
    required this.uploadedAt,
  });

  factory ReportModel.fromJson(Map<String, dynamic> j) => ReportModel(
    id:          j['id'] ?? 0,
    reportName:  j['reportName'] ?? '',
    reportType:  j['reportType'] ?? 'PDF',
    fileUrl:     j['fileUrl'] ?? '',
    notes:       j['notes'],
    doctorName:  j['doctorName'] ?? '',
    uploadedAt:  DateTime.parse(j['uploadedAt']),
  );
}
