class NotificationModel {
  final int id;
  final String message;
  final String type;
  final String priority;
  final bool isRead;
  final String? createdAt;

  NotificationModel({
    required this.id,
    required this.message,
    required this.type,
    required this.priority,
    required this.isRead,
    this.createdAt,
  });

  factory NotificationModel.fromJson(Map<String, dynamic> json) =>
      NotificationModel(
        id: json['id'] ?? 0,
        message: json['message'] ?? '',
        type: json['type'] ?? 'GENERAL',
        priority: json['priority'] ?? 'LOW',
        isRead: json['read'] ?? json['isRead'] ?? false,
        createdAt: json['createdAt']?.toString(),
      );
}
