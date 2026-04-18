class ChatMessageModel {
  final int id;
  final int tokenId;
  final int senderId;
  final String senderName;
  final String message;
  final DateTime timestamp;
  final bool isReport;

  ChatMessageModel({
    required this.id,
    required this.tokenId,
    required this.senderId,
    required this.senderName,
    required this.message,
    required this.timestamp,
    this.isReport = false,
  });

  factory ChatMessageModel.fromJson(Map<String, dynamic> json) {
    return ChatMessageModel(
      id: json['id'] as int,
      tokenId: json['tokenId'] as int,
      senderId: json['senderId'] as int,
      senderName: json['senderName'] as String,
      message: json['message'] as String,
      timestamp: DateTime.parse(json['timestamp'] as String),
      isReport: json['isReport'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'tokenId': tokenId,
      'senderId': senderId,
      'senderName': senderName,
      'message': message,
      'timestamp': timestamp.toIso8601String(),
      'isReport': isReport,
    };
  }

  bool isMine(int currentUserId) => senderId == currentUserId;
}
