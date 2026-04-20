import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../providers/auth_provider.dart';
import '../../../services/patient_service.dart';
import '../../../models/consultation_model.dart';
import '../../../utils/app_theme.dart';
import '../../../utils/constants.dart';
import '../../../utils/helpers.dart';
import '../../../utils/page_transitions.dart';
import '../../../widgets/empty_state.dart';
import '../../../widgets/skeleton_loader.dart';
import '../../auth/login_screen.dart';

class PatientHomeTab extends StatefulWidget {
  final int patientId;
  const PatientHomeTab({super.key, required this.patientId});

  @override
  State<PatientHomeTab> createState() => _PatientHomeTabState();
}

class _PatientHomeTabState extends State<PatientHomeTab> {
  final _service = PatientService();
  List<ConsultationModel> _history = [];
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadHistory();
  }

  Future<void> _loadHistory() async {
    setState(() { _loading = true; _error = null; });
    try {
      _history = await _service.getHistory(widget.patientId);
    } catch (e) {
      _error = e.toString();
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _triggerEmergency() async {
    final level = await showDialog<String>(
      context: context,
      builder: (_) => const _EmergencyDialog(),
    );
    if (level == null) return;
    try {
      final msg = await _service.triggerEmergency(widget.patientId, level);
      if (mounted) showSuccess(context, msg);
    } catch (e) {
      if (mounted) showError(context, e.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth   = context.watch<AuthProvider>();
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final firstName = auth.fullName.split(' ').first;

    return Scaffold(
      backgroundColor:
          isDark ? AppColors.darkBackground : AppColors.background,
      body: RefreshIndicator(
        onRefresh: _loadHistory,
        color: AppColors.primary,
        child: CustomScrollView(
          slivers: [
            // ── SliverAppBar ─────────────────────────────────────────────────
            SliverAppBar(
              expandedHeight: 140,
              floating: true,
              snap: true,
              pinned: false,
              backgroundColor:
                  isDark ? AppColors.darkSurface : AppColors.surface,
              elevation: 0,
              automaticallyImplyLeading: false,
              flexibleSpace: FlexibleSpaceBar(
                background: Container(
                  padding: const EdgeInsets.fromLTRB(
                      AppSpacing.lg, 56, AppSpacing.lg, AppSpacing.md),
                  decoration: BoxDecoration(
                    color: isDark ? AppColors.darkSurface : AppColors.surface,
                    border: Border(
                      bottom: BorderSide(
                        color: isDark
                            ? AppColors.darkBorder
                            : AppColors.border,
                      ),
                    ),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Expanded(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.end,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Good ${_greeting()},',
                                style: AppTextStyles.bodyMd.copyWith(
                                  color: isDark
                                      ? AppColors.darkTextSecondary
                                      : AppColors.textSecondary,
                                )),
                            Text(firstName,
                                style: AppTextStyles.displaySm.copyWith(
                                  color: isDark
                                      ? AppColors.darkTextPrimary
                                      : AppColors.textPrimary,
                                )),
                          ],
                        ),
                      ),
                      // Avatar + logout
                      GestureDetector(
                        onTap: () => _showLogoutDialog(context, auth),
                        child: CircleAvatar(
                          radius: 22,
                          backgroundColor:
                              AppColors.primary.withValues(alpha: 0.12),
                          child: Text(
                            firstName.isNotEmpty
                                ? firstName[0].toUpperCase()
                                : '?',
                            style: AppTextStyles.titleMd.copyWith(
                                color: AppColors.primary),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // ── Emergency banner ──────────────────────────────────────────────
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(
                    AppSpacing.md, AppSpacing.md, AppSpacing.md, 0),
                child: _EmergencyBanner(onTap: _triggerEmergency),
              ),
            ),

            // ── Section header ────────────────────────────────────────────────
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(
                    AppSpacing.md, AppSpacing.lg, AppSpacing.md, AppSpacing.sm),
                child: Row(children: [
                  Text('Consultation History',
                      style: AppTextStyles.titleMd.copyWith(
                        color: isDark
                            ? AppColors.darkTextPrimary
                            : AppColors.textPrimary,
                      )),
                  const Spacer(),
                  if (!_loading)
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 3),
                      decoration: BoxDecoration(
                        color: AppColors.primarySurface,
                        borderRadius:
                            BorderRadius.circular(AppRadius.full),
                      ),
                      child: Text('${_history.length} records',
                          style: AppTextStyles.labelSm.copyWith(
                              color: AppColors.primary)),
                    ),
                ]),
              ),
            ),

            // ── Content ───────────────────────────────────────────────────────
            if (_loading)
              const SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: AppSpacing.md),
                  child: SkeletonList(count: 4, useCards: true),
                ),
              )
            else if (_error != null)
              SliverFillRemaining(
                child: EmptyState(
                  message: 'Could not load history',
                  subtitle: _error,
                  icon: Icons.cloud_off_outlined,
                  onRetry: _loadHistory,
                ),
              )
            else if (_history.isEmpty)
              const SliverFillRemaining(
                child: EmptyState(
                  message: 'No consultations yet',
                  subtitle:
                      'Your consultation history will appear here after your first visit.',
                  icon: Icons.medical_services_outlined,
                ),
              )
            else
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(
                    AppSpacing.md, 0, AppSpacing.md, AppSpacing.xl),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (ctx, i) => _ConsultationCard(
                        consultation: _history[i], index: i),
                    childCount: _history.length,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  String _greeting() {
    final h = DateTime.now().hour;
    if (h < 12) return 'morning';
    if (h < 17) return 'afternoon';
    return 'evening';
  }

  void _showLogoutDialog(BuildContext ctx, AuthProvider auth) {
    showDialog(
      context: ctx,
      builder: (_) => AlertDialog(
        title: const Text('Sign out?'),
        content: const Text('You will need to sign in again to access your account.'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancel')),
          TextButton(
            onPressed: () async {
              Navigator.pop(ctx);
              await auth.logout();
              if (mounted) {
                Navigator.pushAndRemoveUntil(context,
                    FadeRoute(page: const LoginScreen()), (_) => false);
              }
            },
            child: Text('Sign out',
                style: TextStyle(color: AppColors.error)),
          ),
        ],
      ),
    );
  }
}

// ─── Emergency Banner ─────────────────────────────────────────────────────────

class _EmergencyBanner extends StatefulWidget {
  final VoidCallback onTap;
  const _EmergencyBanner({required this.onTap});

  @override
  State<_EmergencyBanner> createState() => _EmergencyBannerState();
}

class _EmergencyBannerState extends State<_EmergencyBanner>
    with SingleTickerProviderStateMixin {
  late AnimationController _pulse;

  @override
  void initState() {
    super.initState();
    _pulse = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _pulse.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onTap,
      child: AnimatedBuilder(
        animation: _pulse,
        builder: (_, child) => Container(
          padding: const EdgeInsets.all(AppSpacing.md),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFFB91C1C), Color(0xFFEF4444)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(AppRadius.lg),
            boxShadow: [
              BoxShadow(
                color: AppColors.critical.withValues(
                    alpha: 0.25 + _pulse.value * 0.2),
                blurRadius: 16 + _pulse.value * 8,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: child,
        ),
        child: Row(children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(AppRadius.md),
            ),
            child: const Icon(Icons.emergency_share,
                color: Colors.white, size: 24),
          ),
          const SizedBox(width: AppSpacing.md),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Emergency Alert',
                    style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                        fontSize: 15)),
                SizedBox(height: 2),
                Text('Tap to notify hospital immediately',
                    style: TextStyle(
                        color: Colors.white70, fontSize: 12)),
              ],
            ),
          ),
          const Icon(Icons.chevron_right, color: Colors.white70),
        ]),
      ),
    );
  }
}

