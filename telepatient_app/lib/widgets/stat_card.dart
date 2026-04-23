import 'package:flutter/material.dart';
import '../utils/app_theme.dart';
import 'app_card.dart';

/// Animated dashboard stat card.
class StatCard extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;
  final VoidCallback? onTap;
  final String? trend; // e.g. "+12%" shown as a small badge

  const StatCard({
    super.key,
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
    this.onTap,
    this.trend,
  });

  @override
  Widget build(BuildContext context) {
    return AppCard(
      onTap: onTap,
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(AppRadius.sm),
              ),
              child: Icon(icon, color: color, size: 20),
            ),
            const Spacer(),
            if (trend != null)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: AppColors.successSurface,
                  borderRadius: BorderRadius.circular(AppRadius.full),
                ),
                child: Text(trend!,
                    style: AppTextStyles.labelSm.copyWith(
                        color: AppColors.success)),
              )
            else if (onTap != null)
              Icon(Icons.arrow_forward_ios,
                  size: 12,
                  color: Theme.of(context).brightness == Brightness.dark
                      ? AppColors.darkTextSecondary
                      : AppColors.textHint),
          ]),
          const SizedBox(height: AppSpacing.sm),
          Text(value,
              style: AppTextStyles.displaySm.copyWith(
                color: Theme.of(context).brightness == Brightness.dark
                    ? AppColors.darkTextPrimary
                    : AppColors.textPrimary,
              )),
          const SizedBox(height: 2),
          Text(label,
              style: AppTextStyles.bodySm.copyWith(
                color: Theme.of(context).brightness == Brightness.dark
                    ? AppColors.darkTextSecondary
                    : AppColors.textSecondary,
              )),
        ],
      ),
    );
  }
}
