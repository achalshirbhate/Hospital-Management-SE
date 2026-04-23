import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/auth_provider.dart';
import 'services/api_client.dart';
import 'utils/app_theme.dart';
import 'utils/constants.dart';
import 'utils/navigator_service.dart';
import 'screens/auth/login_screen.dart';
import 'screens/patient/patient_dashboard.dart';
import 'screens/doctor/doctor_dashboard.dart';
import 'screens/md/md_dashboard.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Create AuthProvider early so we can pass its logout method to ApiClient.
  final authProvider = AuthProvider();

  // Wire the 401 logout callback into the Dio client.
  // When any request returns 401, Dio will:
  //   1. Call authProvider.logout() → clears token + state
  //   2. Navigate to /login via NavigatorService
  ApiClient().setLogoutCallback(authProvider.logout);

  // Restore any existing session from storage.
  await authProvider.restoreSession();

  runApp(
    ChangeNotifierProvider.value(
      value: authProvider,
      child: const TelePatientApp(),
    ),
  );
}

class TelePatientApp extends StatelessWidget {
  const TelePatientApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'TelePatient',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: ThemeMode.system,

      // Global navigator key — used by the Dio 401 interceptor to navigate
      // without a BuildContext.
      navigatorKey: NavigatorService.navigatorKey,

      // Named routes — the 401 interceptor pushes AppRoutes.login.
      initialRoute: AppRoutes.login,
      routes: {
        AppRoutes.login:   (_) => const _AuthGate(),
        AppRoutes.patient: (_) => const PatientDashboard(),
        AppRoutes.doctor:  (_) => const DoctorDashboard(),
        AppRoutes.md:      (_) => const MdDashboard(),
      },
    );
  }
}

/// Decides the initial screen based on the restored session.
/// Shown at app start and whenever the user is logged out.
class _AuthGate extends StatelessWidget {
  const _AuthGate();

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();

    if (!auth.isLoggedIn) return const LoginScreen();

    switch (auth.role) {
      case AppRoles.patient:
        return const PatientDashboard();
      case AppRoles.doctor:
        return const DoctorDashboard();
      case AppRoles.mainDoctor:
        return const MdDashboard();
      default:
        return const LoginScreen();
    }
  }
}
