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

    // Watch the theme mode from theme provider
    final themeMode = ref.watch(themeModeProvider);

    // Watch the router provider (for reactive redirects)
    final router = ref.watch(routerProvider);

    return initialization.when(
      loading: () => MaterialApp(
        title: 'Catat Cuan',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        darkTheme: AppTheme.darkTheme,
        themeMode: themeMode,
        home: const InitializationScreen(),
      ),
      error: (error, stackTrace) {
        AppLogger.e('App initialization failed', error, stackTrace);
        return MaterialApp(
          title: 'Catat Cuan',
          debugShowCheckedModeBanner: false,
          theme: AppTheme.lightTheme,
          darkTheme: AppTheme.darkTheme,
          themeMode: themeMode,
          home: AppInitializationErrorScreen(
            message: ErrorMessageMapper.getUserMessage(error),
          ),
        );
      },
      data: (_) => MaterialApp.router(
        title: 'Catat Cuan',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        darkTheme: AppTheme.darkTheme,
        themeMode: themeMode,
        routerConfig: router,
      ),
    );
  }
}
