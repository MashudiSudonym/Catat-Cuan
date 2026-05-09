import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:catat_cuan/presentation/utils/utils.dart';
import 'package:catat_cuan/presentation/widgets/base/base.dart';
import 'package:catat_cuan/presentation/widgets/savings/circular_goal_progress.dart';
import 'package:catat_cuan/presentation/screens/savings/sheets/quick_add_contribution_sheet.dart';
import 'package:catat_cuan/presentation/providers/savings_goal/savings_goal_providers.dart';
import 'package:catat_cuan/presentation/navigation/routes/app_routes.dart';

class GoalHomeCard extends ConsumerWidget {
  const GoalHomeCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final progressAsync = ref.watch(overallProgressProvider);

    return progressAsync.when(
      data: (percentage) {
        if (percentage <= 0) return const SizedBox.shrink();

        final goalsAsync = ref.watch(savingsGoalsWithProgressProvider);
        double totalSaved = 0;
        double totalTarget = 0;

        goalsAsync.whenData((goals) {
          for (final g in goals) {
            totalSaved += g.goal.currentAmount;
            totalTarget += g.goal.targetAmount;
          }
        });

        return AppGlassContainer.glassCard(
          onTap: () => context.go(AppRoutes.savings),
          padding: AppSpacing.lgAll,
          child: Row(
            children: [
              CircularGoalProgress(
                percentage: percentage,
                size: 36,
                strokeWidth: 3,
                isDark: isDark,
              ),
              const AppSpacingWidget.horizontalMD(),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Tabungan',
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                    ),
                    const AppSpacingWidget.verticalXS(),
                    Text(
                      'Terkumpul: Rp ${CurrencyInputFormatter.formatRupiah(totalSaved.round())} / Target: Rp ${CurrencyInputFormatter.formatRupiah(totalTarget.round())}',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: isDark
                                ? AppColors.textOnDark.withValues(alpha: 0.6)
                                : AppColors.textSecondary,
                          ),
                    ),
                  ],
                ),
              ),
              IconButton(
                icon: const Icon(Icons.add_circle),
                tooltip: 'Tambah Setoran',
                color: AppColors.primary,
                onPressed: () {
                  showModalBottomSheet(
                    context: context,
                    isScrollControlled: false,
                    shape: const RoundedRectangleBorder(
                      borderRadius: BorderRadius.vertical(
                        top: Radius.circular(AppRadius.xxl),
                      ),
                    ),
                    builder: (context) => const QuickAddContributionSheet(),
                  );
                },
              ),
            ],
          ),
        );
      },
      loading: () => const SizedBox.shrink(),
      error: (_, __) => const SizedBox.shrink(),
    );
  }
}
