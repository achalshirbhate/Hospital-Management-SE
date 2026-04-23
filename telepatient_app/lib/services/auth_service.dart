import 'package:dio/dio.dart';
import 'api_client.dart';
import '../models/user_model.dart';

class AuthService {
  final Dio _dio = ApiClient().dio;

  /// Register a new patient account.
  Future<UserModel> register({
    required String fullName,
    required String email,
    required String password,
  }) async {
    final res = await _dio.post('/api/auth/register', data: {
      'fullName': fullName,
      'email': email,
      'password': password,
    });
    return UserModel.fromJson(res.data);
  }

  /// Login with email + password.
  Future<UserModel> login({
    required String email,
    required String password,
  }) async {
    final res = await _dio.post('/api/auth/login', data: {
      'email': email,
      'password': password,
    });
    return UserModel.fromJson(res.data);
  }

  /// Send OTP to email for password reset.
  Future<void> forgotPassword(String email) async {
    await _dio.post('/api/auth/forgot-password',
        queryParameters: {'email': email});
  }

  /// Reset password using OTP.
  Future<void> resetPasswordOtp({
    required String email,
    required String otp,
    required String newPassword,
  }) async {
    await _dio.post('/api/auth/reset-password-otp', queryParameters: {
      'email': email,
      'otp': otp,
      'newPassword': newPassword,
    });
  }

  /// Reset temp password (temp@123 → new password).
  Future<void> resetPasswordTemp({
    required String email,
    required String currentPassword,
    required String newPassword,
  }) async {
    await _dio.post('/api/auth/reset-password-temp', queryParameters: {
      'email': email,
      'currentPassword': currentPassword,
      'newPassword': newPassword,
    });
  }
}
