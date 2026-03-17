import 'package:flutter/material.dart';
import '../../utils/app_colors.dart';
import '../../utils/glassmorphism/app_glassmorphism.dart';
import '../../utils/responsive/app_spacing.dart';

/// Seamless Glassmorphism FAB that integrates with bottom navigation
///
/// Creates a floating action button with enhanced visual effects:
/// - Glassmorphism backdrop blur
/// - Gradient overlay for depth
/// - Animated shadows
/// - Extended size option
/// - Seamless notch integration
class SeamlessGlassFab extends StatefulWidget {
  const SeamlessGlassFab({
    super.key,
    required this.onPressed,
    this.icon,
    this.child,
    this.tooltip,
    this.size = SeamlessFabSize.medium,
    this.extended = false,
    this.label,
    this.elevation,
    this.hoverElevation,
    this.focusElevation,
    this.highlightElevation,
    this.disabledElevation,
    this.foregroundColor,
    this.backgroundColor,
    this.focusColor,
    this.hoverColor,
    this.splashColor,
    this.heroTag,
    this.mouseCursor,
    this.autofocus = false,
    this.materialTapTargetSize,
    this.shape,
    this.clipBehavior = Clip.none,
    this.isExtended = false,
    this.enableFeedback = true,
  });

  final VoidCallback? onPressed;
  final IconData? icon;
  final Widget? child;
  final String? tooltip;
  final SeamlessFabSize size;
  final bool extended;
  final String? label;
  final double? elevation;
  final double? hoverElevation;
  final double? focusElevation;
  final double? highlightElevation;
  final double? disabledElevation;
  final Color? foregroundColor;
  final Color? backgroundColor;
  final Color? focusColor;
  final Color? hoverColor;
  final Color? splashColor;
  final Object? heroTag;
  final MouseCursor? mouseCursor;
  final bool autofocus;
  final MaterialTapTargetSize? materialTapTargetSize;
  final OutlinedBorder? shape;
  final Clip clipBehavior;
  final bool isExtended;
  final bool enableFeedback;

  @override
  State<SeamlessGlassFab> createState() => _SeamlessGlassFabState();
}

