import 'package:flutter/material.dart';
import '../../services/notification_service.dart';
import '../../models/notification_model.dart';
import '../../utils/app_theme.dart';
import '../../utils/helpers.dart';
import '../../widgets/empty_state.dart';
import '../../widgets/skeleton_loader.dart';

class NotificationsScreen extends StatefulWidget {
  final int userId;
  const NotificationsScreen({super.key, required this.userId});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  final _service = NotificationService();
  List<NotificationModel> _notifs = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    try {
      _notifs = await _service.getNotifications(widget.userId);
    } catch (e) {
      if (mounted) showError(context, e.toString());
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _markAllRead() async {
    try {
      await _service.markAllRead(widget.userId);
      setState(() {
        _notifs = _notifs.map((n) => NotificationModel(
          id: n.id, message: n.message, type: n.type,
          priority: n.priority, isRead: true, createdAt: n.createdAt,
        )).toList();
      });
    } catch (e) {
      if (mounted) showError(context, e.toString());
    }
  }

  Future<void> _markRead(int id) async {
    try {
      await _service.markRead(id);
      setState(() {
        final idx = _notifs.indexWhere((n) => n.id == id);
        if (idx != -1) {
          final n = _notifs[idx];
          _notifs[idx] = NotificationModel(
            id: n.id, message: n.message, type: n.type,
            priority: n.priority, isRead: true, createdAt: n.createdAt,
          );
        }
      });
    } catch (_) {}
  }

  Future<void> _delete(int id) async {
    try {
      await _service.deleteNotification(id);
      setState(() => _notifs.removeWhere((n) => n.id == id));
    } catch (e) {
      if (mounted) showError(context, e.toString());
    }
  }

  Color _priorityColor(String p) => switch (p) {
    'HIGH'   => AppColors.error,
    'MEDIUM' => AppColors.warning,
    _        => AppColors.textHint,
  };

  IconData _typeIcon(String t) => switch (t) {
    'EMERGENCY'    => Icons.emergency_outlined,
    'APPOINTMENT'  => Icons.calendar_today_outlined,
    'PRESCRIPTION' => Icons.medication_outlined,
    'REPORT'       => Icons.folder_outlined,
    _              => Icons.notifications_outlined,
  };

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final unread = _notifs.where((n) => !n.isRead).length;

    return Scaffold(
      backgroundColor:
          isDark ? AppColors.darkBackground : AppColors.background,
      body: Column(children: [
        // ── Header ────────────────────────────────────────────────────────────
        Container(
          color: isDark ? AppColors.darkSurface : AppColors.surface,
          padding: EdgeInsets.fromLTRB(
            AppSpacing.lg,
            MediaQuery.of(context).padding.top + AppSpacing.md,
            AppSpacing.md,
            AppSpacing.md,
          ),
          child: Row(children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(children: [
                    Text('Notifications',
                        style: AppTextStyles.displaySm.copyWith(
                          color: isDark
                              ? AppColors.darkTextPrimary
                              : AppColors.textPrimary,
                        )),
                    if (unread > 0) ...[
                      const SizedBox(width: AppSpacing.sm),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: AppColors.primary,
                          borderRadius:
                              BorderRadius.circular(AppRadius.full),
                        ),
                        child: Text('$unread',
                            style: AppTextStyles.labelSm.copyWith(
                                color: Colors.white)),
                      ),
                    ],
                  ]),
                  Text('Stay up to date',
                      style: AppTextStyles.bodyMd.copyWith(
                        color: isDark
                            ? AppColors.darkTextSecondary
                            : AppColors.textSecondary,
                      )),
                ],
              ),
            ),
            if (unread > 0)
              TextButton(
                onPressed: _markAllRead,
                child: Text('Mark all read',
                    style: AppTextStyles.labelMd.copyWith(
                        color: AppColors.primary)),
              ),
          ]),
        ),

        // ── List ──────────────────────────────────────────────────────────────
        Expanded(
          child: RefreshIndicator(
            onRefresh: _load,
            color: AppColors.primary,
            child: _loading
                ? const SkeletonList(count: 6)
                : _notifs.isEmpty
                    ? const EmptyState(
                        message: 'All caught up!',
                        subtitle: 'No notifications at the moment.',
                        icon: Icons.notifications_off_outlined,
                      )
                    : ListView.builder(
                        itemCount: _notifs.length,
                        itemBuilder: (_, i) {
                          final n = _notifs[i];
                          return _NotificationTile(
                            notification: n,
                            priorityColor: _priorityColor(n.priority),
                            typeIcon: _typeIcon(n.type),
                            onTap: () => _markRead(n.id),
                            onDismiss: () => _delete(n.id),
                            index: i,
                          );
                        },
                      ),
          ),
        ),
      ]),
    );
  }
}

// ─── Notification Tile ────────────────────────────────────────────────────────

class _NotificationTile extends StatelessWidget {
  final NotificationModel notification;
  final Color priorityColor;
  final IconData typeIcon;
  final VoidCallback onTap;
  final VoidCallback onDismiss;
  final int index;

  const _NotificationTile({
    required this.notification,
    required this.priorityColor,
    required this.typeIcon,
    required this.onTap,
    required this.onDismiss,
    required this.index,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final n      = notification;
    final isRead = n.isRead;

    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: Duration(milliseconds: 200 + index * 30),
      curve: Curves.easeOut,
      builder: (_, v, child) =>
          Opacity(opacity: v, child: child),
      child: Dismissible(
        key: Key('notif_${n.id}'),
        direction: DismissDirection.endToStart,
        background: Container(
          alignment: Alignment.centerRight,
          padding: const EdgeInsets.only(right: AppSpacing.lg),
          color: AppColors.error,
          child: const Icon(Icons.delete_outline,
              color: Colors.white, size: 22),
        ),
        onDismissed: (_) => onDismiss(),
        child: InkWell(
          onTap: onTap,
          child: Container(
            color: isRead
                ? Colors.transparent
                : AppColors.primary.withValues(alpha: 0.04),
            child: Padding(
              padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.md, vertical: AppSpacing.md),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Icon
                  Container(
                    width: 42,
                    height: 42,
                    decoration: BoxDecoration(
                      color: priorityColor.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(AppRadius.md),
                    ),
                    child: Icon(typeIcon,
                        color: priorityColor, size: 20),
                  ),
                  const SizedBox(width: AppSpacing.md),

                  // Content
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(n.message,
                            style: AppTextStyles.bodyMd.copyWith(
                              fontWeight: isRead
                                  ? FontWeight.w400
                                  : FontWeight.w600,
                              color: isDark
                                  ? AppColors.darkTextPrimary
                                  : AppColors.textPrimary,
                            )),
                        const SizedBox(height: 3),
                        Text(formatDate(n.createdAt),
                            style: AppTextStyles.bodySm.copyWith(
                              color: isDark
                                  ? AppColors.darkTextSecondary
                                  : AppColors.textSecondary,
                            )),
                      ],
                    ),
                  ),

                  // Unread dot
                  if (!isRead)
                    Container(
                      width: 8,
                      height: 8,
                      margin: const EdgeInsets.only(top: 6, left: 8),
                      decoration: const BoxDecoration(
                        color: AppColors.primary,
                        shape: BoxShape.circle,
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
