class SocialPostModel {
  final int id;
  final String title;
  final String content;
  final String? mediaUrl;
  final String? postedAt;
  final int authorId;
  final String authorName;

  SocialPostModel({
    required this.id,
    required this.title,
    required this.content,
    this.mediaUrl,
    this.postedAt,
    required this.authorId,
    required this.authorName,
  });

  factory SocialPostModel.fromJson(Map<String, dynamic> json) =>
      SocialPostModel(
        id: json['id'] ?? 0,
        title: json['title'] ?? '',
        content: json['content'] ?? '',
        mediaUrl: json['mediaUrl'],
        postedAt: json['postedAt']?.toString(),
        authorId: json['author']?['id'] ?? 0,
        authorName: json['author']?['fullName'] ?? '',
      );
}
