class HistoryModel {
  final String doctorName;
  final DateTime date;
  final String notes;
  final String? prescription;
  final String? reportsUrl;
  final String? referralInfo;

  HistoryModel({
    required this.doctorName,
    required this.date,
    required this.notes,
    this.prescription,
    this.reportsUrl,
    this.referralInfo,
  });

  factory HistoryModel.fromJson(Map<String, dynamic> j) => HistoryModel(
    doctorName:   j['doctorName']  ?? '',
    date:         DateTime.parse(j['date']),
    notes:        j['notes']       ?? '',
    prescription: j['prescription'],
    reportsUrl:   j['reportsUrl'],
    referralInfo: j['referralInfo'],
  );
}
