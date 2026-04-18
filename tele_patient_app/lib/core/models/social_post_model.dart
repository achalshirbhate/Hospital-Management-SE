class SocialPostModel {
  final int id;
  final String content;
  final String authorName;
  final String authorRole;
  final DateTime postedAt;
  final int likes;
  final bool isLikedByMe;

  SocialPostModel({
    required this.id,
    required this.content,
    required this.authorName,
    required this.authorRole,
    required this.postedAt,
    this.likes = 0,
    this.isLikedByMe = false,
  });

  factory SocialPostModel.fromJson(Map<String, dynamic> json) {
    return SocialPostModel(
      id: json['id'] as int,
      content: json['content'] as String,
      authorName: json['authorName'] as String,
      authorRole: json['authorRole'] as String,
      postedAt: DateTime.parse(json['postedAt'] as String),
      likes: json['likes'] as int? ?? 0,
      isLikedByMe: json['isLikedByMe'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'content': content,
      'authorName': authorName,
      'authorRole': authorRole,
      'postedAt': postedAt.toIso8601String(),
      'likes': likes,
      'isLikedByMe': isLikedByMe,
    };
  }

  SocialPostModel copyWith({
    int? likes,
    bool? isLikedByMe,
  }) {
    return SocialPostModel(
      id: id,
      content: content,
      authorName: authorName,
      authorRole: authorRole,
      postedAt: postedAt,
      likes: likes ?? this.likes,
      isLikedByMe: isLikedByMe ?? this.isLikedByMe,
    );
  }

  String get roleIcon {
    switch (authorRole) {
      case 'MAIN_DOCTOR':
        return '👨‍⚕️';
      case 'DOCTOR':
        return '🩺';
      case 'PATIENT':
        return '🙋';
      default:
        return '👤';
    }
  }

  String get roleLabel {
    switch (authorRole) {
      case 'MAIN_DOCTOR':
        return 'Main Doctor';
      case 'DOCTOR':
        return 'Doctor';
      case 'PATIENT':
        return 'Patient';
      default:
        return 'User';
    }
  }
}
