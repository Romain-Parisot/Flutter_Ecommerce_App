import 'package:flutter/material.dart';

import 'primary_nav_bar.dart';

class PageWithNavOverlay extends StatelessWidget {
  const PageWithNavOverlay({super.key, required this.child});

  /// Optional override mainly intended for widget tests to replace the default
  /// navigation chrome with a lighter scaffold.
  static Widget Function(BuildContext context, Widget child)? testOverride;

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final override = testOverride;
    if (override != null) {
      return override(context, child);
    }
    return Column(
      children: [
        Expanded(child: child),
        const PrimaryNavBar(),
      ],
    );
  }
}
