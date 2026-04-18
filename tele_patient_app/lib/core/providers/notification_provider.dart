import 'package:flutter/foundation.dart';
import 'dart:async';
import '../models/notification_model.dart';
import '../services/api_service.dart';
import '../services/notification_service.dart';
import '../services/websocket_service.dart';

class NotificationProvider with ChangeNotifier {
  final List<NotificationModel> _notifications = [];
  StreamSubscription? _wsSubscription;
  bool _isInitialized = false;

  List<NotificationModel> get notifications => _notifications;
  int get unreadCount => _notifications.where((n) => !n.isRead).length;
  bool get hasUnread => unreadCount > 0;

  /// Initialize notification provider
  Future<void> initialize(int userId) async {
    if (_isInitialized) return;

    await NotificationService.instance.initialize();
    await NotificationService.instance.requestPermissions();
    await loadNotifications(userId);
    _listenToWebSocket();
    
    _isInitialized = true;
  }

  /// Load notifications from API
  Future<void> loadNotifications(int userId) async {
    try {
      final data = await ApiService.getNotifications(userId);
      _notifications.clear();
      _notifications.addAll(
        data.map((e) => NotificationModel.fromJson(e as Map<String, dynamic>)),
      );
      notifyListeners();
    } catch (e) {
      debugPrint('❌ Error loading notifications: $e');
    }
  }

  /// Listen to WebSocket for real-time notifications
  void _listenToWebSocket() {
    _wsSubscription = WebSocketService.instance.messages.listen((message) {
      final type = message['type'] as String?;

      if (type == 'notification') {
        final notification = NotificationModel.fromJson(message);
        _addNotification(notification);
        
        // Show local notification
        NotificationService.instance.showNotification(
          id: notification.id,
          title: notification.type,
          body: notification.message,
          payload: notification.id.toString(),
        );
      } else if (type == 'emergency') {
        final notification = NotificationModel.fromJson(message);
        _addNotification(notification);
        
        // Show emergency notification
        NotificationService.instance.showEmergencyNotification(
          id: notification.id,
          patientName: message['patientName'] as String? ?? 'Unknown',
          level: message['level'] as String? ?? 'URGENT',
        );
      }
    });
  }

  /// Add notification to list
  void _addNotification(NotificationModel notification) {
    _notifications.insert(0, notification);
    notifyListeners();
  }

  /// Mark notification as read
  Future<void> markAsRead(int notificationId) async {
    try {
      await ApiService.markNotificationRead(notificationId);
      
      final index = _notifications.indexWhere((n) => n.id == notificationId);
      if (index != -1) {
        _notifications[index] = _notifications[index].copyWith(isRead: true);
        notifyListeners();
      }
    } catch (e) {
      debugPrint('❌ Error marking notification as read: $e');
    }
  }

  /// Mark all notifications as read
  Future<void> markAllAsRead(int userId) async {
    try {
      await ApiService.markAllNotificationsRead(userId);
      
      for (var i = 0; i < _notifications.length; i++) {
        _notifications[i] = _notifications[i].copyWith(isRead: true);
      }
      notifyListeners();
    } catch (e) {
      debugPrint('❌ Error marking all notifications as read: $e');
    }
  }

  /// Clear all notifications
  void clearAll() {
    _notifications.clear();
    notifyListeners();
  }

  /// Dispose resources
  @override
  void dispose() {
    _wsSubscription?.cancel();
    super.dispose();
  }
}
