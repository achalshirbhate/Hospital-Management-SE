import 'package:flutter/material.dart';

/// Slide-up transition — used for modals and detail screens.
class SlideUpRoute<T> extends PageRouteBuilder<T> {
  final Widget page;
  SlideUpRoute({required this.page})
      : super(
          pageBuilder: (_, __, ___) => page,
          transitionDuration: const Duration(milliseconds: 320),
          reverseTransitionDuration: const Duration(milliseconds: 280),
          transitionsBuilder: (_, animation, __, child) {
            final tween = Tween(
              begin: const Offset(0, 0.08),
              end: Offset.zero,
            ).chain(CurveTween(curve: Curves.easeOutCubic));
            return FadeTransition(
              opacity: animation,
              child: SlideTransition(
                position: animation.drive(tween),
                child: child,
              ),
            );
          },
        );
}

/// Fade transition — used for tab-level navigation.
class FadeRoute<T> extends PageRouteBuilder<T> {
  final Widget page;
  FadeRoute({required this.page})
      : super(
          pageBuilder: (_, __, ___) => page,
          transitionDuration: const Duration(milliseconds: 250),
          reverseTransitionDuration: const Duration(milliseconds: 200),
          transitionsBuilder: (_, animation, __, child) => FadeTransition(
            opacity: CurvedAnimation(
                parent: animation, curve: Curves.easeInOut),
            child: child,
          ),
        );
}

/// Slide-right transition — standard push navigation.
class SlideRightRoute<T> extends PageRouteBuilder<T> {
  final Widget page;
  SlideRightRoute({required this.page})
      : super(
          pageBuilder: (_, __, ___) => page,
          transitionDuration: const Duration(milliseconds: 300),
          reverseTransitionDuration: const Duration(milliseconds: 250),
          transitionsBuilder: (_, animation, __, child) {
            final tween = Tween(
              begin: const Offset(1.0, 0),
              end: Offset.zero,
            ).chain(CurveTween(curve: Curves.easeOutCubic));
            return SlideTransition(
              position: animation.drive(tween),
              child: child,
            );
          },
        );
}
