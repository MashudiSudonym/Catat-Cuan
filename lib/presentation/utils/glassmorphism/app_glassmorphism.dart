/// Glassmorphism design system utilities
///
/// Provides consistent blur intensity, transparency levels, and border styling
/// for frosted glass UI effects throughout the application.
///
/// All glass effects use the existing orange color scheme (#EC5B13) with
/// appropriate transparency and blur for a modern, premium look.
library;

import 'package:flutter/material.dart';
import 'dart:ui';

/// Blur intensity scale for glass effects
///
/// Higher values create more pronounced frosted glass appearance.
/// Choose the lowest blur that achieves the desired effect for performance.
class GlassBlur {
  GlassBlur._();

  /// 2px - Subtle backgrounds, minimal blur
  static const double xs = 2.0;

  /// 4px - Chips, pills, tags, small elements
  static const double sm = 4.0;

  /// 8px - Small containers, subtle cards
  static const double md = 8.0;

  /// 12px - Default cards, surfaces (most common)
  static const double lg = 12.0;

  /// 20px - Large cards, modals, dialogs
  static const double xl = 20.0;

  /// 30px - Bottom sheets, overlays, navigation bars
  static const double xxl = 30.0;

  /// Get theme-adjusted blur intensity
  /// Dark mode uses slightly more blur for better glass effect
  static double getAdjustedBlur(double blur, {bool isDark = false}) {
    return isDark ? blur * 1.1 : blur;
  }
}

/// Transparency levels (alpha) for glass effects
///
/// Higher values = more opaque, lower values = more transparent
class GlassAlpha {
  GlassAlpha._();

  /// 0.95 - Almost opaque - primary surfaces, forms
  static const double high = 0.95;

  /// 0.85 - Semi-transparent - cards, containers
  static const double medium = 0.85;

  /// 0.70 - More transparent - overlays, chips
  static const double low = 0.70;

  /// 0.50 - Very transparent - backgrounds
  static const double minimal = 0.50;

  /// Get theme-adjusted alpha for better readability
  /// Dark mode needs slightly higher opacity for contrast
  static double getAdjustedAlpha(double alpha, {bool isDark = false}) {
    if (isDark) {
      // Increase opacity slightly for dark mode
      return (alpha * 1.03).clamp(0.0, 1.0);
    }
    return alpha;
  }
}

/// Border styling for glass containers
class GlassBorder {
  GlassBorder._();

  /// Border width in pixels
  static const double width = 1.5;

  /// Border opacity for light mode
  static const double alphaLight = 0.10;

  /// Border opacity for dark mode (lower for subtlety)
  static const double alphaDark = 0.08;

  /// Get border alpha based on theme
  static double getAlpha({bool isDark = false}) {
    return isDark ? alphaDark : alphaLight;
  }
}

/// Glass container variants with predefined blur and alpha values
///
/// Each variant is optimized for specific use cases.
/// Supports both light and dark themes with adjusted values.
enum GlassVariant {
  /// Subtle backgrounds - minimal blur, minimal transparency
  subtle(blur: GlassBlur.xs, alpha: GlassAlpha.minimal),

  /// Chips, pills, tags - light blur, low transparency
  pill(blur: GlassBlur.sm, alpha: GlassAlpha.low),

  /// Cards, small containers - medium blur, medium transparency
  card(blur: GlassBlur.lg, alpha: GlassAlpha.medium),

  /// Forms, dialogs - high blur, high transparency (less transparent)
  surface(blur: GlassBlur.xl, alpha: GlassAlpha.high),

  /// Bottom sheets, overlays - maximum blur
  overlay(blur: GlassBlur.xxl, alpha: GlassAlpha.high),

  /// Navigation bars - maximum blur, medium-high transparency
  navigation(blur: GlassBlur.xxl, alpha: 0.90);

  const GlassVariant({
    required this.blur,
    required this.alpha,
  });

  /// Blur intensity for this variant
  final double blur;

  /// Transparency level for this variant
  final double alpha;

  /// Get theme-adjusted blur
  double getAdjustedBlur({bool isDark = false}) {
    return GlassBlur.getAdjustedBlur(blur, isDark: isDark);
  }

