import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../../providers/auth_provider.dart';
import '../../../services/md_service.dart';
import '../../../models/dashboard_model.dart';
import '../../../utils/app_theme.dart';
import '../../../utils/helpers.dart';
import '../../../utils/page_transitions.dart';
import '../../../widgets/stat_card.dart';
import '../../../widgets/skeleton_loader.dart';
import '../../auth/login_screen.dart';

class MdHomeTab extends StatefulWidget {
  final int mdId;
  const MdHomeTab({super.key, required this.mdId});

  @override
  State<MdHomeTab> createState() => _MdHomeTabState();
}

class _MdHomeTabState extends State<MdHomeTab> {
  final _service = MdService();
  DashboardModel? _data;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    try {
      _data = await _service.getDashboard();
    } catch (e) {
      if (mounted) showError(context, e.toString());
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth   = context.watch<AuthProvider>();
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor:
          isDark ? AppColors.darkBackground : AppColors.background,
      body: RefreshIndicator(
        onRefresh: _load,
        color: AppColors.primary,
        child: CustomScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          slivers: [
            // ── Header ────────────────────────────────────────────────────────
            SliverToBoxAdapter(
              child: Container(
                color: isDark ? AppColors.darkSurface : AppColors.surface,
                padding: EdgeInsets.fromLTRB(
                  AppSpacing.lg,
                  MediaQuery.of(context).padding.top + AppSpacing.md,
                  AppSpacing.lg,
                  AppSpacing.lg,
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Dashboard',
                              style: AppTextStyles.displaySm.copyWith(
                                color: isDark
                                    ? AppColors.darkTextPrimary
                                    : AppColors.textPrimary,
                              )),
                          const SizedBox(height: 2),
                          Text('Welcome back, ${auth.fullName.split(' ').first}',
                              style: AppTextStyles.bodyMd.copyWith(
                                color: isDark
                                    ? AppColors.darkTextSecondary
                                    : AppColors.textSecondary,
                              )),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.refresh_outlined, size: 20),
                      color: isDark
                          ? AppColors.darkTextSecondary
                          : AppColors.textSecondary,
                      onPressed: _load,
                    ),
                    IconButton(
                      icon: const Icon(Icons.logout_outlined, size: 20),
                      color: isDark
                          ? AppColors.darkTextSecondary
                          : AppColors.textSecondary,
                      onPressed: () async {
                        await auth.logout();
                        if (mounted) {
                          Navigator.pushAndRemoveUntil(
                              context,
                              FadeRoute(page: const LoginScreen()),
                              (_) => false);
                        }
                      },
                    ),
                  ],
                ),
              ),
            ),

            // ── Stats grid ────────────────────────────────────────────────────
            SliverPadding(
              padding: const EdgeInsets.all(AppSpacing.md),
              sliver: SliverToBoxAdapter(
                child: _loading
                    ? const SkeletonStatsGrid(count: 6)
                    : GridView.count(
                        crossAxisCount: 2,
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        crossAxisSpacing: AppSpacing.sm,
                        mainAxisSpacing: AppSpacing.sm,
                        childAspectRatio: 1.35,
                        children: [
                          StatCard(
                            label: 'Total Patients',
                            value: '${_data!.patientCount}',
                            icon: Icons.people_outline,
                            color: AppColors.primary,
                          ),
                          StatCard(
                            label: 'Active Doctors',
                            value: '${_data!.activeDoctors}',
                            icon: Icons.medical_services_outlined,
                            color: AppColors.accent,
                          ),
                          StatCard(
                            label: 'Pending Referrals',
                            value: '${_data!.pendingReferrals}',
                            icon: Icons.swap_horiz_outlined,
                            color: AppColors.warning,
                          ),
                          StatCard(
                            label: 'Pending Tokens',
                            value: '${_data!.pendingTokenRequests}',
                            icon: Icons.pending_actions_outlined,
                            color: const Color(0xFF7C3AED),
                          ),
                          StatCard(
                            label: 'Appointments',
                            value: '${_data!.totalAppointments}',
                            icon: Icons.calendar_today_outlined,
                            color: const Color(0xFF0D9488),
                          ),
                          StatCard(
                            label: 'Profit / Loss',
                            value: formatCurrency(_data!.profitLoss),
                            icon: _data!.profitLoss >= 0
                                ? Icons.trending_up
                                : Icons.trending_down,
                            color: _data!.profitLoss >= 0
                                ? AppColors.success
                                : AppColors.error,
                          ),
                        ],
                      ),
              ),
            ),

            // ── Finance summary ───────────────────────────────────────────────
            if (!_loading && _data != null)
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(
                    AppSpacing.md, 0, AppSpacing.md, AppSpacing.md),
                sliver: SliverToBoxAdapter(
                  child: _FinanceSummaryCard(data: _data!),
                ),
              ),

            // ── Doctor activity chart ─────────────────────────────────────────
            if (!_loading &&
                _data != null &&
                _data!.doctorActivity.isNotEmpty)
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(
                    AppSpacing.md, 0, AppSpacing.md, AppSpacing.xl),
                sliver: SliverToBoxAdapter(
                  child: _DoctorActivityCard(data: _data!.doctorActivity),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

// ─── Finance Summary Card ─────────────────────────────────────────────────────

class _FinanceSummaryCard extends StatelessWidget {
  final DashboardModel data;
  const _FinanceSummaryCard({required this.data});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(
            color: isDark ? AppColors.darkBorder : AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            Text('Financial Overview',
                style: AppTextStyles.titleMd.copyWith(
                  color: isDark
                      ? AppColors.darkTextPrimary
                      : AppColors.textPrimary,
                )),
            const Spacer(),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: data.profitLoss >= 0
                    ? AppColors.successSurface
                    : AppColors.errorSurface,
                borderRadius: BorderRadius.circular(AppRadius.full),
              ),
              child: Text(
                data.profitLoss >= 0 ? 'Profitable' : 'Loss',
                style: AppTextStyles.labelSm.copyWith(
                  color: data.profitLoss >= 0
                      ? AppColors.success
                      : AppColors.error,
                ),
              ),
            ),
          ]),
          const SizedBox(height: AppSpacing.md),
          Row(children: [
            _FinanceTile(
                'Revenue', data.totalRevenue, AppColors.success,
                AppColors.successSurface),
            const SizedBox(width: AppSpacing.sm),
            _FinanceTile(
                'Expenses', data.totalExpenses, AppColors.error,
                AppColors.errorSurface),
          ]),
          const SizedBox(height: AppSpacing.sm),
          // Net bar
          ClipRRect(
            borderRadius: BorderRadius.circular(AppRadius.full),
            child: LinearProgressIndicator(
              value: data.totalRevenue > 0
                  ? (data.totalRevenue /
                          (data.totalRevenue + data.totalExpenses))
                      .clamp(0.0, 1.0)
                  : 0,
              minHeight: 6,
              backgroundColor: AppColors.errorSurface,
              valueColor: const AlwaysStoppedAnimation(AppColors.success),
            ),
          ),
        ],
      ),
    );
  }
}

