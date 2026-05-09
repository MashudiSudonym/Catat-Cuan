import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:confetti/confetti.dart';
import 'package:catat_cuan/domain/entities/savings_goal_with_progress_entity.dart';
import 'package:catat_cuan/domain/entities/goal_contribution_entity.dart';
import 'package:catat_cuan/presentation/utils/utils.dart';
import 'package:catat_cuan/presentation/utils/error/error_message_mapper.dart';
import 'package:catat_cuan/presentation/utils/logger/app_logger.dart';
import 'package:catat_cuan/presentation/widgets/base/base.dart';
import 'package:catat_cuan/presentation/widgets/savings/circular_goal_progress.dart';
import 'package:catat_cuan/presentation/widgets/savings/completion_badge.dart';
import 'package:catat_cuan/presentation/widgets/savings/contribution_list_item.dart';
import 'package:catat_cuan/presentation/providers/savings_goal/savings_goal_providers.dart';
import 'package:catat_cuan/presentation/providers/controllers/controller_providers.dart';
import 'package:catat_cuan/presentation/navigation/routes/app_routes.dart';

class SavingsGoalDetailScreen extends ConsumerStatefulWidget {
  const SavingsGoalDetailScreen({super.key, required this.goalId});

  final int goalId;

  @override
  ConsumerState<SavingsGoalDetailScreen> createState() => _SavingsGoalDetailScreenState();
}

class _SavingsGoalDetailScreenState extends ConsumerState<SavingsGoalDetailScreen> {
  late final ConfettiController _confettiController;
  bool _confettiPlayed = false;
  bool _wasLoadedAsCompleted = false;

  @override
  void initState() {
    super.initState();
    _confettiController = ConfettiController(duration: const Duration(seconds: 3));
  }

  @override
  void dispose() {
    _confettiController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final goalsAsync = ref.watch(savingsGoalsWithProgressProvider);
    final contributionsAsync = ref.watch(goalContributionsProvider(widget.goalId));

    return goalsAsync.when(
      data: (goals) {
        final goalWithProgress = goals.where(
          (g) => g.goal.id == widget.goalId,
        ).firstOrNull;

        if (goalWithProgress == null) {
          return Scaffold(
            appBar: AppBar(title: const Text('Detail Goal')),
            body: const Center(child: Text('Goal tidak ditemukan')),
          );
        }

        return _buildContent(context, goalWithProgress, contributionsAsync);
      },
      loading: () => Scaffold(
        appBar: AppBar(title: const Text('Detail Goal')),
        body: const Center(child: CircularProgressIndicator()),
      ),
      error: (error, _) => Scaffold(
        appBar: AppBar(title: const Text('Detail Goal')),
        body: Center(child: Text(ErrorMessageMapper.getUserMessage(error))),
      ),
    );
  }

  Widget _buildContent(
    BuildContext context,
    SavingsGoalWithProgressEntity goalWithProgress,
    AsyncValue<List<GoalContributionEntity>> contributionsAsync,
  ) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final goal = goalWithProgress.goal;
    final isCompleted = goalWithProgress.isCompleted;
    final remaining = goal.targetAmount - goal.currentAmount;

