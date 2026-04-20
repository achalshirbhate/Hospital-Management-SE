import 'package:flutter_test/flutter_test.dart';
import 'package:telepatient_app/models/token_model.dart';

void main() {
  group('TokenModel.fromJson', () {
    test('parses an APPROVED CHAT token', () {
      final json = {
        'id': 10,
        'type': 'CHAT',
        'status': 'APPROVED',
        'scheduledTime': '2:00 PM',
        'requestedAt': '2025-01-15T09:00:00',
        'approvedAt': '2025-01-15T09:30:00',
        'expiresAt': '2025-01-15T10:30:00',
        'frozen': false,
        'patient': {'id': 1, 'fullName': 'Jane Doe'},
        'mainDoctor': {'id': 99},
      };

      final token = TokenModel.fromJson(json);

      expect(token.id, 10);
      expect(token.type, 'CHAT');
      expect(token.status, 'APPROVED');
      expect(token.scheduledTime, '2:00 PM');
      expect(token.isFrozen, false);
      expect(token.patientId, 1);
      expect(token.patientName, 'Jane Doe');
      expect(token.mdId, 99);
    });

    test('isApproved returns true only for APPROVED status', () {
      final approved = TokenModel.fromJson({'id': 1, 'type': 'CHAT', 'status': 'APPROVED'});
      final requested = TokenModel.fromJson({'id': 2, 'type': 'CHAT', 'status': 'REQUESTED'});
      final rejected = TokenModel.fromJson({'id': 3, 'type': 'CHAT', 'status': 'REJECTED'});
      final completed = TokenModel.fromJson({'id': 4, 'type': 'CHAT', 'status': 'COMPLETED'});

      expect(approved.isApproved, true);
      expect(requested.isApproved, false);
      expect(rejected.isApproved, false);
      expect(completed.isApproved, false);
    });

    test('isCompleted returns true only for COMPLETED status', () {
      final completed = TokenModel.fromJson({'id': 1, 'type': 'VIDEO', 'status': 'COMPLETED'});
      final approved  = TokenModel.fromJson({'id': 2, 'type': 'VIDEO', 'status': 'APPROVED'});

      expect(completed.isCompleted, true);
      expect(approved.isCompleted, false);
    });

    test('handles isFrozen field name variant', () {
      final json = {'id': 1, 'type': 'CHAT', 'status': 'APPROVED', 'isFrozen': true};
      final token = TokenModel.fromJson(json);
      expect(token.isFrozen, true);
    });

    test('handles missing optional fields gracefully', () {
      final json = {'id': 5, 'type': 'VIDEO', 'status': 'REQUESTED'};
      final token = TokenModel.fromJson(json);

      expect(token.scheduledTime, isNull);
      expect(token.patientId, isNull);
      expect(token.isFrozen, false);
    });
  });
}
