class UserModel {
  final int id;
  final String fullName;
  final String email;
  final String role;
  final bool requirePasswordReset;
  final String? token; // JWT Bearer token — present after login

  UserModel({
    required this.id,
    required this.fullName,
    required this.email,
    required this.role,
    this.requirePasswordReset = false,
    this.token,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) => UserModel(
        id: json['userId'] ?? json['id'] ?? 0,
        fullName: json['fullName'] ?? '',
        email: json['email'] ?? '',
        role: json['role'] ?? '',
        requirePasswordReset: json['requirePasswordReset'] ?? false,
        token: json['token'],
      );
}
