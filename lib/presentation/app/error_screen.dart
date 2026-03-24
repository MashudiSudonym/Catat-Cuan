import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:catat_cuan/presentation/providers/app_providers.dart';
import 'package:catat_cuan/presentation/utils/utils.dart';
import 'package:catat_cuan/presentation/utils/logger/app_logger.dart';
import 'package:catat_cuan/presentation/widgets/base/base.dart';

/// Error screen shown if app initialization fails.
///
/// Responsibilities:
/// - Display error state when initialization fails
/// - Show user-friendly error messages
/// - Provide retry functionality
///
/// This is a pure presentation component with no business logic.
/// The actual error handling is handled by [appInitializationProvider].
class AppInitializationErrorScreen extends ConsumerStatefulWidget {
  final String message;

  const AppInitializationErrorScreen({
    super.key,
    required this.message,
  });

  @override
  ConsumerState<AppInitializationErrorScreen> createState() =>
      _AppInitializationErrorScreenState();
}

class _AppInitializationErrorScreenState
    extends ConsumerState<AppInitializationErrorScreen>
    with ScreenStateMixin {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Padding(
          padding: AppSpacing.all(AppSpacing.xxxl),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              AppGlassContainer.glassPill(
                child: SizedBox(
                  width: AppSpacing.xxxl + AppSpacing.xl,
                  height: AppSpacing.xxxl + AppSpacing.xl,
                  child: Icon(
                    Icons.error_outline,
                    size: AppSpacing.xxxl + AppSpacing.md,
                    color: AppColors.error,
                  ),
                ),
              ),
              AppSpacingWidget.verticalXXL(),
              Text(
                'Terjadi Kesalahan',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              AppSpacingWidget.verticalMD(),
              Text(
                widget.message,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppColors.textSecondary.withValues(alpha: 0.7),
                ),
              ),
              AppSpacingWidget.verticalXXL(),
              ElevatedButton.icon(
                onPressed: _handleRetry,
                icon: const Icon(Icons.refresh),
                label: const Text('Coba Lagi'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: AppColors.surfaceLight,
                  padding: AppSpacing.symmetric(
                    horizontal: AppSpacing.md,
                    vertical: AppSpacing.sm,
                  ),
                  shape: AppBorderRadius.mdShape,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _handleRetry() {
    AppLogger.i('User requested app restart after error');
    ref.invalidate(appInitializationProvider);
  }
}
