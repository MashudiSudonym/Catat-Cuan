import 'package:flutter/material.dart';

/// Custom notch shape for seamless FAB integration with bottom navigation
///
/// Creates a smooth, curved notch that accommodates the FAB while maintaining
/// visual continuity with the bottom navigation bar.
class FabNotchShape extends NotchedShape {
  const FabNotchShape({
    this.fabSize = 56.0,
    this.fabMargin = 8.0,
    this.notchDepth = 8.0,
    this.cornerRadius = 8.0,
  });

  /// Size of the FAB (default Material FAB is 56)
  final double fabSize;

  /// Margin around the FAB
  final double fabMargin;

  /// How deep the notch extends into the bottom nav
  final double notchDepth;

  /// Corner radius for the notch edges
  final double cornerRadius;

  @override
  Path getOuterPath(Rect host, Rect? guest) {
    if (guest == null || !host.overlaps(guest)) {
      return Path()..addRect(host);
    }

    // Calculate FAB center position
    final fabCenterX = guest.center.dx;

    // Create path with notch
    final path = Path();

    // Start from top-left
    path.moveTo(host.left, host.top);

    // Top edge to notch start (left side)
    final notchHalfWidth = (fabSize / 2) + fabMargin + cornerRadius;
    final notchStartLeft = fabCenterX - notchHalfWidth;

    if (notchStartLeft > host.left) {
      path.lineTo(notchStartLeft, host.top);
    }

    // Create curved notch on left side
    if (notchStartLeft > host.left) {
      final cornerStart = notchStartLeft - cornerRadius;
      final notchTop = host.top - notchDepth;

      // Line to corner
      path.lineTo(cornerStart, host.top);

      // Curve down into notch
      final cornerControlX = cornerStart;
      final cornerControlY = host.top + cornerRadius;
      final cornerEndX = cornerStart + cornerRadius;
      final cornerEndY = notchTop;

      path.quadraticBezierTo(
        cornerControlX,
        cornerControlY,
        cornerEndX,
        cornerEndY,
      );

      // Bottom of notch (flat section under FAB)
      final notchEndRight = fabCenterX + notchHalfWidth - cornerRadius;
      path.lineTo(notchEndRight, notchTop);

      // Curve up from notch
      final notchEndCornerX = notchEndRight + cornerRadius;
      path.quadraticBezierTo(
        notchEndCornerX,
        host.top + cornerRadius,
        notchEndCornerX,
        host.top,
      );
    }

    // Complete top edge to right
    if (notchStartLeft + (notchHalfWidth * 2) < host.right) {
      path.lineTo(host.right, host.top);
    }

    // Right edge
    path.lineTo(host.right, host.bottom);

    // Bottom edge
    path.lineTo(host.left, host.bottom);

    // Close path
    path.close();

    return path;
  }
}

/// Smooth notch shape with circular cutout for FAB
///
/// Creates a circular notch that follows the FAB's shape for a more
/// organic, seamless look.
class CircularNotchShape extends NotchedShape {
  const CircularNotchShape({
    this.fabSize = 56.0,
    this.fabMargin = 4.0,
  });

  final double fabSize;
  final double fabMargin;

  @override
  Path getOuterPath(Rect host, Rect? guest) {
    if (guest == null || !host.overlaps(guest)) {
      return Path()..addRect(host);
    }

    final fabCenterX = guest.center.dx;
    final radius = (fabSize / 2) + fabMargin;

    final path = Path();

    // Top edge to notch
    path.lineTo(fabCenterX - radius, host.top);

    // Circular arc around FAB
    path.arcToPoint(
      Offset(fabCenterX + radius, host.top),
      radius: Radius.circular(radius),
      clockwise: false,
    );

    // Complete top edge
    path.lineTo(host.right, host.top);
    path.lineTo(host.right, host.bottom);
    path.lineTo(host.left, host.bottom);
    path.close();

    return path;
  }
}

/// Extended notch with visual bridge for seamless FAB integration
///
/// Creates a visual "bridge" between the FAB and bottom nav that
/// appears to connect them seamlessly.
class BridgeNotchShape extends NotchedShape {
  const BridgeNotchShape({
    this.fabSize = 56.0,
    this.bridgeWidth = 16.0,
    this.bridgeDepth = 4.0,
  });

  final double fabSize;
  final double bridgeWidth;
  final double bridgeDepth;

