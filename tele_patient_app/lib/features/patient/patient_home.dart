import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/providers/auth_provider.dart';
import '../../core/services/api_service.dart';
import '../../core/models/history_model.dart';
import '../../core/models/token_model.dart';
import '../../core/widgets/app_button.dart';
import '../../core/widgets/notification_bell.dart';
import '../../core/services/pdf_service.dart';
import '../auth/login_screen.dart';
import 'patient_reports_screen.dart';
import 'emergency_screen.dart';
import '../shared/video_call_screen.dart';
import '../shared/chat_screen.dart';
import '../shared/launchpad_screen.dart';
import '../shared/social_feed_screen.dart';

class PatientHome extends StatefulWidget {
  const PatientHome({super.key});
  @override
  State<PatientHome> createState() => _PatientHomeState();
}

class _PatientHomeState extends State<PatientHome> {
  int _tab = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(index: _tab, children: const [
        _AppointmentsTab(),
        _HistoryTab(),
        _ProfileTab(),
      ]),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _tab,
        onTap: (i) => setState(() => _tab = i),
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.calendar_today), label: 'Appointments'),
          BottomNavigationBarItem(icon: Icon(Icons.history), label: 'History'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppColors.danger,
        onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const EmergencyScreen())),
        child: const Icon(Icons.emergency, color: Colors.white),
        tooltip: 'Emergency',
      ),
    );
  }
}

// ── APPOINTMENTS TAB ──
class _AppointmentsTab extends StatefulWidget {
  const _AppointmentsTab();
  @override
  State<_AppointmentsTab> createState() => _AppointmentsTabState();
}

class _AppointmentsTabState extends State<_AppointmentsTab> {
  List<TokenModel> _tokens = [];
  bool _loading = true;

  @override
  void initState() { super.initState(); _load(); }

  Future<void> _load() async {
    final user = context.read<AuthProvider>().user!;
    try {
      final data = await ApiService.getPatientTokens(user.userId);
      setState(() { _tokens = data.map((e) => TokenModel.fromJson(e)).toList(); _loading = false; });
    } catch (_) { setState(() => _loading = false); }
  }

  Future<void> _requestToken(String type) async {
    final user = context.read<AuthProvider>().user!;
    try {
      final mdId = await ApiService.getAdminId();
      await ApiService.requestToken(user.userId, mdId, type);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Token requested!'), backgroundColor: Colors.green));
      _load();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString())));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('My Appointments'),
        actions: [
          IconButton(
            icon: const Icon(Icons.rocket_launch),
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const LaunchpadScreen()),
            ),
            tooltip: 'LaunchPad',
          ),
          IconButton(
            icon: const Icon(Icons.forum),
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const SocialFeedScreen()),
            ),
            tooltip: 'Social Feed',
          ),
          const NotificationBell(),
          IconButton(icon: const Icon(Icons.refresh), onPressed: _load),
        ]),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _load,
              child: ListView(padding: const EdgeInsets.all(16), children: [
                if (_tokens.isEmpty)
                  Card(child: Padding(padding: const EdgeInsets.all(20),
                    child: Column(children: [
                      const Text('No active appointments', style: TextStyle(color: AppColors.textMuted)),
                      const SizedBox(height: 16),
                      Row(children: [
                        Expanded(child: AppButton(label: '💬 Chat', onPressed: () => _requestToken('CHAT'))),
                        const SizedBox(width: 10),
                        Expanded(child: AppButton(label: '📹 Video', onPressed: () => _requestToken('VIDEO'))),
                      ]),
                    ]))),
                ..._tokens.map((t) => _TokenCard(token: t, onRefresh: _load)),
              ]),
            ),
    );
  }
}

class _TokenCard extends StatelessWidget {
  final TokenModel token;
  final VoidCallback onRefresh;
  const _TokenCard({required this.token, required this.onRefresh});

  @override
  Widget build(BuildContext context) {
    final isApproved = token.status == 'APPROVED';
    final color = isApproved ? AppColors.success : AppColors.warning;
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: CircleAvatar(backgroundColor: color.withOpacity(0.15),
          child: Icon(token.type == 'VIDEO' ? Icons.videocam : Icons.chat, color: color)),
        title: Text('${token.type} Session', style: const TextStyle(fontWeight: FontWeight.w600)),
        subtitle: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('Status: ${token.status}', style: TextStyle(color: color, fontWeight: FontWeight.w600)),
          if (token.scheduledTime != null)
            Text('📅 ${token.scheduledTime!.toLocal().toString().substring(0, 16)}',
              style: const TextStyle(fontSize: 12, color: AppColors.textMuted)),
        ]),
        trailing: isApproved
            ? ElevatedButton(
                onPressed: () {
                  final user = context.read<AuthProvider>().user!;
                  if (token.type == 'VIDEO') {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => VideoCallScreen(
                          tokenId: token.id,
                          userId: user.userId,
                          userName: user.fullName,
                          scheduledTime: token.scheduledTime?.toLocal().toString().substring(0, 16),
                        ),
                      ),
                    );
                  } else {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => ChatScreen(
                          tokenId: token.id,
                          scheduledTime: token.scheduledTime?.toLocal().toString().substring(0, 16),
                        ),
                      ),
                    );
                  }
                },
                style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
                child: Text(token.type == 'VIDEO' ? 'Join' : 'Chat',
                  style: const TextStyle(color: Colors.white, fontSize: 12)))
            : null,
      ),
    );
  }
}

