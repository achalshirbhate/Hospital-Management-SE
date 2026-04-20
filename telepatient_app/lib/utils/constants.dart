// ─── App-wide constants ───────────────────────────────────────────────────────
import 'package:flutter/foundation.dart' show kIsWeb;

class AppConstants {
  // Automatically picks the right URL based on platform
  static String get baseUrl {
    if (kIsWeb) {
      return 'http://localhost:8081'; // Running in browser (Chrome)
    }
    // TODO: Replace with your deployed backend URL
    // Example: return 'https://your-app.onrender.com';
    // For now, using local network (only works on same WiFi)
    return 'http://192.168.0.232:8081'; // Android physical device
    // return 'http://10.0.2.2:8081'; // Android emulator
  }

  static String get wsVideoUrl {
    if (kIsWeb) {
      return 'ws://localhost:8081/ws/video';
    }
    return 'ws://192.168.0.232:8081/ws/video';
  }

  // Temp password that forces a reset
  static const String tempPassword = 'temp@123';

  // Chat polling interval in seconds
  static const int chatPollSeconds = 3;

  // SharedPreferences keys (non-sensitive session metadata)
  static const String prefUserId   = 'userId';
  static const String prefRole     = 'role';
  static const String prefFullName = 'fullName';
  static const String prefEmail    = 'email';
  // NOTE: JWT token is stored in flutter_secure_storage, NOT SharedPreferences.
  // The prefToken key below is kept only for migration/legacy reference.
  static const String prefToken    = 'jwt_token';
}

// ─── Named routes ─────────────────────────────────────────────────────────────
class AppRoutes {
  static const String login   = '/login';
  static const String patient = '/patient';
  static const String doctor  = '/doctor';
  static const String md      = '/md';
}

// ─── Role constants ───────────────────────────────────────────────────────────
class AppRoles {
  static const String patient    = 'PATIENT';
  static const String doctor     = 'DOCTOR';
  static const String mainDoctor = 'MAIN_DOCTOR';
}

// ─── Token status ─────────────────────────────────────────────────────────────
class TokenStatus {
  static const String requested = 'REQUESTED';
  static const String approved  = 'APPROVED';
  static const String rejected  = 'REJECTED';
  static const String completed = 'COMPLETED';
}

// ─── Token types ──────────────────────────────────────────────────────────────
class TokenType {
  static const String chat  = 'CHAT';
  static const String video = 'VIDEO';
}

// ─── Emergency levels ─────────────────────────────────────────────────────────
class EmergencyLevel {
  static const String critical = 'CRITICAL';
  static const String urgent   = 'URGENT';
  static const String normal   = 'NORMAL';
}