class _SeamlessGlassFabState extends State<SeamlessGlassFab>
    with SingleTickerProviderStateMixin {
  late AnimationController _scaleController;
  late Animation<double> _scaleAnimation;
  bool _isPressed = false;

  @override
  void initState() {
    super.initState();
    _scaleController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 150),
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.95).animate(
      CurvedAnimation(
        parent: _scaleController,
        curve: Curves.easeInOut,
      ),
    );
  }

  @override
  void dispose() {
    _scaleController.dispose();
    super.dispose();
  }

  void _handleTapDown(TapDownDetails details) {
    if (widget.onPressed != null) {
      setState(() => _isPressed = true);
      _scaleController.forward();
    }
  }

  void _handleTapUp(TapUpDetails details) {
    if (widget.onPressed != null) {
      setState(() => _isPressed = false);
      _scaleController.reverse();
    }
  }

  void _handleTapCancel() {
    if (widget.onPressed != null) {
      setState(() => _isPressed = false);
      _scaleController.reverse();
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final effectiveSize = widget.extended || widget.isExtended
        ? widget.size.extendedValue
        : widget.size.value;

    final effectiveForegroundColor =
        widget.foregroundColor ?? (isDark ? Colors.white : Colors.white);
    final effectiveBackgroundColor =
        widget.backgroundColor ?? AppColors.primary;

    return MouseRegion(
      cursor: widget.mouseCursor ??
          (widget.onPressed != null
              ? SystemMouseCursors.click
              : SystemMouseCursors.forbidden),
      child: GestureDetector(
        onTapDown: _handleTapDown,
        onTapUp: _handleTapUp,
        onTapCancel: _handleTapCancel,
        onTap: widget.onPressed,
        child: Tooltip(
          message: widget.tooltip ?? '',
          excludeFromSemantics: true,
          child: ScaleTransition(
            scale: _scaleAnimation,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              curve: Curves.easeInOut,
              width: effectiveSize,
              height: widget.extended || widget.isExtended ? null : effectiveSize,
              decoration: BoxDecoration(
                gradient: _isPressed
                    ? LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          effectiveBackgroundColor.withValues(alpha: 0.9),
                          effectiveBackgroundColor.withValues(alpha: 0.8),
                        ],
                      )
                    : LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          effectiveBackgroundColor,
                          effectiveBackgroundColor.withValues(alpha: 0.85),
                        ],
                      ),
                borderRadius: BorderRadius.circular(effectiveSize / 2),
                boxShadow: [
                  // Outer glow
                  BoxShadow(
                    color: effectiveBackgroundColor.withValues(alpha: 0.3),
                    blurRadius: _isPressed ? 16 : 24,
                    spreadRadius: _isPressed ? 0 : 2,
                    offset: const Offset(0, 4),
                  ),
                  // Drop shadow
                  BoxShadow(
                    color: Colors.black.withValues(alpha: isDark ? 0.3 : 0.15),
                    blurRadius: _isPressed ? 8 : 16,
                    spreadRadius: _isPressed ? -1 : 0,
                    offset: Offset(0, _isPressed ? 2 : 4),
                  ),
                  // Inner glow (highlight)
                  BoxShadow(
                    color: Colors.white.withValues(alpha: 0.2),
                    blurRadius: 8,
                    spreadRadius: -2,
                    offset: const Offset(-2, -2),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(effectiveSize / 2),
                child: BackdropFilter(
                  filter: GlassImageFilter.create(GlassBlur.md),
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: widget.onPressed,
                      focusColor: widget.focusColor,
                      hoverColor: widget.hoverColor,
                      splashColor: widget.splashColor ??
                          Colors.white.withValues(alpha: 0.3),
                      autofocus: widget.autofocus,
                      enableFeedback: widget.enableFeedback,
                      borderRadius: BorderRadius.circular(effectiveSize / 2),
                      child: Padding(
                        padding: AppSpacing.all(AppSpacing.md),
                        child: _buildContent(effectiveForegroundColor),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildContent(Color foregroundColor) {
    if (widget.child != null) {
      return widget.child!;
    }

    if (widget.extended || widget.isExtended) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (widget.icon != null)
            Icon(
              widget.icon,
              color: foregroundColor,
              size: widget.size.iconSize,
            ),
          if (widget.label != null) ...[
            const SizedBox(width: AppSpacing.sm),
            Text(
              widget.label!,
              style: TextStyle(
                color: foregroundColor,
                fontSize: widget.size.fontSize,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ],
      );
    }

    return Icon(
      widget.icon ?? Icons.add,
      color: foregroundColor,
      size: widget.size.iconSize,
    );
  }
}

/// Size options for SeamlessGlassFab
class SeamlessFabSize {
  const SeamlessFabSize({
    required this.value,
    required this.extendedValue,
    required this.iconSize,
    required this.fontSize,
  });

  final double value;
  final double extendedValue;
  final double iconSize;
  final double fontSize;

  static const small = SeamlessFabSize(
    value: 40.0,
    extendedValue: 48.0,
    iconSize: 20.0,
    fontSize: 14.0,
  );

  static const medium = SeamlessFabSize(
    value: 56.0,
    extendedValue: 64.0,
    iconSize: 24.0,
    fontSize: 16.0,
  );

  static const large = SeamlessFabSize(
    value: 64.0,
    extendedValue: 72.0,
    iconSize: 28.0,
    fontSize: 18.0,
  );

  static const extraLarge = SeamlessFabSize(
    value: 72.0,
    extendedValue: 80.0,
    iconSize: 32.0,
    fontSize: 20.0,
  );
}

/// Glassmorphism FAB with notch-aware positioning
///
/// Use this variant when the FAB needs to be positioned in a notch
/// within the bottom navigation bar for seamless integration.
class SeamlessNotchedFab extends StatelessWidget {
  const SeamlessNotchedFab({
    super.key,
    required this.onPressed,
    this.icon,
    this.child,
    this.tooltip,
    this.size = SeamlessFabSize.medium,
    this.notchMargin = 8.0,
    this.elevation,
    this.shape,
  });

  final VoidCallback? onPressed;
  final IconData? icon;
  final Widget? child;
  final String? tooltip;
  final SeamlessFabSize size;
  final double notchMargin;
  final double? elevation;
  final ShapeBorder? shape;

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton(
      onPressed: onPressed,
      tooltip: tooltip,
      elevation: elevation ?? 8,
      shape: shape ??
          RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(size.value / 2),
          ),
      child: child ??
          Icon(
            icon ?? Icons.add,
            size: size.iconSize,
          ),
    );
  }
}

/// Bottom navigation with seamless FAB notch integration
///
/// Wraps BottomNavigationBar with glassmorphism effect and
/// automatic notch creation for the center FAB.
class SeamlessGlassNavWithFab extends StatelessWidget {
  const SeamlessGlassNavWithFab({
    super.key,
    required this.items,
    required this.onTap,
    required this.currentIndex,
    this.fab,
    this.fabLocation,
    this.fabSize = 56.0,
    this.notchMargin = 8.0,
    this.showTopBorder = true,
    this.borderRadius,
  });

  final List<BottomNavigationBarItem> items;
  final int currentIndex;
  final ValueChanged<int> onTap;
  final Widget? fab;
  final FloatingActionButtonLocation? fabLocation;
  final double fabSize;
  final double notchMargin;
  final bool showTopBorder;
  final BorderRadius? borderRadius;

  @override
  Widget build(BuildContext context) {
    final hasCenterFab = fab != null &&
        (fabLocation == FloatingActionButtonLocation.centerDocked ||
            fabLocation == FloatingActionButtonLocation.centerFloat);

    return ClipRRect(
      borderRadius: borderRadius ?? BorderRadius.zero,
      child: BackdropFilter(
        filter: GlassImageFilter.create(GlassBlur.xxl),
        child: Container(
          decoration: BoxDecoration(
            color: AppColors.getGlassNavigation(
              isDark: Theme.of(context).brightness == Brightness.dark,
              alpha: 0.90,
            ),
            border: Border(
              top: showTopBorder
                  ? BorderSide(
                      color: AppColors.getGlassBorder(
                        isDark: Theme.of(context).brightness == Brightness.dark,
                      ),
                      width: GlassBorder.width,
                    )
                  : BorderSide.none,
            ),
            boxShadow: [
              BoxShadow(
                color: AppColors.getGlassAmbientShadow(
                  isDark: Theme.of(context).brightness == Brightness.dark,
                ),
                blurRadius: 20,
                spreadRadius: 0,
              ),
            ],
          ),
          child: hasCenterFab
              ? BottomNavigationBar(
                  items: items,
                  currentIndex: currentIndex,
                  onTap: onTap,
                  backgroundColor: Colors.transparent,
                  elevation: 0,
                  type: BottomNavigationBarType.fixed,
                )
              : BottomNavigationBar(
                  items: items,
                  currentIndex: currentIndex,
                  onTap: onTap,
                  backgroundColor: Colors.transparent,
                  elevation: 0,
                ),
        ),
      ),
    );
  }
}
