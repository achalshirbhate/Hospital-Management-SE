import 'package:flutter/material.dart';
import '../../../services/md_service.dart';
import '../../../models/patient_model.dart';
import '../../../utils/helpers.dart';
import '../../../utils/app_theme.dart';
import '../../../widgets/empty_state.dart';
import '../../../widgets/loading_overlay.dart';

class MdPatientsTab extends StatefulWidget {
  final int mdId;
  const MdPatientsTab({super.key, required this.mdId});

  @override
  State<MdPatientsTab> createState() => _MdPatientsTabState();
}

class _MdPatientsTabState extends State<MdPatientsTab>
    with SingleTickerProviderStateMixin {
  late TabController _tabCtrl;
  final _service = MdService();

  List<PatientModel> _patients = [];
  List<PatientModel> _doctors  = [];
  bool _loadingP = true;
  bool _loadingD = true;
  String _searchP = '';
  String _searchD = '';

  @override
  void initState() {
    super.initState();
    _tabCtrl = TabController(length: 2, vsync: this);
    _loadPatients();
    _loadDoctors();
  }

  @override
  void dispose() {
    _tabCtrl.dispose();
    super.dispose();
  }

  Future<void> _loadPatients() async {
    setState(() => _loadingP = true);
    try {
      _patients = await _service.getAllPatients();
    } catch (e) {
      if (mounted) showError(context, e.toString());
    } finally {
      if (mounted) setState(() => _loadingP = false);
    }
  }

  Future<void> _loadDoctors() async {
    setState(() => _loadingD = true);
    try {
      _doctors = await _service.getAllDoctors();
    } catch (e) {
      if (mounted) showError(context, e.toString());
    } finally {
      if (mounted) setState(() => _loadingD = false);
    }
  }

  Future<void> _assignPatient(int patientId) async {
    if (_doctors.isEmpty) {
      showError(context, 'No doctors available'); return;
    }
    final doctorId = await showDialog<int>(
      context: context,
      builder: (_) => _AssignDoctorDialog(doctors: _doctors),
    );
    if (doctorId == null) return;
    try {
      await _service.directAssignPatient(patientId, doctorId);
      if (mounted) {
        showSuccess(context, 'Patient assigned!');
        _loadPatients();
      }
    } catch (e) {
      if (mounted) showError(context, e.toString());
    }
  }

  List<PatientModel> get _filteredPatients => _patients
      .where((p) =>
          p.fullName.toLowerCase().contains(_searchP.toLowerCase()))
      .toList();

  List<PatientModel> get _filteredDoctors => _doctors
      .where((d) =>
          d.fullName.toLowerCase().contains(_searchD.toLowerCase()))
      .toList();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('People'),
        bottom: TabBar(
          controller: _tabCtrl,
          tabs: [
            Tab(text: 'Patients (${_patients.length})'),
            Tab(text: 'Doctors (${_doctors.length})'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabCtrl,
        children: [
          // ── Patients ──────────────────────────────────────────────────────
          LoadingOverlay(
            isLoading: _loadingP,
            child: Column(children: [
              Padding(
                padding: const EdgeInsets.all(12),
                child: TextField(
                  onChanged: (v) => setState(() => _searchP = v),
                  decoration: const InputDecoration(
                      hintText: 'Search patients...',
                      prefixIcon: Icon(Icons.search)),
                ),
              ),
              Expanded(
                child: RefreshIndicator(
                  onRefresh: _loadPatients,
                  child: _filteredPatients.isEmpty && !_loadingP
                      ? const EmptyState(message: 'No patients found.')
                      : ListView.builder(
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          itemCount: _filteredPatients.length,
                          itemBuilder: (_, i) {
                            final p = _filteredPatients[i];
                            return Card(
                              margin: const EdgeInsets.only(bottom: 8),
                              child: ListTile(
                                leading: CircleAvatar(
                                  backgroundColor:
                                      AppTheme.primary.withOpacity(0.15),
                                  child: Text(p.fullName[0].toUpperCase(),
                                      style: const TextStyle(
                                          color: AppTheme.primary,
                                          fontWeight: FontWeight.bold)),
                                ),
                                title: Text(p.fullName),
                                subtitle: Text(
                                    p.historySummary ?? 'No assignment',
                                    style: const TextStyle(fontSize: 12)),
                                trailing: IconButton(
                                  icon: const Icon(Icons.assignment_ind,
                                      color: AppTheme.primary),
                                  tooltip: 'Assign Doctor',
                                  onPressed: () => _assignPatient(p.id),
                                ),
                              ),
                            );
                          },
                        ),
                ),
              ),
            ]),
          ),

          // ── Doctors ───────────────────────────────────────────────────────
          LoadingOverlay(
            isLoading: _loadingD,
            child: Column(children: [
              Padding(
                padding: const EdgeInsets.all(12),
                child: TextField(
                  onChanged: (v) => setState(() => _searchD = v),
                  decoration: const InputDecoration(
                      hintText: 'Search doctors...',
                      prefixIcon: Icon(Icons.search)),
                ),
              ),
              Expanded(
                child: RefreshIndicator(
                  onRefresh: _loadDoctors,
                  child: _filteredDoctors.isEmpty && !_loadingD
                      ? const EmptyState(message: 'No doctors found.')
                      : ListView.builder(
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          itemCount: _filteredDoctors.length,
                          itemBuilder: (_, i) {
                            final d = _filteredDoctors[i];
                            return Card(
                              margin: const EdgeInsets.only(bottom: 8),
                              child: ListTile(
                                leading: CircleAvatar(
                                  backgroundColor:
                                      AppTheme.accent.withOpacity(0.15),
                                  child: const Icon(Icons.medical_services,
                                      color: AppTheme.accent),
                                ),
                                title: Text('Dr. ${d.fullName}'),
                                subtitle: Text(
                                    d.specialty ?? d.historySummary ?? '',
                                    style: const TextStyle(fontSize: 12)),
                              ),
                            );
                          },
                        ),
                ),
              ),
            ]),
          ),
        ],
      ),
    );
  }
}

// ─── Assign Doctor Dialog ─────────────────────────────────────────────────────
class _AssignDoctorDialog extends StatelessWidget {
  final List<PatientModel> doctors;
  const _AssignDoctorDialog({required this.doctors});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Select Doctor'),
      content: SizedBox(
        width: double.maxFinite,
        child: ListView.builder(
          shrinkWrap: true,
          itemCount: doctors.length,
          itemBuilder: (_, i) => ListTile(
            leading: const Icon(Icons.medical_services, color: AppTheme.accent),
            title: Text('Dr. ${doctors[i].fullName}'),
            subtitle: Text(doctors[i].specialty ?? ''),
            onTap: () => Navigator.pop(context, doctors[i].id),
          ),
        ),
      ),
      actions: [
        TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel')),
      ],
    );
  }
}
