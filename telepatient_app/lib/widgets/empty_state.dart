import 'package:flutter/material.dart';
import '../utils/app_theme.dart';
import 'app_button.dart';

class EmptyState extends StatelessWidget {
  final String message;
  final String? subtitle;
  final IconData icon;
  final VoidCallback? onRetry;
  final String retryLabel;

  const EmptyState({
    super.key,
    required this.message,
    this.subtitle,
    this.icon = Icons.inbox_outlined,
    this.onRetry,
    this.retryLabel = 'Try again',
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Container(
            padding: const EdgeInsets.all(AppSpacing.lg),
            decoration: BoxDecoration(
              color: isDark
                  ? AppColors.darkSurfaceVariant
                  : AppColors.surfaceVariant,
              shape: BoxShape.circle,
            ),
            child: Icon(icon,
                size: 40,
                color: isDark
                    ? AppColors.darkTextSecondary
                    : AppColors.textHint),
          ),
          const SizedBox(height: AppSpacing.md),
          Text(message,
              textAlign: TextAlign.center,
              style: AppTextStyles.titleSm.copyWith(
                color: isDark
                    ? AppColors.darkTextPrimary
                    : AppColors.textPrimary,
              )),
          if (subtitle != null) ...[
            const SizedBox(height: AppSpacing.xs),
            Text(subtitle!,
                textAlign: TextAlign.center,
                style: AppTextStyles.bodyMd.copyWith(
                  color: isDark
                      ? AppColors.darkTextSecondary
                      : AppColors.textSecondary,
                )),
          ],
          if (onRetry != null) ...[
            const SizedBox(height: AppSpacing.lg),
            AppButton(
              label: retryLabel,
              onPressed: onRetry,
              icon: Icons.refresh,
              width: 160,
              height: 44,
            ),
          ],
        ]),
      ),
    );
  }
}
