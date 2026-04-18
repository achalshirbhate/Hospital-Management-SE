import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/providers/auth_provider.dart';
import '../../core/services/api_service.dart';
import '../../core/widgets/app_button.dart';
import '../../core/widgets/info_card.dart';
import '../auth/login_screen.dart';
import 'role_management_screen.dart';
import 'launchpad_submissions_screen.dart';
import '../shared/hospital_directory_screen.dart';

class MDHome extends StatefulWidget {
  const MDHome({super.key});
  @override
  State<MDHome> createState() => _MDHomeState();
}

class _MDHomeState extends State<MDHome> {
  int _tab = 0;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(index: _tab, children: const [
        _DashboardTab(),
        _QueuesTab(),
        _EmergencyTab(),
        _MDProfileTab(),
      ]),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _tab,
        onTap: (i) => setState(() => _tab = i),
        type: BottomNavigationBarType.fixed,
        selectedItemColor: AppColors.primary,
        unselectedItemColor: AppColors.textMuted,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.dashboard), label: 'Dashboard'),
          BottomNavigationBarItem(icon: Icon(Icons.queue), label: 'Queues'),
          BottomNavigationBarItem(icon: Icon(Icons.emergency), label: 'Emergency'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
        ],
      ),
    );
  }
}

// ── DASHBOARD TAB ──
class _DashboardTab extends StatefulWidget {
  const _DashboardTab();
  @override
  State<_DashboardTab> createState() => _DashboardTabState();
}

class _DashboardTabState extends State<_DashboardTab> {
  Map<String, dynamic> _data = {};
  bool _loading = true;

  @override
  void initState() { super.initState(); _load(); }

  Future<void> _load() async {
    try {
      final d = await ApiService.getMDDashboard();
      setState(() { _data = d; _loading = false; });
    } catch (_) { setState(() => _loading = false); }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Hospital Analytics Dashboard'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _load,
            tooltip: 'Refresh Dashboard',
          )
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _load,
              child: ListView(padding: const EdgeInsets.all(16), children: [
                // Metrics Grid - Only 5 cards (NO FINANCIAL METRICS)
                GridView.count(
                  crossAxisCount: 2,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  childAspectRatio: 1.4,
                  children: [
                    InfoCard(
                      title: 'Patient Count',
                      value: '${_data['patientCount'] ?? 0}',
                      icon: Icons.people,
                      color: AppColors.primary,
                    ),
                    InfoCard(
                      title: 'Appointments',
                      value: '${_data['totalAppointments'] ?? 0}',
                      icon: Icons.calendar_today,
                      color: AppColors.cyan,
                    ),
                    InfoCard(
                      title: 'Pending Referrals',
                      value: '${_data['pendingReferrals'] ?? 0}',
                      icon: Icons.swap_horiz,
                      color: AppColors.warning,
                    ),
                    InfoCard(
                      title: 'Pending Tokens',
                      value: '${_data['pendingTokens'] ?? 0}',
                      icon: Icons.confirmation_number,
                      color: AppColors.primary,
                    ),
                    // Emergency Alert Card
                    InfoCard(
                      title: '🚨 Active Emergencies',
                      value: '${_data['activeEmergencies'] ?? 0}',
                      icon: Icons.emergency,
                      color: AppColors.danger,
                    ),
                  ],
                ),
                
                const SizedBox(height: 24),
                
                // Doctor Activity Section
                const Text(
                  'Doctor Activity',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 12),
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: _data['doctorActivity'] != null && (_data['doctorActivity'] as Map).isNotEmpty
                        ? Column(
                            children: (_data['doctorActivity'] as Map<String, dynamic>)
                                .entries
                                .map((e) => ListTile(
                                      leading: const CircleAvatar(
                                        backgroundColor: AppColors.primaryLight,
                                        child: Icon(Icons.person, color: AppColors.primary),
                                      ),
                                      title: Text('Dr. ${e.key}'),
                                      trailing: Chip(
                                        label: Text('${e.value} consults'),
                                        backgroundColor: AppColors.greenLight,
                                        labelStyle: const TextStyle(
                                          color: AppColors.success,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ))
                                .toList(),
                          )
                        : const Padding(
                            padding: EdgeInsets.all(16),
                            child: Text(
                              'No activity yet.',
                              style: TextStyle(color: AppColors.textMuted),
                              textAlign: TextAlign.center,
                            ),
                          ),
                  ),
                ),
                
                const SizedBox(height: 24),
                
                // Actions Section
                const Text(
                  '⚙️ Actions',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 12),
                
                AppButton(
                  label: '👤 Manage User Roles',
                  icon: Icons.admin_panel_settings,
                  outline: true,
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const RoleManagementScreen()),
                    );
                  },
                ),
                const SizedBox(height: 12),
                
                AppButton(
                  label: '💡 View LaunchPad Ideas',
                  icon: Icons.lightbulb,
                  outline: true,
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const LaunchpadSubmissionsScreen()),
                    );
                  },
                ),
                const SizedBox(height: 12),
                
                AppButton(
                  label: '🏥 Hospital Directory',
                  icon: Icons.business,
                  outline: true,
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const HospitalDirectoryScreen()),
                    );
                  },
                ),
                
                const SizedBox(height: 24),
                
                // Active Sessions Section
                const Text(
                  'Active Approved Sessions',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 12),
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: _data['activeSessions'] != null && (_data['activeSessions'] as List).isNotEmpty
                        ? Column(
                            children: (_data['activeSessions'] as List)
                                .map((session) => ListTile(
                                      leading: const Icon(Icons.video_call, color: AppColors.primary),
                                      title: Text('${session['patientName']} - Dr. ${session['doctorName']}'),
                                      subtitle: Text('Scheduled: ${session['scheduledTime']}'),
                                      trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                                    ))
                                .toList(),
                          )
                        : const Text(
                            'No active sessions.',
                            style: TextStyle(color: AppColors.textMuted),
                            textAlign: TextAlign.center,
                          ),
                  ),
                ),
              ]),
            ),
    );
  }
}

