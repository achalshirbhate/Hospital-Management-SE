import 'package:dio/dio.dart';
import 'api_client.dart';
import '../models/patient_model.dart';

class DoctorService {
  final Dio _dio = ApiClient().dio;

  Future<List<PatientModel>> getAssignedPatients(int doctorId) async {
    final res = await _dio.get('/api/doctor/$doctorId/patients');
    return (res.data as List).map((e) => PatientModel.fromJson(e)).toList();
  }

  /// Register a new patient and assign to this doctor.
  Future<void> addPatient({
    required int doctorId,
    required String fullName,
    required String email,
    required String password,
    int? age,
  }) async {
    await _dio.post(
      '/api/doctor/add-patient',
      data: {'fullName': fullName, 'email': email, 'password': password},
      queryParameters: {
        'doctorId': doctorId,
        if (age != null) 'age': age,
      },
    );
  }

  Future<void> addConsultation({
    required int doctorId,
    required int patientId,
    required String notes,
    String? prescription,
    String? reportsUrl,
  }) async {
    await _dio.post(
      '/api/doctor/$doctorId/consultations',
      queryParameters: {
        'patientId': patientId,
        'notes': notes,
        if (prescription != null) 'prescription': prescription,
        if (reportsUrl != null) 'reportsUrl': reportsUrl,
      },
    );
  }

  Future<void> requestReferral({
    required int doctorId,
    required int patientId,
    required String requestedSpecialty,
    required String urgency,
    required String reason,
  }) async {
    await _dio.post('/api/doctor/$doctorId/referrals', data: {
      'patientId': patientId,
      'requestedSpecialty': requestedSpecialty,
      'urgency': urgency,
      'reason': reason,
    });
  }
}
