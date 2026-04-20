import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import '../utils/app_theme.dart';

// ─── Base shimmer wrapper ─────────────────────────────────────────────────────

class _Shimmer extends StatelessWidget {
  final Widget child;
  const _Shimmer({required this.child});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Shimmer.fromColors(
      baseColor: isDark ? AppColors.darkSurfaceVariant : const Color(0xFFE2E8F0),
      highlightColor: isDark ? AppColors.darkBorder : const Color(0xFFF8FAFC),
      child: child,
    );
  }
}

// ─── Skeleton box ─────────────────────────────────────────────────────────────

class SkeletonBox extends StatelessWidget {
  final double width;
  final double height;
  final double radius;

  const SkeletonBox({
    super.key,
    required this.width,
    required this.height,
    this.radius = AppRadius.sm,
  });

  @override
  Widget build(BuildContext context) {
    return _Shimmer(
      child: Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(radius),
        ),
      ),
    );
  }
}

// ─── Skeleton circle ──────────────────────────────────────────────────────────

class SkeletonCircle extends StatelessWidget {
  final double size;
  const SkeletonCircle({super.key, required this.size});

  @override
  Widget build(BuildContext context) {
    return _Shimmer(
      child: Container(
        width: size,
        height: size,
        decoration: const BoxDecoration(
          color: Colors.white,
          shape: BoxShape.circle,
        ),
      ),
    );
  }
}

// ─── Skeleton list item ───────────────────────────────────────────────────────

class SkeletonListItem extends StatelessWidget {
  final bool hasSubtitle;
  const SkeletonListItem({super.key, this.hasSubtitle = true});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Row(children: [
        const SkeletonCircle(size: 44),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SkeletonBox(
                  width: double.infinity, height: 14, radius: AppRadius.sm),
              if (hasSubtitle) ...[
                const SizedBox(height: 6),
                SkeletonBox(width: 160, height: 11, radius: AppRadius.sm),
              ],
            ],
          ),
        ),
      ]),
    );
  }
}

// ─── Skeleton stat card ───────────────────────────────────────────────────────

class SkeletonStatCard extends StatelessWidget {
  const SkeletonStatCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardTheme.color,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            const SkeletonCircle(size: 36),
            const Spacer(),
            SkeletonBox(width: 14, height: 14, radius: AppRadius.sm),
          ]),
          const SizedBox(height: 12),
          SkeletonBox(width: 60, height: 22, radius: AppRadius.sm),
          const SizedBox(height: 6),
          SkeletonBox(width: 90, height: 11, radius: AppRadius.sm),
        ],
      ),
    );
  }
}

// ─── Skeleton card ────────────────────────────────────────────────────────────

class SkeletonCard extends StatelessWidget {
  final double height;
  const SkeletonCard({super.key, this.height = 100});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardTheme.color,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            const SkeletonCircle(size: 40),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SkeletonBox(
                      width: double.infinity, height: 14, radius: AppRadius.sm),
                  const SizedBox(height: 6),
                  SkeletonBox(width: 120, height: 11, radius: AppRadius.sm),
                ],
              ),
            ),
          ]),
          const SizedBox(height: 12),
          SkeletonBox(
              width: double.infinity, height: 11, radius: AppRadius.sm),
          const SizedBox(height: 6),
          SkeletonBox(width: 200, height: 11, radius: AppRadius.sm),
        ],
      ),
    );
  }
}

// ─── Skeleton list (multiple items) ──────────────────────────────────────────

class SkeletonList extends StatelessWidget {
  final int count;
  final bool useCards;
  const SkeletonList({super.key, this.count = 5, this.useCards = false});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      physics: const NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      padding: useCards
          ? const EdgeInsets.all(16)
          : EdgeInsets.zero,
      itemCount: count,
      itemBuilder: (_, __) => useCards
          ? const SkeletonCard()
          : const SkeletonListItem(),
    );
  }
}

// ─── Skeleton stats grid ──────────────────────────────────────────────────────

class SkeletonStatsGrid extends StatelessWidget {
  final int count;
  const SkeletonStatsGrid({super.key, this.count = 6});

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 1.3,
      ),
      itemCount: count,
      itemBuilder: (_, __) => const SkeletonStatCard(),
    );
  }
}
