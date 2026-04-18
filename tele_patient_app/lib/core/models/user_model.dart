class UserModel {
  final int userId;
  final String fullName;
  final String email;
  final String role; // PATIENT, DOCTOR, MAIN_DOCTOR
  final bool forcePasswordReset;

  UserModel({
    required this.userId,
    required this.fullName,
    required this.email,
    required this.role,
    this.forcePasswordReset = false,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) => UserModel(
    userId:   json['userId']   ?? json['id'] ?? 0,
    fullName: json['fullName'] ?? '',
    email:    json['email']    ?? '',
    role:     json['role']     ?? 'PATIENT',
    forcePasswordReset: json['forcePasswordReset'] ?? false,
  );

  bool get isMainDoctor => role == 'MAIN_DOCTOR';
  bool get isDoctor     => role == 'DOCTOR';
  bool get isPatient    => role == 'PATIENT';
}
