import 'package:flutter/material.dart';

import 'responsive_breakpoints.dart';

class ResponsiveLayout extends StatelessWidget {
  const ResponsiveLayout({
    super.key,
    required this.mobile,
    this.tablet,
    required this.desktop,
  });

  final Widget mobile;
  final Widget? tablet;
  final Widget desktop;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final screenWidth = MediaQuery.sizeOf(context).width;
        final width = constraints.maxWidth.isFinite
            ? constraints.maxWidth
            : screenWidth;
        if (width < ResponsiveBreakpoints.mobileMaxWidth) return mobile;
        if (width <= ResponsiveBreakpoints.tabletMaxWidth) {
          return tablet ?? mobile;
        }
        return desktop;
      },
    );
  }
}
