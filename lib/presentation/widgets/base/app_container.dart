import 'package:flutter/material.dart';
import '../../utils/responsive/app_spacing.dart';
import '../../utils/responsive/app_radius.dart';
import '../../utils/app_colors.dart';

/// Consistent container widget with preset styles
class AppContainer extends StatelessWidget {
  const AppContainer({
    super.key,
    required this.child,
    this.padding,
    this.margin,
    this.color,
    this.borderRadius,
    this.border,
    this.shadow,
    this.width,
    this.height,
    this.constraints,
    this.alignment,
    this.onTap,
  });

  final Widget child;
  final EdgeInsets? padding;
  final EdgeInsets? margin;
  final Color? color;
  final BorderRadius? borderRadius;
  final BoxBorder? border;
  final List<BoxShadow>? shadow;
  final double? width;
  final double? height;
  final BoxConstraints? constraints;
  final AlignmentGeometry? alignment;
  final VoidCallback? onTap;

  /// Card style container
  factory AppContainer.card({
    Key? key,
    required Widget child,
    EdgeInsets? padding,
    Color? color,
    VoidCallback? onTap,
  }) {
    return AppContainer(
      key: key,
      padding: padding ?? AppSpacing.lgAll,
      color: color,
      borderRadius: AppRadius.mdAll,
      onTap: onTap,
      child: child,
    );
  }

  /// Bordered container
  factory AppContainer.bordered({
    Key? key,
    required Widget child,
    EdgeInsets? padding,
    Color? color,
    Color? borderColor,
    VoidCallback? onTap,
  }) {
    return AppContainer(
      key: key,
      padding: padding ?? AppSpacing.lgAll,
      color: color,
      borderRadius: AppRadius.mdAll,
      border: Border.all(
        color: borderColor ?? Colors.grey.shade300,
        width: 1,
      ),
      onTap: onTap,
      child: child,
    );
  }

  /// Rounded container (large border radius)
  factory AppContainer.rounded({
    Key? key,
    required Widget child,
    EdgeInsets? padding,
    Color? color,
    VoidCallback? onTap,
  }) {
    return AppContainer(
      key: key,
      padding: padding ?? AppSpacing.lgAll,
      color: color,
      borderRadius: AppRadius.lgAll,
      onTap: onTap,
      child: child,
    );
  }

  /// Pill-shaped container (fully rounded)
  factory AppContainer.pill({
    Key? key,
    required Widget child,
    EdgeInsets? padding,
    Color? color,
    VoidCallback? onTap,
  }) {
    return AppContainer(
      key: key,
      padding: padding ?? AppSpacing.symmetric(horizontal: AppSpacing.lg, vertical: AppSpacing.sm),
      color: color,
      borderRadius: AppRadius.circleAll,
      onTap: onTap,
      child: child,
    );
  }

  @override
  Widget build(BuildContext context) {
    final container = Container(
      width: width,
      height: height,
      constraints: constraints,
      margin: margin,
      padding: padding,
      decoration: BoxDecoration(
        color: color ?? AppColors.surfaceLight,
        borderRadius: borderRadius,
        border: border,
        boxShadow: shadow,
      ),
      alignment: alignment,
      child: child,
    );

    if (onTap != null) {
      return InkWell(
        onTap: onTap,
        borderRadius: borderRadius,
        child: container,
      );
    }

    return container;
  }
}
