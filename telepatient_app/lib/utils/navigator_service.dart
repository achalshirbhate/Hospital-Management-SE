import 'package:flutter/material.dart';

/// Holds a global NavigatorKey so non-widget code (e.g. Dio interceptors)
/// can push routes without needing a BuildContext.
class NavigatorService {
  static final GlobalKey<NavigatorState> navigatorKey =
      GlobalKey<NavigatorState>();

  static NavigatorState get navigator => navigatorKey.currentState!;

  /// Push a named route, clearing the entire back stack.
  static void pushAndRemoveAll(Widget page) {
    navigator.pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => page),
      (_) => false,
    );
  }
}
