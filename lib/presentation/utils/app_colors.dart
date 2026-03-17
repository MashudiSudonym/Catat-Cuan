import 'package:flutter/material.dart';

/// App color scheme berdasarkan UI reference design
/// Primary color: #ec5b13 (orange)
class AppColors {
  // Primary colors
  static const Color primary = Color(0xFFEC5B13);
  static const Color primaryLight = Color(0xFFFF8A5D);
  static const Color primaryDark = Color(0xFFB8420D);

  // Background colors
  static const Color backgroundLight = Color(0xFFF8F6F6);
  static const Color backgroundDark = Color(0xFF221610);
  static const Color surfaceLight = Color(0xFFFFFFFF);
  static const Color surfaceDark = Color(0xFF1A1210);

  // Transaction type colors
  static const Color income = Color(0xFF10B981); // Green
  static const Color expense = Color(0xFFEF4444); // Red
  static const Color incomeLight = Color(0xFFD1FAE5);
  static const Color expenseLight = Color(0xFFFEE2E2);

  // Text colors
  static const Color textPrimary = Color(0xFF1E293B);
  static const Color textSecondary = Color(0xFF64748B);
  static const Color textTertiary = Color(0xFF94A3B8);
  static const Color textOnDark = Color(0xFFF8F6F6);

  // Status colors
  static const Color success = Color(0xFF10B981);
  static const Color warning = Color(0xFFF59E0B);
  static const Color error = Color(0xFFEF4444);
  static const Color info = Color(0xFF3B82F6);

  // Category colors (preset untuk kategori default)
  static const List<Color> categoryColors = [
    Color(0xFFEC5B13), // Orange - Food
    Color(0xFF3B82F6), // Blue - Transport
    Color(0xFF10B981), // Green - Shopping
    Color(0xFFF59E0B), // Yellow - Bills
    Color(0xFF8B5CF6), // Purple - Entertainment
    Color(0xFFEF4444), // Red - Health
    Color(0xFF06B6D4), // Cyan - Home
    Color(0xFF64748B), // Gray - Other
    // Additional colors for category picker
    Color(0xFF4CAF50), // Green
    Color(0xFF8BC34A), // Light Green
    Color(0xFFCDDC39), // Lime
    Color(0xFFFFEB3B), // Yellow
    Color(0xFFFFC107), // Amber
    Color(0xFFFF9800), // Orange
    Color(0xFFFF5722), // Deep Orange
    Color(0xFFF44336), // Red
    Color(0xFFE91E63), // Pink
    Color(0xFF9C27B0), // Purple
    Color(0xFF673AB7), // Deep Purple
    Color(0xFF3F51B5), // Indigo
    Color(0xFF2196F3), // Blue
    Color(0xFF03A9F4), // Light Blue
    Color(0xFF00BCD4), // Cyan
    Color(0xFF009688), // Teal
    Color(0xFF607D8B), // Blue Gray
    Color(0xFF795548), // Brown
    Color(0xFF9E9E9E), // Gray
  ];

  /// Get income color based on theme
  static Color getIncomeColor(bool isDark) {
    return isDark ? const Color(0xFF34D399) : income;
  }

  /// Get expense color based on theme
  static Color getExpenseColor(bool isDark) {
    return isDark ? const Color(0xFFF87171) : expense;
  }

  /// Get background color based on theme
  static Color getBackgroundColor(bool isDark) {
    return isDark ? backgroundDark : backgroundLight;
  }

  /// Get surface color based on theme
  static Color getSurfaceColor(bool isDark) {
    return isDark ? surfaceDark : surfaceLight;
  }

  /// Get category color by index
  static Color getCategoryColor(int index) {
    return categoryColors[index % categoryColors.length];
  }

  // ========== Glassmorphism Colors ==========

  /// Get glass surface color with specified alpha
  ///
  /// Used for forms, dialogs, and primary surfaces
  /// Dark mode uses slightly higher alpha for better readability
  static Color getGlassSurface({bool isDark = false, double? alpha}) {
    final effectiveAlpha = alpha ?? (isDark ? 0.92 : 0.95);
    final baseColor = isDark ? surfaceDark : surfaceLight;
    return baseColor.withValues(alpha: effectiveAlpha);
  }

