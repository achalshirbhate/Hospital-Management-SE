import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../utils/app_theme.dart';
import '../../utils/helpers.dart';
import '../../widgets/app_button.dart';
import '../../widgets/app_text_field.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey   = GlobalKey<FormState>();
  final _nameCtrl  = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _passCtrl  = TextEditingController();
  final _pass2Ctrl = TextEditingController();
  bool _obscure    = true;

  @override
  void dispose() {
    _nameCtrl.dispose(); _emailCtrl.dispose();
    _passCtrl.dispose(); _pass2Ctrl.dispose();
    super.dispose();
  }

  Future<void> _register() async {
    if (!_formKey.currentState!.validate()) return;
    final auth = context.read<AuthProvider>();
    final ok = await auth.register(
        _nameCtrl.text.trim(), _emailCtrl.text.trim(), _passCtrl.text);
    if (!mounted) return;
    if (ok) {
      showSuccess(context, 'Account created! Please sign in.');
      Navigator.pop(context);
    } else {
      showError(context, auth.error ?? 'Registration failed');
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth   = context.watch<AuthProvider>();
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Account'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, size: 18),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: AppSpacing.sm),

              // Header
              Text('Join TelePatient',
                  style: AppTextStyles.displaySm.copyWith(
                    color: isDark
                        ? AppColors.darkTextPrimary
                        : AppColors.textPrimary,
                  )),
              const SizedBox(height: 4),
              Text('Create your patient account',
                  style: AppTextStyles.bodyMd.copyWith(
                    color: isDark
                        ? AppColors.darkTextSecondary
                        : AppColors.textSecondary,
                  )),
              const SizedBox(height: AppSpacing.xl),

              AppTextField(
                controller: _nameCtrl,
                label: 'Full Name',
                hint: 'John Doe',
                prefixIcon: Icons.person_outline,
                textInputAction: TextInputAction.next,
                validator: (v) =>
                    v == null || v.isEmpty ? 'Enter your name' : null,
              ),
              const SizedBox(height: AppSpacing.md),

              AppTextField(
                controller: _emailCtrl,
                label: 'Email address',
                hint: 'you@example.com',
                prefixIcon: Icons.email_outlined,
                keyboardType: TextInputType.emailAddress,
                textInputAction: TextInputAction.next,
                validator: (v) =>
                    v == null || !v.contains('@') ? 'Enter a valid email' : null,
              ),
              const SizedBox(height: AppSpacing.md),

              AppTextField(
                controller: _passCtrl,
                label: 'Password',
                prefixIcon: Icons.lock_outline,
                obscureText: _obscure,
                textInputAction: TextInputAction.next,
                suffixIcon: IconButton(
                  icon: Icon(
                    _obscure
                        ? Icons.visibility_off_outlined
                        : Icons.visibility_outlined,
                    size: 20,
                  ),
                  onPressed: () => setState(() => _obscure = !_obscure),
                ),
                validator: (v) =>
                    v == null || v.length < 6 ? 'Minimum 6 characters' : null,
              ),
              const SizedBox(height: AppSpacing.md),

              AppTextField(
                controller: _pass2Ctrl,
                label: 'Confirm Password',
                prefixIcon: Icons.lock_outline,
                obscureText: _obscure,
                textInputAction: TextInputAction.done,
                onSubmitted: (_) => _register(),
                validator: (v) =>
                    v != _passCtrl.text ? 'Passwords do not match' : null,
              ),

              const SizedBox(height: AppSpacing.sm),

              // Password hint
              Row(children: [
                const Icon(Icons.info_outline,
                    size: 14, color: AppColors.textHint),
                const SizedBox(width: 6),
                Text('Use at least 6 characters',
                    style: AppTextStyles.bodySm.copyWith(
                        color: isDark
                            ? AppColors.darkTextSecondary
                            : AppColors.textHint)),
              ]),

              const SizedBox(height: AppSpacing.xl),

              AppButton(
                label: 'Create Account',
                loading: auth.loading,
                onPressed: _register,
                icon: Icons.check,
              ),

              const SizedBox(height: AppSpacing.md),

              Center(
                child: TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text('Already have an account? Sign in',
                      style: AppTextStyles.labelLg.copyWith(
                          color: Theme.of(context).colorScheme.primary)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