// ── QUEUES TAB ──
class _QueuesTab extends StatefulWidget {
  const _QueuesTab();
  @override
  State<_QueuesTab> createState() => _QueuesTabState();
}

class _QueuesTabState extends State<_QueuesTab> {
  Map<String, dynamic> _queues = {};
  List<dynamic> _doctors = [];
  bool _loading = true;

  @override
  void initState() { super.initState(); _load(); }

  Future<void> _load() async {
    try {
      final q = await ApiService.getMDQueues();
      final d = await ApiService.getMDDoctors();
      setState(() { _queues = q; _doctors = d; _loading = false; });
    } catch (_) { setState(() => _loading = false); }
  }

  @override
  Widget build(BuildContext context) {
    final referrals = (_queues['referrals'] as List?) ?? [];
    final tokens    = (_queues['tokens']    as List?) ?? [];
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pending Referrals & Token Requests'),
        actions: [IconButton(icon: const Icon(Icons.refresh), onPressed: _load)],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _load,
              child: ListView(padding: const EdgeInsets.all(16), children: [
                if (referrals.isEmpty && tokens.isEmpty)
                  const Center(child: Padding(padding: EdgeInsets.all(40),
                    child: Text('No pending actions', style: TextStyle(color: AppColors.textMuted, fontSize: 16)))),
                if (referrals.isNotEmpty) ...[
                  const Text('Referral Requests', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
                  const SizedBox(height: 12),
                  ...referrals.map((r) => _ReferralCard(referral: r, doctors: _doctors, onDone: _load)),
                  const SizedBox(height: 20),
                ],
                if (tokens.isNotEmpty) ...[
                  const Text('Token Requests', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
                  const SizedBox(height: 12),
                  ...tokens.map((t) => _TokenQueueCard(token: t, onDone: _load)),
                ],
              ]),
            ),
    );
  }
}

class _ReferralCard extends StatelessWidget {
  final Map<String, dynamic> referral;
  final List<dynamic> doctors;
  final VoidCallback onDone;
  const _ReferralCard({required this.referral, required this.doctors, required this.onDone});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: const BorderSide(color: AppColors.primary, width: 1.5)),
      child: Padding(padding: const EdgeInsets.all(14), child: Column(
        crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('Referral #${referral['id']}', style: const TextStyle(fontWeight: FontWeight.w700, color: AppColors.primary, fontSize: 16)),
          const SizedBox(height: 8),
          Text('From: Dr. ${referral['fromDoctor']}  |  Patient: ${referral['patientName']}'),
          const SizedBox(height: 4),
          Text('Dept: ${referral['requestedSpecialty']}  |  Urgency: ${referral['urgency']}',
            style: const TextStyle(color: AppColors.warning, fontWeight: FontWeight.w600)),
          const SizedBox(height: 8),
          Text('"${referral['reason']}"', style: const TextStyle(color: AppColors.textMuted, fontSize: 13, fontStyle: FontStyle.italic)),
          const SizedBox(height: 12),
          Row(children: [
            Expanded(child: AppButton(label: 'Approve', onPressed: () async {
              await ApiService.processReferral(referral['id'], true, assignedDoctorId: doctors.isNotEmpty ? doctors[0]['id'] : null);
              onDone();
            })),
            const SizedBox(width: 8),
            Expanded(child: AppButton(label: 'Reject', danger: true, outline: true,
              onPressed: () async { await ApiService.processReferral(referral['id'], false); onDone(); })),
          ]),
        ],
      )),
    );
  }
}

