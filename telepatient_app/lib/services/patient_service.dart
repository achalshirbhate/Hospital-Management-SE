import 'package:dio/dio.dart';
import 'api_client.dart';
import '../models/consultation_model.dart';
import '../models/token_model.dart';

class PatientService {
  final Dio _dio = ApiClient().dio;

  Future<List<ConsultationModel>> getHistory(int patientId) async {
    final res = await _dio.get('/api/patient/$patientId/history');
    return (res.data as List).map((e) => ConsultationModel.fromJson(e)).toList();
  }

  Future<void> requestToken({
    required int patientId,
    required int mdId,
    required String type,
  }) async {
    await _dio.post('/api/patient/tokens', data: {
      'patientId': patientId,
      'mdId': mdId,
      'type': type,
    });
  }

  Future<List<TokenModel>> getMyTokens(int patientId) async {
    final res = await _dio.get('/api/patient/$patientId/tokens');
    return (res.data as List).map((e) => TokenModel.fromJson(e)).toList();
  }

  Future<String> triggerEmergency(int patientId, String level) async {
    final res = await _dio.post(
      '/api/patient/$patientId/emergency',
      queryParameters: {'level': level},
    );
    return res.data.toString();
  }
}
