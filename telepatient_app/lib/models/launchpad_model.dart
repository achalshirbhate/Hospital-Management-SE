class LaunchpadModel {
  final int id;
  final int submitterId;
  final String submitterEmail;
  final String ideaTitle;
  final String description;
  final String domain;
  final String contactInfo;
  final String? submittedAt;
  final String? response;

  LaunchpadModel({
    required this.id,
    required this.submitterId,
    required this.submitterEmail,
    required this.ideaTitle,
    required this.description,
    required this.domain,
    required this.contactInfo,
    this.submittedAt,
    this.response,
  });

  factory LaunchpadModel.fromJson(Map<String, dynamic> json) => LaunchpadModel(
        id: json['id'] ?? 0,
        submitterId: json['submitterId'] ?? 0,
        submitterEmail: json['submitterEmail'] ?? '',
        ideaTitle: json['ideaTitle'] ?? '',
        description: json['description'] ?? '',
        domain: json['domain'] ?? '',
        contactInfo: json['contactInfo'] ?? '',
        submittedAt: json['submittedAt']?.toString(),
        response: json['response'],
      );
}
