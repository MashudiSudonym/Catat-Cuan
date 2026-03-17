import 'package:flutter/material.dart';

/// Responsive dimension constants and utilities
/// Provides consistent sizing across different screen sizes
class AppDimensions {
  AppDimensions._();

  // Standard heights
  static const double minHeightTouchTarget = 48.0;
  static const double iconButtonSize = 48.0;
  static const double buttonHeight = 48.0;
  static const double inputHeight = 56.0;
  static const double chipHeight = 32.0;
  static const double appBarHeight = 56.0;
  static const double bottomNavHeight = 80.0;

  // Icon sizes
  static const double iconXS = 16.0;
  static const double iconSM = 20.0;
  static const double iconMD = 24.0;
  static const double iconLG = 32.0;
  static const double iconXL = 48.0;

  // Avatar sizes
  static const double avatarSM = 32.0;
  static const double avatarMD = 48.0;
  static const double avatarLG = 64.0;
  static const double avatarXL = 96.0;

  // Card and container sizes
  static const double cardElevation = 0.0;
  static const double dialogElevation = 24.0;
  static const double menuElevation = 8.0;

  // Border width
  static const double borderWidthThin = 1.0;
  static const double borderWidthMedium = 2.0;
  static const double borderWidthThick = 3.0;

  // Divider thickness
  static const double dividerThickness = 1.0;

  // Screen width breakpoints
  static const double breakpointSM = 576.0;   // Small screens
  static const double breakpointMD = 768.0;   // Medium screens (tablets)
  static const double breakpointLG = 992.0;   // Large screens
  static const double breakpointXL = 1200.0;  // Extra large screens

  // Maximum content widths
  static const double maxWidthSM = 544.0;
  static const double maxWidthMD = 720.0;
  static const double maxWidthLG = 960.0;
  static const double maxWidthXL = 1140.0;

  // Grid
  static const int gridColumns = 12;
  static const double gridGutter = 16.0;
  static const double gridMargin = 16.0;
}

/// Screen size utilities
class ScreenSize {
  ScreenSize._();

  /// Check if screen is small (mobile)
  static bool isSmall(BuildContext context) {
    return MediaQuery.of(context).size.width < AppDimensions.breakpointSM;
  }

  /// Check if screen is medium (tablet portrait)
  static bool isMedium(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    return width >= AppDimensions.breakpointSM && width < AppDimensions.breakpointMD;
  }

  /// Check if screen is large (tablet landscape, small desktop)
  static bool isLarge(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    return width >= AppDimensions.breakpointMD && width < AppDimensions.breakpointXL;
  }

  /// Check if screen is extra large (desktop)
  static bool isExtraLarge(BuildContext context) {
    return MediaQuery.of(context).size.width >= AppDimensions.breakpointXL;
  }

  /// Check if screen is mobile (small or medium)
  static bool isMobile(BuildContext context) {
    return MediaQuery.of(context).size.width < AppDimensions.breakpointMD;
  }

  /// Check if screen is desktop (large or extra large)
  static bool isDesktop(BuildContext context) {
    return MediaQuery.of(context).size.width >= AppDimensions.breakpointMD;
  }

  /// Get responsive value based on screen size
  static T getValue<T>({
    required BuildContext context,
    required T small,
    T? medium,
    T? large,
    T? extraLarge,
  }) {
    if (isExtraLarge(context) && extraLarge != null) return extraLarge;
    if (isLarge(context) && large != null) return large;
    if (isMedium(context) && medium != null) return medium;
    return small;
  }

  /// Get screen width
  static double width(BuildContext context) {
    return MediaQuery.of(context).size.width;
  }

  /// Get screen height
  static double height(BuildContext context) {
    return MediaQuery.of(context).size.height;
  }

  /// Get padding for safe area
  static EdgeInsets padding(BuildContext context) {
    return MediaQuery.of(context).padding;
  }

  /// Check if device is in landscape mode
  static bool isLandscape(BuildContext context) {
    return MediaQuery.of(context).orientation == Orientation.landscape;
  }

  /// Check if device is in portrait mode
  static bool isPortrait(BuildContext context) {
    return MediaQuery.of(context).orientation == Orientation.portrait;
  }
}

/// Responsive builder widget
class ResponsiveBuilder extends StatelessWidget {
  const ResponsiveBuilder({
    super.key,
    required this.builder,
    this.small,
    this.medium,
    this.large,
    this.extraLarge,
  });

  final Widget Function(BuildContext, BoxConstraints) builder;
  final Widget Function(BuildContext, BoxConstraints)? small;
  final Widget Function(BuildContext, BoxConstraints)? medium;
  final Widget Function(BuildContext, BoxConstraints)? large;
  final Widget Function(BuildContext, BoxConstraints)? extraLarge;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (extraLarge != null &&
            constraints.maxWidth >= AppDimensions.breakpointXL) {
          return extraLarge!(context, constraints);
        }
        if (large != null &&
            constraints.maxWidth >= AppDimensions.breakpointMD) {
          return large!(context, constraints);
        }
        if (medium != null &&
            constraints.maxWidth >= AppDimensions.breakpointSM) {
          return medium!(context, constraints);
        }
        if (small != null) return small!(context, constraints);
        return builder(context, constraints);
      },
    );
  }
}
