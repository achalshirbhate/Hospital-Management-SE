import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Wraps flutter_secure_storage for JWT token management.
///
/// On Android tokens are stored in EncryptedSharedPreferences (AES-256).
/// On iOS they are stored in the Keychain.
///
/// All other user metadata (userId, role, name) stays in SharedPreferences
/// because it is not sensitive — only the token needs encryption.
class SecureTokenStorage {
  // Singleton
  static final SecureTokenStorage _instance = SecureTokenStorage._internal();
  factory SecureTokenStorage() => _instance;
  SecureTokenStorage._internal();

  static const _storage = FlutterSecureStorage(
    aOptions: AndroidOptions(
      encryptedSharedPreferences: true, // AES-256 via Jetpack Security
    ),
    iOptions: IOSOptions(
      accessibility: KeychainAccessibility.first_unlock_this_device,
    ),
  );

  static const _keyToken = 'jwt_token';

  // ─── Write ────────────────────────────────────────────────────────────────

  Future<void> saveToken(String token) async {
    await _storage.write(key: _keyToken, value: token);
  }

  // ─── Read ─────────────────────────────────────────────────────────────────

  Future<String?> readToken() async {
    return _storage.read(key: _keyToken);
  }

  // ─── Delete ───────────────────────────────────────────────────────────────

  Future<void> deleteToken() async {
    await _storage.delete(key: _keyToken);
  }

  /// Wipe everything — called on logout.
  Future<void> deleteAll() async {
    await _storage.deleteAll();
  }
}
