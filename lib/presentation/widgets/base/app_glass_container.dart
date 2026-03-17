import 'package:flutter/material.dart';

import '../../utils/glassmorphism/app_glassmorphism.dart';
import '../../utils/app_colors.dart';
import '../../utils/responsive/app_spacing.dart';
import '../../utils/responsive/app_radius.dart';

/// Glassmorphism container widget with predefined variants
///
/// Provides frosted glass effect using BackdropFilter with consistent
/// blur intensity, transparency, and border styling.
///
/// Example usage:
/// ```dart
/// // Glass card for transaction/summary cards
/// AppGlassContainer.glassCard(
///   child: Text('Content'),
/// )
///
/// // Glass surface for forms, dialogs, sheets
/// AppGlassContainer.glassSurface(
///   child: Form(...),
/// )
///
/// // Glass pill for chips, tags, category indicators
/// AppGlassContainer.glassPill(
///   child: Text('Chip'),
/// )
///
/// // Glass navigation for bars
/// AppGlassContainer.glassNavigation(
///   child: BottomNavigationBar(...),
/// )
/// ```
class AppGlassContainer extends StatelessWidget {
  const AppGlassContainer.glassCard({
    super.key,
    required this.child,
    this.padding,
    this.margin,
    BorderRadius? borderRadius,
    this.width,
    this.height,
    this.alignment,
    this.constraints,
    this.onTap,
  })  : _variant = GlassVariant.card,
        _customBorderRadius = borderRadius;

  const AppGlassContainer.glassSurface({
    super.key,
    required this.child,
    this.padding,
    this.margin,
    BorderRadius? borderRadius,
    this.width,
    this.height,
    this.alignment,
    this.constraints,
    this.onTap,
  })  : _variant = GlassVariant.surface,
        _customBorderRadius = borderRadius;

  const AppGlassContainer.glassPill({
    super.key,
    required this.child,
    this.padding,
    this.margin,
    this.width,
    this.height,
    this.alignment,
    this.constraints,
    this.onTap,
  })  : _variant = GlassVariant.pill,
        _customBorderRadius = AppRadius.circleAll;

  const AppGlassContainer.glassNavigation({
    super.key,
    required this.child,
    this.padding,
    this.margin,
    BorderRadius? borderRadius,
    this.width,
    this.height,
    this.alignment,
    this.constraints,
    this.onTap,
  })  : _variant = GlassVariant.navigation,
        _customBorderRadius = borderRadius;

  const AppGlassContainer.glassOverlay({
    super.key,
    required this.child,
    this.padding,
    this.margin,
    BorderRadius? borderRadius,
    this.width,
    this.height,
    this.alignment,
    this.constraints,
    this.onTap,
  })  : _variant = GlassVariant.overlay,
        _customBorderRadius = borderRadius;

  const AppGlassContainer.subtle({
    super.key,
    required this.child,
    this.padding,
    this.margin,
    BorderRadius? borderRadius,
    this.width,
    this.height,
    this.alignment,
    this.constraints,
    this.onTap,
  })  : _variant = GlassVariant.subtle,
        _customBorderRadius = borderRadius;

  final Widget child;
  final GlassVariant _variant;
  final EdgeInsets? padding;
  final EdgeInsets? margin;
  final BorderRadius? _customBorderRadius;
  final double? width;
  final double? height;
  final AlignmentGeometry? alignment;
  final BoxConstraints? constraints;
  final VoidCallback? onTap;

