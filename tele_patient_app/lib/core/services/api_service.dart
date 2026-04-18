import 'dart:convert';
import 'package:http/http.dart' as http;
import '../constants/api_constants.dart';

class ApiService {
  static final _client = http.Client();

  static Map<String, String> _headers({String? contentType}) => {
    'Content-Type': contentType ?? 'application/json',
    'Accept': 'application/json',
  };

  // ── AUTH ──
  static Future<Map<String, dynamic>> login(String email, String password) async {
    final res = await _client.post(
      Uri.parse(ApiConstants.login),
      headers: _headers(),
      body: jsonEncode({'email': email, 'password': password}),
    );
    return _parse(res);
  }

  static Future<Map<String, dynamic>> register(String fullName, String email, String password) async {
    final res = await _client.post(
      Uri.parse(ApiConstants.register),
      headers: _headers(),
      body: jsonEncode({'fullName': fullName, 'email': email, 'password': password}),
    );
    return _parse(res);
  }

  static Future<String> forgotPassword(String email) async {
    final res = await _client.post(
      Uri.parse('${ApiConstants.forgotPassword}?email=${Uri.encodeComponent(email)}'),
      headers: _headers(),
    );
    if (res.statusCode >= 400) throw Exception(_parse(res)['error']);
    return res.body;
  }

  static Future<String> verifyOtp(String email, String otp) async {
    final res = await _client.post(
      Uri.parse('${ApiConstants.verifyOtp}?email=${Uri.encodeComponent(email)}&otp=$otp'),
      headers: _headers(),
    );
    if (res.statusCode >= 400) throw Exception(_parse(res)['error']);
    return res.body;
  }

  static Future<String> resetPasswordWithOtp(String email, String otp, String newPassword) async {
    final res = await _client.post(
      Uri.parse('${ApiConstants.resetPasswordOtp}?email=${Uri.encodeComponent(email)}&otp=$otp&newPassword=${Uri.encodeComponent(newPassword)}'),
      headers: _headers(),
    );
    if (res.statusCode >= 400) throw Exception(_parse(res)['error']);
    return res.body;
  }

  static Future<String> forceResetPassword(String email, String newPassword) async {
    final res = await _client.post(
      Uri.parse('${ApiConstants.forceResetPassword}?email=${Uri.encodeComponent(email)}&newPassword=${Uri.encodeComponent(newPassword)}'),
      headers: _headers(),
    );
    if (res.statusCode >= 400) throw Exception(_parse(res)['error']);
    return res.body;
  }

  // ── PATIENT ──
  static Future<List<dynamic>> getPatientHistory(int id) async {
    final res = await _client.get(Uri.parse(ApiConstants.patientHistory(id)), headers: _headers());
    return jsonDecode(res.body) as List;
  }

  static Future<List<dynamic>> getPatientTokens(int id) async {
    final res = await _client.get(Uri.parse(ApiConstants.patientTokens(id)), headers: _headers());
    return jsonDecode(res.body) as List;
  }

  static Future<String> requestToken(int patientId, int mdId, String type) async {
    final res = await _client.post(
      Uri.parse(ApiConstants.requestToken),
      headers: _headers(),
      body: jsonEncode({'patientId': patientId, 'mdId': mdId, 'type': type}),
    );
    return res.body;
  }

  static Future<String> triggerEmergency(int patientId, String level) async {
    final res = await _client.post(
      Uri.parse('${ApiConstants.patientEmergency(patientId)}?level=$level'),
      headers: _headers(),
    );
    return res.body;
  }

  // ── DOCTOR ──
  static Future<List<dynamic>> getDoctorPatients(int doctorId) async {
    final res = await _client.get(Uri.parse(ApiConstants.doctorPatients(doctorId)), headers: _headers());
    return jsonDecode(res.body) as List;
  }

  static Future<void> addConsultation(int doctorId, int patientId, String notes, String rx, String reportUrl) async {
    await _client.post(
      Uri.parse('${ApiConstants.addConsultation(doctorId)}?patientId=$patientId&notes=${Uri.encodeComponent(notes)}&prescription=${Uri.encodeComponent(rx)}&reportsUrl=${Uri.encodeComponent(reportUrl)}'),
      headers: _headers(),
    );
  }

  static Future<void> addReferral(int doctorId, Map<String, dynamic> body) async {
    await _client.post(
      Uri.parse(ApiConstants.addReferral(doctorId)),
      headers: _headers(),
      body: jsonEncode(body),
    );
  }

  // ── MD ──
  static Future<Map<String, dynamic>> getMDDashboard() async {
    final res = await _client.get(Uri.parse(ApiConstants.mdDashboard), headers: _headers());
    return _parse(res);
  }

  static Future<Map<String, dynamic>> getMDQueues() async {
    final res = await _client.get(Uri.parse(ApiConstants.mdQueues), headers: _headers());
    return _parse(res);
  }

  static Future<List<dynamic>> getMDDoctors() async {
    final res = await _client.get(Uri.parse(ApiConstants.mdDoctors), headers: _headers());
    return jsonDecode(res.body) as List;
  }

  static Future<List<dynamic>> getMDPatients() async {
    final res = await _client.get(Uri.parse(ApiConstants.mdPatients), headers: _headers());
    return jsonDecode(res.body) as List;
  }

