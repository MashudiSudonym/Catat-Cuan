import 'package:flutter/material.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:shared_preferences/shared_preferences.dart';

part 'theme_provider.g.dart';

/// Theme mode options
enum ThemeModeOption {
  /// Follow system theme
  system('Sistem'),

  /// Always light theme
  light('Terang'),

  /// Always dark theme
  dark('Gelap');

  final String label;
  const ThemeModeOption(this.label);

  /// Convert to Flutter's ThemeMode
  ThemeMode toThemeMode() {
    switch (this) {
      case ThemeModeOption.system:
        return ThemeMode.system;
      case ThemeModeOption.light:
        return ThemeMode.light;
      case ThemeModeOption.dark:
        return ThemeMode.dark;
    }
  }

  /// Convert from Flutter's ThemeMode
  static ThemeModeOption fromThemeMode(ThemeMode mode) {
    switch (mode) {
      case ThemeMode.system:
        return ThemeModeOption.system;
      case ThemeMode.light:
        return ThemeModeOption.light;
      case ThemeMode.dark:
        return ThemeModeOption.dark;
    }
  }

  /// Get from index
  static ThemeModeOption fromIndex(int index) {
    return ThemeModeOption.values[index];
  }
}

/// Theme state
class ThemeState {
  final ThemeModeOption themeModeOption;

  const ThemeState({required this.themeModeOption});

  /// Get Flutter ThemeMode
  ThemeMode get themeMode => themeModeOption.toThemeMode();

  /// Copy with
  ThemeState copyWith({ThemeModeOption? themeModeOption}) {
    return ThemeState(
      themeModeOption: themeModeOption ?? this.themeModeOption,
    );
  }

  /// Initial state (system theme by default)
  static ThemeState get initial => const ThemeState(
        themeModeOption: ThemeModeOption.system,
      );
}

/// Theme provider with persistence
@riverpod
class ThemeNotifier extends _$ThemeNotifier {
  static const String _themeKey = 'theme_mode';

  @override
  ThemeState build() {
    // Load saved theme preference
    _loadThemePreference();
    return ThemeState.initial;
  }

  /// Load theme preference from shared preferences
  Future<void> _loadThemePreference() async {
    final prefs = await SharedPreferences.getInstance();
    final themeIndex = prefs.getInt(_themeKey) ?? 0; // Default to system (index 0)

    final themeModeOption = ThemeModeOption.fromIndex(themeIndex);

    state = ThemeState(themeModeOption: themeModeOption);
  }

  /// Set theme mode
  Future<void> setThemeMode(ThemeModeOption option) async {
    state = ThemeState(themeModeOption: option);

    // Save to shared preferences
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_themeKey, option.index);
  }

  /// Toggle between light and dark (skipping system)
  Future<void> toggleTheme() async {
    final currentOption = state.themeModeOption;
    final newOption = currentOption == ThemeModeOption.light
        ? ThemeModeOption.dark
        : ThemeModeOption.light;

    await setThemeMode(newOption);
  }
}

/// Provider for theme mode
final themeModeProvider = Provider<ThemeMode>((ref) {
  final themeState = ref.watch(themeNotifierProvider);
  return themeState.themeMode;
});