// ─── Emergency Dialog ─────────────────────────────────────────────────────────

class _EmergencyDialog extends StatelessWidget {
  const _EmergencyDialog();

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Select Emergency Level'),
      content: Column(mainAxisSize: MainAxisSize.min, children: [
        _LevelTile(EmergencyLevel.critical, AppColors.critical,
            Icons.warning_amber_rounded,
            'Immediate life-threatening situation'),
        const SizedBox(height: AppSpacing.sm),
        _LevelTile(EmergencyLevel.urgent, AppColors.urgent,
            Icons.priority_high_rounded,
            'Urgent but not immediately life-threatening'),
        const SizedBox(height: AppSpacing.sm),
        _LevelTile(EmergencyLevel.normal, AppColors.normal,
            Icons.info_outline_rounded,
            'Non-urgent medical concern'),
      ]),
      actions: [
        TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel')),
      ],
    );
  }
}

class _LevelTile extends StatelessWidget {
  final String level;
  final Color color;
  final IconData icon;
  final String description;
  const _LevelTile(this.level, this.color, this.icon, this.description);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => Navigator.pop(context, level),
      borderRadius: BorderRadius.circular(AppRadius.md),
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.md),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(AppRadius.md),
          border: Border.all(color: color.withValues(alpha: 0.3)),
        ),
        child: Row(children: [
          Icon(icon, color: color, size: 22),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(level,
                    style: AppTextStyles.titleSm.copyWith(color: color)),
                Text(description,
                    style: AppTextStyles.bodySm.copyWith(
                        color: AppColors.textSecondary)),
              ],
            ),
          ),
          Icon(Icons.chevron_right, color: color.withValues(alpha: 0.6)),
        ]),
      ),
    );
  }
}

