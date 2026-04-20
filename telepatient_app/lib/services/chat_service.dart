import 'package:dio/dio.dart';
import 'api_client.dart';
import '../models/chat_message_model.dart';

class ChatService {
  final Dio _dio = ApiClient().dio;

  /// Fetch all messages for a token session.
  Future<ChatSyncResponse> getChatHistory(int tokenId) async {
    final res = await _dio.get('/api/chat/$tokenId');
    return ChatSyncResponse.fromJson(res.data);
  }

  /// Send a message in a token session.
  Future<void> sendMessage({
    required int tokenId,
    required int senderId,
    required String message,
  }) async {
    await _dio.post(
      '/api/chat/$tokenId',
      queryParameters: {'senderId': senderId},
      data: message,
      options: Options(contentType: 'text/plain'),
    );
  }
}
