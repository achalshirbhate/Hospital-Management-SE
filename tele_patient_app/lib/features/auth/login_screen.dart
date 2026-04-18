import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/providers/auth_provider.dart';
import '../../core/widgets/app_button.dart';
import '../../core/widgets/app_text_field.dart';
import 'register_screen.dart';
import 'forgot_password_screen.dart';
import 'force_reset_password_screen.dart';
import '../patient/patient_home.dart';
import '../doctor/doctor_home.dart';
import '../md/md_home.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});
  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey  = GlobalKey<FormState>();
  final _email    = TextEditingController();
  final _password = TextEditingController();

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) return;
    final auth = context.read<AuthProvider>();
    final ok = await auth.login(_email.text.trim(), _password.text.trim());
    if (!mounted) return;
    
    if (ok) {
      final user = auth.user!;
      
      // Check if force password reset is needed
      if (user.forcePasswordReset == true) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => ForceResetPasswordScreen(email: user.email),
          ),
        );
        return;
      }
      
      // Navigate to appropriate home screen
      Widget dest;
      if (user.isMainDoctor)     dest = const MDHome();
      else if (user.isDoctor)    dest = const DoctorHome();
      else                       dest = const PatientHome();
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => dest));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 40),
              // Logo / branding
              Container(
                width: 80, height: 80,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(colors: [AppColors.primary, AppColors.green]),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Icon(Icons.local_hospital, color: Colors.white, size: 44),
              ),
              const SizedBox(height: 20),
              const Text('Tele Patient', style: TextStyle(fontSize: 28, fontWeight: FontWeight.w800, color: AppColors.primary)),
              const Text('Your health, securely managed.', style: TextStyle(color: AppColors.textMuted, fontSize: 14)),
              const SizedBox(height: 40),

              // Form card
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Welcome Back', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700)),
                        const SizedBox(height: 20),
                        AppTextField(
                          label: 'Email',
                          controller: _email,
                          keyboardType: TextInputType.emailAddress,
                          prefixIcon: Icons.email_outlined,
                          validator: (v) => v!.isEmpty ? 'Enter email' : null,
                        ),
                        const SizedBox(height: 14),
                        AppTextField(
                          label: 'Password',
                          controller: _password,
                          obscure: true,
                          prefixIcon: Icons.lock_outline,
                          validator: (v) => v!.isEmpty ? 'Enter password' : null,
                        ),
                        const SizedBox(height: 8),
                        Align(
                          alignment: Alignment.centerRight,
                          child: TextButton(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => const ForgotPasswordScreen(),
                                ),
                              );
                            },
                            child: const Text('Forgot Password?', style: TextStyle(fontSize: 13)),
                          ),
                        ),
                        Consumer<AuthProvider>(builder: (_, auth, __) {
                          if (auth.error != null) {
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 10),
                              child: Text(auth.error!, style: const TextStyle(color: AppColors.danger, fontSize: 13)),
                            );
                          }
                          return const SizedBox.shrink();
                        }),
                        Consumer<AuthProvider>(builder: (_, auth, __) =>
                          AppButton(label: 'Sign In', loading: auth.loading, onPressed: _login)),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                const Text("Don't have an account? ", style: TextStyle(color: AppColors.textMuted)),
                TextButton(
                  onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const RegisterScreen())),
                  child: const Text('Register'),
                ),
              ]),
            ],
          ),
        ),
      ),
    );
  }
}
