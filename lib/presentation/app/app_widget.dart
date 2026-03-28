import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:catat_cuan/presentation/providers/app_providers.dart';
import 'package:catat_cuan/presentation/utils/utils.dart';
import 'package:catat_cuan/presentation/utils/logger/app_logger.dart';
import 'package:catat_cuan/presentation/utils/error/error_message_mapper.dart';

/// Root application widget.
///
/// Responsibilities:
/// - Watch app initialization provider
/// - Watch category seeding state
/// - Watch theme mode provider
/// - Watch router provider
/// - Route to appropriate screen based on state
/// - Apply theme configuration
///
/// This widget uses the AsyncValue pattern to handle three states:
/// - Loading: Shows [InitializationScreen]
/// - Error: Shows [AppInitializationErrorScreen]
/// - Data: Shows main app with router
class AppWidget extends ConsumerWidget {
  const AppWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Watch the initialization provider
    final initialization = ref.watch(appInitializationProvider);

    // Watch the category seeding state to prevent flash of wrong screen
    final seedingState = ref.watch(categorySeedingProvider);

    // Watch the theme mode from theme provider
    final themeMode = ref.watch(themeModeProvider);

    // Watch the router provider (for reactive redirects)
    final router = ref.watch(routerProvider);

    // Determine if app is ready (both init and seeding state are resolved)
    final isReady = initialization.hasValue && seedingState.hasValue;

    if (!isReady) {
      // Show initialization screen while loading
      final hasError = initialization.hasError;
      if (hasError) {
        AppLogger.e(
          'App initialization failed',
          initialization.error,
          initialization.stackTrace,
        );
        return MaterialApp(
          title: 'Catat Cuan',
          debugShowCheckedModeBanner: false,
          theme: AppTheme.lightTheme,
          darkTheme: AppTheme.darkTheme,
          themeMode: themeMode,
          home: AppInitializationErrorScreen(
            message: ErrorMessageMapper.getUserMessage(initialization.error),
          ),
        );
      }

      return MaterialApp(
        title: 'Catat Cuan',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        darkTheme: AppTheme.darkTheme,
        themeMode: themeMode,
        home: const InitializationScreen(),
      );
    }

    return MaterialApp.router(
      title: 'Catat Cuan',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: themeMode,
      routerConfig: router,
    );
  }
}
