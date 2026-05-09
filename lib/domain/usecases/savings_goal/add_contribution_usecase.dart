import 'package:catat_cuan/domain/core/result.dart';
import 'package:catat_cuan/domain/core/usecase.dart';
import 'package:catat_cuan/domain/entities/goal_contribution_entity.dart';
import 'package:catat_cuan/domain/failures/failures.dart';
import 'package:catat_cuan/domain/repositories/savings_goal/savings_goal_contribution_repository.dart';
import 'package:catat_cuan/domain/repositories/savings_goal/savings_goal_read_repository.dart';
import 'package:catat_cuan/domain/repositories/savings_goal/savings_goal_write_repository.dart';
import 'package:catat_cuan/presentation/utils/logger/app_logger.dart';

class AddContributionParams {
  final int goalId;
  final double amount;
  final String? note;
  final DateTime? date;

  const AddContributionParams({
    required this.goalId,
    required this.amount,
    this.note,
    this.date,
  });
}

class ContributionResult {
  final GoalContributionEntity contribution;
  final bool isGoalCompleted;

  const ContributionResult({
    required this.contribution,
    required this.isGoalCompleted,
  });
}

class AddContributionUseCase extends UseCase<ContributionResult, AddContributionParams> {
  final SavingsGoalContributionRepository _contributionRepository;
  final SavingsGoalReadRepository _readRepository;
  final SavingsGoalWriteRepository _writeRepository;

  AddContributionUseCase({
    required SavingsGoalContributionRepository contributionRepository,
    required SavingsGoalReadRepository readRepository,
    required SavingsGoalWriteRepository writeRepository,
  })  : _contributionRepository = contributionRepository,
        _readRepository = readRepository,
        _writeRepository = writeRepository;

  @override
  Future<Result<ContributionResult>> call(AddContributionParams params) async {
    if (params.amount <= 0) {
      return Result.failure(
        const ValidationFailure('Jumlah harus lebih dari 0'),
      );
    }

    try {
      final contributionResult = await _contributionRepository.addContribution(
        goalId: params.goalId,
        amount: params.amount,
        note: params.note,
        date: params.date ?? DateTime.now(),
      );

      if (contributionResult.isFailure) {
        return Result.failure(contributionResult.failure!);
      }

      final contribution = contributionResult.data!;

      bool isGoalCompleted = false;
      try {
        isGoalCompleted = await _checkAndMarkCompletion(params.goalId);
      } catch (e, stackTrace) {
        AppLogger.e('AddContribution: Completion check failed', e, stackTrace);
      }

      return Result.success(ContributionResult(
        contribution: contribution,
        isGoalCompleted: isGoalCompleted,
      ));
    } catch (e) {
      return Result.failure(
        DatabaseFailure('Gagal menambahkan setoran: $e'),
      );
    }
  }

  Future<bool> _checkAndMarkCompletion(int goalId) async {
    final goalResult = await _readRepository.getGoalById(goalId);

    if (goalResult.isFailure || goalResult.data == null) {
      return false;
    }

    final goal = goalResult.data!;

    if (goal.status == 'completed') {
      return false;
    }

    if (goal.currentAmount >= goal.targetAmount) {
      await _writeRepository.updateGoal(
        id: goal.id!,
        name: goal.name,
        targetAmount: goal.targetAmount,
        targetDate: goal.targetDate,
        icon: goal.icon,
        color: goal.color,
      );
      return true;
    }

    return false;
  }
}
