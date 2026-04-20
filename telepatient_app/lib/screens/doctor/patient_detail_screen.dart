import 'package:flutter/material.dart';
import '../../models/patient_model.dart';
import '../../services/doctor_service.dart';
import '../../utils/helpers.dart';
import '../../utils/app_theme.dart';
import '../../widgets/loading_overlay.dart';

class PatientDetailScreen extends StatefulWidget {
  final PatientModel patient;
  final int doctorId;
  const PatientDetailScreen(
      {super.key, required this.patient, required this.doctorId});

  @override
  State<PatientDetailScreen> createState() => _PatientDetailScreenState();
}

class _PatientDetailScreenState extends State<PatientDetailScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabCtrl;
  final _service = DoctorService();

  // Consultation form
  final _notesCtrl  = TextEditingController();
  final _rxCtrl     = TextEditingController();
  final _urlCtrl    = TextEditingController();
  bool _consultLoading = false;

  // Referral form
  final _specialtyCtrl = TextEditingController();
  final _reasonCtrl    = TextEditingController();
  String _urgency      = 'MEDIUM';
  bool _refLoading     = false;

  @override
  void initState() {
    super.initState();
    _tabCtrl = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabCtrl.dispose();
    _notesCtrl.dispose(); _rxCtrl.dispose(); _urlCtrl.dispose();
    _specialtyCtrl.dispose(); _reasonCtrl.dispose();
    super.dispose();
  }

  Future<void> _addConsultation() async {
    if (_notesCtrl.text.isEmpty) {
      showError(context, 'Notes are required'); return;
    }
    setState(() => _consultLoading = true);
    try {
      await _service.addConsultation(
        doctorId: widget.doctorId,
        patientId: widget.patient.id,
        notes: _notesCtrl.text,
        prescription: _rxCtrl.text.isNotEmpty ? _rxCtrl.text : null,
        reportsUrl: _urlCtrl.text.isNotEmpty ? _urlCtrl.text : null,
      );
      if (mounted) {
        showSuccess(context, 'Consultation saved!');
        _notesCtrl.clear(); _rxCtrl.clear(); _urlCtrl.clear();
      }
    } catch (e) {
      if (mounted) showError(context, e.toString());
    } finally {
      if (mounted) setState(() => _consultLoading = false);
    }
  }

  Future<void> _requestReferral() async {
    if (_specialtyCtrl.text.isEmpty || _reasonCtrl.text.isEmpty) {
      showError(context, 'Fill all fields'); return;
    }
    setState(() => _refLoading = true);
    try {
      await _service.requestReferral(
        doctorId: widget.doctorId,
        patientId: widget.patient.id,
        requestedSpecialty: _specialtyCtrl.text,
        urgency: _urgency,
        reason: _reasonCtrl.text,
      );
      if (mounted) {
        showSuccess(context, 'Referral submitted to MD!');
        _specialtyCtrl.clear(); _reasonCtrl.clear();
      }
    } catch (e) {
      if (mounted) showError(context, e.toString());
    } finally {
      if (mounted) setState(() => _refLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.patient.fullName),
        bottom: TabBar(
          controller: _tabCtrl,
          tabs: const [
            Tab(icon: Icon(Icons.note_add), text: 'Consultation'),
            Tab(icon: Icon(Icons.transfer_within_a_station), text: 'Referral'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabCtrl,
        children: [
          // ── Consultation Tab ──────────────────────────────────────────────
          LoadingOverlay(
            isLoading: _consultLoading,
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(children: [
                _PatientInfoCard(patient: widget.patient),
                const SizedBox(height: 20),
                TextField(
                  controller: _notesCtrl,
                  maxLines: 4,
                  decoration: const InputDecoration(
                    labelText: 'Clinical Notes *',
                    prefixIcon: Icon(Icons.notes),
                    alignLabelWithHint: true,
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: _rxCtrl,
                  maxLines: 3,
                  decoration: const InputDecoration(
                    labelText: 'Prescription (optional)',
                    prefixIcon: Icon(Icons.medication),
                    alignLabelWithHint: true,
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: _urlCtrl,
                  decoration: const InputDecoration(
                    labelText: 'Report URL (optional)',
                    prefixIcon: Icon(Icons.link),
                  ),
                ),
                const SizedBox(height: 24),
                ElevatedButton.icon(
                  onPressed: _addConsultation,
                  icon: const Icon(Icons.save),
                  label: const Text('Save Consultation'),
                ),
              ]),
            ),
          ),

          // ── Referral Tab ──────────────────────────────────────────────────
          LoadingOverlay(
            isLoading: _refLoading,
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(children: [
                _PatientInfoCard(patient: widget.patient),
                const SizedBox(height: 20),
                TextField(
                  controller: _specialtyCtrl,
                  decoration: const InputDecoration(
                    labelText: 'Requested Specialty *',
                    prefixIcon: Icon(Icons.medical_services_outlined),
                  ),
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  value: _urgency,
                  decoration: const InputDecoration(
                    labelText: 'Urgency',
                    prefixIcon: Icon(Icons.priority_high),
                  ),
                  items: ['LOW', 'MEDIUM', 'HIGH', 'CRITICAL']
                      .map((u) => DropdownMenuItem(value: u, child: Text(u)))
                      .toList(),
                  onChanged: (v) => setState(() => _urgency = v!),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: _reasonCtrl,
                  maxLines: 4,
                  decoration: const InputDecoration(
                    labelText: 'Reason *',
                    prefixIcon: Icon(Icons.description_outlined),
                    alignLabelWithHint: true,
                  ),
                ),
                const SizedBox(height: 24),
                ElevatedButton.icon(
                  onPressed: _requestReferral,
                  icon: const Icon(Icons.send),
                  label: const Text('Submit Referral'),
                  style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.orange),
                ),
              ]),
            ),
          ),
        ],
      ),
    );
  }
}

class _PatientInfoCard extends StatelessWidget {
  final PatientModel patient;
  const _PatientInfoCard({required this.patient});

  @override
  Widget build(BuildContext context) {
    return Card(
      color: AppTheme.primary.withOpacity(0.05),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(children: [
          CircleAvatar(
            radius: 28,
            backgroundColor: AppTheme.primary.withOpacity(0.2),
            child: Text(
              patient.fullName[0].toUpperCase(),
              style: const TextStyle(
                  fontSize: 22,
                  color: AppTheme.primary,
                  fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(width: 16),
          Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(patient.fullName,
                style: const TextStyle(
                    fontWeight: FontWeight.bold, fontSize: 16)),
            if (patient.age != null)
              Text('Age: ${patient.age}',
                  style: const TextStyle(fontSize: 13)),
          ]),
        ]),
      ),
    );
  }
}
