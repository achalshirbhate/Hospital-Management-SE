import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/providers/auth_provider.dart';
import '../../core/services/api_service.dart';
import '../../core/models/patient_model.dart';
import '../../core/widgets/app_button.dart';
import '../auth/login_screen.dart';
import '../patient/patient_reports_screen.dart';

class DoctorHome extends StatefulWidget {
  const DoctorHome({super.key});
  @override
  State<DoctorHome> createState() => _DoctorHomeState();
}

class _DoctorHomeState extends State<DoctorHome> {
  int _tab = 0;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(index: _tab, children: const [
        _PatientsTab(),
        _DoctorProfileTab(),
      ]),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _tab,
        onTap: (i) => setState(() => _tab = i),
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.people), label: 'Patients'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
        ],
      ),
    );
  }
}

class _PatientsTab extends StatefulWidget {
  const _PatientsTab();
  @override
  State<_PatientsTab> createState() => _PatientsTabState();
}

class _PatientsTabState extends State<_PatientsTab> {
  List<PatientModel> _all = [];
  List<PatientModel> _filtered = [];
  bool _loading = true;
  final _search = TextEditingController();

  @override
  void initState() { super.initState(); _load(); }

  Future<void> _load() async {
    final user = context.read<AuthProvider>().user!;
    try {
      final data = await ApiService.getDoctorPatients(user.userId);
      final list = data.map((e) => PatientModel.fromJson(e)).toList();
      setState(() { _all = list; _filtered = list; _loading = false; });
    } catch (_) { setState(() => _loading = false); }
  }

  void _filter(String q) {
    setState(() => _filtered = _all.where((p) =>
      p.fullName.toLowerCase().contains(q.toLowerCase())).toList());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('My Patients'),
        actions: [IconButton(icon: const Icon(Icons.refresh), onPressed: _load)]),
      body: Column(children: [
        // Stats row
        if (!_loading) Padding(
          padding: const EdgeInsets.fromLTRB(12, 12, 12, 0),
          child: Row(children: [
            _StatChip(label: 'Total', value: '${_all.length}', color: AppColors.primary),
            const SizedBox(width: 8),
            _StatChip(label: 'Active', value: '${_all.where((p) => p.lastConsultation != null).length}', color: AppColors.success),
            const SizedBox(width: 8),
            _StatChip(label: 'No History', value: '${_all.where((p) => p.lastConsultation == null).length}', color: AppColors.textMuted),
          ]),
        ),
        Padding(padding: const EdgeInsets.all(12),
          child: TextField(controller: _search, onChanged: _filter,
            decoration: const InputDecoration(prefixIcon: Icon(Icons.search), hintText: 'Search patient...'))),
        Expanded(child: _loading
          ? const Center(child: CircularProgressIndicator())
          : _filtered.isEmpty
            ? const Center(child: Text('No patients found', style: TextStyle(color: AppColors.textMuted)))
            : ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                itemCount: _filtered.length,
                itemBuilder: (_, i) => _PatientCard(patient: _filtered[i], onRefresh: _load))),
      ]),
    );
  }
}

class _StatChip extends StatelessWidget {
  final String label, value;
  final Color color;
  const _StatChip({required this.label, required this.value, required this.color});
  @override
  Widget build(BuildContext context) => Expanded(child: Card(
    child: Padding(padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
      child: Column(children: [
        Text(value, style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: color)),
        Text(label, style: const TextStyle(fontSize: 11, color: AppColors.textMuted)),
      ]))));
}

class _PatientCard extends StatelessWidget {
  final PatientModel patient;
  final VoidCallback onRefresh;
  const _PatientCard({required this.patient, required this.onRefresh});

