class ConsultationModel {
  final String doctorName;
  final String? date;
  final String? notes;
  final String? prescription;
  final String? reportsUrl;
  final String? referralInfo;

  ConsultationModel({
    required this.doctorName,
    this.date,
    this.notes,
    this.prescription,
    this.reportsUrl,
    this.referralInfo,
  });

  factory ConsultationModel.fromJson(Map<String, dynamic> json) =>
      ConsultationModel(
        doctorName: json['doctorName'] ?? 'Unknown',
        date: json['date']?.toString(),
        notes: json['notes'],
        prescription: json['prescription'],
        reportsUrl: json['reportsUrl'],
        referralInfo: json['referralInfo'],
      );
}