  /// Get theme-adjusted alpha
  double getAdjustedAlpha({bool isDark = false}) {
    return GlassAlpha.getAdjustedAlpha(alpha, isDark: isDark);
  }
}

/// Glass decoration utilities for creating consistent glass effects
class GlassDecoration {
  GlassDecoration._();

  /// Creates a BoxDecoration with glass effect
  ///
  /// Parameters:
  /// - [color]: The base color for the glass effect (with alpha applied)
  /// - [blur]: Blur intensity from GlassBlur
  /// - [borderRadius]: Border radius for rounded corners
  /// - [borderColor]: Optional custom border color (defaults to white with alpha)
  /// - [shadowColor]: Optional shadow color (defaults to primary orange with alpha)
  /// - [isDark]: Whether to use dark theme values
  static BoxDecoration create({
    required Color color,
    required double blur,
    BorderRadius? borderRadius,
    Color? borderColor,
    Color? shadowColor,
    bool isDark = false,
  }) {
    return BoxDecoration(
      color: color,
      borderRadius: borderRadius,
      border: Border.all(
        color: borderColor ?? Colors.white.withValues(alpha: GlassBorder.getAlpha(isDark: isDark)),
        width: GlassBorder.width,
      ),
      boxShadow: [
        BoxShadow(
          color: shadowColor ?? Colors.white.withValues(alpha: isDark ? 0.08 : 0.1),
          blurRadius: blur,
          spreadRadius: 2,
        ),
      ],
    );
  }

  /// Creates a glass card decoration
  static BoxDecoration card({
    required Color color,
    BorderRadius? borderRadius,
    Color? shadowColor,
  }) {
    return create(
      color: color,
      blur: GlassBlur.lg,
      borderRadius: borderRadius,
      shadowColor: shadowColor,
    );
  }

  /// Creates a glass surface decoration (for forms, dialogs)
  static BoxDecoration surface({
    required Color color,
    BorderRadius? borderRadius,
    Color? shadowColor,
  }) {
    return create(
      color: color,
      blur: GlassBlur.xl,
      borderRadius: borderRadius,
      shadowColor: shadowColor,
    );
  }

  /// Creates a glass pill decoration (for chips, tags)
  static BoxDecoration pill({
    required Color color,
    Color? shadowColor,
  }) {
    return create(
      color: color,
      blur: GlassBlur.sm,
      borderRadius: const BorderRadius.all(Radius.circular(999)),
      shadowColor: shadowColor,
    );
  }

  /// Creates a glass navigation decoration (for bars)
  static BoxDecoration navigation({
    required Color color,
    Color? shadowColor,
  }) {
    return create(
      color: color,
      blur: GlassBlur.xxl,
      borderRadius: BorderRadius.zero,
      shadowColor: shadowColor,
    );
  }
}

/// ImageFilter factory for glass blur effects
class GlassImageFilter {
  GlassImageFilter._();

  /// Creates an ImageFilter with the specified blur intensity
  static ImageFilter create(double blur) {
    return ImageFilter.blur(
      sigmaX: blur,
      sigmaY: blur,
    );
  }

  /// Creates a blur filter for cards
  static ImageFilter card() => create(GlassBlur.lg);

  /// Creates a blur filter for surfaces (forms, dialogs)
  static ImageFilter surface() => create(GlassBlur.xl);

  /// Creates a blur filter for pills (chips, tags)
  static ImageFilter pill() => create(GlassBlur.sm);

  /// Creates a blur filter for navigation bars
  static ImageFilter navigation() => create(GlassBlur.xxl);

  /// Creates a blur filter for overlays
  static ImageFilter overlay() => create(GlassBlur.xxl);
}

/// Extension to apply glass blur to any Widget
extension GlassBlurExtension on Widget {
  /// Wraps the widget with a BackdropFilter for glass blur effect
  Widget withGlassBlur({
    required double blur,
    BorderRadius? borderRadius,
  }) {
    return ClipRRect(
      borderRadius: borderRadius ?? BorderRadius.zero,
      child: BackdropFilter(
        filter: ImageFilter.blur(
          sigmaX: blur,
          sigmaY: blur,
        ),
        child: this,
      ),
    );
  }
}
