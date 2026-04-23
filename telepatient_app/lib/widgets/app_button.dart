import 'package:flutter/material.dart';
import '../utils/app_theme.dart';

/// Animated primary button with built-in loading state and press scale effect.
class AppButton extends StatefulWidget {
  final String label;
  final VoidCallback? onPressed;
  final bool loading;
  final IconData? icon;
  final Color? color;
  final double? width;
  final double height;

  const AppButton({
    super.key,
    required this.label,
    this.onPressed,
    this.loading = false,
    this.icon,
    this.color,
    this.width,
    this.height = 52,
  });

  @override
  State<AppButton> createState() => _AppButtonState();
}

class _AppButtonState extends State<AppButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 100));
    _scale = Tween<double>(begin: 1.0, end: 0.96)
        .animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bg = widget.color ?? AppColors.primary;
    return GestureDetector(
      onTapDown: (_) => _ctrl.forward(),
      onTapUp: (_) => _ctrl.reverse(),
      onTapCancel: () => _ctrl.reverse(),
      child: ScaleTransition(
        scale: _scale,
        child: SizedBox(
          width: widget.width ?? double.infinity,
          height: widget.height,
          child: ElevatedButton(
            onPressed: widget.loading ? null : widget.onPressed,
            style: ElevatedButton.styleFrom(
              backgroundColor: bg,
              disabledBackgroundColor: bg.withValues(alpha: 0.6),
              foregroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppRadius.md)),
            ),
            child: widget.loading
                ? const SizedBox(
                    width: 22,
                    height: 22,
                    child: CircularProgressIndicator(
                        color: Colors.white, strokeWidth: 2.5))
                : widget.icon != null
                    ? Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(widget.icon, size: 18),
                          const SizedBox(width: 8),
                          Text(widget.label,
                              style: AppTextStyles.labelLg.copyWith(
                                  color: Colors.white, fontSize: 15)),
                        ],
                      )
                    : Text(widget.label,
                        style: AppTextStyles.labelLg.copyWith(
                            color: Colors.white, fontSize: 15)),
          ),
        ),
      ),
    );
  }
}
