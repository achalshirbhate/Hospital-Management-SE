import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../providers/auth_provider.dart';
import '../../../services/patient_service.dart';
import '../../../services/md_service.dart';
import '../../../models/token_model.dart';
import '../../../utils/helpers.dart';
import '../../../utils/constants.dart';
import '../../../utils/app_theme.dart';
import '../../../widgets/loading_overlay.dart';
import '../../../widgets/empty_state.dart';
import '../../../widgets/status_badge.dart';
import '../../chat/chat_screen.dart';
import '../../video/video_call_screen.dart';

/// Session management tab for patients.
/// patientId and mdId are read from AuthProvider / backend — never passed
/// as constructor arguments, so there is no stale userId risk.
class PatientTokensTab extends StatefulWidget {
  const PatientTokensTab({super.key});

  @override
  State<PatientTokensTab> createState() => _PatientTokensTabState();
}

class _PatientTokensTabState extends State<PatientTokensTab> {
  final _patientService = PatientService();
  final _mdService      = MdService();

  List<TokenModel> _tokens = [];
  bool _loading = true;
  int  _mdId    = 1; // resolved from backend on init

  @override
  void initState() {
    super.initState();
    _init();
  }

  Future<void> _init() async {
    // Resolve the MD's userId from the backend (needed for token requests).
    try {
      _mdId = await _mdService.getAdminId();
    } catch (_) {
      // Fall back to 1 if the call fails — backend will validate anyway.
    }
    await _loadTokens();
  }

  Future<void> _loadTokens() async {
    final patientId = context.read<AuthProvider>().userId;
    setState(() => _loading = true);
    try {
      _tokens = await _patientService.getMyTokens(patientId);
    } catch (e) {
      if (mounted) showError(context, e.toString());
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _requestToken(String type) async {
    // patientId comes from the JWT on the backend — we still send it in the
    // body for the request DTO, but the backend overrides it with the JWT claim.
    final patientId = context.read<AuthProvider>().userId;
    try {
      await _patientService.requestToken(
        patientId: patientId,
        mdId: _mdId,
        type: type,
      );
      if (mounted) {
        showSuccess(context, '$type session requested!');
        _loadTokens();
      }
    } catch (e) {
      if (mounted) showError(context, e.toString());
    }
  }

  void _openSession(TokenModel token) {
    if (!token.isApproved) return;
    // currentUserId is read inside ChatScreen/VideoCallScreen from AuthProvider.
    if (token.type == TokenType.chat) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => ChatScreen(
            tokenId: token.id,
            title: 'Chat with Doctor',
          ),
        ),
      );
    } else {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => VideoCallScreen(tokenId: token.id),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('My Sessions')),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showRequestDialog,
        icon: const Icon(Icons.add),
        label: const Text('Request Session'),
      ),
      body: LoadingOverlay(
        isLoading: _loading,
        child: RefreshIndicator(
          onRefresh: _loadTokens,
          child: _tokens.isEmpty && !_loading
              ? const EmptyState(
                  message: 'No sessions yet.\nRequest a chat or video session.',
                  icon: Icons.chat_bubble_outline)
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: _tokens.length,
                  itemBuilder: (_, i) => _TokenCard(
                    token: _tokens[i],
                    onTap: () => _openSession(_tokens[i]),
                  ),
                ),
        ),
      ),
    );
  }

  void _showRequestDialog() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (_) => Padding(
        padding: const EdgeInsets.all(24),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          const Text('Request a Session',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 20),
          _SessionTypeButton(
            icon: Icons.chat_bubble_outline,
            label: 'Chat Session',
            color: AppTheme.primary,
            onTap: () {
              Navigator.pop(context);
              _requestToken(TokenType.chat);
            },
          ),
          const SizedBox(height: 12),
          _SessionTypeButton(
            icon: Icons.videocam_outlined,
            label: 'Video Call',
            color: AppTheme.accent,
            onTap: () {
              Navigator.pop(context);
              _requestToken(TokenType.video);
            },
          ),
        ]),
      ),
    );
  }
}

// ─── Sub-widgets ──────────────────────────────────────────────────────────────

class _SessionTypeButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;
  const _SessionTypeButton({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton.icon(
      onPressed: onTap,
      icon: Icon(icon),
      label: Text(label),
      style: ElevatedButton.styleFrom(backgroundColor: color),
    );
  }
}

class _TokenCard extends StatelessWidget {
  final TokenModel token;
  final VoidCallback onTap;
  const _TokenCard({required this.token, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final isChat  = token.type == TokenType.chat;
    final canOpen = token.isApproved && !token.isCompleted;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor:
              (isChat ? AppTheme.primary : AppTheme.accent).withValues(alpha: 0.15),
          child: Icon(
            isChat ? Icons.chat_bubble : Icons.videocam,
            color: isChat ? AppTheme.primary : AppTheme.accent,
          ),
        ),
        title: Text('${token.type} Session',
            style: const TextStyle(fontWeight: FontWeight.w600)),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (token.scheduledTime != null)
              Text('Scheduled: ${token.scheduledTime}',
                  style: const TextStyle(fontSize: 12)),
            Text('Requested: ${formatDate(token.requestedAt)}',
                style: const TextStyle(fontSize: 11)),
            if (token.isFrozen)
              const Text('⚠️ Session frozen by admin',
                  style: TextStyle(color: Colors.orange, fontSize: 11)),
          ],
        ),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            StatusBadge(token.status),
            if (canOpen) ...[
              const SizedBox(height: 4),
              GestureDetector(
                onTap: onTap,
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: AppTheme.primary,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Text('Open',
                      style: TextStyle(color: Colors.white, fontSize: 11)),
                ),
              ),
            ],
          ],
        ),
        isThreeLine: true,
      ),
    );
  }
}
