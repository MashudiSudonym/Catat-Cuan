import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:file_picker/file_picker.dart';
import 'package:catat_cuan/presentation/providers/app_providers.dart';
import 'package:catat_cuan/presentation/widgets/base/base.dart';
import 'package:catat_cuan/presentation/widgets/import_result_dialog.dart';
import 'package:catat_cuan/presentation/utils/utils.dart';

/// Settings screen for app preferences
class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeState = ref.watch(themeProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Pengaturan'),
      ),
      body: ListView(
        children: [
          // Theme Settings Section
          _buildSectionHeader('Tampilan'),

          AppGlassContainer.glassCard(
            margin: AppSpacing.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.sm),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: AppSpacing.all(AppSpacing.lg),
                  child: Row(
                    children: [
                      Icon(
                        Icons.palette_outlined,
                        color: isDark ? Colors.white : AppColors.textPrimary,
                      ),
                      const SizedBox(width: AppSpacing.md),
                      Text(
                        'Mode Tema',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                      ),
                    ],
                  ),
                ),
                const Divider(height: 1),
                ...ThemeModeOption.values.map((option) {
                  final isSelected = themeState.themeModeOption == option;
                  return _ThemeOptionTile(
                    option: option,
                    isSelected: isSelected,
                    onTap: () {
                      ref.read(themeProvider.notifier).setThemeMode(option);
                    },
                  );
                }),
              ],
            ),
          ),

          const SizedBox(height: AppSpacing.lg),

          // Currency Settings Section
          _buildSectionHeader('Mata Uang'),

          AppGlassContainer.glassCard(
            margin: AppSpacing.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.sm),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: AppSpacing.all(AppSpacing.lg),
                  child: Row(
                    children: [
                      Icon(
                        Icons.attach_money_outlined,
                        color: isDark ? Colors.white : AppColors.textPrimary,
                      ),
                      const SizedBox(width: AppSpacing.md),
                      Text(
                        'Mata Uang',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                      ),
                    ],
                  ),
                ),
                const Divider(height: 1),
                ...CurrencyOption.values.map((option) {
                  final currencyState = ref.watch(currencyProvider);
                  final isSelected = currencyState.currencyOption == option;
                  return _CurrencyOptionTile(
                    option: option,
                    isSelected: isSelected,
                    onTap: () {
                      ref.read(currencyProvider.notifier).setCurrency(option);
                    },
                  );
                }),
              ],
            ),
          ),

          const SizedBox(height: AppSpacing.lg),

          // Data Section
          _buildSectionHeader('Data'),

          AppGlassContainer.glassCard(
            margin: AppSpacing.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.sm),
            child: ListTile(
              leading: Icon(
                Icons.upload_file_outlined,
                color: isDark ? Colors.white : AppColors.textPrimary,
              ),
              title: const Text('Impor Transaksi'),
              subtitle: const Text('Impor data dari file CSV'),
              trailing: Icon(
                Icons.chevron_right,
                color: AppColors.textTertiary,
              ),
              onTap: () => _handleImport(context, ref),
            ),
          ),

          const SizedBox(height: AppSpacing.lg),

          // App Info Section
          _buildSectionHeader('Informasi Aplikasi'),

          AppGlassContainer.glassCard(
            margin: AppSpacing.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.sm),
            child: Column(
              children: [
                ListTile(
                  leading: Icon(
                    Icons.info_outline,
                    color: isDark ? Colors.white : AppColors.textPrimary,
                  ),
                  title: const Text('Versi Aplikasi'),
                  subtitle: const Text('1.0.0'),
                ),
                const Divider(height: 1),
                ListTile(
                  leading: Icon(
                    Icons.brightness_6_outlined,
                    color: isDark ? Colors.white : AppColors.textPrimary,
                  ),
                  title: const Text('Tema Saat Ini'),
                  subtitle: Text(_getCurrentThemeLabel(context, themeState.themeModeOption)),
                ),
              ],
            ),
          ),

          const SizedBox(height: AppSpacing.xxxl),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: AppSpacing.symmetric(horizontal: AppSpacing.lg, vertical: AppSpacing.md),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: AppColors.textSecondary.withValues(alpha: 0.8),
        ),
      ),
    );
  }

  String _getCurrentThemeLabel(BuildContext context, ThemeModeOption option) {
    switch (option) {
      case ThemeModeOption.system:
        return 'Sistem (${Theme.of(context).brightness == Brightness.dark ? 'Gelap' : 'Terang'})';
      case ThemeModeOption.light:
        return 'Terang';
      case ThemeModeOption.dark:
        return 'Gelap';
    }
  }

  Future<void> _handleImport(BuildContext context, WidgetRef ref) async {
    // Pick CSV file
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['csv'],
    );

    if (result == null || result.files.isEmpty) return;

    final filePath = result.files.single.path;
    if (filePath == null) return;

    // Show confirmation dialog
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Impor Transaksi'),
        content: const Text(
          'Data dari file CSV akan diimpor. Transaksi yang sudah ada tidak akan diduplikasi. Lanjutkan?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Impor'),
          ),
        ],
      ),
    );

    if (confirmed != true || !context.mounted) return;

    // Perform import
    await ref.read(importProvider.notifier).importTransactions(filePath);

    if (!context.mounted) return;

    final importState = ref.read(importProvider);

    if (importState.isSuccess) {
      ImportResultDialog.show(context, result: importState.result!);
      ref.read(importProvider.notifier).reset();

      // Invalidate transaction list providers to refresh data after import
      ref.invalidate(transactionListPaginatedProvider);
      ref.invalidate(transactionListProvider);
    } else if (importState.isError) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(importState.errorMessage ?? 'Impor gagal'),
          backgroundColor: AppColors.error,
        ),
      );
      ref.read(importProvider.notifier).reset();
    }
  }
}

