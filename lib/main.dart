import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:catat_cuan/presentation/providers/app_providers.dart';
import 'package:catat_cuan/presentation/screens/home_screen.dart';
import 'package:catat_cuan/presentation/screens/onboarding_screen.dart';
import 'package:catat_cuan/presentation/utils/utils.dart';
import 'package:catat_cuan/presentation/utils/logger/app_logger.dart';
import 'package:catat_cuan/presentation/utils/error/error_message_mapper.dart';

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
    child: MyApp(),
  );
  runApp(app);
  AppLogger.i('Application started successfully');
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Watch the initialization provider
    final initialization = ref.watch(appInitializationProvider);

    // Watch the theme mode from theme provider
    final themeMode = ref.watch(themeModeProvider);

    return MaterialApp(
      title: 'Catat Cuan',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: themeMode,
      // Home: Check onboarding first, then show HomeScreen
      home: initialization.when(
        data: (_) => const _OnboardingChecker(),
        loading: () => const _InitializationScreen(),
        error: (error, stackTrace) {
          AppLogger.e('App initialization failed', error, stackTrace);
          return _ErrorScreen(
            message: ErrorMessageMapper.getUserMessage(error),
          );
        },
      ),
    );
  }
}

/// Initialization screen shown while seeding initial data
class _InitializationScreen extends StatelessWidget {
  const _InitializationScreen();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Center(
                child: SizedBox(
                  width: 30,
                  height: 30,
                  child: CircularProgressIndicator(
                    color: Theme.of(context).colorScheme.primary,
                    strokeWidth: 3,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'Catat Cuan',
              style: Theme.of(context).textTheme.displaySmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Menyiapkan aplikasi...',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Error screen shown if initialization fails
class _ErrorScreen extends ConsumerWidget {
  final String message;

  const _ErrorScreen({required this.message});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      body: Center(
        child: Padding(
          padding: AppSpacing.xxxlAll,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.error.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.error_outline,
                  size: 40,
                  color: Theme.of(context).colorScheme.error,
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
                message,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
                ),
              ),
              AppSpacingWidget.verticalXXL(),
              ElevatedButton.icon(
                onPressed: () {
                  // Attempt to restart the app by invalidating initialization
                  AppLogger.i('User requested app restart after error');
                  ref.invalidate(appInitializationProvider);
                },
                icon: const Icon(Icons.refresh),
                label: const Text('Coba Lagi'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  padding: AppSpacing.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.sm),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Widget to check onboarding state and show appropriate screen
class _OnboardingChecker extends ConsumerWidget {
  const _OnboardingChecker();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final onboardingState = ref.watch(onboardingNotifierProvider);

    return onboardingState.when(
      loading: () => const _InitializationScreen(),
      error: (error, stackTrace) {
        AppLogger.e('Onboarding check failed', error, stackTrace);
        // Show home screen on error
        return const HomeScreen();
      },
      data: (hasSeenOnboarding) {
        if (hasSeenOnboarding) {
          return const HomeScreen();
        } else {
          return const OnboardingScreen();
        }
      },
    );
  }
}

