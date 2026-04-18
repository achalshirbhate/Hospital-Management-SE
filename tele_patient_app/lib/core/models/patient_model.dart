class PatientModel {
  final int id;
  final String fullName;
  final String historySummary;
  final int? age;
  final DateTime? lastConsultation;

  PatientModel({
    required this.id,
    required this.fullName,
    required this.historySummary,
    this.age,
    this.lastConsultation,
  });

  factory PatientModel.fromJson(Map<String, dynamic> j) => PatientModel(
    id:               j['id'] ?? 0,
    fullName:         j['fullName'] ?? '',
    historySummary:   j['historySummary'] ?? '',
    age:              j['age'],
    lastConsultation: j['lastConsultation'] != null
        ? DateTime.parse(j['lastConsultation'])
        : null,
  );
}
