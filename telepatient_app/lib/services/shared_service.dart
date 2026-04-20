import 'package:dio/dio.dart';
import 'api_client.dart';
import '../models/social_post_model.dart';
import '../models/launchpad_model.dart';

class SharedService {
  final Dio _dio = ApiClient().dio;

  // ─── Social Feed ─────────────────────────────────────────────────────────────
  Future<List<SocialPostModel>> getSocialFeed() async {
    final res = await _dio.get('/api/shared/social');
    return (res.data as List).map((e) => SocialPostModel.fromJson(e)).toList();
  }

  Future<void> deleteSocialPost(int postId, int requesterId) async {
    await _dio.delete('/api/shared/social/$postId',
        queryParameters: {'requesterId': requesterId});
  }

  // ─── Launchpad ───────────────────────────────────────────────────────────────
  Future<void> submitIdea({
    required int submitterId,
    required String ideaTitle,
    required String description,
    required String domain,
    required String contactInfo,
  }) async {
    await _dio.post('/api/shared/launchpad', data: {
      'submitterId': submitterId,
      'ideaTitle': ideaTitle,
      'description': description,
      'domain': domain,
      'contactInfo': contactInfo,
    });
  }

  Future<void> deleteLaunchpadIdea(int ideaId, int requesterId) async {
    await _dio.delete('/api/shared/launchpad/$ideaId',
        queryParameters: {'requesterId': requesterId});
  }
}