/// Theme option tile widget
class _ThemeOptionTile extends StatelessWidget {
  final ThemeModeOption option;
  final bool isSelected;
  final VoidCallback onTap;

  const _ThemeOptionTile({
    required this.option,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: AppSpacing.symmetric(horizontal: AppSpacing.lg, vertical: AppSpacing.md),
        child: Row(
          children: [
            // Icon
            Icon(
              _getIconForOption(option),
              color: isSelected ? AppColors.primary : (isDark ? Colors.white70 : Colors.grey.shade600),
              size: 24,
            ),
            const SizedBox(width: AppSpacing.md),

            // Label
            Expanded(
              child: Text(
                option.label,
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                      color: isSelected ? AppColors.primary : null,
                    ),
              ),
            ),

            // Checkmark if selected
            if (isSelected)
              Icon(
                Icons.check_circle,
                color: AppColors.primary,
                size: 24,
              ),
          ],
        ),
      ),
    );
  }

  IconData _getIconForOption(ThemeModeOption option) {
    switch (option) {
      case ThemeModeOption.system:
        return Icons.brightness_auto;
      case ThemeModeOption.light:
        return Icons.light_mode;
      case ThemeModeOption.dark:
        return Icons.dark_mode;
    }
  }
}

/// Currency option tile widget
class _CurrencyOptionTile extends StatelessWidget {
  final CurrencyOption option;
  final bool isSelected;
  final VoidCallback onTap;

  const _CurrencyOptionTile({
    required this.option,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: AppSpacing.symmetric(horizontal: AppSpacing.lg, vertical: AppSpacing.md),
        child: Row(
          children: [
            Container(
              padding: AppSpacing.symmetric(horizontal: AppSpacing.sm, vertical: AppSpacing.xs),
              decoration: BoxDecoration(
                color: isSelected
                    ? AppColors.primary.withValues(alpha: 0.1)
                    : (isDark ? Colors.white12 : Colors.grey.shade200),
                borderRadius: AppRadius.smAll,
              ),
              child: Text(
                '${option.symbol}1.000.000',
                style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Text(
                option.label,
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                      color: isSelected ? AppColors.primary : null,
                    ),
              ),
            ),
            if (isSelected)
              Icon(
                Icons.check_circle,
                color: AppColors.primary,
                size: 24,
              ),
          ],
        ),
      ),
    );
  }
}
