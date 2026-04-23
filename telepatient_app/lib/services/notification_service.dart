import 'package:dio/dio.dart';
import 'api_client.dart';
import '../models/notification_model.dart';

class NotificationService {
  final Dio _dio = ApiClient().dio;

  Future<List<NotificationModel>> getNotifications(int userId) async {
    final res = await _dio.get('/api/notifications/$userId');
    return (res.data as List)
        .map((e) => NotificationModel.fromJson(e))
        .toList();
  }

  Future<int> getUnreadCount(int userId) async {
    final res = await _dio.get('/api/notifications/$userId/unread-count');
    return res.data as int;
  }

  Future<void> markRead(int notifId) async {
    await _dio.put('/api/notifications/$notifId/read');
  }

  Future<void> markAllRead(int userId) async {
    await _dio.put('/api/notifications/$userId/read-all');
  }

  Future<void> deleteNotification(int notifId) async {
    await _dio.delete('/api/notifications/$notifId');
  }
}
