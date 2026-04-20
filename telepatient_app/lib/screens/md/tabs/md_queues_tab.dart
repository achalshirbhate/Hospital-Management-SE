import 'package:flutter/material.dart';
import '../../../services/md_service.dart';
import '../../../models/referral_model.dart';
import '../../../models/token_model.dart';
import '../../../models/emergency_model.dart';
import '../../../models/patient_model.dart';
import '../../../utils/helpers.dart';
import '../../../utils/app_theme.dart';
import '../../../widgets/empty_state.dart';
import '../../../widgets/loading_overlay.dart';
import '../../../widgets/status_badge.dart';

class MdQueuesTab extends StatefulWidget {
  final int mdId;
  const MdQueuesTab({super.key, required this.mdId});

  @override
  State<MdQueuesTab> createState() => _MdQueuesTabState();
}

class _MdQueuesTabState extends State<MdQueuesTab>
    with SingleTickerProviderStateMixin {
  late TabController _tabCtrl;
  final _service = MdService();

  List<ReferralModel> _referrals   = [];
  List<TokenModel>    _tokens      = [];
  List<EmergencyModel> _emergencies = [];
  List<PatientModel>  _doctors     = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _tabCtrl = TabController(length: 3, vsync: this);
    _load();
  }

  @override
  void dispose() {
    _tabCtrl.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    try {
      final queues = await _service.getPendingQueues();
      _referrals = (queues['referrals'] as List? ?? [])
          .map((e) => ReferralModel.fromJson(e))
          .toList();
      _tokens = (queues['tokens'] as List? ?? [])
          .map((e) => TokenModel.fromJson(e))
          .toList();
      _emergencies = await _service.getEmergencies();
      _doctors     = await _service.getAllDoctors();
    } catch (e) {
      if (mounted) showError(context, e.toString());
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  // ─── Referral actions ──────────────────────────────────────────────────────
  Future<void> _processReferral(ReferralModel ref, bool approve) async {
    int? doctorId;
    if (approve) {
      doctorId = await showDialog<int>(
        context: context,
        builder: (_) => _SelectDoctorDialog(doctors: _doctors),
      );
      if (doctorId == null) return;
    }
    try {
      await _service.processReferral(
          referralId: ref.id, approve: approve, assignedDoctorId: doctorId);
      if (mounted) {
        showSuccess(context, approve ? 'Referral approved!' : 'Referral rejected');
        _load();
      }
    } catch (e) {
      if (mounted) showError(context, e.toString());
    }
  }

  // ─── Token actions ─────────────────────────────────────────────────────────
  Future<void> _processToken(TokenModel token, bool approve) async {
    String? scheduledTime;
    if (approve) {
      final ctrl = TextEditingController();
      final ok = await showDialog<bool>(
        context: context,
        builder: (_) => AlertDialog(
          title: const Text('Schedule Session'),
          content: TextField(
            controller: ctrl,
            decoration: const InputDecoration(
                labelText: 'Scheduled Time (e.g. 2:00 PM)'),
          ),
          actions: [
            TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('Cancel')),
            ElevatedButton(
                onPressed: () => Navigator.pop(context, true),
                child: const Text('Approve')),
          ],
        ),
      );
      if (ok != true) return;
      scheduledTime = ctrl.text.isNotEmpty ? ctrl.text : null;
    }
    try {
      await _service.processToken(
          tokenId: token.id, approve: approve, scheduledTime: scheduledTime);
      if (mounted) {
        showSuccess(context, approve ? 'Token approved!' : 'Token rejected');
        _load();
      }
    } catch (e) {
      if (mounted) showError(context, e.toString());
    }
  }

  Future<void> _freezeToken(int tokenId) async {
    try {
      await _service.freezeToken(tokenId);
      if (mounted) { showSuccess(context, 'Token frozen'); _load(); }
    } catch (e) {
      if (mounted) showError(context, e.toString());
    }
  }

  Future<void> _terminateToken(int tokenId) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Terminate Session?'),
        content: const Text('This will permanently close the session.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Terminate'),
          ),
        ],
      ),
    );
    if (ok != true) return;
    try {
      await _service.terminateToken(tokenId);
      if (mounted) { showSuccess(context, 'Session terminated'); _load(); }
    } catch (e) {
      if (mounted) showError(context, e.toString());
    }
  }

  Future<void> _acknowledgeEmergency(int id) async {
    try {
      await _service.acknowledgeEmergency(id);
      if (mounted) { showSuccess(context, 'Acknowledged'); _load(); }
    } catch (e) {
      if (mounted) showError(context, e.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Approval Queues'),
        actions: [
          IconButton(icon: const Icon(Icons.refresh), onPressed: _load),
        ],
        bottom: TabBar(
          controller: _tabCtrl,
          tabs: [
            Tab(text: 'Referrals (${_referrals.length})'),
            Tab(text: 'Tokens (${_tokens.length})'),
            Tab(text: 'Emergency (${_emergencies.length})'),
          ],
        ),
      ),
      body: LoadingOverlay(
        isLoading: _loading,
        child: TabBarView(
          controller: _tabCtrl,
          children: [
            // ── Referrals ──────────────────────────────────────────────────
            RefreshIndicator(
              onRefresh: _load,
              child: _referrals.isEmpty
                  ? const EmptyState(
                      message: 'No pending referrals.',
                      icon: Icons.transfer_within_a_station)
                  : ListView.builder(
                      padding: const EdgeInsets.all(12),
                      itemCount: _referrals.length,
                      itemBuilder: (_, i) => _ReferralCard(
                        ref: _referrals[i],
                        onApprove: () => _processReferral(_referrals[i], true),
                        onReject: () => _processReferral(_referrals[i], false),
                      ),
                    ),
            ),

            // ── Tokens ─────────────────────────────────────────────────────
            RefreshIndicator(
              onRefresh: _load,
              child: _tokens.isEmpty
                  ? const EmptyState(
                      message: 'No pending token requests.',
                      icon: Icons.pending_actions)
                  : ListView.builder(
                      padding: const EdgeInsets.all(12),
                      itemCount: _tokens.length,
                      itemBuilder: (_, i) => _TokenQueueCard(
                        token: _tokens[i],
                        onApprove: () => _processToken(_tokens[i], true),
                        onReject: () => _processToken(_tokens[i], false),
                        onFreeze: () => _freezeToken(_tokens[i].id),
                        onTerminate: () => _terminateToken(_tokens[i].id),
                      ),
                    ),
            ),

            // ── Emergencies ────────────────────────────────────────────────
            RefreshIndicator(
              onRefresh: _load,
              child: _emergencies.isEmpty
                  ? const EmptyState(
                      message: 'No active emergencies.',
                      icon: Icons.check_circle_outline)
                  : ListView.builder(
                      padding: const EdgeInsets.all(12),
                      itemCount: _emergencies.length,
                      itemBuilder: (_, i) => _EmergencyCard(
                        em: _emergencies[i],
                        onAck: () => _acknowledgeEmergency(_emergencies[i].id),
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Referral Card ────────────────────────────────────────────────────────────
class _ReferralCard extends StatelessWidget {
  final ReferralModel ref;
  final VoidCallback onApprove;
  final VoidCallback onReject;
  const _ReferralCard(
      {required this.ref, required this.onApprove, required this.onReject});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            const Icon(Icons.transfer_within_a_station,
                color: Colors.orange, size: 20),
            const SizedBox(width: 8),
            Expanded(
              child: Text(ref.patientName,
                  style: const TextStyle(fontWeight: FontWeight.bold)),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: Colors.orange.withOpacity(0.15),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(ref.urgency,
                  style: const TextStyle(
                      color: Colors.orange, fontSize: 11)),
            ),
          ]),
          const SizedBox(height: 8),
          Text('From: Dr. ${ref.fromDoctor}',
              style: const TextStyle(fontSize: 13)),
          Text('Specialty: ${ref.requestedSpecialty}',
              style: const TextStyle(fontSize: 13)),
          Text('Reason: ${ref.reason}',
              style: TextStyle(fontSize: 12, color: Colors.grey.shade600)),
          const SizedBox(height: 12),
          Row(children: [
            Expanded(
              child: OutlinedButton.icon(
                onPressed: onReject,
                icon: const Icon(Icons.close, size: 16),
                label: const Text('Reject'),
                style: OutlinedButton.styleFrom(foregroundColor: Colors.red),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: ElevatedButton.icon(
                onPressed: onApprove,
                icon: const Icon(Icons.check, size: 16),
                label: const Text('Approve'),
                style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.success),
              ),
            ),
          ]),
        ]),
      ),
    );
  }
}

// ─── Token Queue Card ─────────────────────────────────────────────────────────
class _TokenQueueCard extends StatelessWidget {
  final TokenModel token;
  final VoidCallback onApprove;
  final VoidCallback onReject;
  final VoidCallback onFreeze;
  final VoidCallback onTerminate;
  const _TokenQueueCard({
    required this.token,
    required this.onApprove,
    required this.onReject,
    required this.onFreeze,
    required this.onTerminate,
  });

  @override
  Widget build(BuildContext context) {
    final isChat = token.type == 'CHAT';
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            Icon(isChat ? Icons.chat_bubble : Icons.videocam,
                color: isChat ? AppTheme.primary : AppTheme.accent, size: 20),
            const SizedBox(width: 8),
            Expanded(
              child: Text(token.patientName ?? 'Unknown',
                  style: const TextStyle(fontWeight: FontWeight.bold)),
            ),
            StatusBadge(token.status),
          ]),
          const SizedBox(height: 6),
          Text('Type: ${token.type}',
              style: const TextStyle(fontSize: 13)),
          if (token.scheduledTime != null)
            Text('Scheduled: ${token.scheduledTime}',
                style: const TextStyle(fontSize: 12)),
          const SizedBox(height: 12),
          if (token.status == 'REQUESTED')
            Row(children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: onReject,
                  style: OutlinedButton.styleFrom(foregroundColor: Colors.red),
                  child: const Text('Reject'),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: ElevatedButton(
                  onPressed: onApprove,
                  style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.success),
                  child: const Text('Approve'),
                ),
              ),
            ])
          else if (token.status == 'APPROVED')
            Row(children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: onFreeze,
                  icon: const Icon(Icons.pause, size: 16),
                  label: const Text('Freeze'),
                  style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.orange),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: onTerminate,
                  icon: const Icon(Icons.stop, size: 16),
                  label: const Text('Terminate'),
                  style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red),
                ),
              ),
            ]),
        ]),
      ),
    );
  }
}

