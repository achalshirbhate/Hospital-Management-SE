import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../utils/constants.dart';
import '../../utils/helpers.dart';
import '../../widgets/loading_overlay.dart';
import '../patient/patient_dashboard.dart';
import '../doctor/doctor_dashboard.dart';
import '../md/md_dashboard.dart';

/// Shown when user logs in with temp password "temp@123".
class ResetTempPasswordScreen extends StatefulWidget {
  final String email;
  const ResetTempPasswordScreen({super.key, required this.email});

  @override
  State<ResetTempPasswordScreen> createState() =>
      _ResetTempPasswordScreenState();
}

class _ResetTempPasswordScreenState extends State<ResetTempPasswordScreen> {
  final _passCtrl  = TextEditingController();
  final _pass2Ctrl = TextEditingController();
  bool _obscure    = true;

  @override
  void dispose() {
    _passCtrl.dispose(); _pass2Ctrl.dispose();
    super.dispose();
  }

  Future<void> _reset() async {
    if (_passCtrl.text.isEmpty || _passCtrl.text != _pass2Ctrl.text) {
      showError(context, 'Passwords do not match'); return;
    }
    final auth = context.read<AuthProvider>();
    final ok = await auth.resetPasswordTemp(
        widget.email, AppConstants.tempPassword, _passCtrl.text);
    if (!mounted) return;
    if (ok) {
      showSuccess(context, 'Password updated!');
      _navigateByRole(auth.role);
    } else {
      showError(context, auth.error ?? 'Reset failed');
    }
  }

  void _navigateByRole(String role) {
    Widget dest;
    switch (role) {
      case AppRoles.doctor:     dest = const DoctorDashboard(); break;
      case AppRoles.mainDoctor: dest = const MdDashboard();     break;
      default:                  dest = const PatientDashboard();
    }
    Navigator.pushAndRemoveUntil(context,
        MaterialPageRoute(builder: (_) => dest), (_) => false);
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    return LoadingOverlay(
      isLoading: auth.loading,
      child: Scaffold(
        appBar: AppBar(title: const Text('Set New Password')),
        body: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(Icons.security, size: 56, color: Colors.orange),
              const SizedBox(height: 16),
              const Text(
                'Your account was created with a temporary password.\nPlease set a new secure password to continue.',
                style: TextStyle(fontSize: 15),
              ),
              const SizedBox(height: 24),
              TextFormField(
                controller: _passCtrl,
                obscureText: _obscure,
                decoration: InputDecoration(
                  labelText: 'New Password',
                  prefixIcon: const Icon(Icons.lock_outline),
                  suffixIcon: IconButton(
                    icon: Icon(
                        _obscure ? Icons.visibility_off : Icons.visibility),
                    onPressed: () => setState(() => _obscure = !_obscure),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _pass2Ctrl,
                obscureText: _obscure,
                decoration: const InputDecoration(
                    labelText: 'Confirm Password',
                    prefixIcon: Icon(Icons.lock_outline)),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                  onPressed: _reset, child: const Text('Update Password')),
            ],
          ),
        ),
      ),
    );
  }
}
