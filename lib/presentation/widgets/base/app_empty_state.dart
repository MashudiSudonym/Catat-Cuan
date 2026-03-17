import 'package:flutter/material.dart';
import '../../utils/responsive/app_spacing.dart';
import '../../utils/app_colors.dart';
import 'app_glass_container.dart';

/// Unified empty state widget with glassmorphism
/// Provides a consistent look for empty states across the app
class AppEmptyState extends StatelessWidget {
  const AppEmptyState({
    super.key,
    required this.title,
    this.subtitle,
    this.icon,
    this.image,
    this.onAction,
    this.actionLabel,
    this.actionType = ActionType.outlined,
  });

  final String title;
  final String? subtitle;
  final IconData? icon;
  final Widget? image;
  final VoidCallback? onAction;
  final String? actionLabel;
  final ActionType actionType;

  @override
  Widget build(BuildContext context) {
    final hasVisual = icon != null || image != null;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final secondaryColor = isDark ? AppColors.textOnDark.withValues(alpha: 0.7) : AppColors.textSecondary;

    return Center(
      child: Padding(
        padding: AppSpacing.all(AppSpacing.xxxl),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (hasVisual) ...[
              _buildVisual(context),
              const AppSpacingWidget.verticalXL(),
            ],
            Text(
              title,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
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
            if (onAction != null && actionLabel != null) ...[
              const AppSpacingWidget.verticalXL(),
              _buildActionButton(context),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildVisual(BuildContext context) {
    if (image != null) return image!;

    return AppGlassContainer.glassPill(
      width: 100,
      height: 100,
      padding: EdgeInsets.zero,
      alignment: Alignment.center,
      child: Icon(
        icon,
        size: 50,
        color: AppColors.primary,
      ),
    );
  }

  Widget _buildActionButton(BuildContext context) {
    switch (actionType) {
      case ActionType.elevated:
        return ElevatedButton(
          onPressed: onAction,
          child: Text(actionLabel!),
        );
      case ActionType.outlined:
        return OutlinedButton(
          onPressed: onAction,
          child: Text(actionLabel!),
        );
      case ActionType.text:
        return TextButton(
          onPressed: onAction,
          child: Text(actionLabel!),
        );
    }
  }
}

enum ActionType { elevated, outlined, text }

/// Pre-configured empty states for common scenarios
class AppEmptyStates {
  AppEmptyStates._();

  /// Empty state for transactions
  static Widget transactions({
    VoidCallback? onAdd,
    String? message,
  }) {
    return AppEmptyState(
      icon: Icons.receipt_long,
      title: 'Belum ada transaksi',
      subtitle: message ?? 'Mulai lacak pengeluaran dan pemasukan Anda',
      actionLabel: 'Tambah Transaksi',
      onAction: onAdd,
    );
  }

  /// Empty state for categories
  static Widget categories({
    VoidCallback? onAdd,
  }) {
    return AppEmptyState(
      icon: Icons.category,
      title: 'Belum ada kategori',
      subtitle: 'Buat kategori untuk mengelompokkan transaksi Anda',
      actionLabel: 'Buat Kategori',
      onAction: onAdd,
    );
  }

  /// Empty state for filtered results
  static Widget noResults({
    VoidCallback? onClear,
    String? filterDescription,
  }) {
    return AppEmptyState(
      icon: Icons.search_off,
      title: 'Tidak ada hasil',
      subtitle: filterDescription != null
          ? 'Tidak ada transaksi dengan filter: $filterDescription'
          : 'Coba ubah filter atau kata kunci pencarian',
      actionLabel: 'Hapus Filter',
      onAction: onClear,
    );
  }

  /// Empty state for monthly summary
  static Widget monthlySummary({
    VoidCallback? onAdd,
  }) {
    return AppEmptyState(
      icon: Icons.pie_chart,
      title: 'Belum ada data ringkasan',
      subtitle: 'Tambahkan transaksi untuk melihat ringkasan bulanan',
      actionLabel: 'Tambah Transaksi',
      onAction: onAdd,
    );
  }

  /// Empty state for search
  static Widget search({
    VoidCallback? onBrowse,
  }) {
    return AppEmptyState(
      icon: Icons.search,
      title: 'Cari transaksi',
      subtitle: 'Ketik untuk mencari transaksi berdasarkan nama, kategori, atau catatan',
      actionLabel: onBrowse != null ? 'Telusuri' : null,
      onAction: onBrowse,
    );
  }
}
