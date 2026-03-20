import 'package:flutter/material.dart';
import '../../utils/responsive/app_spacing.dart';
import '../../utils/app_colors.dart';
import 'app_glass_container.dart';

/// Unified error state widget with glassmorphism
/// Provides a consistent look for error states across the app
class AppErrorState extends StatelessWidget {
  const AppErrorState({
    super.key,
    required this.title,
    this.subtitle,
    this.icon,
    this.onRetry,
    this.retryLabel = 'Coba Lagi',
    this.onDismiss,
    this.dismissLabel,
  });

  final String title;
  final String? subtitle;
  final IconData? icon;
  final VoidCallback? onRetry;
  final String retryLabel;
  final VoidCallback? onDismiss;
  final String? dismissLabel;

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
            AppGlassContainer.glassPill(
              width: 100,
              height: 100,
              padding: EdgeInsets.zero,
              alignment: Alignment.center,
              child: Icon(
                icon ?? Icons.error_outline,
                size: 50,
                color: AppColors.error,
              ),
            ),
            const AppSpacingWidget.verticalXL(),
            Text(
              title,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppColors.error,
                  ),
              textAlign: TextAlign.center,
            ),
            if (subtitle != null) ...[
              const AppSpacingWidget.verticalSM(),
              Text(
                subtitle!,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: secondaryColor,
                    ),
                textAlign: TextAlign.center,
              ),
            ],
            if (onRetry != null || onDismiss != null) ...[
              const AppSpacingWidget.verticalXL(),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (onDismiss != null) ...[
                    TextButton(
                      onPressed: onDismiss,
                      child: Text(dismissLabel ?? 'Tutup'),
                    ),
                    const AppSpacingWidget.horizontalSM(),
                  ],
                  if (onRetry != null)
                    ElevatedButton(
                      onPressed: onRetry,
                      child: Text(retryLabel),
                    ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// Pre-configured error states for common scenarios
class AppErrorStates {
  AppErrorStates._();

  /// Generic error state
  static Widget generic({
    String? message,
    VoidCallback? onRetry,
  }) {
    return AppErrorState(
      title: 'Terjadi kesalahan',
      subtitle: message ?? 'Terjadi kesalahan yang tidak terduga. Silakan coba lagi.',
      onRetry: onRetry,
    );
  }

  /// Network error state
  static Widget network({
    VoidCallback? onRetry,
  }) {
    return AppErrorState(
      icon: Icons.wifi_off,
      title: 'Tidak ada koneksi internet',
      subtitle: 'Periksa koneksi internet Anda dan coba lagi.',
      onRetry: onRetry,
    );
  }

  /// Not found error state
  static Widget notFound({
    String? itemType,
    VoidCallback? onRetry,
  }) {
    return AppErrorState(
      icon: Icons.search_off,
      title: '$itemType tidak ditemukan',
      subtitle: 'Data yang Anda cari mungkin telah dihapus atau dipindahkan.',
      onRetry: onRetry,
    );
  }

  /// Permission error state
  static Widget permission({
    String? permission,
    VoidCallback? onOpenSettings,
  }) {
    return AppErrorState(
      icon: Icons.lock,
      title: 'Izin diperlukan',
      subtitle: 'Aplikasi memerlukan izin ${permission ?? "yang diperlukan"} untuk berfungsi.',
      retryLabel: 'Buka Pengaturan',
      onRetry: onOpenSettings,
    );
  }

  /// Storage error state
  static Widget storage({
    VoidCallback? onRetry,
  }) {
    return AppErrorState(
      icon: Icons.storage,
      title: 'Gagal menyimpan data',
      subtitle: 'Tidak dapat menyimpan data ke penyimpanan lokal.',
      onRetry: onRetry,
    );
  }

  /// Camera error state
  static Widget camera({
    VoidCallback? onRetry,
  }) {
    return AppErrorState(
      icon: Icons.camera_alt,
      title: 'Gagal membuka kamera',
      subtitle: 'Pastikan aplikasi memiliki izin kamera dan kamera tersedia.',
      onRetry: onRetry,
    );
  }

  /// Server error state
  static Widget server({
    VoidCallback? onRetry,
  }) {
    return AppErrorState(
      icon: Icons.cloud_off,
      title: 'Gagal menghubungi server',
      subtitle: 'Server tidak dapat dihubungi. Periksa koneksi Anda dan coba lagi.',
      onRetry: onRetry,
    );
  }
}

/// Loading state widget for consistency
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

/// Initial/placeholder state widget
class AppInitial extends StatelessWidget {
  const AppInitial({
    super.key,
    this.message,
  });

  final String? message;

  @override
  Widget build(BuildContext context) {
    return const SizedBox.shrink();
  }
}
