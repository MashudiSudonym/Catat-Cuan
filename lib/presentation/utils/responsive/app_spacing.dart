import 'package:flutter/widgets.dart';

/// Consistent spacing system based on 4px grid scale
/// All spacing values should be multiples of 4 for consistency
class AppSpacing {
  AppSpacing._();

  // Base unit
  static const double unit = 4.0;

  // Spacing scale (4px grid)
  static const double xs = unit;        // 4px
  static const double sm = unit * 2;    // 8px
  static const double md = unit * 3;    // 12px
  static const double lg = unit * 4;    // 16px
  static const double xl = unit * 5;    // 20px
  static const double xxl = unit * 6;   // 24px
  static const double xxxl = unit * 8;  // 32px
  static const double huge = unit * 10; // 40px
  static const double massive = unit * 12; // 48px

  // EdgeInsets helpers
  static EdgeInsets all(double value) => EdgeInsets.all(value);
  static EdgeInsets horizontal(double value) => EdgeInsets.symmetric(horizontal: value);
  static EdgeInsets vertical(double value) => EdgeInsets.symmetric(vertical: value);
  static EdgeInsets only({double left = 0, double top = 0, double right = 0, double bottom = 0}) =>
      EdgeInsets.only(left: left, top: top, right: right, bottom: bottom);
  static EdgeInsets symmetric({double horizontal = 0, double vertical = 0}) =>
      EdgeInsets.symmetric(horizontal: horizontal, vertical: vertical);

  // Common presets
  static const EdgeInsets xsAll = EdgeInsets.all(xs);
  static const EdgeInsets smAll = EdgeInsets.all(sm);
  static const EdgeInsets mdAll = EdgeInsets.all(md);
  static const EdgeInsets lgAll = EdgeInsets.all(lg);
  static const EdgeInsets xlAll = EdgeInsets.all(xl);
  static const EdgeInsets xxlAll = EdgeInsets.all(xxl);
  static const EdgeInsets xxxlAll = EdgeInsets.all(xxxl);

  static const EdgeInsets smHorizontal = EdgeInsets.symmetric(horizontal: sm);
  static const EdgeInsets mdHorizontal = EdgeInsets.symmetric(horizontal: md);
  static const EdgeInsets lgHorizontal = EdgeInsets.symmetric(horizontal: lg);
  static const EdgeInsets xlHorizontal = EdgeInsets.symmetric(horizontal: xl);

  static const EdgeInsets smVertical = EdgeInsets.symmetric(vertical: sm);
  static const EdgeInsets mdVertical = EdgeInsets.symmetric(vertical: md);
  static const EdgeInsets lgVertical = EdgeInsets.symmetric(vertical: lg);
  static const EdgeInsets xlVertical = EdgeInsets.symmetric(vertical: xl);
  static const EdgeInsets xxlVertical = EdgeInsets.symmetric(vertical: xxl);
}

/// Spacing widget helpers
class AppSpacingWidget extends StatelessWidget {
  const AppSpacingWidget({super.key, this.width, this.height});

  final double? width;
  final double? height;

  @override
  Widget build(BuildContext context) {
    return SizedBox(width: width, height: height);
  }

  // Preset constructors
  const AppSpacingWidget.xs({super.key}) : width = AppSpacing.xs, height = AppSpacing.xs;
  const AppSpacingWidget.sm({super.key}) : width = AppSpacing.sm, height = AppSpacing.sm;
  const AppSpacingWidget.md({super.key}) : width = AppSpacing.md, height = AppSpacing.md;
  const AppSpacingWidget.lg({super.key}) : width = AppSpacing.lg, height = AppSpacing.lg;
  const AppSpacingWidget.xl({super.key}) : width = AppSpacing.xl, height = AppSpacing.xl;
  const AppSpacingWidget.xxl({super.key}) : width = AppSpacing.xxl, height = AppSpacing.xxl;
  const AppSpacingWidget.xxxl({super.key}) : width = AppSpacing.xxxl, height = AppSpacing.xxxl;

  const AppSpacingWidget.horizontalXS({super.key}) : width = AppSpacing.xs, height = 0;
  const AppSpacingWidget.horizontalSM({super.key}) : width = AppSpacing.sm, height = 0;
  const AppSpacingWidget.horizontalMD({super.key}) : width = AppSpacing.md, height = 0;
  const AppSpacingWidget.horizontalLG({super.key}) : width = AppSpacing.lg, height = 0;
  const AppSpacingWidget.horizontalXL({super.key}) : width = AppSpacing.xl, height = 0;

  const AppSpacingWidget.verticalXS({super.key}) : width = 0, height = AppSpacing.xs;
  const AppSpacingWidget.verticalSM({super.key}) : width = 0, height = AppSpacing.sm;
  const AppSpacingWidget.verticalMD({super.key}) : width = 0, height = AppSpacing.md;
  const AppSpacingWidget.verticalLG({super.key}) : width = 0, height = AppSpacing.lg;
  const AppSpacingWidget.verticalXL({super.key}) : width = 0, height = AppSpacing.xl;
  const AppSpacingWidget.verticalXXL({super.key}) : width = 0, height = AppSpacing.xxl;
  const AppSpacingWidget.verticalXXXL({super.key}) : width = 0, height = AppSpacing.xxxl;
}

/// Extension for easy spacing in widget trees
extension AppSpacingExtension on Widget {
  Widget withSpacing(double spacing) {
    return Padding(padding: AppSpacing.all(spacing), child: this);
  }

  Widget withHorizontalSpacing(double spacing) {
    return Padding(padding: AppSpacing.horizontal(spacing), child: this);
  }

  Widget withVerticalSpacing(double spacing) {
    return Padding(padding: AppSpacing.vertical(spacing), child: this);
  }
}
