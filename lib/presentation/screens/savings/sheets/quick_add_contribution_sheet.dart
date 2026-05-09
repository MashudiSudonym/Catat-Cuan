import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:catat_cuan/domain/entities/savings_goal_with_progress_entity.dart';
import 'package:catat_cuan/presentation/utils/utils.dart';
import 'package:catat_cuan/presentation/utils/error/error_message_mapper.dart';
import 'package:catat_cuan/presentation/utils/logger/app_logger.dart';
import 'package:catat_cuan/presentation/widgets/savings/circular_goal_progress.dart';
import 'package:catat_cuan/presentation/providers/savings_goal/savings_goal_providers.dart';
import 'package:catat_cuan/presentation/providers/controllers/controller_providers.dart';

class QuickAddContributionSheet extends ConsumerStatefulWidget {
  const QuickAddContributionSheet({super.key});

  @override
  ConsumerState<QuickAddContributionSheet> createState() => _QuickAddContributionSheetState();
}

class _QuickAddContributionSheetState extends ConsumerState<QuickAddContributionSheet> {
  final _amountController = TextEditingController();
  int? _selectedGoalId;
  bool _isSubmitting = false;

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final goalsAsync = ref.watch(savingsGoalsWithProgressProvider);

    return Container(
      decoration: BoxDecoration(
        color: AppColors.getGlassOverlay(isDark: isDark),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(AppRadius.xxl)),
      ),
      padding: EdgeInsets.only(
        left: AppSpacing.lg,
        right: AppSpacing.lg,
        top: AppSpacing.lg,
        bottom: MediaQuery.of(context).viewInsets.bottom + AppSpacing.lg,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: isDark
                    ? AppColors.textOnDark.withValues(alpha: 0.3)
                    : AppColors.textTertiary.withValues(alpha: 0.5),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const AppSpacingWidget.verticalLG(),
          Text(
            'Tambah Setoran',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
          ),
          const AppSpacingWidget.verticalLG(),
          goalsAsync.when(
            data: (goals) {
              final activeGoals = goals.where((g) => !g.isCompleted).toList();
              if (activeGoals.isEmpty) {
                return const Padding(
                  padding: AppSpacing.xxlAll,
                  child: Text('Tidak ada goal aktif', textAlign: TextAlign.center),
                );
              }

              _selectedGoalId ??= activeGoals.first.goal.id;

              return Column(
                children: [
                  _buildGoalSelector(activeGoals, isDark),
                  const AppSpacingWidget.verticalLG(),
                  _buildAmountField(),
                  const AppSpacingWidget.verticalLG(),
                  _buildSubmitButton(),
                ],
              );
            },
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (error, _) => Padding(
              padding: AppSpacing.xxlAll,
              child: Text(ErrorMessageMapper.getUserMessage(error), textAlign: TextAlign.center),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGoalSelector(List<SavingsGoalWithProgressEntity> goals, bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Pilih Goal',
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: AppColors.textSecondary,
              ),
        ),
        const AppSpacingWidget.verticalXS(),
        DropdownButtonFormField<int>(
          initialValue: _selectedGoalId,
          decoration: InputDecoration(
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppRadius.md),
            ),
            contentPadding: AppSpacing.symmetric(
              horizontal: AppSpacing.lg,
              vertical: AppSpacing.md,
            ),
          ),
          items: goals.map((goalWithProgress) {
            final goal = goalWithProgress.goal;
            return DropdownMenuItem<int>(
              value: goal.id,
              child: Row(
                children: [
                  CircularGoalProgress(
                    percentage: goalWithProgress.progressPercentage,
                    size: 24,
                    strokeWidth: 2,
                    showCenterText: false,
                    isDark: isDark,
                  ),
                  const AppSpacingWidget.horizontalSM(),
                  Expanded(
                    child: Text(
                      goal.name,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
          onChanged: (value) {
            setState(() => _selectedGoalId = value);
          },
        ),
      ],
    );
  }

  Widget _buildAmountField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Jumlah Setoran',
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: AppColors.textSecondary,
              ),
        ),
        const AppSpacingWidget.verticalXS(),
        TextFormField(
          controller: _amountController,
          keyboardType: TextInputType.number,
          inputFormatters: [CurrencyInputFormatter()],
          decoration: InputDecoration(
            hintText: 'Masukkan jumlah',
            prefixText: 'Rp ',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppRadius.md),
            ),
            contentPadding: AppSpacing.symmetric(
              horizontal: AppSpacing.lg,
              vertical: AppSpacing.md,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSubmitButton() {
    return FilledButton(
      onPressed: _isSubmitting ? null : _submit,
      child: _isSubmitting
          ? const SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
            )
          : const Text('Tambah Setoran'),
    );
  }

  Future<void> _submit() async {
    if (_selectedGoalId == null) return;
    final amount = CurrencyInputFormatter.parseRupiah(_amountController.text);
    if (amount == null || amount <= 0) return;

    setState(() => _isSubmitting = true);

    try {
      final controller = ref.read(savingsGoalContributionControllerProvider);
      final result = await controller.addContribution(
        goalId: _selectedGoalId!,
        amount: amount.toDouble(),
      );

      if (!mounted) return;

      if (result.isSuccess) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Setoran berhasil ditambahkan'),
            backgroundColor: AppColors.success,
          ),
        );
        ref.invalidate(savingsGoalsWithProgressProvider);
      } else {
        final userMessage = ErrorMessageMapper.getUserMessage(result.failure);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(userMessage), backgroundColor: AppColors.error),
        );
      }
    } catch (e, stackTrace) {
      AppLogger.e('QuickAddContribution: Error', e, stackTrace);
      if (mounted) {
        final userMessage = ErrorMessageMapper.getUserMessage(e);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(userMessage), backgroundColor: AppColors.error),
        );
      }
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }
}
