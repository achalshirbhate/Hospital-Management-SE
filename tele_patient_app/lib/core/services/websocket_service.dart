import 'dart:async';
import 'dart:convert';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:flutter/foundation.dart';

class WebSocketService {
  static WebSocketService? _instance;
  WebSocketChannel? _channel;
  final _messageController = StreamController<Map<String, dynamic>>.broadcast();
  bool _isConnected = false;

  WebSocketService._();

  static WebSocketService get instance {
    _instance ??= WebSocketService._();
    return _instance!;
  }

  Stream<Map<String, dynamic>> get messages => _messageController.stream;
  bool get isConnected => _isConnected;

  /// Connect to WebSocket server
  Future<void> connect(int userId, String token) async {
    try {
      // Close existing connection if any
      await disconnect();

      // WebSocket URL - adjust based on your backend
final wsUrl = 'ws://192.168.0.232:8081/ws?userId=$userId&token=$token';
      
      _channel = WebSocketChannel.connect(Uri.parse(wsUrl));
      _isConnected = true;

      // Listen to messages
      _channel!.stream.listen(
        (message) {
          try {
            final data = jsonDecode(message as String) as Map<String, dynamic>;
            _messageController.add(data);
            debugPrint('📩 WebSocket message received: $data');
          } catch (e) {
            debugPrint('❌ Error parsing WebSocket message: $e');
          }
        },
        onError: (error) {
          debugPrint('❌ WebSocket error: $error');
          _isConnected = false;
        },
        onDone: () {
          debugPrint('🔌 WebSocket connection closed');
          _isConnected = false;
        },
      );

      debugPrint('✅ WebSocket connected for user $userId');
    } catch (e) {
      debugPrint('❌ Failed to connect WebSocket: $e');
      _isConnected = false;
    }
  }

  /// Send message through WebSocket
  void send(Map<String, dynamic> message) {
    if (_isConnected && _channel != null) {
      _channel!.sink.add(jsonEncode(message));
      debugPrint('📤 WebSocket message sent: $message');
    } else {
      debugPrint('⚠️ Cannot send message - WebSocket not connected');
    }
  }

  /// Disconnect WebSocket
  Future<void> disconnect() async {
    if (_channel != null) {
      await _channel!.sink.close();
      _channel = null;
      _isConnected = false;
      debugPrint('🔌 WebSocket disconnected');
    }
  }

  /// Dispose resources
  void dispose() {
    disconnect();
    _messageController.close();
  }
}
