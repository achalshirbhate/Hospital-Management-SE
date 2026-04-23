class ApiConstants {
  // Change this to your deployed backend URL or local IP for testing
  // For local testing on Android emulator use: http://10.0.2.2:8081
  // For physical device use your machine's local IP: http://192.168.x.x:8081
static const baseUrl = 'http://192.168.0.232:8081/api';

  // Auth
  static const login          = '$baseUrl/auth/login';
  static const register       = '$baseUrl/auth/register';
  static const forgotPassword = '$baseUrl/auth/forgot-password';
  static const resetPasswordOtp = '$baseUrl/auth/reset-password-otp';
  static const verifyOtp      = '$baseUrl/auth/verify-otp';
  static const resetPassword  = '$baseUrl/auth/reset-password';
  static const forceResetPassword = '$baseUrl/auth/force-reset-password';

  // Patient
  static String patientHistory(int id)  => '$baseUrl/patient/$id/history';
  static String patientTokens(int id)   => '$baseUrl/patient/$id/tokens';
  static String patientEmergency(int id)=> '$baseUrl/patient/$id/emergency';
  static const requestToken             = '$baseUrl/patient/tokens';

  // Doctor
  static String doctorPatients(int id)  => '$baseUrl/doctor/$id/patients';
  static String addConsultation(int id) => '$baseUrl/doctor/$id/consultations';
  static String addReferral(int id)     => '$baseUrl/doctor/$id/referrals';

  // MD
  static const mdDashboard   = '$baseUrl/md/dashboard';
  static const mdQueues      = '$baseUrl/md/queues';
  static const mdAppointments= '$baseUrl/md/appointments';
  static const mdDoctors     = '$baseUrl/md/doctors';
  static const mdPatients    = '$baseUrl/md/patients';
  static const mdEmergencies = '$baseUrl/md/emergencies';
  static const mdAdminId     = '$baseUrl/md/admin-id';
  static String mdTokenAction(int id)    => '$baseUrl/md/tokens/$id';
  static String mdReferralAction(int id) => '$baseUrl/md/referrals/$id/assign';
  static String mdPatientHistory(int patId) => '$baseUrl/md/patients/$patId/history';
  static String mdDoctorPatients(int docId) => '$baseUrl/md/doctors/$docId/patients';
  static String mdAckEmergency(int id)   => '$baseUrl/md/emergencies/$id/acknowledge';
  static String mdAssignPatient(int patId) => '$baseUrl/md/patients/$patId/assign';
  static const mdFinance     = '$baseUrl/md/finance';
  static const mdPromote     = '$baseUrl/md/promote';
  static const mdSocial      = '$baseUrl/md/social';

  // Chat
  static String chatHistory(int tokenId) => '$baseUrl/chat/$tokenId';
  static String sendMessage(int tokenId) => '$baseUrl/chat/$tokenId';

  // Reports
  static String reports(int patientId)   => '$baseUrl/reports/$patientId';
  static const uploadReport              = '$baseUrl/reports/upload';
  static const sendReportToChat          = '$baseUrl/reports/send-to-chat';

  // Shared
  static const socialFeed  = '$baseUrl/shared/social';
  static const launchpad   = '$baseUrl/shared/launchpad';
}
