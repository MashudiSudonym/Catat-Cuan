import 'package:flutter/material.dart';

/// Consistent border radius system
/// All radius values should be multiples of 4 for consistency with spacing system
class AppRadius {
  AppRadius._();

  // Radius scale (4px grid)
  static const double xs = 4.0;   // 4px
  static const double sm = 8.0;   // 8px
  static const double md = 12.0;  // 12px
  static const double lg = 16.0;  // 16px
  static const double xl = 20.0;  // 20px
  static const double xxl = 24.0; // 24px
  static const double xxxl = 32.0; // 32px
  static const double circle = 999.0; // For circular borders

  // BorderRadius helpers
  static BorderRadius all(double value) => BorderRadius.all(Radius.circular(value));
  static BorderRadius horizontal(double value) => BorderRadius.horizontal(
        left: Radius.circular(value),
        right: Radius.circular(value),
      );
  static BorderRadius vertical(double value) => BorderRadius.vertical(
        top: Radius.circular(value),
        bottom: Radius.circular(value),
      );
  static BorderRadius only({
    double topLeft = 0,
    double topRight = 0,
    double bottomLeft = 0,
    double bottomRight = 0,
  }) =>
      BorderRadius.only(
        topLeft: Radius.circular(topLeft),
        topRight: Radius.circular(topRight),
        bottomLeft: Radius.circular(bottomLeft),
        bottomRight: Radius.circular(bottomRight),
      );
  static BorderRadius circular(double radius) => BorderRadius.circular(radius);

  // Common presets
  static const BorderRadius xsAll = BorderRadius.all(Radius.circular(xs));
  static const BorderRadius smAll = BorderRadius.all(Radius.circular(sm));
  static const BorderRadius mdAll = BorderRadius.all(Radius.circular(md));
  static const BorderRadius lgAll = BorderRadius.all(Radius.circular(lg));
  static const BorderRadius xlAll = BorderRadius.all(Radius.circular(xxl));
  static const BorderRadius xxlAll = BorderRadius.all(Radius.circular(xxl));
  static const BorderRadius xxxlAll = BorderRadius.all(Radius.circular(xxxl));
  static const BorderRadius circleAll = BorderRadius.all(Radius.circular(circle));
}

/// RoundedRectangleBorder helpers
class AppBorderRadius {
  AppBorderRadius._();

  static RoundedRectangleBorder shape(BorderRadius radius) =>
      RoundedRectangleBorder(borderRadius: radius);

  // Preset shapes
  static RoundedRectangleBorder get xsShape =>
      RoundedRectangleBorder(borderRadius: AppRadius.xsAll);
  static RoundedRectangleBorder get smShape =>
      RoundedRectangleBorder(borderRadius: AppRadius.smAll);
  static RoundedRectangleBorder get mdShape =>
      RoundedRectangleBorder(borderRadius: AppRadius.mdAll);
  static RoundedRectangleBorder get lgShape =>
      RoundedRectangleBorder(borderRadius: AppRadius.lgAll);
  static RoundedRectangleBorder get xlShape =>
      RoundedRectangleBorder(borderRadius: AppRadius.xlAll);
  static RoundedRectangleBorder get xxlShape =>
      RoundedRectangleBorder(borderRadius: AppRadius.xxlAll);
  static RoundedRectangleBorder get circleShape =>
      RoundedRectangleBorder(borderRadius: AppRadius.circleAll);
}