  /// Get glass card color with specified alpha
  ///
  /// Used for transaction cards, summary cards, and general containers
  /// Dark mode uses slightly higher alpha for better contrast
  static Color getGlassCard({bool isDark = false, double? alpha}) {
    final effectiveAlpha = alpha ?? (isDark ? 0.82 : 0.85);
    final baseColor = isDark ? surfaceDark : surfaceLight;
    return baseColor.withValues(alpha: effectiveAlpha);
  }

  /// Get glass pill color with specified alpha
  ///
  /// Used for chips, tags, and category indicators
  static Color getGlassPill({bool isDark = false, double? alpha}) {
    final effectiveAlpha = alpha ?? (isDark ? 0.65 : 0.70);
    final baseColor = isDark ? surfaceDark : surfaceLight;
    return baseColor.withValues(alpha: effectiveAlpha);
  }

  /// Get glass navigation color with specified alpha
  ///
  /// Used for bottom navigation bar and app bar
  static Color getGlassNavigation({bool isDark = false, double? alpha}) {
    final effectiveAlpha = alpha ?? (isDark ? 0.88 : 0.90);
    final baseColor = isDark ? surfaceDark : surfaceLight;
    return baseColor.withValues(alpha: effectiveAlpha);
  }

  /// Get glass overlay color with specified alpha
  ///
  /// Used for bottom sheets, modals, and overlays
  static Color getGlassOverlay({bool isDark = false, double? alpha}) {
    final effectiveAlpha = alpha ?? (isDark ? 0.88 : 0.90);
    final baseColor = isDark ? backgroundDark : backgroundLight;
    return baseColor.withValues(alpha: effectiveAlpha);
  }

  /// Get glass border color
  ///
  /// Used for glass container borders
  /// Returns subtle border with appropriate opacity for theme
  static Color getGlassBorder({bool isDark = false, double? alpha}) {
    final effectiveAlpha = alpha ?? (isDark ? 0.08 : 0.10);
    if (isDark) {
      return Colors.white.withValues(alpha: effectiveAlpha);
    }
    return Colors.black.withValues(alpha: effectiveAlpha);
  }

  /// Get glass shadow color
  ///
  /// Used for glass container shadows
  /// Dark mode uses lighter shadow for better depth perception
  static Color getGlassShadow({bool isDark = false, double? alpha}) {
    final effectiveAlpha = alpha ?? (isDark ? 0.15 : 0.08);
    if (isDark) {
      // Dark mode: use lighter shadow for better contrast
      return const Color(0xFF000000).withValues(alpha: effectiveAlpha);
    }
    // Light mode: orange-tinted shadow for brand consistency
    return primary.withValues(alpha: effectiveAlpha);
  }

  /// Get glass ambient shadow (outer glow effect)
  ///
  /// Used for creating depth with ambient light effect
  static Color getGlassAmbientShadow({bool isDark = false}) {
    if (isDark) {
      return const Color(0xFF000000).withValues(alpha: 0.25);
    }
    return const Color(0xFFEC5B13).withValues(alpha: 0.06); // Subtle orange tint
  }

  /// Get glass primary color with specified alpha
  ///
  /// Used for primary-colored glass elements (buttons, highlights)
  static Color getGlassPrimary({double alpha = 0.85}) {
    return primary.withValues(alpha: alpha);
  }

  /// Get glass highlight color for hover/focus states
  ///
  /// Used for interactive elements in glass containers
  static Color getGlassHighlight({bool isDark = false}) {
    if (isDark) {
      return Colors.white.withValues(alpha: 0.08);
    }
    return Colors.white.withValues(alpha: 0.30);
  }

  /// Get glass text color based on theme and background
  ///
  /// Returns appropriate text color for glass surfaces
  static Color getGlassTextColor({bool isDark = false, bool isSecondary = false}) {
    if (isDark) {
      return isSecondary ? textTertiary.withValues(alpha: 0.8) : textOnDark;
    }
    return isSecondary ? textSecondary : textPrimary;
  }
}
