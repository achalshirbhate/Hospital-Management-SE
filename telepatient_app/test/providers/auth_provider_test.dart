import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:telepatient_app/models/user_model.dart';
import 'package:telepatient_app/providers/auth_provider.dart';

import 'auth_provider_test.mocks.dart';

/// These tests verify AuthProvider state management logic only.
/// They do NOT test persistence (SecureTokenStorage / SharedPreferences)
/// because those require platform channels unavailable in unit tests.
///
/// To run: flutter test test/providers/auth_provider_test.dart
void main() {
  late AuthProvider authProvider;
  late MockAuthService mockAuthService;

  setUp(() {
    TestWidgetsFlutterBinding.ensureInitialized();
    mockAuthService = MockAuthService();
    authProvider = AuthProvider.withService(mockAuthService);
  });

  // ─── Initial state ─────────────────────────────────────────────────────────

  group('initial state', () {
    test('isLoggedIn is false before login', () {
      expect(authProvider.isLoggedIn, false);
    });

    test('userId returns 0 before login', () {
      expect(authProvider.userId, 0);
    });

    test('role returns empty string before login', () {
      expect(authProvider.role, '');
    });

    test('loading is false initially', () {
      expect(authProvider.loading, false);
    });

    test('error is null initially', () {
      expect(authProvider.error, isNull);
    });
  });

  // ─── Login ─────────────────────────────────────────────────────────────────

  group('login()', () {
    test('returns UserModel and sets isLoggedIn on success', () async {
      final user = UserModel(
        id: 1,
        fullName: 'Jane Doe',
        email: 'jane@example.com',
        role: 'PATIENT',
        token: 'eyJ.test.token',
      );

      when(mockAuthService.login(
        email: 'jane@example.com',
        password: 'secret123',
      )).thenAnswer((_) async => user);

      final result = await authProvider.login('jane@example.com', 'secret123');

      expect(result, isNotNull);
      expect(result!.role, 'PATIENT');
      expect(authProvider.isLoggedIn, true);
      expect(authProvider.userId, 1);
      expect(authProvider.role, 'PATIENT');
      expect(authProvider.fullName, 'Jane Doe');
      expect(authProvider.loading, false);
      expect(authProvider.error, isNull);
    });

    test('returns null and sets error on failure', () async {
      when(mockAuthService.login(
        email: 'bad@example.com',
        password: 'wrong',
      )).thenThrow(Exception('Invalid email or password'));

      final result = await authProvider.login('bad@example.com', 'wrong');

      expect(result, isNull);
      expect(authProvider.isLoggedIn, false);
      expect(authProvider.error, contains('Invalid email or password'));
      expect(authProvider.loading, false);
    });

    test('sets requirePasswordReset flag for temp password', () async {
      final user = UserModel(
        id: 2,
        fullName: 'Dr. Smith',
        email: 'doctor@123',
        role: 'DOCTOR',
        token: 'some.token',
        requirePasswordReset: true,
      );

      when(mockAuthService.login(
        email: 'doctor@123',
        password: 'temp@123',
      )).thenAnswer((_) async => user);

      final result = await authProvider.login('doctor@123', 'temp@123');

      expect(result!.requirePasswordReset, true);
      expect(authProvider.role, 'DOCTOR');
    });
  });

  // ─── Register ──────────────────────────────────────────────────────────────

  group('register()', () {
    test('returns true on success', () async {
      final user = UserModel(
        id: 3,
        fullName: 'New User',
        email: 'new@example.com',
        role: 'PATIENT',
      );

      when(mockAuthService.register(
        fullName: 'New User',
        email: 'new@example.com',
        password: 'pass123',
      )).thenAnswer((_) async => user);

      final ok = await authProvider.register('New User', 'new@example.com', 'pass123');

      expect(ok, true);
      expect(authProvider.error, isNull);
    });

    test('returns false and sets error on failure', () async {
      when(mockAuthService.register(
        fullName: 'Jane',
        email: 'jane@example.com',
        password: 'pass',
      )).thenThrow(Exception('Email already exists'));

      final ok = await authProvider.register('Jane', 'jane@example.com', 'pass');

      expect(ok, false);
      expect(authProvider.error, contains('Email already exists'));
    });
  });

  // ─── Forgot password ───────────────────────────────────────────────────────

  group('forgotPassword()', () {
    test('returns true when service succeeds', () async {
      when(mockAuthService.forgotPassword('jane@example.com'))
          .thenAnswer((_) async {});

      final ok = await authProvider.forgotPassword('jane@example.com');
      expect(ok, true);
    });

    test('returns false and sets error when service throws', () async {
      when(mockAuthService.forgotPassword('ghost@example.com'))
          .thenThrow(Exception('No account found'));

      final ok = await authProvider.forgotPassword('ghost@example.com');
      expect(ok, false);
      expect(authProvider.error, contains('No account found'));
    });
  });
}