class _FinanceTile extends StatelessWidget {
  final String label;
  final double amount;
  final Color color;
  final Color bg;
  const _FinanceTile(this.label, this.amount, this.color, this.bg);

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.md),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(AppRadius.md),
        ),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(label,
              style: AppTextStyles.labelMd.copyWith(color: color)),
          const SizedBox(height: 4),
          Text(formatCurrency(amount),
              style: AppTextStyles.titleMd.copyWith(color: color)),
        ]),
      ),
    );
  }
}

// ─── Doctor Activity Chart ────────────────────────────────────────────────────

class _DoctorActivityCard extends StatelessWidget {
  final Map<String, int> data;
  const _DoctorActivityCard({required this.data});

  @override
  Widget build(BuildContext context) {
    final isDark   = Theme.of(context).brightness == Brightness.dark;
    final entries  = data.entries.toList();
    final maxY     = entries
            .map((e) => e.value)
            .reduce((a, b) => a > b ? a : b)
            .toDouble() +
        2;

    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(
            color: isDark ? AppColors.darkBorder : AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Doctor Activity',
              style: AppTextStyles.titleMd.copyWith(
                color: isDark
                    ? AppColors.darkTextPrimary
                    : AppColors.textPrimary,
              )),
          Text('Consultations per doctor',
              style: AppTextStyles.bodySm.copyWith(
                color: isDark
                    ? AppColors.darkTextSecondary
                    : AppColors.textSecondary,
              )),
          const SizedBox(height: AppSpacing.md),
          SizedBox(
            height: 180,
            child: BarChart(
              BarChartData(
                alignment: BarChartAlignment.spaceAround,
                maxY: maxY,
                barGroups: entries.asMap().entries.map((e) {
                  return BarChartGroupData(x: e.key, barRods: [
                    BarChartRodData(
                      toY: e.value.value.toDouble(),
                      gradient: LinearGradient(
                        colors: [
                          AppColors.primary,
                          AppColors.primaryLight,
                        ],
                        begin: Alignment.bottomCenter,
                        end: Alignment.topCenter,
                      ),
                      width: 22,
                      borderRadius: const BorderRadius.vertical(
                          top: Radius.circular(6)),
                    ),
                  ]);
                }).toList(),
                titlesData: FlTitlesData(
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 28,
                      getTitlesWidget: (v, _) {
                        final idx = v.toInt();
                        if (idx >= entries.length) return const SizedBox();
                        final parts = entries[idx].key.split(' ');
                        final name = parts.length > 1
                            ? parts.last
                            : parts.first;
                        return Padding(
                          padding: const EdgeInsets.only(top: 4),
                          child: Text(name,
                              style: AppTextStyles.labelSm.copyWith(
                                color: isDark
                                    ? AppColors.darkTextSecondary
                                    : AppColors.textSecondary,
                              )),
                        );
                      },
                    ),
                  ),
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 32,
                      getTitlesWidget: (v, _) => Text(
                        v.toInt().toString(),
                        style: AppTextStyles.labelSm.copyWith(
                          color: isDark
                              ? AppColors.darkTextSecondary
                              : AppColors.textSecondary,
                        ),
                      ),
                    ),
                  ),
                  topTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false)),
                  rightTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false)),
                ),
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: false,
                  getDrawingHorizontalLine: (_) => FlLine(
                    color: isDark
                        ? AppColors.darkBorder
                        : AppColors.border,
                    strokeWidth: 1,
                  ),
                ),
                borderData: FlBorderData(show: false),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
