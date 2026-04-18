class LaunchpadModel {
  final int id;
  final String title;
  final String description;
  final String domain;
  final String contactInfo;
  final String submittedBy;
  final DateTime submittedAt;

  LaunchpadModel({
    required this.id,
    required this.title,
    required this.description,
    required this.domain,
    required this.contactInfo,
    required this.submittedBy,
    required this.submittedAt,
  });

  factory LaunchpadModel.fromJson(Map<String, dynamic> json) {
    return LaunchpadModel(
      id: json['id'] as int,
      title: json['title'] as String,
      description: json['description'] as String,
      domain: json['domain'] as String? ?? '',
      contactInfo: json['contactInfo'] as String? ?? '',
      submittedBy: json['submittedBy'] as String,
      submittedAt: DateTime.parse(json['submittedAt'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'domain': domain,
      'contactInfo': contactInfo,
      'submittedBy': submittedBy,
      'submittedAt': submittedAt.toIso8601String(),
    };
  }
}
