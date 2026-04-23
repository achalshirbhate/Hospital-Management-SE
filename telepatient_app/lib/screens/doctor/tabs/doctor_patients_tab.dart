import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../providers/auth_provider.dart';
import '../../../services/doctor_service.dart';
import '../../../models/patient_model.dart';
import '../../../utils/app_theme.dart';
import '../../../utils/helpers.dart';
import '../../../utils/page_transitions.dart';
import '../../../widgets/empty_state.dart';
import '../../../widgets/skeleton_loader.dart';
import '../../auth/login_screen.dart';
import '../patient_detail_screen.dart';

class DoctorPatientsTab extends StatefulWidget {
  final int doctorId;
  const DoctorPatientsTab({super.key, required this.doctorId});

  @override
  State<DoctorPatientsTab> createState() => _DoctorPatientsTabState();
}

class _DoctorPatientsTabState extends State<DoctorPatientsTab> {
  final _service = DoctorService();
  List<PatientModel> _patients = [];
  bool _loading = true;
  String _search = '';

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    try {
      _patients = await _service.getAssignedPatients(widget.doctorId);
    } catch (e) {
      if (mounted) showError(context, e.toString());
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  List<PatientModel> get _filtered => _patients
      .where((p) => p.fullName.toLowerCase().contains(_search.toLowerCase()))
      .toList();

  @override
  Widget build(BuildContext context) {
    final auth   = context.watch<AuthProvider>();
    final isDark = Theme.of(context).brightness == Brightness.dark;

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
            AppSpacing.lg,
            AppSpacing.md,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('My Patients',
                          style: AppTextStyles.displaySm.copyWith(
                            color: isDark
                                ? AppColors.darkTextPrimary
                                : AppColors.textPrimary,
                          )),
                      Text('Dr. ${auth.fullName}',
                          style: AppTextStyles.bodyMd.copyWith(
                            color: isDark
                                ? AppColors.darkTextSecondary
                                : AppColors.textSecondary,
                          )),
                    ],
                  ),
                ),
                // Patient count badge
                if (!_loading)
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: AppColors.primarySurface,
                      borderRadius: BorderRadius.circular(AppRadius.full),
                    ),
                    child: Text('${_patients.length}',
                        style: AppTextStyles.titleSm.copyWith(
                            color: AppColors.primary)),
                  ),
                const SizedBox(width: AppSpacing.sm),
                // Logout
                IconButton(
                  icon: const Icon(Icons.logout_outlined, size: 20),
                  color: isDark
                      ? AppColors.darkTextSecondary
                      : AppColors.textSecondary,
                  onPressed: () => _showLogoutDialog(context, auth),
                ),
              ]),
              const SizedBox(height: AppSpacing.md),
              // Search bar
              TextField(
                onChanged: (v) => setState(() => _search = v),
                style: AppTextStyles.bodyMd.copyWith(
                  color: isDark
                      ? AppColors.darkTextPrimary
                      : AppColors.textPrimary,
                ),
                decoration: InputDecoration(
                  hintText: 'Search patients...',
                  prefixIcon: const Icon(Icons.search, size: 20),
                  filled: true,
                  fillColor: isDark
                      ? AppColors.darkSurfaceVariant
                      : AppColors.surfaceVariant,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(AppRadius.md),
                    borderSide: BorderSide.none,
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(AppRadius.md),
                    borderSide: BorderSide.none,
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(AppRadius.md),
                    borderSide: const BorderSide(
                        color: AppColors.primary, width: 1.5),
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16, vertical: 12),
                ),
              ),
            ],
          ),
        ),

        // ── List ──────────────────────────────────────────────────────────────
        Expanded(
          child: RefreshIndicator(
            onRefresh: _load,
            color: AppColors.primary,
            child: _loading
                ? const SkeletonList(count: 6)
                : _filtered.isEmpty
                    ? EmptyState(
                        message: _search.isNotEmpty
                            ? 'No patients match "$_search"'
                            : 'No patients assigned yet',
                        subtitle: _search.isEmpty
                            ? 'Patients you add will appear here.'
                            : null,
                        icon: Icons.people_outline,
                        onRetry: _search.isNotEmpty
                            ? () => setState(() => _search = '')
                            : null,
                        retryLabel: 'Clear search',
                      )
                    : ListView.separated(
                        padding: const EdgeInsets.symmetric(
                            vertical: AppSpacing.sm),
                        itemCount: _filtered.length,
                        separatorBuilder: (_, __) =>
                            const Divider(height: 1, indent: 72),
                        itemBuilder: (_, i) => _PatientTile(
                          patient: _filtered[i],
                          index: i,
                          onTap: () => Navigator.push(
                            context,
                            SlideRightRoute(
                              page: PatientDetailScreen(
                                patient: _filtered[i],
                                doctorId: widget.doctorId,
                              ),
                            ),
                          ).then((_) => _load()),
                        ),
                      ),
          ),
        ),
      ]),
    );
  }

  void _showLogoutDialog(BuildContext ctx, AuthProvider auth) {
    showDialog(
      context: ctx,
      builder: (_) => AlertDialog(
        title: const Text('Sign out?'),
        content: const Text(
            'You will need to sign in again to access your account.'),
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

// ─── Patient Tile ─────────────────────────────────────────────────────────────

class _PatientTile extends StatelessWidget {
  final PatientModel patient;
  final int index;
  final VoidCallback onTap;
  const _PatientTile(
      {required this.patient, required this.index, required this.onTap});

  // Cycle through a palette for avatar backgrounds
  static const _avatarColors = [
    Color(0xFF3B82F6), Color(0xFF8B5CF6), Color(0xFF10B981),
    Color(0xFFF59E0B), Color(0xFFEF4444), Color(0xFF06B6D4),
  ];

  @override
  Widget build(BuildContext context) {
    final isDark    = Theme.of(context).brightness == Brightness.dark;
    final avatarBg  = _avatarColors[index % _avatarColors.length];
    final initial   = patient.fullName.isNotEmpty
        ? patient.fullName[0].toUpperCase()
        : '?';

    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: Duration(milliseconds: 250 + index * 40),
      curve: Curves.easeOutCubic,
      builder: (_, v, child) => Opacity(
        opacity: v,
        child: Transform.translate(offset: Offset(20 * (1 - v), 0), child: child),
      ),
      child: ListTile(
        onTap: onTap,
        contentPadding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.md, vertical: AppSpacing.xs),
        leading: CircleAvatar(
          radius: 22,
          backgroundColor: avatarBg,
          child: Text(initial,
              style: AppTextStyles.titleSm.copyWith(color: Colors.white)),
        ),
        title: Text(patient.fullName,
            style: AppTextStyles.titleSm.copyWith(
              color: isDark
                  ? AppColors.darkTextPrimary
                  : AppColors.textPrimary,
            )),
        subtitle: Row(children: [
          if (patient.age != null) ...[
            Icon(Icons.cake_outlined,
                size: 12,
                color: isDark
                    ? AppColors.darkTextSecondary
                    : AppColors.textSecondary),
            const SizedBox(width: 3),
            Text('${patient.age} yrs',
                style: AppTextStyles.bodySm.copyWith(
                  color: isDark
                      ? AppColors.darkTextSecondary
                      : AppColors.textSecondary,
                )),
            const SizedBox(width: AppSpacing.sm),
          ],
          if (patient.lastConsultation != null) ...[
            Icon(Icons.access_time_outlined,
                size: 12,
                color: isDark
                    ? AppColors.darkTextSecondary
                    : AppColors.textSecondary),
            const SizedBox(width: 3),
            Text(formatDateOnly(patient.lastConsultation),
                style: AppTextStyles.bodySm.copyWith(
                  color: isDark
                      ? AppColors.darkTextSecondary
                      : AppColors.textSecondary,
                )),
          ],
        ]),
        trailing: const Icon(Icons.chevron_right,
            size: 18, color: AppColors.textHint),
      ),
    );
  }
}
