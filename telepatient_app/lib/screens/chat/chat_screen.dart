import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../services/chat_service.dart';
import '../../services/report_service.dart';
import '../../models/chat_message_model.dart';
import '../../models/report_model.dart';
import '../../utils/app_theme.dart';
import '../../utils/constants.dart';
import '../../utils/helpers.dart';

class ChatScreen extends StatefulWidget {
  final int    tokenId;
  final String title;

  const ChatScreen({
    super.key,
    required this.tokenId,
    required this.title,
  });

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen>
    with TickerProviderStateMixin {
  final _chatService   = ChatService();
  final _reportService = ReportService();
  final _msgCtrl       = TextEditingController();
  final _scrollCtrl    = ScrollController();

  List<ChatMessageModel> _messages     = [];
  bool _isTerminated = false;
  bool _isFrozen     = false;
  bool _sending      = false;
  bool _hasText      = false;
  Timer? _pollTimer;

  late int _currentUserId;

  // Animation for new messages
  final List<AnimationController> _msgAnimations = [];

  @override
  void initState() {
    super.initState();
    _currentUserId = context.read<AuthProvider>().userId;
    _msgCtrl.addListener(() {
      setState(() => _hasText = _msgCtrl.text.trim().isNotEmpty);
    });
    _startPolling();
  }

  @override
  void dispose() {
    _pollTimer?.cancel();
    _msgCtrl.dispose();
    _scrollCtrl.dispose();
    for (final c in _msgAnimations) c.dispose();
    super.dispose();
  }

  void _startPolling() {
    _fetchMessages();
    _pollTimer = Timer.periodic(
      const Duration(seconds: AppConstants.chatPollSeconds),
      (_) => _fetchMessages(),
    );
  }

  Future<void> _fetchMessages() async {
    try {
      final sync = await _chatService.getChatHistory(widget.tokenId);
      if (!mounted) return;
      final prevCount = _messages.length;
      setState(() {
        _messages     = sync.messages;
        _isTerminated = sync.isTerminated;
      });
      if (sync.messages.length > prevCount) {
        WidgetsBinding.instance
            .addPostFrameCallback((_) => _scrollToBottom());
      }
    } catch (_) {}
  }

  void _scrollToBottom() {
    if (_scrollCtrl.hasClients) {
      _scrollCtrl.animateTo(
        _scrollCtrl.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  Future<void> _sendMessage() async {
    final text = _msgCtrl.text.trim();
    if (text.isEmpty || _isTerminated || _isFrozen) return;
    setState(() => _sending = true);
    try {
      await _chatService.sendMessage(
        tokenId:  widget.tokenId,
        senderId: _currentUserId,
        message:  text,
      );
      _msgCtrl.clear();
      await _fetchMessages();
    } catch (e) {
      if (mounted) showError(context, e.toString());
    } finally {
      if (mounted) setState(() => _sending = false);
    }
  }

  Future<void> _shareReport() async {
    try {
      final reports = await _reportService.getReports(_currentUserId);
      if (!mounted) return;
      if (reports.isEmpty) {
        showError(context, 'No reports available to share');
        return;
      }
      final report = await showModalBottomSheet<ReportModel>(
        context: context,
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
        builder: (_) => _ReportPickerSheet(reports: reports),
      );
      if (report == null) return;
      await _reportService.sendReportToChat(
        reportId: report.id,
        tokenId:  widget.tokenId,
        senderId: _currentUserId,
      );
      if (mounted) {
        showSuccess(context, 'Report shared!');
        _fetchMessages();
      }
    } catch (e) {
      if (mounted) showError(context, e.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor:
          isDark ? const Color(0xFF0B141A) : const Color(0xFFECE5DD),
      appBar: _buildAppBar(isDark),
      body: Column(children: [
        // ── Terminated / frozen banner ────────────────────────────────────────
        if (_isTerminated)
          _StatusBanner(
            message: 'This session has ended',
            color: AppColors.textSecondary,
            icon: Icons.lock_outline,
          )
        else if (_isFrozen)
          _StatusBanner(
            message: 'Chat paused by admin',
            color: AppColors.warning,
            icon: Icons.pause_circle_outline,
          ),

        // ── Messages ──────────────────────────────────────────────────────────
        Expanded(
          child: _messages.isEmpty
              ? Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.chat_bubble_outline,
                          size: 48,
                          color: isDark
                              ? AppColors.darkTextSecondary
                              : AppColors.textHint),
                      const SizedBox(height: AppSpacing.sm),
                      Text('No messages yet',
                          style: AppTextStyles.bodyMd.copyWith(
                            color: isDark
                                ? AppColors.darkTextSecondary
                                : AppColors.textSecondary,
                          )),
                    ],
                  ),
                )
              : ListView.builder(
                  controller: _scrollCtrl,
                  padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.sm,
                      vertical: AppSpacing.md),
                  itemCount: _messages.length,
                  itemBuilder: (_, i) {
                    final msg  = _messages[i];
                    final isMe = msg.senderId == _currentUserId;
                    final showDate = i == 0 ||
                        _isDifferentDay(
                            _messages[i - 1].sentAt, msg.sentAt);
                    return Column(children: [
                      if (showDate) _DateDivider(iso: msg.sentAt),
                      _MessageBubble(
                          msg: msg, isMe: isMe, index: i),
                    ]);
                  },
                ),
        ),

        // ── Input bar ─────────────────────────────────────────────────────────
        if (!_isTerminated) _buildInputBar(isDark),
      ]),
    );
  }

