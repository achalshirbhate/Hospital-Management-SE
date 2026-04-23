import 'package:flutter/material.dart';
import '../../services/shared_service.dart';
import '../../utils/helpers.dart';
import '../../widgets/loading_overlay.dart';

class LaunchpadSubmitScreen extends StatefulWidget {
  final int userId;
  const LaunchpadSubmitScreen({super.key, required this.userId});

  @override
  State<LaunchpadSubmitScreen> createState() => _LaunchpadSubmitScreenState();
}

class _LaunchpadSubmitScreenState extends State<LaunchpadSubmitScreen> {
  final _formKey      = GlobalKey<FormState>();
  final _titleCtrl    = TextEditingController();
  final _descCtrl     = TextEditingController();
  final _domainCtrl   = TextEditingController();
  final _contactCtrl  = TextEditingController();
  final _service      = SharedService();
  bool _loading       = false;

  @override
  void dispose() {
    _titleCtrl.dispose(); _descCtrl.dispose();
    _domainCtrl.dispose(); _contactCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _loading = true);
    try {
      await _service.submitIdea(
        submitterId: widget.userId,
        ideaTitle: _titleCtrl.text.trim(),
        description: _descCtrl.text.trim(),
        domain: _domainCtrl.text.trim(),
        contactInfo: _contactCtrl.text.trim(),
      );
      if (mounted) {
        showSuccess(context, 'Idea submitted to LaunchPad!');
        Navigator.pop(context);
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
      appBar: AppBar(title: const Text('Submit Idea')),
      body: LoadingOverlay(
        isLoading: _loading,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(children: [
              const Icon(Icons.lightbulb, size: 56, color: Colors.amber),
              const SizedBox(height: 8),
              const Text(
                'Share your innovation idea with the Medical Director.',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey),
              ),
              const SizedBox(height: 24),
              TextFormField(
                controller: _titleCtrl,
                decoration: const InputDecoration(
                    labelText: 'Idea Title *',
                    prefixIcon: Icon(Icons.title)),
                validator: (v) =>
                    v == null || v.isEmpty ? 'Required' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _descCtrl,
                maxLines: 4,
                decoration: const InputDecoration(
                    labelText: 'Description *',
                    prefixIcon: Icon(Icons.description_outlined),
                    alignLabelWithHint: true),
                validator: (v) =>
                    v == null || v.isEmpty ? 'Required' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _domainCtrl,
                decoration: const InputDecoration(
                    labelText: 'Domain (e.g. AI, Telemedicine) *',
                    prefixIcon: Icon(Icons.category_outlined)),
                validator: (v) =>
                    v == null || v.isEmpty ? 'Required' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _contactCtrl,
                decoration: const InputDecoration(
                    labelText: 'Contact Info *',
                    prefixIcon: Icon(Icons.contact_phone_outlined)),
                validator: (v) =>
                    v == null || v.isEmpty ? 'Required' : null,
              ),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: _submit,
                icon: const Icon(Icons.send),
                label: const Text('Submit to LaunchPad'),
                style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.amber,
                    foregroundColor: Colors.black),
              ),
            ]),
          ),
        ),
      ),
    );
  }
}
