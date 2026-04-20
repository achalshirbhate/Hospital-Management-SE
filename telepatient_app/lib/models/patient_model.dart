class PatientModel {
  final int id;
  final String fullName;
  final String? historySummary;
  final int? age;
  final String? lastConsultation;
  final String? specialty;

  PatientModel({
    required this.id,
    required this.fullName,
    this.historySummary,
    this.age,
    this.lastConsultation,
    this.specialty,
  });

  factory PatientModel.fromJson(Map<String, dynamic> json) => PatientModel(
        id: json['id'] ?? 0,
        fullName: json['fullName'] ?? '',
        historySummary: json['historySummary'],
        age: json['age'],
        lastConsultation: json['lastConsultation']?.toString(),
        specialty: json['specialty'],
      );
}
