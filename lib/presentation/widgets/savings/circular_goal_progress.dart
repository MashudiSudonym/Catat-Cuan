import 'package:flutter/material.dart';
import 'package:catat_cuan/presentation/utils/utils.dart';

class CircularGoalProgress extends StatelessWidget {
  const CircularGoalProgress({
    super.key,
    required this.percentage,
    this.size = 48,
    this.strokeWidth = 4,
    this.showCenterText = true,
    required this.isDark,
  });

  final double percentage;
  final double size;
  final double strokeWidth;
  final bool showCenterText;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    final progressColor = AppColors.getGoalProgressColor(percentage, isDark);
    final trackColor = AppColors.getGlassPill(isDark: isDark);

    return TweenAnimationBuilder<double>(
      tween: Tween<double>(begin: 0, end: percentage.clamp(0.0, 100.0) / 100),
      duration: const Duration(milliseconds: 500),
      curve: Curves.easeOut,
      builder: (context, animatedValue, child) {
        return SizedBox(
          width: size,
          height: size,
          child: CustomPaint(
            painter: _CircularProgressPainter(
              progress: animatedValue,
              progressColor: progressColor,
              trackColor: trackColor,
              strokeWidth: strokeWidth,
            ),
            child: showCenterText
                ? Center(
                    child: Text(
                      '${percentage.round()}%',
                      style: TextStyle(
                        fontSize: size * 0.25,
                        fontWeight: FontWeight.w500,
                        color: isDark ? AppColors.textOnDark : AppColors.textPrimary,
                      ),
                    ),
                  )
                : null,
          ),
        );
      },
    );
  }
}

class _CircularProgressPainter extends CustomPainter {
  final double progress;
  final Color progressColor;
  final Color trackColor;
  final double strokeWidth;

  _CircularProgressPainter({
    required this.progress,
    required this.progressColor,
    required this.trackColor,
    required this.strokeWidth,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width - strokeWidth) / 2;

    final trackPaint = Paint()
      ..color = trackColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    canvas.drawCircle(center, radius, trackPaint);

    if (progress > 0) {
      final progressPaint = Paint()
        ..color = progressColor
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth
        ..strokeCap = StrokeCap.round;

      final sweepAngle = 2 * 3.141592653589793 * progress;
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        -1.5707963267948966,
        sweepAngle,
        false,
        progressPaint,
      );
    }
  }

  @override
  bool shouldRepaint(_CircularProgressPainter oldDelegate) {
    return oldDelegate.progress != progress || oldDelegate.progressColor != progressColor;
  }
}