// ─── Emergency Card ───────────────────────────────────────────────────────────
class _EmergencyCard extends StatelessWidget {
  final EmergencyModel em;
  final VoidCallback onAck;
  const _EmergencyCard({required this.em, required this.onAck});

  @override
  Widget build(BuildContext context) {
    final color = emergencyColor(em.level);
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: color.withOpacity(0.4)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: color.withOpacity(0.15),
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.emergency, color: color),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(em.patientName,
                  style: const TextStyle(fontWeight: FontWeight.bold)),
              Text('Level: ${em.level}',
                  style: TextStyle(color: color, fontWeight: FontWeight.w600)),
              Text(formatDate(em.alertTime),
                  style: const TextStyle(fontSize: 11)),
            ]),
          ),
          ElevatedButton(
            onPressed: onAck,
            style: ElevatedButton.styleFrom(
                backgroundColor: color, padding: const EdgeInsets.all(8)),
            child: const Text('ACK', style: TextStyle(fontSize: 12)),
          ),
        ]),
      ),
    );
  }
}

// ─── Select Doctor Dialog ─────────────────────────────────────────────────────
class _SelectDoctorDialog extends StatelessWidget {
  final List<PatientModel> doctors;
  const _SelectDoctorDialog({required this.doctors});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Assign to Doctor'),
      content: SizedBox(
        width: double.maxFinite,
        child: ListView.builder(
          shrinkWrap: true,
          itemCount: doctors.length,
          itemBuilder: (_, i) => ListTile(
            leading: const Icon(Icons.medical_services, color: AppTheme.accent),
            title: Text('Dr. ${doctors[i].fullName}'),
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