  static Future<List<dynamic>> getMDEmergencies() async {
    final res = await _client.get(Uri.parse(ApiConstants.mdEmergencies), headers: _headers());
    return jsonDecode(res.body) as List;
  }

  static Future<void> processToken(int id, bool approve, {String? scheduledTime}) async {
    final url = scheduledTime != null
        ? '${ApiConstants.mdTokenAction(id)}?approve=$approve&scheduledTime=${Uri.encodeComponent(scheduledTime)}'
        : '${ApiConstants.mdTokenAction(id)}?approve=$approve';
    await _client.put(Uri.parse(url), headers: _headers());
  }

  static Future<void> processReferral(int id, bool approve, {int? assignedDoctorId}) async {
    final url = approve && assignedDoctorId != null
        ? '${ApiConstants.mdReferralAction(id)}?approve=$approve&assignedDoctorId=$assignedDoctorId'
        : '${ApiConstants.mdReferralAction(id)}?approve=$approve';
    await _client.put(Uri.parse(url), headers: _headers());
  }

  static Future<void> acknowledgeEmergency(int id) async {
    await _client.put(Uri.parse(ApiConstants.mdAckEmergency(id)), headers: _headers());
  }

  static Future<int> getAdminId() async {
    final res = await _client.get(Uri.parse(ApiConstants.mdAdminId), headers: _headers());
    return int.parse(res.body);
  }

  // ── CHAT ──
  static Future<Map<String, dynamic>> getChatHistory(int tokenId) async {
    final res = await _client.get(Uri.parse(ApiConstants.chatHistory(tokenId)), headers: _headers());
    return _parse(res);
  }

  static Future<void> sendMessage(int tokenId, int senderId, String message) async {
    await _client.post(
      Uri.parse('${ApiConstants.sendMessage(tokenId)}?senderId=$senderId'),
      headers: {'Content-Type': 'text/plain'},
      body: message,
    );
  }

  // ── REPORTS ──
  static Future<List<dynamic>> getReports(int patientId) async {
    final res = await _client.get(Uri.parse(ApiConstants.reports(patientId)), headers: _headers());
    return jsonDecode(res.body) as List;
  }

  static Future<void> uploadReport(Map<String, dynamic> body) async {
    await _client.post(Uri.parse(ApiConstants.uploadReport), headers: _headers(), body: jsonEncode(body));
  }

  static Future<void> sendReportToChat(int reportId, int tokenId) async {
    await _client.post(
      Uri.parse('${ApiConstants.sendReportToChat}?reportId=$reportId&tokenId=$tokenId'),
      headers: _headers(),
    );
  }

  // ── SOCIAL ──
  static Future<List<dynamic>> getSocialFeed() async {
    final res = await _client.get(Uri.parse(ApiConstants.socialFeed), headers: _headers());
    return jsonDecode(res.body) as List;
  }

  static Future<void> postSocial(String content) async {
    await _client.post(
      Uri.parse(ApiConstants.socialFeed),
      headers: _headers(),
      body: jsonEncode({'content': content}),
    );
  }

  static Future<void> likeSocialPost(int postId) async {
    await _client.post(
      Uri.parse('${ApiConstants.baseUrl}/shared/social/$postId/like'),
      headers: _headers(),
    );
  }

  // ── LAUNCHPAD ──
  static Future<void> submitLaunchpad(Map<String, dynamic> data) async {
    await _client.post(
      Uri.parse(ApiConstants.launchpad),
      headers: _headers(),
      body: jsonEncode(data),
    );
  }

  static Future<List<dynamic>> getLaunchpadSubmissions() async {
    final res = await _client.get(Uri.parse(ApiConstants.launchpad), headers: _headers());
    return jsonDecode(res.body) as List;
  }

  // ── NOTIFICATIONS ──
  static Future<List<dynamic>> getNotifications(int userId) async {
    final res = await _client.get(
      Uri.parse('${ApiConstants.baseUrl}/notifications/$userId'),
      headers: _headers(),
    );
    return jsonDecode(res.body) as List;
  }

  static Future<void> markNotificationRead(int notificationId) async {
    await _client.put(
      Uri.parse('${ApiConstants.baseUrl}/notifications/$notificationId/read'),
      headers: _headers(),
    );
  }

  static Future<void> markAllNotificationsRead(int userId) async {
    await _client.put(
      Uri.parse('${ApiConstants.baseUrl}/notifications/$userId/read-all'),
      headers: _headers(),
    );
  }

  // ── FINANCE ──
  static Future<void> addFinance(String type, double amount, String description) async {
    await _client.post(
      Uri.parse('${ApiConstants.baseUrl}/md/finance'),
      headers: _headers(),
      body: jsonEncode({'type': type, 'amount': amount, 'description': description}),
    );
  }

  // ── ROLE MANAGEMENT ──
  static Future<String> promoteUser(String email, String fullName, String role) async {
    final res = await _client.post(
      Uri.parse('${ApiConstants.mdPromote}?email=${Uri.encodeComponent(email)}&fullName=${Uri.encodeComponent(fullName)}&role=$role'),
      headers: _headers(),
    );
    if (res.statusCode >= 400) throw Exception(_parse(res)['error']);
    return res.body;
  }

  // ── HELPER ──
  static Map<String, dynamic> _parse(http.Response res) {
    final body = jsonDecode(res.body);
    if (res.statusCode >= 400) throw Exception(body['error'] ?? body.toString());
    return body as Map<String, dynamic>;
  }
}
