import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../utils/helpers.dart';
import '../../widgets/loading_overlay.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _emailCtrl = TextEditingController();
  final _otpCtrl   = TextEditingController();
  final _passCtrl  = TextEditingController();
  bool _otpSent    = false;

  @override
  void dispose() {
    _emailCtrl.dispose(); _otpCtrl.dispose(); _passCtrl.dispose();
    super.dispose();
  }

  Future<void> _sendOtp() async {
    if (_emailCtrl.text.trim().isEmpty) {
      showError(context, 'Enter your email'); return;
    }
    final auth = context.read<AuthProvider>();
    final ok = await auth.forgotPassword(_emailCtrl.text.trim());
    if (!mounted) return;
    if (ok) {
      setState(() => _otpSent = true);
      showSuccess(context, 'OTP sent to your email');
    } else {
      showError(context, auth.error ?? 'Failed to send OTP');
    }
  }

  Future<void> _resetPassword() async {
    if (_otpCtrl.text.isEmpty || _passCtrl.text.isEmpty) {
      showError(context, 'Fill all fields'); return;
    }
    final auth = context.read<AuthProvider>();
    final ok = await auth.resetPasswordOtp(
        _emailCtrl.text.trim(), _otpCtrl.text.trim(), _passCtrl.text);
    if (!mounted) return;
    if (ok) {
      showSuccess(context, 'Password reset successfully!');
      Navigator.pop(context);
    } else {
      showError(context, auth.error ?? 'Reset failed');
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    return LoadingOverlay(
      isLoading: auth.loading,
      child: Scaffold(
        appBar: AppBar(title: const Text('Forgot Password')),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 16),
              const Icon(Icons.lock_reset, size: 64, color: Colors.blue),
              const SizedBox(height: 16),
              Text(
                _otpSent
                    ? 'Enter the OTP sent to your email and set a new password.'
                    : 'Enter your registered email to receive an OTP.',
                style: const TextStyle(fontSize: 15),
              ),
              const SizedBox(height: 24),
              TextFormField(
                controller: _emailCtrl,
                enabled: !_otpSent,
                keyboardType: TextInputType.emailAddress,
                decoration: const InputDecoration(
                    labelText: 'Email',
                    prefixIcon: Icon(Icons.email_outlined)),
              ),
              if (!_otpSent) ...[
                const SizedBox(height: 24),
                ElevatedButton(
                    onPressed: _sendOtp, child: const Text('Send OTP')),
              ],
              if (_otpSent) ...[
                const SizedBox(height: 16),
                TextFormField(
                  controller: _otpCtrl,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                      labelText: 'OTP Code',
                      prefixIcon: Icon(Icons.pin_outlined)),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _passCtrl,
                  obscureText: true,
                  decoration: const InputDecoration(
                      labelText: 'New Password',
                      prefixIcon: Icon(Icons.lock_outline)),
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                    onPressed: _resetPassword,
                    child: const Text('Reset Password')),
                const SizedBox(height: 8),
                TextButton(
                  onPressed: () => setState(() => _otpSent = false),
                  child: const Text('Resend OTP'),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
