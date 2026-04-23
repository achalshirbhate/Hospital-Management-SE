import 'package:flutter/material.dart';
import '../../../services/doctor_service.dart';
import '../../../utils/helpers.dart';
import '../../../widgets/loading_overlay.dart';

class DoctorAddPatientTab extends StatefulWidget {
  final int doctorId;
  const DoctorAddPatientTab({super.key, required this.doctorId});

  @override
  State<DoctorAddPatientTab> createState() => _DoctorAddPatientTabState();
}

class _DoctorAddPatientTabState extends State<DoctorAddPatientTab> {
  final _formKey   = GlobalKey<FormState>();
  final _nameCtrl  = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _passCtrl  = TextEditingController();
  final _ageCtrl   = TextEditingController();
  final _service   = DoctorService();
  bool _loading    = false;

  @override
  void dispose() {
    _nameCtrl.dispose(); _emailCtrl.dispose();
    _passCtrl.dispose(); _ageCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _loading = true);
    try {
      await _service.addPatient(
        doctorId: widget.doctorId,
        fullName: _nameCtrl.text.trim(),
        email: _emailCtrl.text.trim(),
        password: _passCtrl.text,
        age: _ageCtrl.text.isNotEmpty ? int.tryParse(_ageCtrl.text) : null,
      );
      if (mounted) {
        showSuccess(context, 'Patient added successfully!');
        _formKey.currentState!.reset();
        _nameCtrl.clear(); _emailCtrl.clear();
        _passCtrl.clear(); _ageCtrl.clear();
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
      appBar: AppBar(title: const Text('Add New Patient')),
      body: LoadingOverlay(
        isLoading: _loading,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(children: [
              const Icon(Icons.person_add, size: 56, color: Colors.blue),
              const SizedBox(height: 8),
              const Text('Register a new patient and assign them to your care.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.grey)),
              const SizedBox(height: 24),
              TextFormField(
                controller: _nameCtrl,
                decoration: const InputDecoration(
                    labelText: 'Full Name *',
                    prefixIcon: Icon(Icons.person_outline)),
                validator: (v) =>
                    v == null || v.isEmpty ? 'Required' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _emailCtrl,
                keyboardType: TextInputType.emailAddress,
                decoration: const InputDecoration(
                    labelText: 'Email *',
                    prefixIcon: Icon(Icons.email_outlined)),
                validator: (v) =>
                    v == null || !v.contains('@') ? 'Valid email required' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _passCtrl,
                obscureText: true,
                decoration: const InputDecoration(
                    labelText: 'Password *',
                    prefixIcon: Icon(Icons.lock_outline)),
                validator: (v) =>
                    v == null || v.length < 6 ? 'Min 6 chars' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _ageCtrl,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                    labelText: 'Age (optional)',
                    prefixIcon: Icon(Icons.cake_outlined)),
              ),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: _submit,
                icon: const Icon(Icons.save),
                label: const Text('Add Patient'),
              ),
            ]),
          ),
        ),
      ),
    );
  }
}
