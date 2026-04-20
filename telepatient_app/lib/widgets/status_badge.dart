import 'package:flutter/material.dart';
import '../utils/app_theme.dart';
import '../utils/helpers.dart';

class StatusBadge extends StatelessWidget {
  final String status;
  final double fontSize;

  const StatusBadge(this.status, {super.key, this.fontSize = 11});

  @override
  Widget build(BuildContext context) {
    final color = tokenStatusColor(status);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(AppRadius.full),
      ),
      child: Text(
        status,
        style: AppTextStyles.labelSm.copyWith(
            color: color, fontSize: fontSize),
      ),
    );
  }
}

/// Priority badge (HIGH / MEDIUM / LOW)
class PriorityBadge extends StatelessWidget {
  final String priority;
  const PriorityBadge(this.priority, {super.key});

  @override
  Widget build(BuildContext context) {
    final (color, bg) = switch (priority) {
      'HIGH'   => (AppColors.error, AppColors.errorSurface),
      'MEDIUM' => (AppColors.warning, AppColors.warningSurface),
      _        => (AppColors.textSecondary, AppColors.surfaceVariant),
    };
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(AppRadius.full),
      ),
      child: Text(priority,
          style: AppTextStyles.labelSm.copyWith(color: color)),
    );
  }
}
