import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:catat_cuan/domain/core/usecase.dart';
import 'package:catat_cuan/domain/entities/goal_contribution_entity.dart';
import 'package:catat_cuan/domain/entities/savings_goal_with_progress_entity.dart';
import 'package:catat_cuan/data/repositories/savings_goal/savings_goal_read_repository_impl.dart';
import 'package:catat_cuan/data/repositories/savings_goal/savings_goal_write_repository_impl.dart';
import 'package:catat_cuan/data/repositories/savings_goal/savings_goal_contribution_repository_impl.dart';
import 'package:catat_cuan/data/repositories/savings_goal/savings_goal_query_repository_impl.dart';
import 'package:catat_cuan/domain/repositories/savings_goal/savings_goal_read_repository.dart';
import 'package:catat_cuan/domain/repositories/savings_goal/savings_goal_write_repository.dart';
import 'package:catat_cuan/domain/repositories/savings_goal/savings_goal_contribution_repository.dart';
import 'package:catat_cuan/domain/repositories/savings_goal/savings_goal_query_repository.dart';
import 'package:catat_cuan/domain/usecases/savings_goal/create_savings_goal_usecase.dart';
import 'package:catat_cuan/domain/usecases/savings_goal/update_savings_goal_usecase.dart';
import 'package:catat_cuan/domain/usecases/savings_goal/soft_delete_savings_goal_usecase.dart';
import 'package:catat_cuan/domain/usecases/savings_goal/get_savings_goals_usecase.dart';
import 'package:catat_cuan/domain/usecases/savings_goal/get_savings_goal_with_progress_usecase.dart';
import 'package:catat_cuan/domain/usecases/savings_goal/add_contribution_usecase.dart';
import 'package:catat_cuan/domain/usecases/savings_goal/withdraw_from_goal_usecase.dart';
import 'package:catat_cuan/domain/usecases/savings_goal/check_goal_completion_usecase.dart';
import 'package:catat_cuan/domain/usecases/savings_goal/get_goal_contributions_usecase.dart';
import 'package:catat_cuan/domain/usecases/savings_goal/get_overall_progress_usecase.dart';
import 'package:catat_cuan/presentation/providers/repositories/repository_providers.dart';

/// ============================================================================
/// Savings Goal Repository Providers (Segregated Interfaces)
/// ============================================================================

final savingsGoalReadRepositoryProvider = Provider<SavingsGoalReadRepository>((ref) {
  return SavingsGoalReadRepositoryImpl(ref.read(localDataSourceProvider));
});

final savingsGoalWriteRepositoryProvider = Provider<SavingsGoalWriteRepository>((ref) {
  return SavingsGoalWriteRepositoryImpl(ref.read(localDataSourceProvider));
});

final savingsGoalContributionRepositoryProvider = Provider<SavingsGoalContributionRepository>((ref) {
  return SavingsGoalContributionRepositoryImpl(ref.read(localDataSourceProvider));
});

final savingsGoalQueryRepositoryProvider = Provider<SavingsGoalQueryRepository>((ref) {
  return SavingsGoalQueryRepositoryImpl(ref.read(localDataSourceProvider));
});

/// ============================================================================
/// Savings Goal Use Case Providers
/// ============================================================================

final createSavingsGoalUseCaseProvider = Provider<CreateSavingsGoalUseCase>((ref) {
  return CreateSavingsGoalUseCase(ref.read(savingsGoalWriteRepositoryProvider));
});

final updateSavingsGoalUseCaseProvider = Provider<UpdateSavingsGoalUseCase>((ref) {
  return UpdateSavingsGoalUseCase(ref.read(savingsGoalWriteRepositoryProvider));
});

final softDeleteSavingsGoalUseCaseProvider = Provider<SoftDeleteSavingsGoalUseCase>((ref) {
  return SoftDeleteSavingsGoalUseCase(ref.read(savingsGoalWriteRepositoryProvider));
});

final getSavingsGoalsUseCaseProvider = Provider<GetSavingsGoalsUseCase>((ref) {
  return GetSavingsGoalsUseCase(ref.read(savingsGoalReadRepositoryProvider));
});

final getSavingsGoalWithProgressUseCaseProvider = Provider<GetSavingsGoalWithProgressUseCase>((ref) {
  return GetSavingsGoalWithProgressUseCase(ref.read(savingsGoalQueryRepositoryProvider));
});

final addContributionUseCaseProvider = Provider<AddContributionUseCase>((ref) {
  return AddContributionUseCase(
    contributionRepository: ref.read(savingsGoalContributionRepositoryProvider),
    readRepository: ref.read(savingsGoalReadRepositoryProvider),
    writeRepository: ref.read(savingsGoalWriteRepositoryProvider),
  );
});

final withdrawFromGoalUseCaseProvider = Provider<WithdrawFromGoalUseCase>((ref) {
  return WithdrawFromGoalUseCase(ref.read(savingsGoalContributionRepositoryProvider));
});

final checkGoalCompletionUseCaseProvider = Provider<CheckGoalCompletionUseCase>((ref) {
  return CheckGoalCompletionUseCase(
    readRepository: ref.read(savingsGoalReadRepositoryProvider),
    writeRepository: ref.read(savingsGoalWriteRepositoryProvider),
  );
});

final getGoalContributionsUseCaseProvider = Provider<GetGoalContributionsUseCase>((ref) {
  return GetGoalContributionsUseCase(ref.read(savingsGoalContributionRepositoryProvider));
});

final getOverallProgressUseCaseProvider = Provider<GetOverallProgressUseCase>((ref) {
  return GetOverallProgressUseCase(ref.read(savingsGoalQueryRepositoryProvider));
});

/// ============================================================================
/// Savings Goal Feature Providers
/// ============================================================================

final savingsGoalsWithProgressProvider = FutureProvider.autoDispose<List<SavingsGoalWithProgressEntity>>((ref) async {
  final useCase = ref.read(getSavingsGoalWithProgressUseCaseProvider);
  final result = await useCase(const NoParams());
  if (result.isSuccess) {
    return result.data ?? [];
  }
  return [];
});

final overallProgressProvider = FutureProvider.autoDispose<double>((ref) async {
  final useCase = ref.read(getOverallProgressUseCaseProvider);
  final result = await useCase(const NoParams());
  if (result.isSuccess) {
    return result.data ?? 0.0;
  }
  return 0.0;
});

final goalContributionsProvider = FutureProvider.autoDispose.family<List<GoalContributionEntity>, int>((ref, goalId) async {
  final useCase = ref.read(getGoalContributionsUseCaseProvider);
  final result = await useCase(GetGoalContributionsParams(goalId: goalId));
  if (result.isSuccess) {
    return result.data ?? [];
  }
  return [];
});
