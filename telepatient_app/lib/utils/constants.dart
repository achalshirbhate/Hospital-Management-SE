// ─── App-wide constants ───────────────────────────────────────────────────────

class AppConstants {
  // Automatically picks the right URL based on platform
  // ✅ Production URL — works on phone, web, anywhere
  static const String _renderUrl = 'https://telepatient-api.onrender.com';

  static String get baseUrl => _renderUrl;

  static String get wsVideoUrl => 'wss://telepatient-api.onrender.com/ws/video';

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