// ─── Consultation Card ────────────────────────────────────────────────────────

class _ConsultationCard extends StatelessWidget {
  final ConsultationModel consultation;
  final int index;
  const _ConsultationCard(
      {required this.consultation, required this.index});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final c = consultation;

    // Staggered entrance animation
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: Duration(milliseconds: 300 + index * 60),
      curve: Curves.easeOutCubic,
      builder: (_, value, child) => Opacity(
        opacity: value,
        child: Transform.translate(
          offset: Offset(0, 20 * (1 - value)),
          child: child,
        ),
      ),
      child: Container(
        margin: const EdgeInsets.only(bottom: AppSpacing.md),
        decoration: BoxDecoration(
          color: isDark ? AppColors.darkSurface : AppColors.surface,
          borderRadius: BorderRadius.circular(AppRadius.lg),
          border: Border.all(
              color: isDark ? AppColors.darkBorder : AppColors.border),
        ),
        child: Theme(
          data: Theme.of(context).copyWith(
            dividerColor: Colors.transparent,
          ),
          child: ExpansionTile(
            tilePadding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.md, vertical: AppSpacing.xs),
            childrenPadding: const EdgeInsets.fromLTRB(
                AppSpacing.md, 0, AppSpacing.md, AppSpacing.md),
            leading: CircleAvatar(
              radius: 22,
              backgroundColor: AppColors.primary.withValues(alpha: 0.1),
              child: Text(
                c.doctorName.isNotEmpty
                    ? c.doctorName[0].toUpperCase()
                    : 'D',
                style: AppTextStyles.titleSm.copyWith(
                    color: AppColors.primary),
              ),
            ),
            title: Text('Dr. ${c.doctorName}',
                style: AppTextStyles.titleSm.copyWith(
                  color: isDark
                      ? AppColors.darkTextPrimary
                      : AppColors.textPrimary,
                )),
            subtitle: Text(formatDate(c.date),
                style: AppTextStyles.bodySm.copyWith(
                  color: isDark
                      ? AppColors.darkTextSecondary
                      : AppColors.textSecondary,
                )),
            children: [
              const Divider(height: 1),
              const SizedBox(height: AppSpacing.md),
              if (c.notes != null && c.notes!.isNotEmpty)
                _DetailRow(Icons.notes_outlined, 'Notes', c.notes!),
              if (c.prescription != null && c.prescription!.isNotEmpty)
                _DetailRow(
                    Icons.medication_outlined, 'Prescription', c.prescription!),
              if (c.reportsUrl != null && c.reportsUrl!.isNotEmpty)
                _DetailRow(Icons.link_outlined, 'Report', c.reportsUrl!),
            ],
          ),
        ),
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  const _DetailRow(this.icon, this.label, this.value);

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: AppColors.primarySurface,
            borderRadius: BorderRadius.circular(AppRadius.sm),
          ),
          child: Icon(icon, size: 14, color: AppColors.primary),
        ),
        const SizedBox(width: AppSpacing.sm),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label,
                  style: AppTextStyles.labelMd.copyWith(
                    color: isDark
                        ? AppColors.darkTextSecondary
                        : AppColors.textSecondary,
                  )),
              const SizedBox(height: 2),
              Text(value,
                  style: AppTextStyles.bodyMd.copyWith(
                    color: isDark
                        ? AppColors.darkTextPrimary
                        : AppColors.textPrimary,
                  )),
            ],
          ),
        ),
      ]),
    );
  }
}
