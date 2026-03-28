import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:catat_cuan/presentation/screens/onboarding_screen.dart';
import 'package:catat_cuan/presentation/screens/transaction_list_screen.dart';
import 'package:catat_cuan/presentation/screens/monthly_summary_screen.dart';
import 'package:catat_cuan/presentation/screens/transaction_form_screen.dart';
import 'package:catat_cuan/presentation/screens/category_form_screen.dart';
import 'package:catat_cuan/presentation/screens/settings_screen.dart';
import 'package:catat_cuan/presentation/screens/scan_receipt_screen.dart';
import 'package:catat_cuan/presentation/screens/category_management_screen.dart';
import 'package:catat_cuan/presentation/providers/app_providers.dart';
import 'package:catat_cuan/presentation/widgets/base/base.dart';
import 'package:catat_cuan/presentation/utils/utils.dart';
import 'package:catat_cuan/presentation/navigation/routes/app_routes.dart';

/// Navigator keys for shell routes
/// Following SRP: Separate keys for root and shell navigation
/// Public so other widgets (e.g., export bottom sheet) can use it for stable context access
final rootNavigatorKey = GlobalKey<NavigatorState>();

/// Create GoRouter configuration with Riverpod integration
/// Following SOLID principles:
/// - SRP: Single responsibility for router configuration
/// - DIP: Depends on Ref abstraction, not concrete implementations
GoRouter createGoRouter(Ref ref) {
  return GoRouter(
    navigatorKey: rootNavigatorKey,
    debugLogDiagnostics: true,
    initialLocation: AppRoutes.transactions,
    redirect: (context, state) {
      // Watch category seeding state for reactive redirects
      final seedingState = ref.read(categorySeedingProvider);

      // Check if categories exist (determines if onboarding is needed)
      if (seedingState.hasValue || seedingState.isLoading) {
        final categoriesExist = seedingState.value ?? false;

        // If trying to access onboarding route
        if (state.matchedLocation == AppRoutes.onboarding) {
          // If categories already exist, redirect to home
          if (categoriesExist) {
            return AppRoutes.transactions;
          }
          return null; // Show onboarding
        }

        // If trying to access other routes without categories (need onboarding)
        if (!categoriesExist && state.matchedLocation != AppRoutes.onboarding) {
          return AppRoutes.onboarding;
        }
      }

      return null; // No redirect needed
    },
    routes: [
      // Onboarding route (standalone)
      GoRoute(
        path: AppRoutes.onboarding,
        pageBuilder: (context, state) => MaterialPage(
          key: state.pageKey,
          child: const OnboardingScreen(),
        ),
      ),

      // StatefulShellRoute for bottom navigation
      // This preserves tab state when switching between tabs
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) {
          return HomeNavigationShell(navigationShell: navigationShell);
        },
        branches: [
          // Branch 1: Transactions tab
          StatefulShellBranch(
            routes: [
              // Transactions list (tab route)
              GoRoute(
                path: AppRoutes.transactions,
                pageBuilder: (context, state) => const NoTransitionPage(
                  child: TransactionListScreen(),
                ),
                routes: [
                  // Add transaction (full-screen, uses parentNavigatorKey)
                  GoRoute(
                    path: 'add',
                    parentNavigatorKey: rootNavigatorKey,
                    pageBuilder: (context, state) => MaterialPage(
                      key: state.pageKey,
                      child: const TransactionFormScreen(),
                    ),
                  ),
                  // Edit transaction (full-screen, uses parentNavigatorKey)
                  GoRoute(
                    path: 'edit/:id',
                    parentNavigatorKey: rootNavigatorKey,
                    pageBuilder: (context, state) {
                      final transactionId = int.parse(state.pathParameters['id']!);
                      return MaterialPage(
                        key: state.pageKey,
                        child: TransactionFormScreen(
                          transactionId: transactionId,
                        ),
                      );
                    },
                  ),
                  // Scan receipt (full-screen, uses parentNavigatorKey)
                  GoRoute(
                    path: 'scan',
                    parentNavigatorKey: rootNavigatorKey,
                    pageBuilder: (context, state) => MaterialPage(
                      key: state.pageKey,
                      child: const ScanReceiptScreen(),
                    ),
                  ),
                ],
              ),
            ],
          ),

          // Branch 2: Summary tab
          StatefulShellBranch(
            routes: [
              // Monthly summary (tab route)
              GoRoute(
                path: AppRoutes.summary,
                pageBuilder: (context, state) => const NoTransitionPage(
                  child: MonthlySummaryScreen(),
                ),
                routes: [
                  // Category management (full-screen, uses parentNavigatorKey)
                  GoRoute(
                    path: 'categories',
                    parentNavigatorKey: rootNavigatorKey,
                    pageBuilder: (context, state) => MaterialPage(
                      key: state.pageKey,
                      child: const CategoryManagementScreen(),
                    ),
                    routes: [
                      // Add category
                      GoRoute(
                        path: 'add',
                        parentNavigatorKey: rootNavigatorKey,
                        pageBuilder: (context, state) => MaterialPage(
                          key: state.pageKey,
                          child: const CategoryFormScreen(),
                        ),
                      ),
                      // Edit category
                      GoRoute(
                        path: 'edit/:id',
                        parentNavigatorKey: rootNavigatorKey,
                        pageBuilder: (context, state) {
                          final categoryId = int.parse(state.pathParameters['id']!);
                          return MaterialPage(
                            key: state.pageKey,
                            child: CategoryFormScreen(
                              categoryId: categoryId,
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ],
      ),

      // Settings route (can be accessed from any tab)
      GoRoute(
        path: AppRoutes.settings,
        parentNavigatorKey: rootNavigatorKey,
        pageBuilder: (context, state) => MaterialPage(
          key: state.pageKey,
          child: const SettingsScreen(),
        ),
      ),
    ],
  );
}

/// Home Navigation Shell for StatefulShellRoute
/// Following SRP: Manages bottom navigation UI and branch switching
class HomeNavigationShell extends ConsumerWidget {
  final StatefulNavigationShell navigationShell;

  const HomeNavigationShell({
    super.key,
    required this.navigationShell,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      body: navigationShell,
      floatingActionButton: _buildSeamlessFab(context),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: _buildSeamlessBottomNav(),
    );
  }

  /// Build seamless glassmorphism FAB for adding transactions
  Widget _buildSeamlessFab(BuildContext context) {
    return SeamlessGlassFab(
      icon: Icons.add,
      tooltip: 'Tambah Transaksi',
      size: SeamlessFabSize.large,
      onPressed: () => context.push(AppRoutes.addTransaction),
    );
  }

  /// Build seamless bottom navigation with glassmorphism
  Widget _buildSeamlessBottomNav() {
    return AppGlassNavigation(
      showTopBorder: true,
      child: BottomNavigationBar(
        currentIndex: navigationShell.currentIndex,
        onTap: (index) => navigationShell.goBranch(index),
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
        ],
      ),
    );
  }
}
