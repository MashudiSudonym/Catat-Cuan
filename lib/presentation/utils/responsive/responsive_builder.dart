import 'package:flutter/widgets.dart';

/// Responsive utilities and helper widgets
/// This file aggregates responsive functionality for easy importing

export 'app_dimensions.dart' show AppDimensions, ScreenSize, ResponsiveBuilder;
export 'app_radius.dart' show AppRadius, AppBorderRadius;
export 'app_spacing.dart' show AppSpacing, AppSpacingWidget, AppSpacingExtension;

// Note: This file has an intentional circular dependency with app_dimensions.dart
// The classes defined here are exported by app_dimensions.dart and vice versa
// This is handled by Dart's export system correctly

/// A widget that responds to screen size changes
class ScreenTypeLayout extends StatelessWidget {
  const ScreenTypeLayout({
    super.key,
    required this.mobile,
    this.tablet,
    this.desktop,
  });

  final WidgetBuilder mobile;
  final WidgetBuilder? tablet;
  final WidgetBuilder? desktop;

  static const double breakpointSM = 576.0;
  static const double breakpointMD = 768.0;

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;

    if (width >= breakpointMD && desktop != null) {
      return desktop!(context);
    }
    if (width >= breakpointSM && tablet != null) {
      return tablet!(context);
    }
    return mobile(context);
  }
}

/// A widget that shows different content based on orientation
class OrientationLayout extends StatelessWidget {
  const OrientationLayout({
    super.key,
    required this.portrait,
    required this.landscape,
  });

  final WidgetBuilder portrait;
  final WidgetBuilder landscape;

  @override
  Widget build(BuildContext context) {
    final orientation = MediaQuery.of(context).orientation;
    return orientation == Orientation.portrait
        ? portrait(context)
        : landscape(context);
  }
}

/// Value variant based on screen size
class ResponsiveValue<T> {
  const ResponsiveValue({
    required this.mobile,
    this.tablet,
    this.desktop,
  });

  final T mobile;
  final T? tablet;
  final T? desktop;

  static const double breakpointSM = 576.0;
  static const double breakpointMD = 768.0;

  T getValue(BuildContext context) {
    final width = MediaQuery.of(context).size.width;

    if (width >= breakpointMD && desktop != null) {
      return desktop!;
    }
    if (width >= breakpointSM && tablet != null) {
      return tablet!;
    }
    return mobile;
  }
}

/// Extension to get responsive value from BuildContext
extension ResponsiveContextExtension on BuildContext {
  T getResponsiveValue<T>({
    required T mobile,
    T? tablet,
    T? desktop,
  }) {
    return ResponsiveValue(
      mobile: mobile,
      tablet: tablet,
      desktop: desktop,
    ).getValue(this);
  }
}
