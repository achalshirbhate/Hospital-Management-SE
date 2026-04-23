import 'package:dio/dio.dart';
import 'api_client.dart';
import '../models/dashboard_model.dart';
import '../models/patient_model.dart';
import '../models/emergency_model.dart';
import '../models/launchpad_model.dart';
import '../models/token_model.dart';

class MdService {
  final Dio _dio = ApiClient().dio;

  // ─── Dashboard ──────────────────────────────────────────────────────────────
  Future<DashboardModel> getDashboard() async {
    final res = await _dio.get('/api/md/dashboard');
    return DashboardModel.fromJson(res.data);
  }

  Future<int> getAdminId() async {
    final res = await _dio.get('/api/md/admin-id');
    return res.data as int;
  }

  // ─── Patients & Doctors ─────────────────────────────────────────────────────
  Future<List<PatientModel>> getAllPatients() async {
    final res = await _dio.get('/api/md/patients');
    return (res.data as List).map((e) => PatientModel.fromJson(e)).toList();
  }

  Future<List<PatientModel>> getAllDoctors() async {
    final res = await _dio.get('/api/md/doctors');
    return (res.data as List).map((e) => PatientModel.fromJson(e)).toList();
  }

  Future<List<PatientModel>> getDoctorPatients(int doctorId) async {
    final res = await _dio.get('/api/md/doctors/$doctorId/patients');
    return (res.data as List).map((e) => PatientModel.fromJson(e)).toList();
  }

  Future<void> directAssignPatient(int patientId, int doctorId) async {
    await _dio.put('/api/md/patients/$patientId/assign',
        queryParameters: {'doctorId': doctorId});
  }

  // ─── Queues ─────────────────────────────────────────────────────────────────
  Future<Map<String, dynamic>> getPendingQueues() async {
    final res = await _dio.get('/api/md/queues');
    return res.data as Map<String, dynamic>;
  }

  Future<List<TokenModel>> getActiveAppointments() async {
    final res = await _dio.get('/api/md/appointments');
    return (res.data as List).map((e) => TokenModel.fromJson(e)).toList();
  }

  // ─── Referrals ──────────────────────────────────────────────────────────────
  Future<void> processReferral({
    required int referralId,
    required bool approve,
    int? assignedDoctorId,
  }) async {
    await _dio.put('/api/md/referrals/$referralId/assign', queryParameters: {
      'approve': approve,
      if (assignedDoctorId != null) 'assignedDoctorId': assignedDoctorId,
    });
  }

  // ─── Tokens ─────────────────────────────────────────────────────────────────
  Future<void> processToken({
    required int tokenId,
    required bool approve,
    String? scheduledTime,
  }) async {
    await _dio.put('/api/md/tokens/$tokenId', queryParameters: {
      'approve': approve,
      if (scheduledTime != null) 'scheduledTime': scheduledTime,
    });
  }

  Future<void> freezeToken(int tokenId) async {
    await _dio.put('/api/md/tokens/$tokenId/freeze');
  }

  Future<void> terminateToken(int tokenId) async {
    await _dio.put('/api/md/tokens/$tokenId/terminate');
  }

  // ─── Emergencies ────────────────────────────────────────────────────────────
  Future<List<EmergencyModel>> getEmergencies() async {    final res = await _dio.get('/api/md/emergencies');
    return (res.data as List).map((e) => EmergencyModel.fromJson(e)).toList();
  }

  Future<void> acknowledgeEmergency(int id) async {
    await _dio.put('/api/md/emergencies/$id/acknowledge');
  }

  // ─── Finance ────────────────────────────────────────────────────────────────
  Future<void> addFinancialRecord({
    required String type,
    required double amount,
    required String description,
  }) async {
    await _dio.post('/api/md/finance', data: {
      'type': type,
      'amount': amount,
      'description': description,
    });
  }

  // ─── Reports (download URLs) ─────────────────────────────────────────────────
  String revenueExcelUrl()   => '${_dio.options.baseUrl}/api/md/reports/revenue/excel';
  String expenseExcelUrl()   => '${_dio.options.baseUrl}/api/md/reports/expenses/excel';
  String doctorExcelUrl()    => '${_dio.options.baseUrl}/api/md/reports/doctors/excel';
  String revenuePdfUrl()     => '${_dio.options.baseUrl}/api/md/reports/revenue/pdf';
  String expensePdfUrl()     => '${_dio.options.baseUrl}/api/md/reports/expenses/pdf';
  String doctorPdfUrl()      => '${_dio.options.baseUrl}/api/md/reports/doctors/pdf';

  // ─── Social ─────────────────────────────────────────────────────────────────
  Future<void> createPost({
    required int mdId,
    required String title,
    required String content,
    String? mediaUrl,
  }) async {
    await _dio.post('/api/md/social', queryParameters: {
      'mdId': mdId,
      'title': title,
      'content': content,
      if (mediaUrl != null) 'mediaUrl': mediaUrl,
    });
  }

  // ─── Launchpad ───────────────────────────────────────────────────────────────
  Future<List<LaunchpadModel>> getLaunchpadSubmissions() async {
    final res = await _dio.get('/api/md/launchpad/submissions');
    return (res.data as List).map((e) => LaunchpadModel.fromJson(e)).toList();
  }

  Future<void> respondToLaunchpad(int id, String response) async {
    await _dio.put('/api/md/launchpad/$id/respond',
        queryParameters: {'response': response});
  }

  // ─── Promote user ────────────────────────────────────────────────────────────
  Future<void> promoteUser({
    required String email,
    required String name,
    required String role,
  }) async {
    await _dio.post('/api/md/promote', queryParameters: {
      'email': email,
      'name': name,
      'role': role,
    });
  }
}
