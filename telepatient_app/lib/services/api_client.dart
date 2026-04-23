import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import '../utils/constants.dart';
import '../utils/navigator_service.dart';
import 'secure_storage_service.dart';

// Callback type — AuthProvider.logout() matches this signature.
typedef LogoutCallback = Future<void> Function();

/// Singleton Dio client.
///
/// Interceptor chain (in order):
///   1. _AuthInterceptor   — injects JWT Bearer token from secure storage.
///   2. _ErrorInterceptor  — handles 401 (auto-logout + redirect) and
///                           normalises all error messages.
///   3. LogInterceptor     — dev logging (remove in production).
class ApiClient {
  static final ApiClient _instance = ApiClient._internal();
  factory ApiClient() => _instance;

  late final Dio dio;

  /// Registered once from main.dart after AuthProvider is ready.
  /// Called by the 401 handler before navigating to login.
  LogoutCallback? _onUnauthorized;

  void setLogoutCallback(LogoutCallback cb) => _onUnauthorized = cb;

  ApiClient._internal() {
    dio = Dio(BaseOptions(
      baseUrl: AppConstants.baseUrl,
      connectTimeout: const Duration(seconds: 15),
      receiveTimeout: const Duration(seconds: 15),
      headers: {'Content-Type': 'application/json'},
    ));

    dio.interceptors.addAll([
      _AuthInterceptor(),
      _ErrorInterceptor(this),
      LogInterceptor(
        requestBody: true,
        responseBody: true,
        error: true,
        logPrint: (o) => debugPrint(o.toString()),
      ),
    ]);
  }
}

// ─── 1. Auth Interceptor ──────────────────────────────────────────────────────

class _AuthInterceptor extends Interceptor {
  final _storage = SecureTokenStorage();

  @override
  Future<void> onRequest(
      RequestOptions options, RequestInterceptorHandler handler) async {
    final token = await _storage.readToken();
    if (token != null && token.isNotEmpty) {
      options.headers['Authorization'] = 'Bearer $token';
    }
    handler.next(options);
  }
}

// ─── 2. Error Interceptor ─────────────────────────────────────────────────────

class _ErrorInterceptor extends Interceptor {
  final ApiClient _client;
  _ErrorInterceptor(this._client);

  @override
  Future<void> onError(
      DioException err, ErrorInterceptorHandler handler) async {
    final status = err.response?.statusCode;

    // ── 401: token expired / invalid ─────────────────────────────────────────
    if (status == 401) {
      // 1. Wipe the stored token
      await SecureTokenStorage().deleteToken();

      // 2. Clear AuthProvider state (if callback is registered)
      await _client._onUnauthorized?.call();

      // 3. Navigate to login, clearing the entire navigation stack.
      //    We import LoginScreen here (at call-time) to avoid a
      //    compile-time circular dependency.
      _navigateToLogin();

      handler.reject(DioException(
        requestOptions: err.requestOptions,
        response: err.response,
        message: 'Session expired. Please log in again.',
        type: DioExceptionType.badResponse,
      ));
      return;
    }

    // ── All other errors: normalise the message ───────────────────────────────
    handler.reject(DioException(
      requestOptions: err.requestOptions,
      response: err.response,
      message: _extractMessage(err),
      type: err.type,
    ));
  }

  void _navigateToLogin() {
    // Deferred import — resolved at runtime, not at compile time.
    // This is the standard Flutter pattern for navigating from non-widget code.
    final context = NavigatorService.navigatorKey.currentContext;
    if (context == null) return;

    Navigator.of(context).pushNamedAndRemoveUntil(
      AppRoutes.login,
      (_) => false,
    );
  }

  String _extractMessage(DioException err) {
    final data = err.response?.data;
    if (data is String && data.isNotEmpty) return data;
    if (data is Map) {
      return data['error']?.toString() ??
          data['message']?.toString() ??
          'Request failed (${err.response?.statusCode})';
    }
    switch (err.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.receiveTimeout:
        return 'Connection timed out. Check your network.';
      case DioExceptionType.connectionError:
        return 'Cannot reach server. Is the backend running?';
      default:
        return err.message ?? 'An unexpected error occurred.';
    }
  }
}
