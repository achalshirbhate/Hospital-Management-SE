import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/providers/auth_provider.dart';
import '../../core/services/api_service.dart';
import '../../core/widgets/app_button.dart';
import '../../core/widgets/info_card.dart';
import '../auth/login_screen.dart';

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
      appBar: AppBar(title: const Text('Hospital Analytics'),
        actions: [IconButton(icon: const Icon(Icons.refresh), onPressed: _load)]),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _load,
              child: ListView(padding: const EdgeInsets.all(16), children: [
                GridView.count(crossAxisCount: 2, shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisSpacing: 12, mainAxisSpacing: 12, childAspectRatio: 1.4,
                  children: [
                    InfoCard(title: 'Total Revenue', value: '₹${_data['totalRevenue'] ?? 0}', icon: Icons.currency_rupee, color: AppColors.success),
                    InfoCard(title: 'Total Expenses', value: '₹${_data['totalExpenses'] ?? 0}', icon: Icons.money_off, color: AppColors.danger),
                    InfoCard(title: 'Profit / Loss', value: '₹${_data['profitLoss'] ?? 0}', icon: Icons.trending_up, color: AppColors.primary),
                    InfoCard(title: 'Patients', value: '${_data['patientCount'] ?? 0}', icon: Icons.people, color: AppColors.cyan),
                    InfoCard(title: 'Appointments', value: '${_data['totalAppointments'] ?? 0}', icon: Icons.calendar_today, color: AppColors.warning),
                    InfoCard(title: 'Pending Referrals', value: '${_data['pendingReferrals'] ?? 0}', icon: Icons.swap_horiz, color: AppColors.primary),
                  ],
                ),
                const SizedBox(height: 20),
                const Text('Doctor Activity', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
                const SizedBox(height: 10),
                if (_data['doctorActivity'] != null)
                  ...(_data['doctorActivity'] as Map<String, dynamic>).entries.map((e) =>
                    Card(child: ListTile(
                      leading: const CircleAvatar(backgroundColor: AppColors.primaryLight,
                        child: Icon(Icons.person, color: AppColors.primary)),
                      title: Text('Dr. ${e.key}'),
                      trailing: Chip(label: Text('${e.value} consults'),
                        backgroundColor: AppColors.greenLight,
                        labelStyle: const TextStyle(color: AppColors.success, fontWeight: FontWeight.w600)),
                    ))),
                const SizedBox(height: 20),
                AppButton(label: '+ Add Finance Record', icon: Icons.add,
                  onPressed: () => _showFinanceDialog(context)),
              ]),
            ),
    );
  }

  void _showFinanceDialog(BuildContext context) {
    String type = 'REVENUE';
    final amountCtrl = TextEditingController();
    final descCtrl   = TextEditingController();
    showDialog(context: context, builder: (_) => AlertDialog(
      title: const Text('Add Financial Record'),
      content: SingleChildScrollView(child: Column(mainAxisSize: MainAxisSize.min, children: [
        DropdownButtonFormField<String>(
          value: type,
          items: const [
            DropdownMenuItem(value: 'REVENUE', child: Text('Revenue')),
            DropdownMenuItem(value: 'EXPENDITURE', child: Text('Expenditure')),
          ],
          onChanged: (v) => type = v!,
          decoration: const InputDecoration(labelText: 'Type'),
        ),
        const SizedBox(height: 12),
        TextField(controller: amountCtrl, keyboardType: TextInputType.number,
          decoration: const InputDecoration(labelText: 'Amount (₹)')),
        const SizedBox(height: 12),
        TextField(controller: descCtrl, decoration: const InputDecoration(labelText: 'Description')),
      ])),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
        ElevatedButton(onPressed: () async {
          await ApiService._client.post(Uri.parse(ApiConstants.mdFinance),
            headers: {'Content-Type': 'application/json'},
            body: '{"type":"$type","amount":${amountCtrl.text},"description":"${descCtrl.text}"}');
          Navigator.pop(context); _load();
        }, child: const Text('Add')),
      ],
    ));
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
      appBar: AppBar(title: const Text('Pending Queues'),
        actions: [IconButton(icon: const Icon(Icons.refresh), onPressed: _load)]),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _load,
              child: ListView(padding: const EdgeInsets.all(16), children: [
                if (referrals.isEmpty && tokens.isEmpty)
                  const Center(child: Padding(padding: EdgeInsets.all(40),
                    child: Text('No pending actions', style: TextStyle(color: AppColors.textMuted)))),
                if (referrals.isNotEmpty) ...[
                  const Text('Referral Requests', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
                  const SizedBox(height: 8),
                  ...referrals.map((r) => _ReferralCard(referral: r, doctors: _doctors, onDone: _load)),
                  const SizedBox(height: 16),
                ],
                if (tokens.isNotEmpty) ...[
                  const Text('Token Requests', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
                  const SizedBox(height: 8),
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
          Text('Referral #${referral['id']}', style: const TextStyle(fontWeight: FontWeight.w700, color: AppColors.primary)),
          Text('From: Dr. ${referral['fromDoctor']}  |  Patient: ${referral['patientName']}'),
          Text('Dept: ${referral['requestedSpecialty']}  |  Urgency: ${referral['urgency']}',
            style: const TextStyle(color: AppColors.warning, fontWeight: FontWeight.w600)),
          Text('"${referral['reason']}"', style: const TextStyle(color: AppColors.textMuted, fontSize: 13)),
          const SizedBox(height: 10),
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
            style: const TextStyle(fontWeight: FontWeight.w700, color: AppColors.warning)),
          Text('Patient: ${token['patientName']}'),
          const SizedBox(height: 10),
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
      appBar: AppBar(title: const Text('Emergency Alerts'),
        backgroundColor: _alerts.isNotEmpty ? AppColors.danger : null,
        foregroundColor: _alerts.isNotEmpty ? Colors.white : null,
        actions: [IconButton(icon: const Icon(Icons.refresh), onPressed: _load)]),
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
                      leading: CircleAvatar(backgroundColor: color.withOpacity(0.15),
                        child: Icon(Icons.emergency, color: color)),
                      title: Text('${a['level']} — ${a['patientName']}',
                        style: TextStyle(fontWeight: FontWeight.w700, color: color)),
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
        CircleAvatar(radius: 40, backgroundColor: AppColors.primaryLight,
          child: Text(user.fullName[0].toUpperCase(),
            style: const TextStyle(fontSize: 32, fontWeight: FontWeight.w700, color: AppColors.primary))),
        const SizedBox(height: 16),
        Center(child: Text(user.fullName, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w700))),
        Center(child: Text(user.email, style: const TextStyle(color: AppColors.textMuted))),
        const SizedBox(height: 8),
        Center(child: Chip(label: const Text('MAIN DOCTOR'), backgroundColor: AppColors.primaryLight,
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

// ignore: avoid_classes_with_only_static_members
class ApiConstants {
  static const mdFinance = 'http://10.0.2.2:8081/api/md/finance';
}
