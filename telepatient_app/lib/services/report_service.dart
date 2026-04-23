import 'package:dio/dio.dart';
import 'api_client.dart';
import '../models/report_model.dart';

class ReportService {
  final Dio _dio = ApiClient().dio;

  Future<List<ReportModel>> getReports(int patientId) async {
    final res = await _dio.get('/api/reports/$patientId');
    return (res.data as List).map((e) => ReportModel.fromJson(e)).toList();
  }

  Future<ReportModel> uploadReport({
    required int patientId,
    required int doctorId,
    required String reportName,
    required String fileUrl,
    String reportType = 'PDF',
    String notes = '',
  }) async {
    final res = await _dio.post('/api/reports/upload', data: {
      'patientId': patientId,
      'doctorId': doctorId,
      'reportName': reportName,
      'fileUrl': fileUrl,
      'reportType': reportType,
      'notes': notes,
    });
    return ReportModel.fromJson(res.data);
  }

  Future<void> sendReportToChat({
    required int reportId,
    required int tokenId,
    required int senderId,
  }) async {
    await _dio.post('/api/reports/send-to-chat', data: {
      'reportId': reportId,
      'tokenId': tokenId,
      'senderId': senderId,
    });
  }
}
