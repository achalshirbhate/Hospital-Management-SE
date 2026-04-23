import 'package:flutter_test/flutter_test.dart';
import 'package:telepatient_app/models/user_model.dart';

void main() {
  group('UserModel.fromJson', () {
    test('parses login response with token', () {
      final json = {
        'userId': 1,
        'fullName': 'Jane Doe',
        'email': 'jane@example.com',
        'role': 'PATIENT',
        'requirePasswordReset': false,
        'token': 'eyJhbGciOiJIUzI1NiJ9.test.token',
      };

      final user = UserModel.fromJson(json);

      expect(user.id, 1);
      expect(user.fullName, 'Jane Doe');
      expect(user.email, 'jane@example.com');
      expect(user.role, 'PATIENT');
      expect(user.requirePasswordReset, false);
      expect(user.token, 'eyJhbGciOiJIUzI1NiJ9.test.token');
    });

    test('parses register response without token', () {
      final json = {
        'userId': 2,
        'fullName': 'John Smith',
        'email': 'john@example.com',
        'role': 'PATIENT',
      };

      final user = UserModel.fromJson(json);

      expect(user.id, 2);
      expect(user.token, isNull);
      expect(user.requirePasswordReset, false);
    });

    test('sets requirePasswordReset=true for temp password login', () {
      final json = {
        'userId': 3,
        'fullName': 'Dr. Smith',
        'email': 'doctor@123',
        'role': 'DOCTOR',
        'requirePasswordReset': true,
        'token': 'some.jwt.token',
      };

      final user = UserModel.fromJson(json);

      expect(user.requirePasswordReset, true);
      expect(user.role, 'DOCTOR');
    });

    test('handles id field as alternative to userId', () {
      final json = {
        'id': 99,
        'fullName': 'Admin',
        'email': 'admin@123',
        'role': 'MAIN_DOCTOR',
      };

      final user = UserModel.fromJson(json);
      expect(user.id, 99);
    });
  });
}