    if (isCompleted && !_confettiPlayed && !_wasLoadedAsCompleted) {
      _confettiPlayed = true;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _confettiController.play();
      });
    }
    if (isCompleted) _wasLoadedAsCompleted = true;

    return Stack(
      children: [
        Scaffold(
          appBar: AppBar(
            title: Text(goal.name),
            actions: [
              IconButton(
                icon: const Icon(Icons.edit_outlined),
                tooltip: 'Edit Goal',
                onPressed: () async {
                  final result = await context.push<bool>(
                    '${AppRoutes.savings}/edit/${goal.id}',
                  );
                  if (result == true) {
                    ref.invalidate(savingsGoalsWithProgressProvider);
                  }
                },
              ),
              if (!isCompleted)
                IconButton(
                  icon: const Icon(Icons.delete_outline),
                  tooltip: 'Batalkan Goal',
                  onPressed: () => _showDeleteConfirmation(context, goal.id!),
                ),
            ],
          ),
          body: RefreshIndicator(
            onRefresh: () async {
              ref.invalidate(savingsGoalsWithProgressProvider);
              ref.invalidate(goalContributionsProvider(widget.goalId));
            },
            child: ListView(
              padding: AppSpacing.lgAll,
              children: [
                _buildProgressSection(context, goalWithProgress, isDark, remaining),
                if (isCompleted)
                  _buildCompletionCard(context, isDark)
                else
                  _buildActionButtons(context),
                const AppSpacingWidget.verticalXL(),
                _buildContributionSection(context, contributionsAsync, isDark),
              ],
            ),
          ),
        ),
        Align(
          alignment: Alignment.bottomCenter,
          child: ConfettiWidget(
            confettiController: _confettiController,
            blastDirection: -pi / 2,
            blastDirectionality: BlastDirectionality.directional,
            maxBlastForce: 20,
            minBlastForce: 5,
            emissionFrequency: 0.05,
            numberOfParticles: 30,
            gravity: 0.3,
            colors: const [
              AppColors.primary,
              AppColors.success,
              AppColors.warning,
              AppColors.info,
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildProgressSection(
    BuildContext context,
    SavingsGoalWithProgressEntity goalWithProgress,
    bool isDark,
    double remaining,
  ) {
    final goal = goalWithProgress.goal;

    return AppGlassContainer.glassCard(
      padding: AppSpacing.xlAll,
      child: Column(
        children: [
          CircularGoalProgress(
            percentage: goalWithProgress.progressPercentage,
            size: 120,
            strokeWidth: 8,
            isDark: isDark,
          ),
          const AppSpacingWidget.verticalLG(),
          Text(
            'Target: Rp ${CurrencyInputFormatter.formatRupiah(goal.targetAmount.round())}',
            style: Theme.of(context).textTheme.displayMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const AppSpacingWidget.verticalSM(),
          Text(
            'Terkumpul: Rp ${CurrencyInputFormatter.formatRupiah(goal.currentAmount.round())}',
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: AppColors.getGoalProgressColor(
                    goalWithProgress.progressPercentage, isDark,
                  ),
                ),
          ),
          const AppSpacingWidget.verticalXS(),
          Text(
            goalWithProgress.isCompleted
                ? 'Selamat! Goal tercapai!'
                : 'Sisa: Rp ${CurrencyInputFormatter.formatRupiah(remaining.round())}',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: isDark
                      ? AppColors.textOnDark.withValues(alpha: 0.7)
                      : AppColors.textSecondary,
                ),
          ),
          if (goal.targetDate != null && !goalWithProgress.isCompleted) ...[
            const AppSpacingWidget.verticalXS(),
            Text(
              goalWithProgress.isOverdue
                  ? 'Lewat ${-goalWithProgress.daysRemaining!} hari'
                  : '${goalWithProgress.daysRemaining} hari lagi',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: goalWithProgress.isOverdue
                        ? AppColors.getExpenseColor(isDark)
                        : (isDark
                            ? AppColors.textOnDark.withValues(alpha: 0.5)
                            : AppColors.textTertiary),
                  ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildCompletionCard(BuildContext context, bool isDark) {
    return Padding(
      padding: AppSpacing.only(top: AppSpacing.lg),
      child: AppGlassContainer.glassCard(
        padding: AppSpacing.all(AppSpacing.lg),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.emoji_events, color: AppColors.success, size: 28),
            const AppSpacingWidget.horizontalMD(),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const CompletionBadge(),
                const AppSpacingWidget.verticalXS(),
                Text(
                  'Goal ini sudah tercapai',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: isDark
                            ? AppColors.textOnDark.withValues(alpha: 0.6)
                            : AppColors.textSecondary,
                      ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButtons(BuildContext context) {
    return Padding(
      padding: AppSpacing.only(top: AppSpacing.lg),
      child: Row(
        children: [
          Expanded(
            child: FilledButton.icon(
              onPressed: () => _showContributionForm(context),
              icon: const Icon(Icons.add, size: 18),
              label: const Text('Tambah Setoran'),
            ),
          ),
          const AppSpacingWidget.horizontalSM(),
          Expanded(
            child: OutlinedButton.icon(
              onPressed: () => _showWithdrawalForm(context),
              icon: const Icon(Icons.remove, size: 18),
              label: const Text('Tarik Dana'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContributionSection(
    BuildContext context,
    AsyncValue<List<GoalContributionEntity>> contributionsAsync,
    bool isDark,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Riwayat Setoran',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
        ),
        const AppSpacingWidget.verticalMD(),
        contributionsAsync.when(
          data: (contributions) {
            if (contributions.isEmpty) {
              return AppGlassContainer.glassCard(
                padding: AppSpacing.xxxlAll,
                child: Column(
                  children: [
                    Icon(
                      Icons.receipt_long_outlined,
                      size: 48,
                      color: isDark
                          ? AppColors.textOnDark.withValues(alpha: 0.3)
                          : AppColors.textTertiary,
                    ),
                    const AppSpacingWidget.verticalMD(),
                    Text(
                      'Belum ada riwayat',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: isDark
                                ? AppColors.textOnDark.withValues(alpha: 0.5)
                                : AppColors.textSecondary,
                          ),
                    ),
                  ],
                ),
              );
            }

            return Column(
              children: contributions.map((contribution) {
                return Padding(
                  padding: AppSpacing.only(bottom: AppSpacing.sm),
                  child: ContributionListItem(contribution: contribution),
                );
              }).toList(),
            );
          },
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, _) => Center(
            child: Text(ErrorMessageMapper.getUserMessage(error)),
          ),
        ),
      ],
    );
  }

  void _showContributionForm(BuildContext context) {
    final amountController = TextEditingController();
    final noteController = TextEditingController();

    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Tambah Setoran'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: amountController,
              keyboardType: TextInputType.number,
              inputFormatters: [CurrencyInputFormatter()],
              decoration: InputDecoration(
                labelText: 'Jumlah',
                hintText: 'Masukkan jumlah',
                prefixText: 'Rp ',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppRadius.md),
                ),
              ),
            ),
            const AppSpacingWidget.verticalMD(),
            TextField(
              controller: noteController,
              decoration: InputDecoration(
                labelText: 'Catatan (Opsional)',
                hintText: 'Tambahkan catatan',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppRadius.md),
                ),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('Batal'),
          ),
          FilledButton(
            onPressed: () async {
              final amount = CurrencyInputFormatter.parseRupiah(amountController.text);
              if (amount == null || amount <= 0) return;

              Navigator.of(dialogContext).pop();
              await _addContribution(amount.toDouble(), noteController.text.trim());
            },
            child: const Text('Tambah Setoran'),
          ),
        ],
      ),
    );
  }

  void _showWithdrawalForm(BuildContext context) {
    final amountController = TextEditingController();
    final reasonController = TextEditingController();

    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Tarik Dana'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: amountController,
              keyboardType: TextInputType.number,
              inputFormatters: [CurrencyInputFormatter()],
              decoration: InputDecoration(
                labelText: 'Jumlah',
                hintText: 'Masukkan jumlah',
                prefixText: 'Rp ',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppRadius.md),
                ),
              ),
            ),
            const AppSpacingWidget.verticalMD(),
            TextField(
              controller: reasonController,
              decoration: InputDecoration(
                labelText: 'Alasan Penarikan (Opsional)',
                hintText: 'Masukkan alasan penarikan',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppRadius.md),
                ),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('Batal'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: AppColors.getExpenseColor(false)),
            onPressed: () async {
              final amount = CurrencyInputFormatter.parseRupiah(amountController.text);
              if (amount == null || amount <= 0) return;

              Navigator.of(dialogContext).pop();
              await _withdraw(amount.toDouble(), reasonController.text.trim());
            },
            child: const Text('Tarik'),
          ),
        ],
      ),
    );
  }

  Future<void> _addContribution(double amount, String note) async {
    try {
      final controller = ref.read(savingsGoalContributionControllerProvider);
      final result = await controller.addContribution(
        goalId: widget.goalId,
        amount: amount,
        note: note.isNotEmpty ? note : null,
      );

      if (!mounted) return;

      if (result.isSuccess) {
        final data = result.data;
        if (data != null && data.isGoalCompleted && !_confettiPlayed) {
          _confettiPlayed = true;
          _confettiController.play();
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Selamat! Goal tercapai!'),
              backgroundColor: AppColors.success,
              duration: Duration(seconds: 3),
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Setoran berhasil ditambahkan'),
              backgroundColor: AppColors.success,
            ),
          );
        }
        ref.invalidate(savingsGoalsWithProgressProvider);
        ref.invalidate(goalContributionsProvider(widget.goalId));
      } else {
        final userMessage = ErrorMessageMapper.getUserMessage(result.failure);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(userMessage), backgroundColor: AppColors.error),
        );
      }
    } catch (e, stackTrace) {
      AppLogger.e('SavingsGoalDetail: Error adding contribution', e, stackTrace);
      if (mounted) {
        final userMessage = ErrorMessageMapper.getUserMessage(e);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(userMessage), backgroundColor: AppColors.error),
        );
      }
    }
  }

  Future<void> _withdraw(double amount, String reason) async {
    try {
      final controller = ref.read(savingsGoalContributionControllerProvider);
      final result = await controller.withdrawFromGoal(
        goalId: widget.goalId,
        amount: amount,
        reason: reason.isNotEmpty ? reason : null,
      );

      if (!mounted) return;

      if (result.isSuccess) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Penarikan berhasil dicatat'),
            backgroundColor: AppColors.success,
          ),
        );
        ref.invalidate(savingsGoalsWithProgressProvider);
        ref.invalidate(goalContributionsProvider(widget.goalId));
      } else {
        final userMessage = ErrorMessageMapper.getUserMessage(result.failure);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(userMessage), backgroundColor: AppColors.error),
        );
      }
    } catch (e, stackTrace) {
      AppLogger.e('SavingsGoalDetail: Error withdrawing', e, stackTrace);
      if (mounted) {
        final userMessage = ErrorMessageMapper.getUserMessage(e);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(userMessage), backgroundColor: AppColors.error),
        );
      }
    }
  }

  void _showDeleteConfirmation(BuildContext context, int goalId) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Batalkan Goal'),
        content: const Text(
          'Apakah Anda yakin ingin membatalkan goal ini? Riwayat setoran tetap tersimpan.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('Batal'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: AppColors.getExpenseColor(false)),
            onPressed: () async {
              Navigator.of(dialogContext).pop();
              await _deleteGoal(goalId);
            },
            child: const Text('Batalkan Goal'),
          ),
        ],
      ),
    );
  }

  Future<void> _deleteGoal(int goalId) async {
    try {
      final controller = ref.read(savingsGoalFormControllerProvider);
      final result = await controller.deleteGoal(goalId);

      if (!mounted) return;

      if (result.isSuccess) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Goal dibatalkan'),
            backgroundColor: AppColors.success,
          ),
        );
        context.pop(true);
      } else {
        final userMessage = ErrorMessageMapper.getUserMessage(result.failure);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(userMessage), backgroundColor: AppColors.error),
        );
      }
    } catch (e, stackTrace) {
      AppLogger.e('SavingsGoalDetail: Error deleting goal', e, stackTrace);
      if (mounted) {
        final userMessage = ErrorMessageMapper.getUserMessage(e);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(userMessage), backgroundColor: AppColors.error),
        );
      }
    }
  }
}
