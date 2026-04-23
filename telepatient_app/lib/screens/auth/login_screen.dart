import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../utils/app_theme.dart';
import '../../utils/constants.dart';
import '../../utils/helpers.dart';
import '../../utils/page_transitions.dart';
import '../../widgets/app_button.dart';
import '../../widgets/app_text_field.dart';
import 'register_screen.dart';
import 'forgot_password_screen.dart';
import 'reset_temp_password_screen.dart';
import '../patient/patient_dashboard.dart';
import '../doctor/doctor_dashboard.dart';
import '../md/md_dashboard.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen>
    with SingleTickerProviderStateMixin {
  final _formKey   = GlobalKey<FormState>();
  final _emailCtrl = TextEditingController();
  final _passCtrl  = TextEditingController();
  bool _obscure    = true;

  late AnimationController _animCtrl;
  late Animation<double>   _fadeAnim;
  late Animation<Offset>   _slideAnim;

  @override
  void initState() {
    super.initState();
    _animCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 600));
    _fadeAnim = CurvedAnimation(parent: _animCtrl, curve: Curves.easeOut);
    _slideAnim = Tween<Offset>(
      begin: const Offset(0, 0.06),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _animCtrl, curve: Curves.easeOutCubic));
    _animCtrl.forward();
  }

  @override
  void dispose() {
    _animCtrl.dispose();
    _emailCtrl.dispose();
    _passCtrl.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) return;
    final auth = context.read<AuthProvider>();
    final user = await auth.login(_emailCtrl.text.trim(), _passCtrl.text);
    if (!mounted) return;
    if (user == null) {
      showError(context, auth.error ?? 'Login failed');
      return;
    }
    if (user.requirePasswordReset) {
      Navigator.pushReplacement(context,
          SlideUpRoute(page: ResetTempPasswordScreen(email: user.email)));
      return;
    }
    _navigateByRole(user.role);
  }

  void _navigateByRole(String role) {
    final Widget dest = switch (role) {
      AppRoles.doctor     => const DoctorDashboard(),
      AppRoles.mainDoctor => const MdDashboard(),
      _                   => const PatientDashboard(),
    };
    Navigator.pushReplacement(context, FadeRoute(page: dest));
  }

  @override
  Widget build(BuildContext context) {
    final auth    = context.watch<AuthProvider>();
    final isDark  = Theme.of(context).brightness == Brightness.dark;
    final primary = Theme.of(context).colorScheme.primary;

    return Scaffold(
      backgroundColor:
          isDark ? AppColors.darkBackground : AppColors.background,
      body: SafeArea(
        child: FadeTransition(
          opacity: _fadeAnim,
          child: SlideTransition(
            position: _slideAnim,
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.lg, vertical: AppSpacing.xl),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: AppSpacing.xl),

                    // ── Logo ─────────────────────────────────────────────────
                    Center(
                      child: Column(children: [
                        Container(
                          width: 80,
                          height: 80,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [primary, AppColors.accent],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            borderRadius:
                                BorderRadius.circular(AppRadius.xl),
                            boxShadow: [
                              BoxShadow(
                                color: primary.withValues(alpha: 0.3),
                                blurRadius: 20,
                                offset: const Offset(0, 8),
                              ),
                            ],
                          ),
                          child: const Icon(Icons.local_hospital,
                              size: 40, color: Colors.white),
                        ),
                        const SizedBox(height: AppSpacing.md),
                        Text('TelePatient',
                            style: AppTextStyles.displayMd.copyWith(
                              color: isDark
                                  ? AppColors.darkTextPrimary
                                  : AppColors.textPrimary,
                            )),
                        const SizedBox(height: 4),
                        Text('Healthcare at your fingertips',
                            style: AppTextStyles.bodyMd.copyWith(
                              color: isDark
                                  ? AppColors.darkTextSecondary
                                  : AppColors.textSecondary,
                            )),
                      ]),
                    ),

                    const SizedBox(height: AppSpacing.xxl),

                    // ── Form header ───────────────────────────────────────────
                    Text('Welcome back',
                        style: AppTextStyles.displaySm.copyWith(
                          color: isDark
                              ? AppColors.darkTextPrimary
                              : AppColors.textPrimary,
                        )),
                    const SizedBox(height: 4),
                    Text('Sign in to your account',
                        style: AppTextStyles.bodyMd.copyWith(
                          color: isDark
                              ? AppColors.darkTextSecondary
                              : AppColors.textSecondary,
                        )),
                    const SizedBox(height: AppSpacing.lg),

                    // ── Email ─────────────────────────────────────────────────
                    AppTextField(
                      controller: _emailCtrl,
                      label: 'Email address',
                      hint: 'you@example.com',
                      prefixIcon: Icons.email_outlined,
                      keyboardType: TextInputType.emailAddress,
                      textInputAction: TextInputAction.next,
                      validator: (v) =>
                          v == null || v.isEmpty ? 'Enter your email' : null,
                    ),
                    const SizedBox(height: AppSpacing.md),

                    // ── Password ──────────────────────────────────────────────
                    AppTextField(
                      controller: _passCtrl,
                      label: 'Password',
                      prefixIcon: Icons.lock_outline,
                      obscureText: _obscure,
                      textInputAction: TextInputAction.done,
                      onSubmitted: (_) => _login(),
                      suffixIcon: IconButton(
                        icon: Icon(
                          _obscure
                              ? Icons.visibility_off_outlined
                              : Icons.visibility_outlined,
                          size: 20,
                        ),
                        onPressed: () =>
                            setState(() => _obscure = !_obscure),
                      ),
                      validator: (v) =>
                          v == null || v.isEmpty ? 'Enter your password' : null,
                    ),

                    // ── Forgot password ───────────────────────────────────────
                    Align(
                      alignment: Alignment.centerRight,
                      child: TextButton(
                        onPressed: () => Navigator.push(context,
                            SlideUpRoute(
                                page: const ForgotPasswordScreen())),
                        child: Text('Forgot password?',
                            style: AppTextStyles.labelLg.copyWith(
                                color: primary)),
                      ),
                    ),

                    const SizedBox(height: AppSpacing.sm),

                    // ── Sign in button ────────────────────────────────────────
                    AppButton(
                      label: 'Sign In',
                      loading: auth.loading,
                      onPressed: _login,
                      icon: Icons.arrow_forward,
                    ),

                    const SizedBox(height: AppSpacing.lg),

                    // ── Divider ───────────────────────────────────────────────
                    Row(children: [
                      const Expanded(child: Divider()),
                      Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: AppSpacing.md),
                        child: Text('or',
                            style: AppTextStyles.bodySm.copyWith(
                              color: isDark
                                  ? AppColors.darkTextSecondary
                                  : AppColors.textSecondary,
                            )),
                      ),
                      const Expanded(child: Divider()),
                    ]),

                    const SizedBox(height: AppSpacing.md),

                    // ── Register ──────────────────────────────────────────────
                    OutlinedButton(
                      onPressed: () => Navigator.push(
                          context,
                          SlideUpRoute(page: const RegisterScreen())),
                      child: const Text('Create an account'),
                    ),

                    const SizedBox(height: AppSpacing.lg),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