  PreferredSizeWidget _buildAppBar(bool isDark) {
    return AppBar(
      backgroundColor:
          isDark ? const Color(0xFF1F2C34) : const Color(0xFF075E54),
      foregroundColor: Colors.white,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_ios_new, size: 18),
        onPressed: () => Navigator.pop(context),
      ),
      titleSpacing: 0,
      title: Row(children: [
        CircleAvatar(
          radius: 18,
          backgroundColor: Colors.white.withValues(alpha: 0.2),
          child: Text(
            widget.title.isNotEmpty ? widget.title[0].toUpperCase() : 'D',
            style: AppTextStyles.titleSm.copyWith(color: Colors.white),
          ),
        ),
        const SizedBox(width: AppSpacing.sm),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(widget.title,
                  style: AppTextStyles.titleSm.copyWith(
                      color: Colors.white)),
              Text(
                _isTerminated
                    ? 'Session ended'
                    : _isFrozen
                        ? 'Paused by admin'
                        : 'Active session',
                style: AppTextStyles.bodySm.copyWith(
                    color: Colors.white70),
              ),
            ],
          ),
        ),
      ]),
      actions: [
        if (!_isTerminated)
          IconButton(
            icon: const Icon(Icons.attach_file, size: 20),
            onPressed: _shareReport,
          ),
      ],
    );
  }

  Widget _buildInputBar(bool isDark) {
    return Container(
      padding: EdgeInsets.fromLTRB(
        AppSpacing.sm,
        AppSpacing.sm,
        AppSpacing.sm,
        AppSpacing.sm + MediaQuery.of(context).viewInsets.bottom,
      ),
      color: isDark ? const Color(0xFF1F2C34) : const Color(0xFFF0F0F0),
      child: Row(children: [
        // Text field
        Expanded(
          child: Container(
            constraints: const BoxConstraints(maxHeight: 120),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF2A3942) : Colors.white,
              borderRadius: BorderRadius.circular(AppRadius.xl),
            ),
            child: TextField(
              controller: _msgCtrl,
              enabled: !_isFrozen,
              maxLines: null,
              textInputAction: TextInputAction.newline,
              style: AppTextStyles.bodyMd.copyWith(
                color: isDark
                    ? AppColors.darkTextPrimary
                    : AppColors.textPrimary,
              ),
              decoration: InputDecoration(
                hintText: _isFrozen
                    ? 'Chat is paused'
                    : 'Message...',
                hintStyle: AppTextStyles.bodyMd.copyWith(
                    color: isDark
                        ? AppColors.darkTextSecondary
                        : AppColors.textHint),
                border: InputBorder.none,
                enabledBorder: InputBorder.none,
                focusedBorder: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16, vertical: 10),
              ),
            ),
          ),
        ),
        const SizedBox(width: AppSpacing.sm),

        // Send / mic button
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 200),
          transitionBuilder: (child, anim) => ScaleTransition(
            scale: anim,
            child: child,
          ),
          child: GestureDetector(
            key: ValueKey(_hasText),
            onTap: _sending ? null : _sendMessage,
            child: Container(
              width: 46,
              height: 46,
              decoration: BoxDecoration(
                color: isDark
                    ? const Color(0xFF00A884)
                    : const Color(0xFF25D366),
                shape: BoxShape.circle,
              ),
              child: _sending
                  ? const Padding(
                      padding: EdgeInsets.all(12),
                      child: CircularProgressIndicator(
                          color: Colors.white, strokeWidth: 2),
                    )
                  : Icon(
                      _hasText ? Icons.send_rounded : Icons.mic_none_rounded,
                      color: Colors.white,
                      size: 22,
                    ),
            ),
          ),
        ),
      ]),
    );
  }

  bool _isDifferentDay(String? a, String? b) {
    if (a == null || b == null) return false;
    try {
      final da = DateTime.parse(a);
      final db = DateTime.parse(b);
      return da.day != db.day ||
          da.month != db.month ||
          da.year != db.year;
    } catch (_) {
      return false;
    }
  }
}

