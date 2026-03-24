import 'package:flutter/material.dart';
import 'package:catat_cuan/presentation/utils/utils.dart';

/// Initialization screen shown while seeding initial data.
///
/// Displays a loading state during app initialization with:
/// - App branding (Catat Cuan title)
/// - Circular progress indicator with theme colors
/// - Loading message ("Menyiapkan aplikasi...")
///
/// This is a pure presentation component with no business logic.
/// The actual initialization is handled by [appInitializationProvider].
class InitializationScreen extends StatelessWidget {
  const InitializationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: AppSpacing.xxxl,
              height: AppSpacing.xxxl,
              decoration: BoxDecoration(
                color: AppColors.getGlassCard(
                  isDark: false,
                  alpha: GlassAlpha.minimal,
                ),
                shape: BoxShape.circle,
              ),
              child: Center(
                child: SizedBox(
                  width: AppSpacing.lg + AppSpacing.sm,
                  height: AppSpacing.lg + AppSpacing.sm,
                  child: CircularProgressIndicator(
                    color: AppColors.primary,
                    strokeWidth: AppRadius.xs,
                  ),
                ),
              ),
            ),
            AppSpacingWidget.verticalXL(),
            Text(
              'Catat Cuan',
              style: Theme.of(context).textTheme.displaySmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: AppColors.primary,
              ),
            ),
            AppSpacingWidget.verticalMD(),
            Text(
              'Menyiapkan aplikasi...',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: AppColors.textSecondary.withValues(alpha: 0.7),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
