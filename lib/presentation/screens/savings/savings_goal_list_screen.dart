import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:catat_cuan/presentation/utils/utils.dart';
import 'package:catat_cuan/presentation/utils/error/error_message_mapper.dart';
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
            return AppEmptyState(
              icon: Icons.savings,
              title: 'Belum ada tabungan',
              subtitle: 'Buat goal tabungan untuk mulai menabung',
              actionLabel: 'Buat Goal',
              onAction: () => context.push('${AppRoutes.savings}/add'),
            );
          }

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
                    onTap: () => context.push('${AppRoutes.savings}/detail/${goalWithProgress.goal.id}'),
                  ),
                );
              },
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(
          child: Text(ErrorMessageMapper.getUserMessage(error)),
        ),
      ),
    );
  }
}
