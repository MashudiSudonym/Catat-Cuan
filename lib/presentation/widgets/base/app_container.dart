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

/// Shimmer loading container for skeleton screens
class AppShimmer extends StatefulWidget {
  const AppShimmer({
    super.key,
    required this.child,
    this.baseColor,
    this.highlightColor,
  });

  final Widget child;
  final Color? baseColor;
  final Color? highlightColor;

  @override
  State<AppShimmer> createState() => _AppShimmerState();
}

class _AppShimmerState extends State<AppShimmer>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat();

    _animation = Tween<double>(begin: -2, end: 2).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOutSine),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return ShaderMask(
          blendMode: BlendMode.srcATop,
          shaderCallback: (bounds) {
            return LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.centerRight,
              colors: [
                widget.baseColor ??
                    (isDark ? Colors.grey.shade800 : Colors.grey.shade200),
                widget.highlightColor ??
                    (isDark ? Colors.grey.shade700 : Colors.grey.shade300),
                widget.baseColor ??
                    (isDark ? Colors.grey.shade800 : Colors.grey.shade200),
              ],
              stops: const [0.0, 0.5, 1.0],
              transform: _SlidingGradientTransform(
                slidePercent: _animation.value,
              ),
            ).createShader(bounds);
          },
          child: widget.child,
        );
      },
    );
  }
}

class _SlidingGradientTransform extends GradientTransform {
  const _SlidingGradientTransform({required this.slidePercent});

  final double slidePercent;

  @override
  Matrix4? transform(Rect bounds, {TextDirection? textDirection}) {
    return Matrix4.translationValues(bounds.width * slidePercent, 0.0, 0.0);
  }
}

/// Shimmer box for skeleton loading
class AppShimmerBox extends StatelessWidget {
  const AppShimmerBox({
    super.key,
    this.width,
    this.height,
    this.borderRadius,
  });

  final double? width;
  final double? height;
  final BorderRadius? borderRadius;

  @override
  Widget build(BuildContext context) {
    return AppShimmer(
      child: Container(
        width: width,
        height: height ?? 16,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: borderRadius ?? AppRadius.smAll,
        ),
      ),
    );
  }
}