class _TokenQueueCard extends StatelessWidget {
  final Map<String, dynamic> token;
  final VoidCallback onDone;
  const _TokenQueueCard({required this.token, required this.onDone});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: const BorderSide(color: AppColors.warning, width: 1.5)),
      child: Padding(padding: const EdgeInsets.all(14), child: Column(
        crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('${token['type']} Request #${token['id']}',
            style: const TextStyle(fontWeight: FontWeight.w700, color: AppColors.warning, fontSize: 16)),
          const SizedBox(height: 8),
          Text('Patient: ${token['patientName']}'),
          const SizedBox(height: 12),
          Row(children: [
            Expanded(child: AppButton(label: 'Approve', onPressed: () async {
              await ApiService.processToken(token['id'], true);
              onDone();
            })),
            const SizedBox(width: 8),
            Expanded(child: AppButton(label: 'Reject', danger: true, outline: true,
              onPressed: () async { await ApiService.processToken(token['id'], false); onDone(); })),
          ]),
        ],
      )),
    );
  }
}

// ── EMERGENCY TAB ──
class _EmergencyTab extends StatefulWidget {
  const _EmergencyTab();
  @override
  State<_EmergencyTab> createState() => _EmergencyTabState();
}

class _EmergencyTabState extends State<_EmergencyTab> {
  List<dynamic> _alerts = [];
  bool _loading = true;

  @override
  void initState() { super.initState(); _load(); }

  Future<void> _load() async {
    try {
      final data = await ApiService.getMDEmergencies();
      setState(() { _alerts = data; _loading = false; });
    } catch (_) { setState(() => _loading = false); }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('🚨 Emergency Alerts'),
        backgroundColor: _alerts.isNotEmpty ? AppColors.danger : null,
        foregroundColor: _alerts.isNotEmpty ? Colors.white : null,
        actions: [
          if (_alerts.isNotEmpty)
            TextButton(
              onPressed: () async {
                // Acknowledge all emergencies
                for (final alert in _alerts) {
                  await ApiService.acknowledgeEmergency(alert['id']);
                }
                _load();
              },
              child: const Text(
                'Ack All',
                style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
              ),
            ),
          IconButton(icon: const Icon(Icons.refresh), onPressed: _load),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _alerts.isEmpty
            ? const Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                Icon(Icons.check_circle, size: 64, color: AppColors.success),
                SizedBox(height: 12),
                Text('No active emergencies', style: TextStyle(color: AppColors.textMuted, fontSize: 16)),
              ]))
            : ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: _alerts.length,
                itemBuilder: (_, i) {
                  final a = _alerts[i];
                  final color = a['level'] == 'CRITICAL' ? AppColors.danger
                      : a['level'] == 'URGENT' ? AppColors.warning : AppColors.success;
                  return Card(
                    margin: const EdgeInsets.only(bottom: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                      side: BorderSide(color: color, width: 2)),
                    child: ListTile(
                      contentPadding: const EdgeInsets.all(12),
                      leading: CircleAvatar(
                        backgroundColor: color.withOpacity(0.15),
                        child: Icon(Icons.emergency, color: color),
                      ),
                      title: Text(
                        '${a['level']} — ${a['patientName']}',
                        style: TextStyle(fontWeight: FontWeight.w700, color: color, fontSize: 16),
                      ),
                      subtitle: Text(a['alertTime']?.toString().substring(0, 16) ?? ''),
                      trailing: ElevatedButton(
                        onPressed: () async {
                          await ApiService.acknowledgeEmergency(a['id']);
                          _load();
                        },
                        style: ElevatedButton.styleFrom(backgroundColor: AppColors.success),
                        child: const Text('✓ Ack', style: TextStyle(color: Colors.white, fontSize: 12)),
                      ),
                    ),
                  );
                }),
    );
  }
}

// ── PROFILE TAB ──
class _MDProfileTab extends StatelessWidget {
  const _MDProfileTab();
  @override
  Widget build(BuildContext context) {
    final user = context.read<AuthProvider>().user!;
    return Scaffold(
      appBar: AppBar(title: const Text('Profile')),
      body: ListView(padding: const EdgeInsets.all(20), children: [
        CircleAvatar(
          radius: 50,
          backgroundColor: AppColors.primaryLight,
          child: Text(
            user.fullName[0].toUpperCase(),
            style: const TextStyle(fontSize: 40, fontWeight: FontWeight.w700, color: AppColors.primary),
          ),
        ),
        const SizedBox(height: 20),
        Center(child: Text(user.fullName, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w700))),
        const SizedBox(height: 8),
        Center(child: Text(user.email, style: const TextStyle(color: AppColors.textMuted, fontSize: 14))),
        const SizedBox(height: 12),
        Center(child: Chip(
          label: const Text('MAIN DOCTOR'),
          backgroundColor: AppColors.primaryLight,
          labelStyle: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.w600),
        )),
        const SizedBox(height: 40),
        AppButton(
          label: 'Logout',
          danger: true,
          icon: Icons.logout,
          onPressed: () {
            context.read<AuthProvider>().logout();
            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(builder: (_) => const LoginScreen()),
              (_) => false,
            );
          },
        ),
      ]),
    );
  }
}
