import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:catat_cuan/presentation/providers/app_providers.dart';
import 'package:catat_cuan/presentation/screens/transaction_list_screen.dart';
import 'package:catat_cuan/presentation/screens/monthly_summary_screen.dart';
import 'package:catat_cuan/presentation/screens/transaction_form_screen.dart';
import 'package:catat_cuan/presentation/widgets/base/base.dart';
import 'package:catat_cuan/presentation/utils/utils.dart';

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
