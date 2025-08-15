import 'package:flutter/material.dart';

/// and provides helper methods to check current device screen size category.
class ResponsiveBreakpoints {
  // Screen width thresholds in logical pixels:
  static const double mobile = 600;
  static const double tablet = 1200;

  /// Checks if the current device width is considered a mobile device.
  static bool isMobile(BuildContext context) =>
      MediaQuery.sizeOf(context).width < mobile;

  /// Checks if the current device width is considered a tablet.
  static bool isTablet(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    return width >= mobile && width < tablet;
  }

  /// Checks if the device width is considered a desktop (large screen).
  static bool isDesktop(BuildContext context) =>
      MediaQuery.sizeOf(context).width >= tablet;

  /// Returns the number of columns to display for recipe/grid layouts based on device width.
  /// You can customize these defaults when calling by passing different counts.
  static int getColumns(
    BuildContext context, {
    int mobileColumns = 1,
    int tabletColumns = 2,
    int desktopColumns = 3,
  }) {
    final width = MediaQuery.sizeOf(context).width;

    if (width < mobile) return mobileColumns;
    if (width < tablet) return tabletColumns;
    return desktopColumns;
  }
}
