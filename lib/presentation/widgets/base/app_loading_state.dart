import 'package:flutter/material.dart';
import '../../utils/responsive/app_spacing.dart';
import '../../utils/app_colors.dart';

/// Loading state widget for consistency
/// Provides a centered loading indicator with optional message
class AppLoadingState extends StatelessWidget {
  const AppLoadingState({
    super.key,
    this.message,
  });

  final String? message;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final secondaryColor = isDark ? AppColors.textOnDark.withValues(alpha: 0.7) : AppColors.textSecondary;

    return Center(
      child: Padding(
        padding: AppSpacing.all(AppSpacing.xxxl),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const CircularProgressIndicator(),
            if (message != null) ...[
              const AppSpacingWidget.verticalLG(),
              Text(
                message!,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: secondaryColor,
                    ),
                textAlign: TextAlign.center,
              ),
            ],
          ],
        ),
      ),
    );
  }
}
