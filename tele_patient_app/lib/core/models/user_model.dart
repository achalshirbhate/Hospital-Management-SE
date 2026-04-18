class UserModel {
  final int userId;
  final String fullName;
  final String email;
  final String role; // PATIENT, DOCTOR, MAIN_DOCTOR

  UserModel({
    required this.userId,
    required this.fullName,
    required this.email,
    required this.role,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) => UserModel(
    userId:   json['userId']   ?? json['id'] ?? 0,
    fullName: json['fullName'] ?? '',
    email:    json['email']    ?? '',
    role:     json['role']     ?? 'PATIENT',
  );

  bool get isMainDoctor => role == 'MAIN_DOCTOR';
  bool get isDoctor     => role == 'DOCTOR';
  bool get isPatient    => role == 'PATIENT';
}
