import 'package:flutter/material.dart';

/// Color-coded budget progress bar per BUD-03/D-03
///
/// Shows spending progress with color transitions:
/// - Green (0-75%): Healthy spending
/// - Yellow (75-100%): Approaching limit
/// - Red (>100%): Over budget
///
/// Uses AnimatedContainer for smooth color transitions.
class BudgetProgressBar extends StatelessWidget {
  const BudgetProgressBar({
    super.key,
    required this.progressPercent,
    this.height = 8.0,
    this.borderRadius = 4.0,
  });

  /// Progress percentage (0-100+, where >100 means over budget)
  final double progressPercent;

  /// Height of the progress bar
  final double height;

  /// Border radius for rounded ends
  final double borderRadius;

  /// Get progress color based on spending threshold per BUD-03
  Color get progressColor {
    if (progressPercent > 100) return Colors.red.shade400;
    if (progressPercent > 75) return Colors.orange.shade400;
    return Colors.green.shade400;
  }

  /// Get clamped progress value (max 100% for bar width)
  double get clampedProgress => (progressPercent / 100).clamp(0.0, 1.0);

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final trackColor = isDark
        ? Colors.white.withValues(alpha: 0.12)
        : Colors.black.withValues(alpha: 0.08);

    return ClipRRect(
      borderRadius: BorderRadius.circular(borderRadius),
      child: SizedBox(
        height: height,
        child: LayoutBuilder(
          builder: (context, constraints) {
            final maxWidth = constraints.maxWidth;
            return Stack(
              children: [
                // Background track
                Container(
                  decoration: BoxDecoration(
                    color: trackColor,
                    borderRadius: BorderRadius.circular(borderRadius),
                  ),
                ),
                // Progress fill
                AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeInOut,
                  width: maxWidth * clampedProgress,
                  decoration: BoxDecoration(
                    color: progressColor,
                    borderRadius: BorderRadius.circular(borderRadius),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
