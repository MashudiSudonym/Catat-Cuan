import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:catat_cuan/presentation/providers/app_providers.dart';
import 'package:catat_cuan/presentation/widgets/base/base.dart';
import 'package:catat_cuan/presentation/utils/utils.dart';

/// Settings screen for app preferences
class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeState = ref.watch(themeNotifierProvider);
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
                      ref.read(themeNotifierProvider.notifier).setThemeMode(option);
                    },
                  );
                }),
              ],
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
