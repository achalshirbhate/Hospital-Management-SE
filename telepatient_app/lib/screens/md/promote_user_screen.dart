import 'package:flutter/material.dart';
import '../../services/md_service.dart';
import '../../utils/helpers.dart';
import '../../widgets/loading_overlay.dart';

class PromoteUserScreen extends StatefulWidget {
  const PromoteUserScreen({super.key});

  @override
  State<PromoteUserScreen> createState() => _PromoteUserScreenState();
}

class _PromoteUserScreenState extends State<PromoteUserScreen> {
  final _emailCtrl = TextEditingController();
  final _nameCtrl  = TextEditingController();
  final _service   = MdService();
  String _role     = 'DOCTOR';
  bool _loading    = false;

  @override
  void dispose() {
    _emailCtrl.dispose(); _nameCtrl.dispose();
    super.dispose();
  }

  Future<void> _promote() async {
    if (_emailCtrl.text.isEmpty || _nameCtrl.text.isEmpty) {
      showError(context, 'Fill all fields'); return;
    }
    setState(() => _loading = true);
    try {
      await _service.promoteUser(
          email: _emailCtrl.text.trim(),
          name: _nameCtrl.text.trim(),
          role: _role);
      if (mounted) {
        showSuccess(context, 'User promoted to $_role!');
        _emailCtrl.clear(); _nameCtrl.clear();
      }
    } catch (e) {
      if (mounted) showError(context, e.toString());
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Promote User')),
      body: LoadingOverlay(
        isLoading: _loading,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(children: [
            const Icon(Icons.admin_panel_settings,
                size: 56, color: Colors.teal),
            const SizedBox(height: 8),
            const Text(
              'Promote an existing user or create a new one with a role.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 24),
            TextField(
              controller: _emailCtrl,
              keyboardType: TextInputType.emailAddress,
              decoration: const InputDecoration(
                  labelText: 'Email *',
                  prefixIcon: Icon(Icons.email_outlined)),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _nameCtrl,
              decoration: const InputDecoration(
                  labelText: 'Full Name *',
                  prefixIcon: Icon(Icons.person_outline)),
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              value: _role,
              decoration: const InputDecoration(
                  labelText: 'Role',
                  prefixIcon: Icon(Icons.badge_outlined)),
              items: ['DOCTOR', 'MAIN_DOCTOR', 'PATIENT']
                  .map((r) => DropdownMenuItem(value: r, child: Text(r)))
                  .toList(),
              onChanged: (v) => setState(() => _role = v!),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: _promote,
              icon: const Icon(Icons.upgrade),
              label: const Text('Promote / Create User'),
            ),
          ]),
        ),
      ),
    );
  }
}
