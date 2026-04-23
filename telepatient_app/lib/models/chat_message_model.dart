class ChatMessageModel {
  final int id;
  final int senderId;
  final String senderName;
  final String message;
  final String? sentAt;

  ChatMessageModel({
    required this.id,
    required this.senderId,
    required this.senderName,
    required this.message,
    this.sentAt,
  });

  factory ChatMessageModel.fromJson(Map<String, dynamic> json) =>
      ChatMessageModel(
        id: json['id'] ?? 0,
        senderId: json['senderId'] ?? 0,
        senderName: json['senderName'] ?? '',
        message: json['message'] ?? '',
        sentAt: json['sentAt']?.toString(),
      );
}

class ChatSyncResponse {
  final bool isTerminated;
  final List<ChatMessageModel> messages;

  ChatSyncResponse({required this.isTerminated, required this.messages});

  factory ChatSyncResponse.fromJson(Map<String, dynamic> json) =>
      ChatSyncResponse(
        isTerminated: json['terminated'] ?? json['isTerminated'] ?? false,
        messages: (json['messages'] as List? ?? [])
            .map((m) => ChatMessageModel.fromJson(m))
            .toList(),
      );
}