// ── HISTORY TAB ──
class _HistoryTab extends StatefulWidget {
  const _HistoryTab();
  @override
  State<_HistoryTab> createState() => _HistoryTabState();
}

class _HistoryTabState extends State<_HistoryTab> {
  List<HistoryModel> _history = [];
  List<HistoryModel> _filtered = [];
  bool _loading = true;
  final _search = TextEditingController();

  @override
  void initState() { super.initState(); _load(); }

  Future<void> _load() async {
    final user = context.read<AuthProvider>().user!;
    try {
      final data = await ApiService.getPatientHistory(user.userId);
      final list = data.map((e) => HistoryModel.fromJson(e)).toList()
        ..sort((a, b) => b.date.compareTo(a.date));
      setState(() { _history = list; _filtered = list; _loading = false; });
    } catch (_) { setState(() => _loading = false); }
  }

  void _filter(String q) {
    setState(() => _filtered = _history.where((h) =>
      h.doctorName.toLowerCase().contains(q.toLowerCase()) ||
      h.notes.toLowerCase().contains(q.toLowerCase())).toList());
  }

  @override
  Widget build(BuildContext context) {
    final user = context.read<AuthProvider>().user!;
    return Scaffold(
      appBar: AppBar(title: const Text('Medical History'), actions: [
        IconButton(
          icon: const Icon(Icons.picture_as_pdf),
          onPressed: () async {
            if (_filtered.isEmpty) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('No history to export')),
              );
              return;
            }
            try {
              await PdfService.exportHistoryToPdf(_filtered, user.fullName, user.email);
            } catch (e) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Error: ${e.toString()}')),
              );
            }
          },
          tooltip: 'Export PDF',
        ),
        IconButton(icon: const Icon(Icons.folder_open),
          onPressed: () => Navigator.push(context,
            MaterialPageRoute(builder: (_) => PatientReportsScreen(patientId: user.userId)))),
      ]),
      body: Column(children: [
        Padding(padding: const EdgeInsets.all(12),
          child: TextField(controller: _search, onChanged: _filter,
            decoration: const InputDecoration(prefixIcon: Icon(Icons.search), hintText: 'Search doctor or diagnosis...'))),
        Expanded(child: _loading
          ? const Center(child: CircularProgressIndicator())
          : _filtered.isEmpty
            ? const Center(child: Text('No records found', style: TextStyle(color: AppColors.textMuted)))
            : ListView.builder(padding: const EdgeInsets.symmetric(horizontal: 12),
                itemCount: _filtered.length,
                itemBuilder: (_, i) => _HistoryCard(item: _filtered[i]))),
      ]),
    );
  }
}

class _HistoryCard extends StatelessWidget {
  final HistoryModel item;
  const _HistoryCard({required this.item});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      child: Padding(padding: const EdgeInsets.all(14), child: Column(
        crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            Text('Dr. ${item.doctorName}', style: const TextStyle(fontWeight: FontWeight.w700, color: AppColors.primary)),
            Text('${item.date.day}/${item.date.month}/${item.date.year}',
              style: const TextStyle(fontSize: 12, color: AppColors.textMuted)),
          ]),
          const SizedBox(height: 6),
          Text(item.notes, style: const TextStyle(fontSize: 14)),
          if (item.prescription != null) ...[
            const SizedBox(height: 4),
            Text('Rx: ${item.prescription}', style: const TextStyle(color: AppColors.cyan, fontSize: 13)),
          ],
          if (item.reportsUrl != null) ...[
            const SizedBox(height: 6),
            TextButton.icon(onPressed: () {}, icon: const Icon(Icons.attach_file, size: 16),
              label: const Text('View Report', style: TextStyle(fontSize: 13))),
          ],
        ],
      )),
    );
  }
}

// ── PROFILE TAB ──
class _ProfileTab extends StatelessWidget {
  const _ProfileTab();
  @override
  Widget build(BuildContext context) {
    final user = context.read<AuthProvider>().user!;
    return Scaffold(
      appBar: AppBar(title: const Text('My Profile')),
      body: ListView(padding: const EdgeInsets.all(20), children: [
        CircleAvatar(radius: 40, backgroundColor: AppColors.primaryLight,
          child: Text(user.fullName[0].toUpperCase(),
            style: const TextStyle(fontSize: 32, fontWeight: FontWeight.w700, color: AppColors.primary))),
        const SizedBox(height: 16),
        Center(child: Text(user.fullName, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w700))),
        Center(child: Text(user.email, style: const TextStyle(color: AppColors.textMuted))),
        const SizedBox(height: 8),
        Center(child: Chip(label: Text(user.role), backgroundColor: AppColors.primaryLight,
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
