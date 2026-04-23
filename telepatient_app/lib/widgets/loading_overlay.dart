import 'package:flutter/material.dart';
import '../utils/app_theme.dart';

/// Full-screen loading overlay with a subtle blur effect.
class LoadingOverlay extends StatelessWidget {
  final bool isLoading;
  final Widget child;

  const LoadingOverlay({
    super.key,
    required this.isLoading,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(children: [
      child,
      if (isLoading)
        AnimatedOpacity(
          opacity: isLoading ? 1.0 : 0.0,
          duration: const Duration(milliseconds: 200),
          child: Container(
            color: Colors.black.withValues(alpha: 0.35),
            child: const Center(child: _Spinner()),
          ),
        ),
    ]);
  }
}

class _Spinner extends StatelessWidget {
  const _Spinner();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).brightness == Brightness.dark
            ? AppColors.darkSurface
            : AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.15),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: const SizedBox(
        width: 36,
        height: 36,
        child: CircularProgressIndicator(
          color: AppColors.primary,
          strokeWidth: 3,
        ),
      ),
    );
  }
}

/// Inline centered loader for list/content areas.
class InlineLoader extends StatelessWidget {
  const InlineLoader({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Padding(
        padding: EdgeInsets.all(32),
        child: CircularProgressIndicator(
          color: AppColors.primary,
          strokeWidth: 2.5,
        ),
      ),
    );
  }
}
