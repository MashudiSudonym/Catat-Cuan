import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:catat_cuan/presentation/utils/utils.dart';
import 'package:catat_cuan/presentation/utils/error/error_message_mapper.dart';
import 'package:catat_cuan/presentation/utils/logger/app_logger.dart';
import 'package:catat_cuan/presentation/providers/savings_goal/savings_goal_providers.dart';
import 'package:catat_cuan/presentation/widgets/base/base.dart';
import 'package:catat_cuan/presentation/widgets/savings/savings_goal_card.dart';
import 'package:catat_cuan/presentation/navigation/routes/app_routes.dart';
import 'package:go_router/go_router.dart';

class SavingsGoalListScreen extends ConsumerWidget {
  const SavingsGoalListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final goalsAsync = ref.watch(savingsGoalsWithProgressProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Tabungan'),
      ),
      body: goalsAsync.when(
        data: (goals) {
          if (goals.isEmpty) {
            return _buildEmptyState(context);
          }
          return _buildGoalList(context, ref, goals);
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => _buildErrorState(context, ref, error),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return AppEmptyState(
      icon: Icons.savings,
      title: 'Belum ada tabungan',
      subtitle: 'Buat goal tabungan untuk mulai menabung',
      actionLabel: 'Buat Goal',
      onAction: () => context.push('${AppRoutes.savings}/add'),
    );
  }

  Widget _buildGoalList(BuildContext context, WidgetRef ref, List goals) {
    return RefreshIndicator(
      onRefresh: () async {
        ref.invalidate(savingsGoalsWithProgressProvider);
      },
      child: ListView.builder(
        padding: AppSpacing.only(
          left: AppSpacing.lg,
          right: AppSpacing.lg,
          top: AppSpacing.sm,
          bottom: AppSpacing.xxxl,
        ),
        itemCount: goals.length,
        itemBuilder: (context, index) {
          final goalWithProgress = goals[index];
          return Padding(
            padding: AppSpacing.only(bottom: AppSpacing.sm),
            child: SavingsGoalCard(
              goalWithProgress: goalWithProgress,
              onTap: () => context.push(
                '${AppRoutes.savings}/detail/${goalWithProgress.goal.id}',
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildErrorState(BuildContext context, WidgetRef ref, dynamic error) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    AppLogger.e('SavingsGoalList: Error loading goals: $error');
    final userMessage = ErrorMessageMapper.getUserMessage(error);

    return Center(
      child: Padding(
        padding: AppSpacing.xxxlAll,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            AppGlassContainer.glassPill(
              width: 80,
              height: 80,
              padding: EdgeInsets.zero,
              alignment: Alignment.center,
              child: const Icon(
                Icons.error_outline,
                size: 40,
                color: AppColors.error,
              ),
            ),
            const AppSpacingWidget.verticalXL(),
            Text(
              'Terjadi Kesalahan',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const AppSpacingWidget.verticalSM(),
            Text(
              userMessage,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: isDark
                        ? AppColors.textOnDark.withValues(alpha: 0.7)
                        : AppColors.textTertiary,
                  ),
            ),
            const AppSpacingWidget.verticalLG(),
            ElevatedButton.icon(
              onPressed: () => ref.invalidate(savingsGoalsWithProgressProvider),
              icon: const Icon(Icons.refresh),
              label: const Text('Coba Lagi'),
            ),
          ],
        ),
      ),
    );
  }
}
