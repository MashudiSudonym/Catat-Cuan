import 'package:flutter/material.dart';
import 'package:catat_cuan/presentation/models/onboarding_page_data.dart';
import 'package:catat_cuan/presentation/utils/utils.dart';
import 'package:catat_cuan/presentation/widgets/base/base.dart';

/// Custom illustration widget for onboarding pages
/// Uses glassmorphism design with icons and decorative elements
class OnboardingIllustration extends StatelessWidget {
  final OnboardingPageData data;

  const OnboardingIllustration({
    super.key,
    required this.data,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return SizedBox(
      height: MediaQuery.of(context).size.height * 0.4,
      child: Stack(
        children: [
          // Background decorative circles
          _buildDecorativeCircles(isDark),

          // Main illustration container
          Center(
            child: AppGlassContainer.glassCard(
              child: Container(
                width: 180,
                height: 180,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      data.iconColor.withValues(alpha: 0.2),
                      data.iconColor.withValues(alpha: 0.05),
                    ],
                  ),
                  borderRadius: AppRadius.xxlAll,
                ),
                child: Stack(
                  children: [
                    // Primary icon (center)
                    Center(
                      child: Icon(
                        data.primaryIcon,
                        size: 80,
                        color: data.iconColor,
                      ),
                    ),

                    // Secondary icon (top right, animated position)
                    if (data.secondaryIcon != null)
                      Positioned(
                        top: 12,
                        right: 12,
                        child: _buildSecondaryIcon(data.secondaryIcon!, data.iconColor),
                      ),

                    // Decorative dots
                    _buildDecorativeDots(data.iconColor),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Build decorative background circles
  Widget _buildDecorativeCircles(bool isDark) {
    return Stack(
      children: [
        // Large outer circle
        Positioned(
          top: 20,
          left: 20,
          right: 20,
          bottom: 20,
          child: Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: data.iconColor.withValues(alpha: isDark ? 0.05 : 0.08),
            ),
          ),
        ),
        // Medium inner circle
        Positioned(
          top: 50,
          left: 50,
          right: 50,
          bottom: 50,
          child: Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: data.iconColor.withValues(alpha: isDark ? 0.08 : 0.12),
            ),
          ),
        ),
      ],
    );
  }

  /// Build secondary icon with glass effect
  Widget _buildSecondaryIcon(IconData icon, Color color) {
    return AppGlassContainer.glassPill(
      child: Container(
        padding: AppSpacing.all(AppSpacing.sm),
        child: Icon(
          icon,
          size: 24,
          color: color,
        ),
      ),
    );
  }

  /// Build decorative dots around the illustration
  Widget _buildDecorativeDots(Color color) {
    return Stack(
      children: [
        // Top left dot
        Positioned(
          top: 20,
          left: 20,
          child: _buildDot(color),
        ),
        // Bottom right dot
        Positioned(
          bottom: 20,
          right: 20,
          child: _buildDot(color),
        ),
        // Bottom left dot
        Positioned(
          bottom: 30,
          left: 30,
          child: _buildDot(color, size: 6),
        ),
      ],
    );
  }

  /// Build a single decorative dot
  Widget _buildDot(Color color, {double size = 8}) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: color.withValues(alpha: 0.4),
      ),
    );
  }
}
