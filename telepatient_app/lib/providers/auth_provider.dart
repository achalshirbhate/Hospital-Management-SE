import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user_model.dart';
import '../services/auth_service.dart';
import '../services/secure_storage_service.dart';
import '../utils/constants.dart';

/// Manages authentication state for the entire app.
///
/// Token storage strategy:
///   • JWT token  → flutter_secure_storage (AES-256 / Keychain)
///   • userId, role, name, email → SharedPreferences (non-sensitive metadata
///     used to restore the session UI without a network call)
class AuthProvider extends ChangeNotifier {
  final AuthService          _authService;
  final SecureTokenStorage   _tokenStore;

  /// Default constructor — uses real service instances.
  AuthProvider()
      : _authService = AuthService(),
        _tokenStore  = SecureTokenStorage();

  /// Test constructor — inject mock services.
  /// Uses a real SecureTokenStorage but tests should not rely on persistence.
  AuthProvider.withService(AuthService authService)
      : _authService = authService,
        _tokenStore  = SecureTokenStorage();

  UserModel? _user;
  bool       _loading = false;
  String?    _error;

  // ─── Public getters ───────────────────────────────────────────────────────

  UserModel? get user      => _user;
  bool       get loading   => _loading;
  String?    get error     => _error;
  bool       get isLoggedIn => _user != null;

  int    get userId   => _user?.id ?? 0;
  String get role     => _user?.role ?? '';
  String get fullName => _user?.fullName ?? '';
  String get email    => _user?.email ?? '';

  // ─── Session persistence ──────────────────────────────────────────────────

  /// Called once at app start (main.dart).
  /// Restores the user object from SharedPreferences so the UI can render
  /// immediately without a network call.  The JWT itself is read from secure
  /// storage by the Dio interceptor on the first real API call.
  Future<void> restoreSession() async {
    final prefs = await SharedPreferences.getInstance();
    final id   = prefs.getInt(AppConstants.prefUserId);
    final role = prefs.getString(AppConstants.prefRole);
    final name = prefs.getString(AppConstants.prefFullName);
    final mail = prefs.getString(AppConstants.prefEmail);

    // Also verify the token still exists in secure storage.
    // If it was wiped (e.g. app reinstall on Android) treat as logged out.
    final token = await _tokenStore.readToken();

    if (id != null && role != null && token != null) {
      _user = UserModel(
        id: id,
        fullName: name ?? '',
        email: mail ?? '',
        role: role,
      );
      notifyListeners();
    }
  }

  Future<void> _persistSession(UserModel u) async {
    try {
      // 1. Store JWT securely
      if (u.token != null && u.token!.isNotEmpty) {
        await _tokenStore.saveToken(u.token!);
      }

      // 2. Store non-sensitive metadata in SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt(AppConstants.prefUserId, u.id);
      await prefs.setString(AppConstants.prefRole, u.role);
      await prefs.setString(AppConstants.prefFullName, u.fullName);
      await prefs.setString(AppConstants.prefEmail, u.email);
    } catch (_) {
      // Silently ignore persistence errors in test environments
      // where platform channels are unavailable.
    }
  }

  // ─── Login ────────────────────────────────────────────────────────────────

  Future<UserModel?> login(String email, String password) async {
    _setLoading(true);
    try {
      final u = await _authService.login(email: email, password: password);
      _user = u;
      await _persistSession(u);
      notifyListeners();
      return u;
    } on Exception catch (e) {
      _error = _extractMessage(e);
      notifyListeners();
      return null;
    } finally {
      _setLoading(false);
    }
  }

  // ─── Register ─────────────────────────────────────────────────────────────

  Future<bool> register(String fullName, String email, String password) async {
    _setLoading(true);
    try {
      await _authService.register(
          fullName: fullName, email: email, password: password);
      return true;
    } on Exception catch (e) {
      _error = _extractMessage(e);
      notifyListeners();
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // ─── Password reset ───────────────────────────────────────────────────────

  Future<bool> forgotPassword(String email) async {
    _setLoading(true);
    try {
      await _authService.forgotPassword(email);
      return true;
    } on Exception catch (e) {
      _error = _extractMessage(e);
      notifyListeners();
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> resetPasswordOtp(
      String email, String otp, String newPassword) async {
    _setLoading(true);
    try {
      await _authService.resetPasswordOtp(
          email: email, otp: otp, newPassword: newPassword);
      return true;
    } on Exception catch (e) {
      _error = _extractMessage(e);
      notifyListeners();
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> resetPasswordTemp(
      String email, String currentPassword, String newPassword) async {
    _setLoading(true);
    try {
      await _authService.resetPasswordTemp(
          email: email,
          currentPassword: currentPassword,
          newPassword: newPassword);
      // Rebuild user model without the requirePasswordReset flag.
      // The existing token stays valid — no need to re-login.
      if (_user != null) {
        _user = UserModel(
          id: _user!.id,
          fullName: _user!.fullName,
          email: _user!.email,
          role: _user!.role,
          requirePasswordReset: false,
          token: _user!.token,
        );
        // Re-persist (token unchanged, just clears the reset flag in memory)
        await _persistSession(_user!);
      }
      return true;
    } on Exception catch (e) {
      _error = _extractMessage(e);
      notifyListeners();
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // ─── Logout ───────────────────────────────────────────────────────────────

  /// Clears all stored credentials and resets in-memory state.
  /// Called both by the user tapping "Logout" and by the 401 interceptor.
  Future<void> logout() async {
    // Wipe encrypted token
    await _tokenStore.deleteAll();

    // Wipe non-sensitive metadata
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();

    _user  = null;
    _error = null;
    notifyListeners();
  }

  // ─── Helpers ──────────────────────────────────────────────────────────────

  void _setLoading(bool value) {
    _loading = value;
    notifyListeners();
  }

  String _extractMessage(Exception e) =>
      e.toString().replaceAll('Exception: ', '').trim();
}
