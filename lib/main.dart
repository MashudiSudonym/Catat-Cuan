import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:catat_cuan/presentation/providers/app_providers.dart';
import 'package:catat_cuan/presentation/screens/transaction_list_screen.dart';
import 'package:catat_cuan/presentation/screens/monthly_summary_screen.dart';
import 'package:catat_cuan/presentation/screens/transaction_form_screen.dart';
import 'package:catat_cuan/presentation/screens/profile_screen.dart';
import 'package:catat_cuan/presentation/screens/settings_screen.dart';
import 'package:catat_cuan/presentation/widgets/base/base.dart';
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
      // Home: HomeScreen with Bottom Navigation
      home: initialization.when(
        data: (_) => const HomeScreen(),
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

/// Main Home Screen with Bottom Navigation
class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedIndex = ref.watch(navigationProvider).selectedIndex;

    return Scaffold(
      body: IndexedStack(
        index: selectedIndex,
        children: const [
          TransactionListScreen(),
          MonthlySummaryScreen(),
          ProfileScreen(),
          SettingsScreen(),
        ],
      ),
      floatingActionButton: _buildSeamlessFab(context, ref),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: _buildSeamlessBottomNav(context, ref, selectedIndex),
    );
  }

  /// Build seamless glassmorphism FAB
  Widget _buildSeamlessFab(BuildContext context, WidgetRef ref) {
    return SeamlessGlassFab(
      icon: Icons.add,
      tooltip: 'Tambah Transaksi',
      size: SeamlessFabSize.large,
      onPressed: () => _showAddTransactionForm(context, ref),
    );
  }

  /// Build seamless bottom navigation with glassmorphism
  Widget _buildSeamlessBottomNav(
    BuildContext context,
    WidgetRef ref,
    int selectedIndex,
  ) {
    return AppGlassNavigation(
      showTopBorder: true,
      child: BottomNavigationBar(
        currentIndex: selectedIndex,
        onTap: (index) => ref.read(navigationProvider.notifier).changeTab(index),
        backgroundColor: Colors.transparent,
        elevation: 0,
        type: BottomNavigationBarType.fixed,
        selectedItemColor: AppColors.primary,
        unselectedItemColor: AppColors.textSecondary,
        selectedLabelStyle: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
        unselectedLabelStyle: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w500,
        ),
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.receipt_long),
            activeIcon: Icon(Icons.receipt_long),
            label: 'Transaksi',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.bar_chart),
            activeIcon: Icon(Icons.bar_chart),
            label: 'Ringkasan',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            activeIcon: Icon(Icons.person),
            label: 'Profil',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings_outlined),
            activeIcon: Icon(Icons.settings),
            label: 'Pengaturan',
          ),
        ],
      ),
    );
  }

  /// Show add transaction form (called from center button)
  void _showAddTransactionForm(BuildContext context, WidgetRef ref) {
    // Reset form before navigating
    ref.read(transactionFormNotifierProvider.notifier).resetForm();

    // Navigate to form screen
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const TransactionFormScreen(),
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
class _ErrorScreen extends StatelessWidget {
  final String message;

  const _ErrorScreen({required this.message});

  @override
  Widget build(BuildContext context) {
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
                  // Attempt to restart the app
                  AppLogger.i('User requested app restart after error');
                  main();
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