// ─── Status Banner ────────────────────────────────────────────────────────────

class _StatusBanner extends StatelessWidget {
  final String message;
  final Color color;
  final IconData icon;
  const _StatusBanner(
      {required this.message, required this.color, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md, vertical: AppSpacing.sm),
      color: color.withValues(alpha: 0.1),
      child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
        Icon(icon, size: 14, color: color),
        const SizedBox(width: 6),
        Text(message,
            style: AppTextStyles.labelMd.copyWith(color: color)),
      ]),
    );
  }
}

// ─── Date Divider ─────────────────────────────────────────────────────────────

class _DateDivider extends StatelessWidget {
  final String? iso;
  const _DateDivider({this.iso});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
      child: Center(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          decoration: BoxDecoration(
            color: Theme.of(context).brightness == Brightness.dark
                ? const Color(0xFF1F2C34)
                : Colors.white.withValues(alpha: 0.8),
            borderRadius: BorderRadius.circular(AppRadius.full),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.08),
                blurRadius: 4,
              ),
            ],
          ),
          child: Text(
            formatDateOnly(iso),
            style: AppTextStyles.labelSm.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
        ),
      ),
    );
  }
}

// ─── Message Bubble ───────────────────────────────────────────────────────────

class _MessageBubble extends StatelessWidget {
  final ChatMessageModel msg;
  final bool isMe;
  final int index;
  const _MessageBubble(
      {required this.msg, required this.isMe, required this.index});