  @override
  Widget build(BuildContext context) {
    final hasVisit = patient.lastConsultation != null;
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(padding: const EdgeInsets.all(14), child: Column(
        crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            CircleAvatar(
              backgroundColor: hasVisit ? AppColors.primaryLight : AppColors.bgSecondary,
              child: Text(patient.fullName[0].toUpperCase(),
                style: TextStyle(color: hasVisit ? AppColors.primary : AppColors.textMuted, fontWeight: FontWeight.w700)),
            ),
            const SizedBox(width: 12),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(children: [
                Expanded(child: Text(patient.fullName,
                  style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15))),
                Container(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(color: AppColors.primaryLight, borderRadius: BorderRadius.circular(8)),
                  child: Text('ID ${patient.id}', style: const TextStyle(fontSize: 11, color: AppColors.primary, fontWeight: FontWeight.w600))),
              ]),
              if (patient.age != null)
                Text('Age: ${patient.age}', style: const TextStyle(fontSize: 12, color: AppColors.textMuted)),
              if (hasVisit)
                Text('Last visit: ${patient.lastConsultation!.day}/${patient.lastConsultation!.month}/${patient.lastConsultation!.year}',
                  style: const TextStyle(fontSize: 12, color: AppColors.textMuted)),
            ])),
          ]),
          if (patient.historySummary.isNotEmpty && patient.historySummary != 'No history available') ...[
            const SizedBox(height: 8),
            Text(patient.historySummary, maxLines: 2, overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontSize: 13, color: AppColors.textMuted)),
          ],
          const SizedBox(height: 12),
          Wrap(spacing: 8, runSpacing: 8, children: [
            _ActionBtn(label: '📝 Notes', onTap: () => _showNotesDialog(context)),
            _ActionBtn(label: '🔄 Refer', onTap: () => _showReferDialog(context)),
            _ActionBtn(label: '📋 History', onTap: () {}),
            _ActionBtn(label: '📁 Reports', onTap: () => Navigator.push(context,
              MaterialPageRoute(builder: (_) => PatientReportsScreen(patientId: patient.id)))),
          ]),
        ],
      )),
    );
  }

  void _showNotesDialog(BuildContext context) {
    final notesCtrl = TextEditingController();
    final rxCtrl    = TextEditingController();
    showDialog(context: context, builder: (_) => AlertDialog(
      title: Text('Notes — ${patient.fullName}'),
      content: SingleChildScrollView(child: Column(mainAxisSize: MainAxisSize.min, children: [
        TextField(controller: notesCtrl, maxLines: 3,
          decoration: const InputDecoration(labelText: 'Diagnosis / Notes')),
        const SizedBox(height: 12),
        TextField(controller: rxCtrl, decoration: const InputDecoration(labelText: 'Prescription')),
      ])),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
        ElevatedButton(onPressed: () async {
          final user = context.read<AuthProvider>().user!;
          await ApiService.addConsultation(user.userId, patient.id, notesCtrl.text, rxCtrl.text, '');
          Navigator.pop(context);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Saved!'), backgroundColor: Colors.green));
        }, child: const Text('Save')),
      ],
    ));
  }

  void _showReferDialog(BuildContext context) {
    final reasonCtrl = TextEditingController();
    String specialty = 'Cardiology';
    String urgency   = 'Medium';
    showDialog(context: context, builder: (_) => AlertDialog(
      title: Text('Refer — ${patient.fullName}'),
      content: SingleChildScrollView(child: Column(mainAxisSize: MainAxisSize.min, children: [
        TextField(controller: reasonCtrl, maxLines: 3,
          decoration: const InputDecoration(labelText: 'Reason for referral')),
        const SizedBox(height: 12),
        DropdownButtonFormField<String>(
          value: specialty,
          items: ['Cardiology','Radiology','Orthopedics','Neurology','General Practice']
            .map((s) => DropdownMenuItem(value: s, child: Text(s))).toList(),
          onChanged: (v) => specialty = v!,
          decoration: const InputDecoration(labelText: 'Specialty'),
        ),
        const SizedBox(height: 12),
        DropdownButtonFormField<String>(
          value: urgency,
          items: ['Low','Medium','High'].map((s) => DropdownMenuItem(value: s, child: Text(s))).toList(),
          onChanged: (v) => urgency = v!,
          decoration: const InputDecoration(labelText: 'Urgency'),
        ),
      ])),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
        ElevatedButton(onPressed: () async {
          final user = context.read<AuthProvider>().user!;
          await ApiService.addReferral(user.userId, {
            'patientId': patient.id, 'requestedSpecialty': specialty,
            'urgency': urgency, 'reason': reasonCtrl.text,
          });
          Navigator.pop(context);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Referral sent to MD'), backgroundColor: Colors.green));
        }, child: const Text('Submit')),
      ],
    ));
  }
}

class _ActionBtn extends StatelessWidget {
  final String label;
  final VoidCallback onTap;
  const _ActionBtn({required this.label, required this.onTap});
  @override
  Widget build(BuildContext context) => InkWell(
    onTap: onTap,
    borderRadius: BorderRadius.circular(8),
    child: Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
      decoration: BoxDecoration(
        color: AppColors.bgSecondary, borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.border)),
      child: Text(label, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600))));
}

class _DoctorProfileTab extends StatelessWidget {
  const _DoctorProfileTab();
  @override
  Widget build(BuildContext context) {
    final user = context.read<AuthProvider>().user!;
    return Scaffold(
      appBar: AppBar(title: const Text('Profile')),
      body: ListView(padding: const EdgeInsets.all(20), children: [
        CircleAvatar(radius: 40, backgroundColor: AppColors.primaryLight,
          child: Text(user.fullName[0].toUpperCase(),
            style: const TextStyle(fontSize: 32, fontWeight: FontWeight.w700, color: AppColors.primary))),
        const SizedBox(height: 16),
        Center(child: Text(user.fullName, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w700))),
        Center(child: Text(user.email, style: const TextStyle(color: AppColors.textMuted))),
        const SizedBox(height: 8),
        Center(child: Chip(label: const Text('DOCTOR'), backgroundColor: AppColors.primaryLight,
          labelStyle: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.w600))),
        const SizedBox(height: 32),
        AppButton(label: 'Logout', danger: true, icon: Icons.logout,
          onPressed: () {
            context.read<AuthProvider>().logout();
            Navigator.pushAndRemoveUntil(context,
              MaterialPageRoute(builder: (_) => const LoginScreen()), (_) => false);
          }),
      ]),
    );
  }
}
