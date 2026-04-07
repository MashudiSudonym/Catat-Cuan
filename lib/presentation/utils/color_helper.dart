import 'package:flutter/material.dart';

/// Helper for color conversion
class ColorHelper {
  /// Convert Color to hex string
  static String colorToHex(Color color) {
    final red = (color.r * 255).round().toRadixString(16).padLeft(2, '0');
    final green = (color.g * 255).round().toRadixString(16).padLeft(2, '0');
    final blue = (color.b * 255).round().toRadixString(16).padLeft(2, '0');
    return '#$red$green$blue'.toUpperCase();
  }

  /// Convert hex string to Color
  static Color hexToColor(String hex) {
    // Remove # if present
    final hexCode = hex.replaceAll('#', '');

    // Add 0xFF prefix if not present
    final prefixedHex = hexCode.length == 6
        ? '0xFF$hexCode'
        : hexCode.startsWith('0xFF') || hexCode.startsWith('0xff')
            ? hexCode
            : '0xFF$hexCode';

    return Color(int.parse(prefixedHex));
  }

  /// Get color from hex string with fallback
  static Color hexToColorWithFallback(String hex, {Color fallback = Colors.grey}) {
    try {
      return hexToColor(hex);
    } catch (e) {
      return fallback;
    }
  }

  /// Check if string is valid hex color
  static bool isValidHex(String hex) {
    try {
      hexToColor(hex);
      return true;
    } catch (e) {
      return false;
    }
  }

  /// Darken color by percentage (0.0 - 1.0)
  static Color darkenColor(Color color, double percentage) {
    assert(percentage >= 0 && percentage <= 1);

    final hsl = HSLColor.fromColor(color);
    return hsl.withLightness((hsl.lightness * (1 - percentage)).clamp(0.0, 1.0))
        .toColor();
  }

  /// Lighten color by percentage (0.0 - 1.0)
  static Color lightenColor(Color color, double percentage) {
    assert(percentage >= 0 && percentage <= 1);

    final hsl = HSLColor.fromColor(color);
    return hsl.withLightness((hsl.lightness + (1 - hsl.lightness) * percentage).clamp(0.0, 1.0))
        .toColor();
  }

  /// Get contrast color (black or white) based on background color
  static Color getContrastColor(Color color) {
    // Calculate luminance using the newer API
    final luminance = (0.299 * color.r + 0.587 * color.g + 0.114 * color.b);

    // Return black for bright colors, white for dark colors
    return luminance > 0.5 ? Colors.black : Colors.white;
  }

  /// Get text color that is readable on background color
  static Color getTextColor(Color backgroundColor) {
    return getContrastColor(backgroundColor);
  }

  /// Parse color from various formats
  static Color? parseColor(dynamic color) {
    if (color == null) return null;

    if (color is Color) {
      return color;
    }

    if (color is String) {
      return hexToColorWithFallback(color);
    }

    if (color is int) {
      return Color(color);
    }

    return null;
  }
}

/// Extension for Color class
extension ColorExtension on Color {
  /// Convert Color to hex string
  String toHex() {
    return ColorHelper.colorToHex(this);
  }

  /// Darken color
  Color darken(double percentage) {
    return ColorHelper.darkenColor(this, percentage);
  }

  /// Lighten color
  Color lighten(double percentage) {
    return ColorHelper.lightenColor(this, percentage);
  }

  /// Get contrast color
  Color get contrastColor {
    return ColorHelper.getContrastColor(this);
  }

  /// Check if color is light color
  bool get isLight {
    final luminance = (0.299 * r + 0.587 * g + 0.114 * b);
    return luminance > 0.5;
  }

  /// Check if color is dark color
  bool get isDark => !isLight;
}
