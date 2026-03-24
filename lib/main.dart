import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:catat_cuan/presentation/app/app_widget.dart';
import 'package:catat_cuan/presentation/utils/logger/app_logger.dart';

/// Application entry point.
///
/// Responsibilities:
/// - Initialize global services (logger, locale)
/// - Set up ProviderScope for state management
/// - Launch the app
///
/// This is the only function in main.dart following the
/// Single Responsibility Principle. All other components
/// have been extracted to separate files:
/// - [AppWidget] - Root widget with routing and theming
/// - [InitializationScreen] - Loading state screen
/// - [AppInitializationErrorScreen] - Error handling screen
void main() async {
  // Initialize logger first (before any other operations)
  AppLogger.initialize();
  AppLogger.i('Application starting...');

  // Initialize date formatting for Indonesian locale
  try {
    await initializeDateFormatting('id_ID');
    AppLogger.i('Date formatting initialized for id_ID locale');
  } catch (e, stackTrace) {
    AppLogger.e('Failed to initialize date formatting', e, stackTrace);
  }

  const app = ProviderScope(
    child: AppWidget(),
  );
  runApp(app);
  AppLogger.i('Application started successfully');
}