  @override
  Path getOuterPath(Rect host, Rect? guest) {
    if (guest == null || !host.overlaps(guest)) {
      return Path()..addRect(host);
    }

    final fabCenterX = guest.center.dx;
    final halfFab = fabSize / 2;

    final path = Path();

    // Calculate bridge dimensions
    final bridgeLeft = fabCenterX - halfFab - bridgeWidth;
    final bridgeRight = fabCenterX + halfFab + bridgeWidth;
    final bridgeTop = host.top - bridgeDepth;

    // Start top-left
    path.moveTo(host.left, host.top);

    // Top edge to bridge start
    path.lineTo(bridgeLeft, host.top);

    // Bridge left edge with curve
    path.lineTo(bridgeLeft, bridgeTop);

    // Bridge top edge (under FAB)
    path.lineTo(bridgeRight, bridgeTop);

    // Bridge right edge
    path.lineTo(bridgeRight, host.top);

    // Complete top edge
    path.lineTo(host.right, host.top);
    path.lineTo(host.right, host.bottom);
    path.lineTo(host.left, host.bottom);
    path.close();

    return path;
  }
}

/// Clipper for creating a seamless glassmorphism notch effect
///
/// Clips the bottom navigation to create space for the FAB while
/// maintaining the glass effect.
class GlassNotchClipper extends CustomClipper<Path> {
  const GlassNotchClipper({
    required this.fabSize,
    this.fabMargin = 8.0,
    this.notchDepth = 12.0,
    this.smoothness = 0.5,
  });

  final double fabSize;
  final double fabMargin;
  final double notchDepth;
  final double smoothness; // 0.0 = sharp, 1.0 = very smooth

  @override
  Path getClip(Size size) {
    final centerX = size.width / 2.0;
    final notchHalfWidth = (fabSize / 2.0) + fabMargin;
    final notchLeft = centerX - notchHalfWidth;
    final notchRight = centerX + notchHalfWidth;

    final path = Path();

    // Start top-left
    path.moveTo(0, 0);

    // Top edge to notch
    path.lineTo(notchLeft, 0);

    // Create smooth notch curve
    final curveDepth = notchDepth * (1.0 - smoothness);

    // Left curve into notch
    path.cubicTo(
      notchLeft - 20, 0,
      notchLeft - 10, curveDepth,
      notchLeft, curveDepth,
    );

    // Bottom of notch (flat under FAB)
    path.lineTo(notchRight, curveDepth);

    // Right curve out of notch
    path.cubicTo(
      notchRight + 10, curveDepth,
      notchRight + 20, 0,
      notchRight, 0,
    );

    // Complete top edge
    path.lineTo(size.width, 0);

    // Right and bottom edges
    path.lineTo(size.width, size.height);
    path.lineTo(0, size.height);
    path.close();

    return path;
  }

  @override
  bool shouldReclip(GlassNotchClipper oldClipper) {
    return oldClipper.fabSize != fabSize ||
        oldClipper.fabMargin != fabMargin ||
        oldClipper.notchDepth != notchDepth ||
        oldClipper.smoothness != smoothness;
  }
}

/// Shape border for seamless FAB integration
///
/// Use this with ShapeDecoration or Material to create
/// a bottom nav with a notch for the FAB.
class SeamlessNotchBorder extends ShapeBorder {
  const SeamlessNotchBorder({
    required this.fabSize,
    this.fabMargin = 8.0,
    this.notchDepth = 12.0,
    this.side = BorderSide.none,
    this.borderRadius = BorderRadius.zero,
  });

  final double fabSize;
  final double fabMargin;
  final double notchDepth;
  final BorderSide side;
  final BorderRadius borderRadius;

  @override
  EdgeInsetsGeometry get dimensions => EdgeInsets.all(side.width);

  @override
  Path getInnerPath(Rect rect, {TextDirection? textDirection}) {
    return getOuterPath(rect, textDirection: textDirection);
  }

  @override
  Path getOuterPath(Rect rect, {TextDirection? textDirection}) {
    final path = Path();
    final rrect = borderRadius.toRRect(rect);
    final centerX = rect.center.dx;
    final notchHalfWidth = (fabSize / 2.0) + fabMargin;
    final notchLeft = centerX - notchHalfWidth;
    final notchRight = centerX + notchHalfWidth;

    // Start with rounded rect
    path.addRRect(rrect);

    // Add notch cutout using even-odd fill rule
    final notchPath = Path();
    final notchRect = Rect.fromPoints(
      Offset(notchLeft, rect.top - notchDepth),
      Offset(notchRight, rect.top),
    );
    final notchRRect = RRect.fromRectAndRadius(
      notchRect,
      Radius.circular(notchDepth / 2),
    );
    notchPath.addRRect(notchRRect);

    // Combine paths
    return Path.combine(PathOperation.difference, path, notchPath);
  }

  @override
  void paint(Canvas canvas, Rect rect, {TextDirection? textDirection}) {
    if (side.style == BorderStyle.none) return;

    final path = getOuterPath(rect, textDirection: textDirection);
    canvas.drawPath(path, side.toPaint());
  }

  @override
  ShapeBorder scale(double t) {
    return SeamlessNotchBorder(
      fabSize: fabSize * t,
      fabMargin: fabMargin * t,
      notchDepth: notchDepth * t,
      side: side.scale(t),
      borderRadius: borderRadius * t,
    );
  }
}