  /// Get default padding for each variant
  EdgeInsets get _defaultPadding {
    switch (_variant) {
      case GlassVariant.pill:
        return AppSpacing.symmetric(
          horizontal: AppSpacing.lg,
          vertical: AppSpacing.sm,
        );
      case GlassVariant.navigation:
        return AppSpacing.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.sm);
      case GlassVariant.subtle:
        return AppSpacing.smAll;
      default:
        return AppSpacing.lgAll;
    }
  }

  /// Get default border radius for each variant
  BorderRadius get _defaultBorderRadius {
    switch (_variant) {
      case GlassVariant.pill:
        return AppRadius.circleAll;
      case GlassVariant.surface:
        return AppRadius.lgAll;
      case GlassVariant.navigation:
      case GlassVariant.overlay:
        return AppRadius.xlAll;
      default:
        return AppRadius.mdAll;
    }
  }

  /// Get glass color for the current variant
  Color _getGlassColor(bool isDark) {
    switch (_variant) {
      case GlassVariant.pill:
        return AppColors.getGlassPill(isDark: isDark, alpha: _variant.alpha);
      case GlassVariant.surface:
        return AppColors.getGlassSurface(isDark: isDark, alpha: _variant.alpha);
      case GlassVariant.navigation:
        return AppColors.getGlassNavigation(isDark: isDark, alpha: _variant.alpha);
      case GlassVariant.overlay:
        return AppColors.getGlassOverlay(isDark: isDark, alpha: _variant.alpha);
      case GlassVariant.subtle:
        return AppColors.getGlassCard(isDark: isDark, alpha: _variant.alpha);
      default:
        return AppColors.getGlassCard(isDark: isDark, alpha: _variant.alpha);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final borderRadius = _customBorderRadius ?? _defaultBorderRadius;
    final effectivePadding = padding ?? _defaultPadding;

    // Theme-aware adjustments
    final adjustedBlur = _variant.getAdjustedBlur(isDark: isDark);
    final adjustedAlpha = _variant.getAdjustedAlpha(isDark: isDark);

    final glassContent = ClipRRect(
      borderRadius: borderRadius,
      child: BackdropFilter(
        filter: GlassImageFilter.create(adjustedBlur),
        child: Container(
          width: width,
          height: height,
          margin: margin,
          constraints: constraints,
          padding: effectivePadding,
          alignment: alignment,
          decoration: BoxDecoration(
            color: _getGlassColor(isDark).withValues(alpha: adjustedAlpha),
            borderRadius: borderRadius,
            border: Border.all(
              color: AppColors.getGlassBorder(isDark: isDark, alpha: GlassBorder.getAlpha(isDark: isDark)),
              width: GlassBorder.width,
            ),
            boxShadow: [
              // Ambient shadow (outer glow)
              BoxShadow(
                color: AppColors.getGlassAmbientShadow(isDark: isDark),
                blurRadius: adjustedBlur * 0.8,
                spreadRadius: 0,
              ),
              // Drop shadow (depth)
              BoxShadow(
                color: AppColors.getGlassShadow(isDark: isDark),
                blurRadius: adjustedBlur * 0.4,
                spreadRadius: isDark ? 0 : 1,
                offset: Offset(0, isDark ? 2 : 1),
              ),
            ],
          ),
          child: child,
        ),
      ),
    );

    if (onTap != null) {
      return Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: borderRadius,
          splashColor: AppColors.getGlassHighlight(isDark: isDark),
          highlightColor: AppColors.getGlassHighlight(isDark: isDark),
          child: glassContent,
        ),
      );
    }

    return glassContent;
  }
}

/// Glassmorphism container for navigation elements
///
/// Pre-configured for bottom navigation bars and app bars with
/// maximum blur and top/bottom border only.
class AppGlassNavigation extends StatelessWidget {
  const AppGlassNavigation({
    super.key,
    required this.child,
    this.padding,
    this.borderRadius,
    this.showTopBorder = false,
    this.showBottomBorder = true,
  });

  final Widget child;
  final EdgeInsets? padding;
  final BorderRadius? borderRadius;
  final bool showTopBorder;
  final bool showBottomBorder;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final adjustedBlur = GlassVariant.navigation.getAdjustedBlur(isDark: isDark);
    final adjustedAlpha = GlassVariant.navigation.getAdjustedAlpha(isDark: isDark);
    final borderAlpha = GlassBorder.getAlpha(isDark: isDark);

    return ClipRRect(
      borderRadius: borderRadius ?? BorderRadius.zero,
      child: BackdropFilter(
        filter: GlassImageFilter.create(adjustedBlur),
        child: Container(
          padding: padding ?? AppSpacing.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.sm),
          decoration: BoxDecoration(
            color: AppColors.getGlassNavigation(isDark: isDark, alpha: adjustedAlpha),
            border: Border(
              top: showTopBorder
                  ? BorderSide(
                      color: AppColors.getGlassBorder(isDark: isDark, alpha: borderAlpha),
                      width: GlassBorder.width,
                    )
                  : BorderSide.none,
              bottom: showBottomBorder
                  ? BorderSide(
                      color: AppColors.getGlassBorder(isDark: isDark, alpha: borderAlpha),
                      width: GlassBorder.width,
                    )
                  : BorderSide.none,
            ),
            boxShadow: [
              BoxShadow(
                color: AppColors.getGlassAmbientShadow(isDark: isDark),
                blurRadius: adjustedBlur * 0.5,
                spreadRadius: 0,
              ),
            ],
          ),
          child: child,
        ),
      ),
    );
  }
}

/// Floating action button with glassmorphism effect
class AppGlassFab extends StatelessWidget {
  const AppGlassFab({
    super.key,
    required this.onPressed,
    required this.child,
    this.heroTag,
    this.elevation,
    this.backgroundColor,
  });

  final VoidCallback? onPressed;
  final Widget child;
  final Object? heroTag;
  final double? elevation;
  final Color? backgroundColor;

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton(
      heroTag: heroTag,
      onPressed: onPressed,
      elevation: elevation ?? 4,
      backgroundColor: backgroundColor ?? AppColors.primary,
      child: child,
    );
  }
}
