import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:catat_cuan/domain/entities/transaction_entity.dart';
import 'package:catat_cuan/presentation/providers/app_providers.dart';
import 'package:catat_cuan/presentation/services/user_tracking_level_service.dart';
import 'package:catat_cuan/presentation/widgets/base/base.dart';
import 'package:catat_cuan/presentation/utils/utils.dart';

/// Mock user data for profile screen
class MockUserData {
  final String fullName;
  final String username;
  final String email;
  final String phone;
  final String location;
  final DateTime memberSince;

  const MockUserData({
    required this.fullName,
    required this.username,
    required this.email,
    required this.phone,
    required this.location,
    required this.memberSince,
  });
}

/// Profile screen for user information and financial summary
class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  // Mock user data
  static final _mockUser = MockUserData(
    fullName: 'Budi Santoso',
    username: '@budisantoso',
    email: 'budi.santoso@email.com',
    phone: '+62 812-3456-7890',
    location: 'Jakarta, Indonesia',
    memberSince: MockUserDateProvider.january2024,
  );

  // Service instance for calculating tracking level
  static const _trackingService = UserTrackingLevelService();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profil'),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit_outlined),
            onPressed: () => _showEditProfileSheet(context),
            tooltip: 'Edit Profil',
          ),
        ],
      ),
      body: ListView(
        children: [
          const SizedBox(height: AppSpacing.lg),

          // User Info Card with dynamic quote
          Consumer(
            builder: (context, ref, child) {
              final transactionsAsync = ref.watch(transactionListNotifierProvider);

              return transactionsAsync.when(
                loading: () => _buildUserInfoCard(context, _mockUser, null),
                error: (error, stack) => _buildUserInfoCard(context, _mockUser, null),
                data: (transactions) => _buildUserInfoCard(context, _mockUser, transactions),
              );
            },
          ),

          const SizedBox(height: AppSpacing.md),

          // Quick Financial Summary
          _buildSectionHeader('Ringkasan Keuangan'),

          Consumer(
            builder: (context, ref, child) {
              final transactionsAsync = ref.watch(transactionListNotifierProvider);

              return transactionsAsync.when(
                loading: () => _buildFinancialLoadingSkeleton(context),
                error: (error, stack) => _buildFinancialError(context, error.toString()),
                data: (transactions) => _buildQuickFinancialSummary(context, ref, transactions),
              );
            },
          ),

          const SizedBox(height: AppSpacing.md),

          // Personal Details Section
          _buildSectionHeader('Informasi Pribadi'),

          _buildPersonalDetailsCard(context, _mockUser),

          const SizedBox(height: AppSpacing.xxxl),
        ],
      ),
    );
  }

  /// Build user info card with avatar and dynamic quote based on tracking habits
  Widget _buildUserInfoCard(
    BuildContext context,
    MockUserData user,
    List<TransactionEntity>? transactions,
  ) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // Calculate tracking level and get category info
    final category = transactions != null
        ? _trackingService.getCategoryFromTransactions(transactions)
        : const UserTrackingCategory(
            title: 'Pemula',
            quote: 'Siap memulai perjalanan keuangan yang hebat 💪',
            emoji: '🌱',
            colorType: ColorType.grey,
          );

    final levelColor = category.colorType.toColor();

    return AppGlassContainer.glassCard(
      margin: AppSpacing.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.sm),
      child: Column(
        children: [
          const SizedBox(height: AppSpacing.lg),

          // Avatar with edit indicator
          Stack(
            children: [
              CircleAvatar(
                radius: AppSpacing.xxxl,
                backgroundColor: AppColors.primary.withValues(alpha: 0.15),
                child: Icon(
                  Icons.person,
                  size: AppSpacing.xxxl,
                  color: AppColors.primary,
                ),
              ),
              Positioned(
                bottom: 0,
                right: 0,
                child: Container(
                  padding: AppSpacing.all(AppSpacing.xs),
                  decoration: BoxDecoration(
                    color: levelColor,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: isDark ? Colors.black : Colors.white,
                      width: 2,
                    ),
                  ),
                  child: Text(
                    category.emoji,
                    style: const TextStyle(fontSize: 12),
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: AppSpacing.lg),

          // Full Name
          Text(
            user.fullName,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),

          const SizedBox(height: AppSpacing.xs),

          // Username with tracking level badge
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                user.username,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppColors.textSecondary,
                      fontWeight: FontWeight.w500,
                    ),
              ),
              const SizedBox(width: AppSpacing.sm),
              // Tracking level badge
              AppGlassContainer.glassPill(
                padding: AppSpacing.symmetric(horizontal: AppSpacing.sm, vertical: AppSpacing.xs),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      category.emoji,
                      style: const TextStyle(fontSize: 10),
                    ),
                    const AppSpacingWidget.horizontalXS(),
                    Text(
                      category.title,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: levelColor,
                            fontWeight: FontWeight.w600,
                            fontSize: 10,
                          ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: AppSpacing.md),

          // Dynamic quote based on tracking habits
          AppGlassContainer.subtle(
            margin: AppSpacing.symmetric(horizontal: AppSpacing.lg),
            padding: AppSpacing.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.sm),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.format_quote,
                  size: 16,
                  color: levelColor.withValues(alpha: 0.7),
                ),
                const SizedBox(width: AppSpacing.xs),
                Flexible(
                  child: Text(
                    category.quote,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppColors.textSecondary,
                          fontStyle: FontStyle.italic,
                        ),
                    textAlign: TextAlign.center,
                  ),
                ),
                Icon(
                  Icons.format_quote,
                  size: 16,
                  color: levelColor.withValues(alpha: 0.7),
                ),
              ],
            ),
          ),

          const SizedBox(height: AppSpacing.md),

          // Member Since Badge
          AppGlassContainer.glassPill(
            padding: AppSpacing.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.xs),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.calendar_today_outlined,
                  size: 14,
                  color: AppColors.textSecondary,
                ),
                const SizedBox(width: AppSpacing.xs),
                Text(
                  'Bergabung sejak ${AppDateFormatter.formatMonthYearDate(user.memberSince)}',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppColors.textSecondary,
                      ),
                ),
              ],
            ),
          ),

          const SizedBox(height: AppSpacing.lg),
        ],
      ),
    );
  }

  /// Build quick financial summary with stat cards
  Widget _buildQuickFinancialSummary(BuildContext context, WidgetRef ref, List<TransactionEntity> transactions) {
    if (transactions.isEmpty) {
      return AppGlassContainer.glassCard(
        margin: AppSpacing.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.sm),
        child: Padding(
          padding: AppSpacing.all(AppSpacing.xl),
          child: Column(
            children: [
              Icon(
                Icons.account_balance_wallet_outlined,
                size: 48,
                color: AppColors.textSecondary.withValues(alpha: 0.5),
              ),
              const SizedBox(height: AppSpacing.md),
              Text(
                'Belum ada data transaksi',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppColors.textSecondary,
                    ),
              ),
            ],
          ),
        ),
      );
    }

    // Calculate metrics
    final totalIncome = transactions
        .where((t) => t.type == TransactionType.income)
        .fold<double>(0, (sum, t) => sum + t.amount);

    final totalExpense = transactions
        .where((t) => t.type == TransactionType.expense)
        .fold<double>(0, (sum, t) => sum + t.amount);

    final balance = totalIncome - totalExpense;
    final transactionCount = transactions.length;

    // Current month stats
    final now = DateTime.now();
    final currentMonthTransactions = transactions.where((t) {
      return t.dateTime.year == now.year && t.dateTime.month == now.month;
    }).toList();

    final monthIncome = currentMonthTransactions
        .where((t) => t.type == TransactionType.income)
        .fold<double>(0, (sum, t) => sum + t.amount);

    final monthExpense = currentMonthTransactions
        .where((t) => t.type == TransactionType.expense)
        .fold<double>(0, (sum, t) => sum + t.amount);

    return Padding(
      padding: AppSpacing.symmetric(horizontal: AppSpacing.md),
      child: Column(
        children: [
          // Balance Card - Main Highlight
          AppGlassContainer.glassCard(
            child: Container(
              width: double.infinity,
              padding: AppSpacing.all(AppSpacing.lg),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: AppSpacing.all(AppSpacing.sm),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withValues(alpha: 0.15),
                          borderRadius: AppRadius.smAll,
                        ),
                        child: Icon(
                          Icons.account_balance_wallet,
                          size: 20,
                          color: AppColors.primary,
                        ),
                      ),
                      const SizedBox(width: AppSpacing.md),
                      Text(
                        'Saldo Total',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: AppColors.textSecondary,
                            ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  Text(
                    balance.toCurrency(ref: ref),
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: balance >= 0 ? AppColors.primary : AppColors.error,
                        ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: AppSpacing.sm),

          // Quick Stats Grid
          Row(
            children: [
              // Income Card
              Expanded(
                child: _buildQuickStatCard(
                  context,
                  icon: Icons.arrow_downward,
                  iconColor: AppColors.success,
                  label: 'Pemasukan',
                  value: monthIncome.toCurrency(ref: ref),
                  subtitle: 'Bulan ini',
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              // Expense Card
              Expanded(
                child: _buildQuickStatCard(
                  context,
                  icon: Icons.arrow_upward,
                  iconColor: AppColors.expense,
                  label: 'Pengeluaran',
                  value: monthExpense.toCurrency(ref: ref),
                  subtitle: 'Bulan ini',
                ),
              ),
            ],
          ),

          const SizedBox(height: AppSpacing.sm),

          Row(
            children: [
              // Transaction Count Card
              Expanded(
                child: _buildQuickStatCard(
                  context,
                  icon: Icons.receipt_long,
                  iconColor: AppColors.primary,
                  label: 'Transaksi',
                  value: '$transactionCount',
                  subtitle: 'Total',
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              // Savings Rate Card
              Expanded(
                child: _buildQuickStatCard(
                  context,
                  icon: Icons.savings,
                  iconColor: monthIncome > 0 && (monthIncome - monthExpense) / monthIncome >= 0.2
                      ? AppColors.success
                      : AppColors.textSecondary,
                  label: 'Tabungan',
                  value: monthIncome > 0
                      ? '${((monthIncome - monthExpense) / monthIncome * 100).toStringAsFixed(0)}%'
                      : '-',
                  subtitle: 'Dari pemasukan',
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// Build a quick stat card
  Widget _buildQuickStatCard(
    BuildContext context, {
    required IconData icon,
    required Color iconColor,
    required String label,
    required String value,
    required String subtitle,
  }) {
    return AppGlassContainer.glassCard(
      padding: AppSpacing.all(AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 16, color: iconColor),
              const SizedBox(width: AppSpacing.xs),
              Expanded(
                child: Text(
                  label,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppColors.textSecondary,
                      ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            value,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
            overflow: TextOverflow.ellipsis,
          ),
          Text(
            subtitle,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppColors.textSecondary.withValues(alpha: 0.7),
                  fontSize: 10,
                ),
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  /// Build personal details card
  Widget _buildPersonalDetailsCard(BuildContext context, MockUserData user) {
    return AppGlassContainer.glassCard(
      margin: AppSpacing.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.sm),
      child: Column(
        children: [
          _buildDetailTile(
            context,
            icon: Icons.email_outlined,
            label: 'Email',
            value: user.email,
          ),
          const Divider(height: 1),
          _buildDetailTile(
            context,
            icon: Icons.phone_outlined,
            label: 'Telepon',
            value: user.phone,
          ),
          const Divider(height: 1),
          _buildDetailTile(
            context,
            icon: Icons.location_on_outlined,
            label: 'Lokasi',
            value: user.location,
          ),
          const Divider(height: 1),
          _buildDetailTile(
            context,
            icon: Icons.calendar_today_outlined,
            label: 'Bergabung Sejak',
            value: AppDateFormatter.formatDayMonthYearDate(user.memberSince),
          ),
        ],
      ),
    );
  }

  /// Build a detail tile for personal info
  Widget _buildDetailTile(
    BuildContext context, {
    required IconData icon,
    required String label,
    required String value,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return ListTile(
      contentPadding: AppSpacing.symmetric(horizontal: AppSpacing.lg, vertical: AppSpacing.sm),
      leading: Icon(
        icon,
        color: isDark ? Colors.white70 : Colors.grey.shade600,
        size: 20,
      ),
      title: Text(
        label,
        style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: AppColors.textSecondary,
            ),
      ),
      subtitle: Text(
        value,
        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w500,
            ),
      ),
    );
  }

  /// Build loading skeleton for financial summary
  Widget _buildFinancialLoadingSkeleton(BuildContext context) {
    return Padding(
      padding: AppSpacing.symmetric(horizontal: AppSpacing.md),
      child: Column(
        children: [
          // Balance skeleton
          AppGlassContainer.glassCard(
            child: Container(
              width: double.infinity,
              height: 80,
              padding: AppSpacing.all(AppSpacing.lg),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 120,
                    height: 14,
                    decoration: BoxDecoration(
                      color: AppColors.textSecondary.withValues(alpha: 0.1),
                      borderRadius: AppRadius.xsAll,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  Container(
                    width: 180,
                    height: 28,
                    decoration: BoxDecoration(
                      color: AppColors.textSecondary.withValues(alpha: 0.1),
                      borderRadius: AppRadius.xsAll,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          // Stats grid skeleton
          Row(
            children: List.generate(2, (index) => Expanded(
              child: Container(
                height: 70,
                margin: AppSpacing.only(right: index == 0 ? AppSpacing.sm : 0),
                decoration: BoxDecoration(
                  color: AppColors.textSecondary.withValues(alpha: 0.05),
                  borderRadius: AppRadius.mdAll,
                ),
              ),
            )),
          ),
        ],
      ),
    );
  }

  /// Build error state for financial summary
  Widget _buildFinancialError(BuildContext context, String error) {
    return AppGlassContainer.glassCard(
      margin: AppSpacing.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.sm),
      child: Padding(
        padding: AppSpacing.all(AppSpacing.lg),
        child: Row(
          children: [
            Icon(
              Icons.error_outline,
              color: AppColors.error,
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Text(
                'Gagal memuat data keuangan',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppColors.error,
                    ),
              ),
            ),
          ],
        ),
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

  /// Show edit profile bottom sheet (mock)
  void _showEditProfileSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _EditProfileSheet(user: _mockUser),
    );
  }
}

/// Mock date provider for user data
class MockUserDateProvider {
  static final january2024 = DateTime(2024, 1, 15);
}

/// Edit profile bottom sheet (mock)
class _EditProfileSheet extends StatelessWidget {
  final MockUserData user;

  const _EditProfileSheet({required this.user});

  @override
  Widget build(BuildContext context) {
    return AppGlassContainer.glassSurface(
      margin: AppSpacing.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.xl),
      borderRadius: BorderRadius.only(
        topLeft: Radius.circular(AppSpacing.xl),
        topRight: Radius.circular(AppSpacing.xl),
      ),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Handle bar
            Container(
              width: 40,
              height: 4,
              margin: AppSpacing.symmetric(vertical: AppSpacing.md),
              decoration: BoxDecoration(
                color: AppColors.textSecondary.withValues(alpha: 0.3),
                borderRadius: AppRadius.xsAll,
              ),
            ),

            // Header
            Padding(
              padding: AppSpacing.symmetric(horizontal: AppSpacing.lg),
              child: Row(
                children: [
                  Text(
                    'Edit Profil',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const Spacer(),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
            ),

            const Divider(height: 1),

            // Mock form fields
            ListView(
              shrinkWrap: true,
              padding: AppSpacing.all(AppSpacing.lg),
              children: [
                _buildMockField(
                  context,
                  label: 'Nama Lengkap',
                  value: user.fullName,
                ),
                _buildMockField(
                  context,
                  label: 'Username',
                  value: user.username,
                ),
                _buildMockField(
                  context,
                  label: 'Email',
                  value: user.email,
                ),
                _buildMockField(
                  context,
                  label: 'Telepon',
                  value: user.phone,
                ),
                _buildMockField(
                  context,
                  label: 'Lokasi',
                  value: user.location,
                ),

                const SizedBox(height: AppSpacing.lg),

                // Save button (mock)
                SizedBox(
                  width: double.infinity,
                  child: AppGlassContainer.glassPill(
                    padding: AppSpacing.all(AppSpacing.md),
                    child: Text(
                      'Simpan Perubahan',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            color: AppColors.primary,
                            fontWeight: FontWeight.w600,
                          ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMockField(
    BuildContext context, {
    required String label,
    required String value,
    int maxLines = 1,
  }) {
    return Padding(
      padding: AppSpacing.only(bottom: AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppColors.textSecondary,
                  fontWeight: FontWeight.w500,
                ),
          ),
          const SizedBox(height: AppSpacing.xs),
          AppGlassContainer.subtle(
            padding: AppSpacing.all(AppSpacing.md),
            child: Text(
              value,
              style: Theme.of(context).textTheme.bodyMedium,
              maxLines: maxLines,
            ),
          ),
        ],
      ),
    );
  }
}