  @override
  Widget build(BuildContext context) {
    final isDark   = Theme.of(context).brightness == Brightness.dark;
    final isReport = msg.message.startsWith('📎 Report Shared:');

    final bubbleColor = isMe
        ? (isDark ? const Color(0xFF005C4B) : const Color(0xFFDCF8C6))
        : (isDark ? const Color(0xFF1F2C34) : Colors.white);

    final textColor = isDark ? Colors.white : AppColors.textPrimary;
    final timeColor = isDark
        ? Colors.white.withValues(alpha: 0.5)
        : AppColors.textHint;

    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: const Duration(milliseconds: 200),
      curve: Curves.easeOutCubic,
      builder: (_, v, child) => Opacity(
        opacity: v,
        child: Transform.translate(
          offset: Offset(isMe ? 20 * (1 - v) : -20 * (1 - v), 0),
          child: child,
        ),
      ),
      child: Padding(
        padding: EdgeInsets.only(
          left: isMe ? 60 : 0,
          right: isMe ? 0 : 60,
          bottom: 4,
        ),
        child: Row(
          mainAxisAlignment:
              isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            // Avatar for other person
            if (!isMe) ...[
              CircleAvatar(
                radius: 14,
                backgroundColor: AppColors.accent.withValues(alpha: 0.2),
                child: Text(
                  msg.senderName.isNotEmpty
                      ? msg.senderName[0].toUpperCase()
                      : '?',
                  style: AppTextStyles.labelSm.copyWith(
                      color: AppColors.accent),
                ),
              ),
              const SizedBox(width: 6),
            ],

            // Bubble
            Flexible(
              child: Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: bubbleColor,
                  borderRadius: BorderRadius.only(
                    topLeft: const Radius.circular(16),
                    topRight: const Radius.circular(16),
                    bottomLeft: Radius.circular(isMe ? 16 : 4),
                    bottomRight: Radius.circular(isMe ? 4 : 16),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.06),
                      blurRadius: 4,
                      offset: const Offset(0, 1),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Sender name (for others)
                    if (!isMe)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 3),
                        child: Text(msg.senderName,
                            style: AppTextStyles.labelSm.copyWith(
                                color: AppColors.accent)),
                      ),

                    // Report card style
                    if (isReport)
                      _ReportMessageContent(
                          message: msg.message, textColor: textColor)
                    else
                      Text(msg.message,
                          style: AppTextStyles.bodyMd.copyWith(
                              color: textColor)),

                    // Timestamp + read receipt
                    const SizedBox(height: 3),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(_formatTime(msg.sentAt),
                            style: AppTextStyles.labelSm.copyWith(
                                color: timeColor, fontSize: 10)),
                        if (isMe) ...[
                          const SizedBox(width: 3),
                          Icon(Icons.done_all,
                              size: 14, color: timeColor),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatTime(String? iso) {
    if (iso == null) return '';
    try {
      final dt = DateTime.parse(iso);
      return '${dt.hour.toString().padLeft(2, '0')}:'
          '${dt.minute.toString().padLeft(2, '0')}';
    } catch (_) {
      return '';
    }
  }
}

// ─── Report Message Content ───────────────────────────────────────────────────

class _ReportMessageContent extends StatelessWidget {
  final String message;
  final Color textColor;
  const _ReportMessageContent(
      {required this.message, required this.textColor});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.sm),
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(AppRadius.sm),
        border: Border.all(
            color: AppColors.primary.withValues(alpha: 0.2)),
      ),
      child: Row(children: [
        const Icon(Icons.picture_as_pdf,
            color: AppColors.error, size: 20),
        const SizedBox(width: AppSpacing.sm),
        Expanded(
          child: Text(message,
              style: AppTextStyles.bodySm.copyWith(color: textColor)),
        ),
      ]),
    );
  }
}

// ─── Report Picker Sheet ──────────────────────────────────────────────────────

class _ReportPickerSheet extends StatelessWidget {
  final List<ReportModel> reports;
  const _ReportPickerSheet({required this.reports});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : AppColors.surface,
        borderRadius: const BorderRadius.vertical(
            top: Radius.circular(AppRadius.xl)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle
          Container(
            margin: const EdgeInsets.only(top: AppSpacing.sm),
            width: 36,
            height: 4,
            decoration: BoxDecoration(
              color: AppColors.border,
              borderRadius: BorderRadius.circular(AppRadius.full),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: Text('Share a Report',
                style: AppTextStyles.titleMd.copyWith(
                  color: isDark
                      ? AppColors.darkTextPrimary
                      : AppColors.textPrimary,
                )),
          ),
          const Divider(height: 1),
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: reports.length,
            itemBuilder: (_, i) => ListTile(
              leading: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.errorSurface,
                  borderRadius: BorderRadius.circular(AppRadius.sm),
                ),
                child: const Icon(Icons.picture_as_pdf,
                    color: AppColors.error, size: 20),
              ),
              title: Text(reports[i].reportName,
                  style: AppTextStyles.titleSm),
              subtitle: Text(reports[i].reportType,
                  style: AppTextStyles.bodySm.copyWith(
                      color: AppColors.textSecondary)),
              onTap: () => Navigator.pop(context, reports[i]),
            ),
          ),
          SizedBox(height: MediaQuery.of(context).padding.bottom + 8),
        ],
      ),
    );
  }
}
