import 'package:flutter/material.dart';
import '../utils/app_theme.dart';

/// Tappable card with press animation and consistent styling.
class AppCard extends StatefulWidget {
  final Widget child;
  final VoidCallback? onTap;
  final EdgeInsetsGeometry? padding;
  final Color? color;
  final double? borderRadius;

  const AppCard({
    super.key,
    required this.child,
    this.onTap,
    this.padding,
    this.color,
    this.borderRadius,
  });

  @override
  State<AppCard> createState() => _AppCardState();
}

class _AppCardState extends State<AppCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 120));
    _scale = Tween<double>(begin: 1.0, end: 0.98)
        .animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardColor = widget.color ??
        (isDark ? AppColors.darkSurface : AppColors.surface);
    final borderColor = isDark ? AppColors.darkBorder : AppColors.border;
    final radius = widget.borderRadius ?? AppRadius.lg;

    return GestureDetector(
      onTapDown: widget.onTap != null ? (_) => _ctrl.forward() : null,
      onTapUp: widget.onTap != null ? (_) => _ctrl.reverse() : null,
      onTapCancel: widget.onTap != null ? () => _ctrl.reverse() : null,
      onTap: widget.onTap,
      child: ScaleTransition(
        scale: _scale,
        child: Container(
          padding: widget.padding ?? const EdgeInsets.all(AppSpacing.md),
          decoration: BoxDecoration(
            color: cardColor,
            borderRadius: BorderRadius.circular(radius),
            border: Border.all(color: borderColor),
          ),
          child: widget.child,
        ),
      ),
    );
  }
}
